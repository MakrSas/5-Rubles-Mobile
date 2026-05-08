import flixel.FlxSubState;

import game.backend.system.states.MusicBeatState;
import game.backend.system.audio.EffectSound;
import game.objects.FlxOverlaySprite;

import flixel.addons.display.FlxBackdrop;
import flixel.input.mouse.FlxMouseEvent;
import flixel.input.keyboard.FlxKey;

import haxe.Json;

static var ICON_SIZE = 150;
static var ICON_OFFSET = 60;

/*
	Как выглядит один блок кредитов:

    {
        "name": "name",
        "image": "transitionSwag/stickers-set-1/image",
        "check": "credits/checks/image",
        "socials":
        {
		"telegram": "",
		"newgrounds": "",
		"tiktok": "",
		"x": "",
		"soundcloud": "",
		"discord": "",
		"vk": "",
		"github": "",
		"donationalerts": "",
		"boosty": "",
		"twitch": "",
		"youtube": ""
       }
    }
*/

var music:FlxSound;
var ambience:FlxSound;

var conveyor:FlxBackdrop;
var iconContainer:FlxTypedSpriteGroup<CreditsIcon>;
var checkContainer:FlxTypedSpriteGroup<FlxSprite>;
var glowMain:FlxSprite;
var glowSide:FlxSprite;
var arrowUp:FlxSprite;
var arrowDown:FlxSprite;
var exit:FlxSprite;

var deltaTimeSincePress:Float = 0;
var tweenSpeedMultiplier:Int = 1;

var curSelected = 0;

var socialsScreen:SocialsScreen;

function loadSound(asset:FlxSoundAsset, volume:Float = 1, loop:Bool = false, applyEffect:Bool = true, ?group:FlxSoundGroup):EffectSound
{
	var sound = EffectSound.load(asset, volume, loop, group);
	if ((applyEffect || applyEffect == null) && !ClientPrefs.lowQuality)
	{
		sound.setEffect("REVERB");
		sound.setEffectVar("DECAY TIME", 0.5);
		sound.setEffectVar("GAINHF", 0.5);
	}
	return sound;
}

function playSound(asset:FlxSoundAsset, volume:Float = 1, loop:Bool = false, applyEffect:Bool = true, ?group:FlxSoundGroup):EffectSound
{
	var sound = loadSound(asset, volume, loop, applyEffect, group);
	sound.play();
	return sound;
}

var dudes = [];
function loadDudesData():Void
{
	dudes = [];
	try
	{
		var data:Array<Dynamic> = Json.parse(Assets.getText(AssetsPaths.json('credits')));

		for (dudeData in data.people)
		{
			dudeData.yOffset ??= 0;
			dudes.push(dudeData);
		}
	}
	catch(e)
	{
		Log(e, TColor.RED);
	}
}

function create()
{
	FlxG.mouse.visible = true;
	FlxG.sound.music.fadeOut(0.6, FlxMath.EPSILON);

	music = loadSound(Paths.music("5bossa"), 0, true, false, FlxG.sound.defaultMusicGroup);
	music.play(false, FlxG.sound.music.time);
	music.fadeIn(0.6, music.volume);
	// music.setEffectVar("GAINHF", 0.45);

	ambience = loadSound(Paths.sound("credits/ambience5orochka-loop"), 0, true);
	ambience.play(false, FlxG.random.float(0, ambience.length));
	ambience.fadeIn(2.6, music.volume, 0.35);
	// ambience.setEffectVar("GAINHF", 0.45);

	conveyor = new FlxBackdrop(Paths.image("credits/conveyer"), Y);
	conveyor.x = 104;

	var bg = new FlxSprite(0, 0, Paths.image("credits/base"));

	iconContainer = new FlxTypedSpriteGroup();
	iconContainer.ID = 0;

	loadDudesData();

	for (i => dude in dudes.concat([{image: "credits/next-pedik"}]))
	{
		var icon = new CreditsIcon(200, 220, dude.image);
		icon.y += (ICON_SIZE + ICON_OFFSET + dude.yOffset) * i;
		iconContainer.add(icon);
	}
	var lastIcon = iconContainer.members[iconContainer.length - 1];
	lastIcon.scale.x = lastIcon.scale.y = lastIcon.scale.x * 0.88;

	function centerOffsets(spr:FlxSprite, _, frame:Int, _)
	{
		if (frame == 0)
			spr.centerOffsets();
	}

	function backToIdle(spr:FlxSprite)
		spr.animation.play("idle");

	var arrowFrames = Paths.getSparrowAtlas("credits/arrow");
	arrowUp = new FlxSprite(220, 110);
	arrowUp.frames = arrowFrames;
	arrowUp.animation.addByPrefix("idle", "стрелошка0", 24);
	arrowUp.animation.addByPrefix("press", "стрелошка нажатая", 24, false);
	arrowUp.animation.play("idle");
	arrowUp.animation.callback = centerOffsets.bind(arrowUp, _, _, _);

	arrowDown = new FlxSprite(arrowUp.x, 420);
	arrowDown.frames = arrowFrames;
	arrowDown.animation.addByPrefix("idle", "стрелошка0", 24, true, false, true);
	arrowDown.animation.addByPrefix("press", "стрелошка нажатая", 24, false, false, true);
	arrowDown.animation.play("idle");
	arrowDown.animation.callback = centerOffsets.bind(arrowDown, _, _, _);

	function onDownArrow(_, index:Int)
	{
		if (subState == null)
		{
			change(index, false);
			holdingArrow = index;
		}
	}

	function onUpArrow(spr:FlxSprite)
	{
		backToIdle(spr);
		holdingArrow = 0;
		deltaTimeSincePress = 0;
		updateTweenSpeedMult();
	}

	function onOverArrow(_)
	{
		onArrow = true;
	}

	function onOutArrow(spr:FlxSprite)
	{
		backToIdle(spr);
		onArrow = false;
		holdingArrow = 0;
		deltaTimeSincePress = 0;
		updateTweenSpeedMult();
	}

	FlxMouseEvent.add(arrowUp, onDownArrow.bind(_, -1), onUpArrow, onOverArrow, onOutArrow, false, true, false);
	FlxMouseEvent.add(arrowDown, onDownArrow.bind(_, 1), onUpArrow, onOverArrow, onOutArrow, false, true, false);

	exit = new FlxSprite(20, 630);
	exit.frames = Paths.getSparrowAtlas("credits/exit");
	exit.animation.addByPrefix("idle", "уходи0", 0, false);
	exit.animation.addByPrefix("press", "уходи нажатие", 0, false);
	exit.animation.play("idle");

	FlxMouseEvent.add(exit, _ -> if (subState == null) goBack(), backToIdle, _ -> onArrow = true, onOutArrow, false, true, false);

	checkContainer = new FlxTypedSpriteGroup();
	checkContainer.ID = 0;

	var checkEnd = new FlxSprite(738, 132, Paths.image("credits/checks/end"));
	checkEnd.ID = checkContainer.ID++;
	checkContainer.add(checkEnd);

	glowMain = new FlxSprite(51, 0, Paths.image("credits/light"));
	glowSide = new FlxSprite(1130, glowMain.y, Paths.image("credits/light"));
	glowMain.blend = glowSide.blend = ADD;
	glowMain.alpha = glowSide.alpha = 0;

	var printer = new FlxSprite(690, -41, Paths.image("credits/printer"));

	var vignette = new FlxSprite(0, 0, Paths.image("credits/vignette"));

	var title = new FlxSprite(346, 9);
	title.frames = Paths.getSparrowAtlas("credits/title");
	title.animation.addByPrefix("idle", "title", 24);
	title.animation.play("idle");

	add(conveyor);
	add(bg);
	add(iconContainer);
	add(glowMain);
	add(glowSide);
	add(checkContainer);
	add(printer);
	add(vignette);
	add(arrowUp);
	add(arrowDown);
	add(exit);
	add(title);

	change(0, true);
	// FlxG.camera.zoom = 0.2;
}

function getRandomTimer()
	return FlxG.random.float(9, 22);

var sounds = [/*"5 рублей 12 копеек",*/ "pisun"];
var timer = getRandomTimer();
var prevAd = -1;
var adsSoundsPaths:Array<String> = [
	for (i in AssetsPaths.getFolderContent("sounds/credits/ads", false, false))
		if (StringTools.endsWith(i.toLowerCase(), ".ogg"))
			i
];

var point = FlxPoint.get();
var curIcon = null;
var onArrow = false;
var holdingArrow = 0;

function postUpdate(elapsed:Float)
{
	if (subState == null)
	{
		if (controls.ACCEPT || (!onArrow && FlxG.mouse.justPressed && curIcon.overlapsPoint(FlxG.mouse.getScreenPosition(null, point))))
		{
			var targetDude = dudes[curSelected];
			var socialsData:Array<Array<String>> = [];

			function pushData(data:String)
			{
				var value = Reflect.field(targetDude.socials, data);
				if (value != null)
					socialsData.push([data, value]);
			}

			pushData('telegram');
			pushData('newgrounds');
			pushData('tiktok');
			pushData('x');
			pushData('soundcloud');
			pushData('discord');
			pushData('vk');
			pushData('github');
			pushData('twitch');
			pushData('youtube');

			if (socialsData.length != 0)
			{
				socialsScreen = new SocialsScreen(socialsData);
				openSubState(socialsScreen);
				persistentUpdate = true;
			}
		}

		if (controls.BACK)
			goBack();
		else if (controls.BACK_R)
			exit.animation.play("idle");

		var ui_up = controls.UI_UP;
		var ui_down = controls.UI_DOWN;
		var ui_up_r = controls.UI_UP_R;
		var ui_down_r = controls.UI_DOWN_R;

		var pressed = ui_up || ui_down || holdingArrow != 0;
		var justReleased = ui_up_r || ui_down_r;
		if (pressed || justReleased)
		{
			if (pressed)
			{
				if (controls.UI_UP)
					change(-1, false);
				else if (controls.UI_DOWN)
					change(1, false);
				else
					change(holdingArrow, false);

				deltaTimeSincePress += elapsed;
			}

			if (justReleased)
			{
				if (controls.UI_UP_R)
					arrowUp.animation.play("idle");
				else if (controls.UI_DOWN_R)
					arrowDown.animation.play("idle");

				deltaTimeSincePress = 0;
			}

			updateTweenSpeedMult();
		}
	}

	if (timer > 0)
	{
		timer -= elapsed;
		if (timer <= 0)
		{
			timer = getRandomTimer();
			switch (FlxG.random.int(0, 2))
			{
				case 1:
					var reduce = 0.3;
					music.fadeOut(0.4, music.volume * reduce);
					ambience.fadeOut(0.4, ambience.volume * reduce);
					// var adId = FlxG.random.int(0, 20, [prevAd]);
					// var ad = playSound(Paths.sound('credits/ads/ad$adId'));
					var adId = FlxG.random.int(0, adsSoundsPaths.length - 1, [prevAd]);
					var ad = playSound(Paths.sound('credits/ads/${adsSoundsPaths[adId]}'), 0.57);
					ad.setFilter("LOWPASS");
					ad.setFilterVar("GAINHF", 0.55);
					// ad.setEffectVar("GAINHF", 0.45);
					ad.onComplete = () ->
					{
						music.fadeIn(0.8, music.volume, music.volume / reduce);
						ambience.fadeIn(0.8, ambience.volume, ambience.volume / reduce);
					}
					timer += ad.length / 1000;
					prevAd = adId;

				default:
					doFlash(glowSide, FlxG.random.float(0.4, 0.7));
			}
		}
	}
}

function updateTweenSpeedMult()
	tweenSpeedMultiplier = (deltaTimeSincePress > 1.0) ? 0.3 : 1;

var soundTimer = new FlxTimer();
var checkSound:FlxSound;
var canChange = true;
function change(add:Int, force:Bool) // TODO: IMPROVE IT
{
	if (!alive)
		return;

	if (add < 0)
		pressArrow(arrowUp);
	else if (add > 0)
		pressArrow(arrowDown);

	if (!canChange)
		return;

	var prevSelected = curSelected;
	curSelected = FlxMath.bound(curSelected + add, 0, dudes.length - 1);
	curIcon = iconContainer.members[curSelected];

	if (curSelected != prevSelected || force)
	{
		canChange = false;
		if (checkSound == null)
		{
			checkSound = playSound(Paths.soundRandom("credits/checksound", 1, 3), 1.0, true);
		}
		checkSound.pitch = 1 / tweenSpeedMultiplier;

		if (add != 0)
		{
			var up = add > 0;
			var mult = up ? 1 : -1;
			var time = 19 / 24 * tweenSpeedMultiplier;
			var easeIn = up ? FlxEase.quadIn : FlxEase.quadOut;
			var easeOut = up ? FlxEase.quadOut : FlxEase.quadIn;

			// time * (up ? 0.6 : 0.1)
			if (up)
			{
				var volume = 0.85 * tweenSpeedMultiplier;
				soundTimer.start(time * 0.6,  _ -> doFlash(glowMain, volume));
			}

			var prevIcon = iconContainer.members[up ? prevSelected : curSelected];
			FlxTween.num(prevIcon.offset.y, prevIcon.offset.y + ICON_OFFSET * 4 * mult, time, {ease: easeIn}, prevIcon.offset.set_y);
			FlxTween.num(prevIcon.angle, prevIcon.angle + 60 * (prevIcon.angle > 0 ? 1 : -1) * mult, time, {ease: easeOut}, prevIcon.set_angle);
			FlxTween.color(prevIcon, time, prevIcon.color, up ? 0xFF666666 : FlxColor.WHITE);

			var offset = -(ICON_SIZE + ICON_OFFSET) * mult;
			FlxTween.num(conveyor.y, conveyor.y + offset, time, null, conveyor.set_y);
			FlxTween.num(iconContainer.y, iconContainer.y + offset, time, null, iconContainer.set_y);
		}

		var first = checkContainer.getFirstAlive();
		var check = checkContainer.recycle(FlxSprite);
		check.ID = checkContainer.ID++;
		check.loadGraphic(Paths.image(dudes[curSelected].check));
		check.setPosition(first.x, first.y - check.height + 2);

		checkContainer.sort((index, obj1, obj2) -> obj1.ID > obj2.ID ? -index : obj2.ID > obj1.ID ? index : 0, 1);
		FlxTween.num(checkContainer.y, checkContainer.y + check.height - 2, 44 / 24 * tweenSpeedMultiplier, {
			onComplete: _ ->
			{
				canChange = true;
				if (checkSound != null)
				{
					checkSound.stop();
					checkSound = null;
				}
				var last = checkContainer.group.getLast(spr -> spr.alive);
				if (checkContainer.ID - last.ID > 2)
					last.kill();
			}
		}, checkContainer.set_y);
	}
}

function pressArrow(arrow:FlxSprite)
{
	if (arrow.animation.curAnim.name != "press")
		arrow.animation.play("press");
}

function goBack()
{
	if (!alive)
		return;

	alive = false;
	FlxG.sound.play(Paths.sound("cancelMenu"));
	MusicBeatState.switchState(new MusicBeatState("MenuState"));
	music.fadeOut(0.2);
	ambience.fadeOut(0.15);
	exit.animation.play("press");
}

var _tweenSprs:Map<FlxSprite, FlxTween> = [];
function doFlash(spr:FlxSprite, volume:Float = 1.0)
{
	_tweenSprs.get(spr)?.cancel();
	_tweenSprs.set(spr,
		FlxTween.num(spr.alpha, 0.5, 4 / 24, {
			onComplete: _ -> {
				_tweenSprs.set(spr, FlxTween.num(_.value, 0.0, 20 / 24, {
					onComplete: _ -> _tweenSprs.remove(spr)
				}, spr.set_alpha));
			}
		}, spr.set_alpha)
	);
	playSound(Paths.sound("credits/" + sounds[FlxG.random.int(0, sounds.length - 1)]), volume, false);
}

function destroy()
{
	point.put();
	soundTimer.cancel();
	FlxG.mouse.visible = false;
	FlxG.sound.music.fadeIn(0.4, FlxG.sound.music.volume);
}

class CreditsIcon extends FlxSprite
{
	inline static function getRandomOffset():Float
		return FlxG.random.float(-5, 5);

	public function new(x:Float, y:Float, image:String)
	{
		super(x, y, Paths.image(image));
		var size = 150;
		width = Math.abs(scale.x) * size;
		height = Math.abs(scale.y) * size;
		offset.set(getRandomOffset() + (size - frameWidth) / -2, getRandomOffset() + (size - frameHeight) / -2);
		angle = FlxG.random.float(-10, 10);
		scale.x = scale.y = 1.25;
	}

	override function drawComplex(camera:FlxCamera)
	{
		// тень
		var o = 5;
		offset.x -= o;
		offset.y -= o;
		var r = colorTransform.redMultiplier;
		var g = colorTransform.greenMultiplier;
		var b = colorTransform.blueMultiplier;
		var a = colorTransform.alphaMultiplier;
		colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = 0;
		colorTransform.alphaMultiplier *= 0.55;
		super.drawComplex(camera);
		offset.x += o;
		offset.y += o;
		colorTransform.redMultiplier = r;
		colorTransform.greenMultiplier = g;
		colorTransform.blueMultiplier = b;
		colorTransform.alphaMultiplier = a;
		// сама иконка
		super.drawComplex(camera);
	}
}

class SocialsScreen extends FlxSubState
{
	var initializationDone:Bool = false;

	var bg:FlxSprite;

	var gradientLeft:FlxSprite;
	var gradientRight:FlxSprite;

	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;
	var exitButton:FlxSprite;

	var socialsData:Array<Array<String>>;

	var icon:SocialIcon;

	var iconContainer:FlxTypedSpriteGroup<SocialIcon>;
	var iconsClipRect:FlxRect;

	var curSelected = 0;

	var busy:Bool = true;

	var bgOverlay:FlxOverlaySprite;

	public function new(socialsData:Array<Array<String>>)
	{
		super();

		this.socialsData = socialsData;
	}

	public function create()
	{
		super.create();

		bgColor = FlxColor.TRANSPARENT;

		FlxTween.color(null, 0.2, bgColor, FlxColor.fromRGBFloat(0, 0, 0, 0.3), {onUpdate: t -> bgColor = t.color});

		if (ClientPrefs.shaders && !ClientPrefs.lowQuality)
		{
			bgOverlay = new FlxOverlaySprite();
			bgOverlay.shader = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('engine/bgOnOptions')));
			bgOverlay.shader.setFloat("iFactor", 0);
			FlxTween.num(0, 0.9, 0.2, null, bgOverlay.shader.setFloat.bind("iFactor", _));
			add(bgOverlay);
		}


		bg = new FlxSprite(300, 227);
		bg.frames = Paths.getSparrowAtlas("credits/socials/bg");
		bg.animation.addByPrefix("idle", "socials_bg", 24, false);
		bg.animation.play("idle");
		add(bg);

		FlxG.sound.play(Paths.sound("credits/socials_open"));
	}

	function initMenu()
	{
		var gradientImage = Paths.image("credits/socials/gradient");
		gradientLeft = new FlxSprite(395, 297, gradientImage);
		gradientLeft.scale.y = 152;
		gradientLeft.updateHitbox();

		gradientRight = new FlxSprite(755, 297, gradientImage);
		gradientRight.scale.y = 152;
		gradientRight.updateHitbox();
		gradientRight.flipX = true;

		var arrowFrames = Paths.getSparrowAtlas("credits/socials/arrow");
		arrowLeft = new FlxSprite(400, 338);
		arrowLeft.frames = arrowFrames;
		arrowLeft.flipX = true;
		arrowLeft.animation.addByIndices("idle", "socials_arrow", [0], null, 24, false);
		arrowLeft.animation.addByIndices("press", "socials_arrow", [1], null, 24, false);
		arrowLeft.animation.play("idle");
		FlxMouseEvent.add(arrowLeft, _ -> change(-1), backToIdle, null, backToIdle, false, true, false);

		arrowRight = new FlxSprite(882, 338);
		arrowRight.frames = arrowFrames;
		arrowRight.animation.addByIndices("idle", "socials_arrow", [0], null, 24, false);
		arrowRight.animation.addByIndices("press", "socials_arrow", [1], null, 24, false);
		arrowRight.animation.play("idle");
		FlxMouseEvent.add(arrowRight, _ -> change(1), backToIdle, null, backToIdle, false, true, false);

		exitButton = new FlxSprite(890, 238, Paths.image("credits/socials/close"));
		FlxMouseEvent.add(exitButton, _ -> goBack(), null, null, null, false, true, false);

		setupSocialItems();

		add(gradientLeft);
		add(gradientRight);
		add(arrowLeft);
		add(arrowRight);
		add(exitButton);
	}

	function setupSocialItems()
	{
		iconContainer = new FlxTypedSpriteGroup();
		for (i in 0...socialsData.length)
		{
			var data = socialsData[i];
			var icon:SocialIcon = new SocialIcon(591 + 125 * i, 305, data[0], data[1]);
			icon.index = i;
			icon.selected = (curSelected == icon.index);
			icon.scale.x = icon.selected ? 1 : 0.7;
			icon.scale.y = icon.selected ? 1 : 0.7;
			iconContainer.add(icon);
		}
		iconsClipRect = new FlxRect(430, 0, 450, 1000);
		add(iconContainer);
	}

	function change(value:Int)
	{
		if (value > 0)
			arrowRight.animation.play("press");
		else if (value < 0)
			arrowLeft.animation.play("press");

		var prevSelected = curSelected;
		// curSelected = FlxMath.bound(curSelected + value, 0, iconContainer.members.length - 1);
		curSelected = FlxMath.wrap(curSelected + value, 0, iconContainer.members.length - 1);

		if (curSelected != prevSelected)
			FlxG.sound.play(Paths.sound("credits/socials_switch"));

		iconContainer.forEach(icon -> icon.selected = (curSelected == icon.index));
	}

	function backToIdle(spr:FlxSprite)
	{
		spr.animation.play("idle");
	}

	function goBack()
	{
		busy = true;

		FlxG.sound.play(Paths.sound("credits/socials_close"));

		bg.animation.play("idle", false, true);
		gradientLeft.kill();
		gradientRight.kill();
		arrowLeft.kill();
		arrowRight.kill();
		exitButton.kill();
		iconContainer.kill();

		FlxTween.color(null, 0.2, bgColor, FlxColor.TRANSPARENT, {onComplete: _ -> close(), onUpdate: t -> bgColor = t.color});
		if (bgOverlay != null)
			FlxTween.num(bgOverlay.shader.getFloat("iFactor"), 0.0, 0.2, null, bgOverlay.shader.setFloat.bind("iFactor", _));
	}

	public function tryUpdate(elapsed:Float)
	{
		super.tryUpdate(elapsed);

		if (bg.animation.finished && !initializationDone)
		{
			initMenu();
			initializationDone = true;
			busy = false;
		}

		if (busy) return;

		if (controls.ACCEPT || (
			FlxG.mouse.justReleased && CoolUtil.mouseOverlapping(iconContainer.members[curSelected], null, this.camera)
		))
		{
			iconContainer.members[curSelected].openSocial();
		}

		if (controls.BACK)
		{
			goBack();
			return;
		}

		if (controls.UI_LEFT_P)
			change(-1);
		else if (controls.UI_RIGHT_P)
			change(1);

		if (controls.UI_LEFT_R)
			backToIdle(arrowLeft);
		else if (controls.UI_RIGHT_R)
			backToIdle(arrowRight);

		iconContainer.forEach(icon -> icon.lerpPosition(curSelected));
		iconContainer.clipRect = iconsClipRect;
	}
}

class SocialIcon extends FlxSprite
{
	var originX:Float;
	var name:String;
	var link:String;

	var index:Int;

	var selected:Bool;

	public function new(x:Float, y:Float, name:String, link:String)
	{
		super(x, y, Paths.image('credits/socials/icons/$name'));

		this.originX = x;
		this.name = name;
		this.link = link;
	}

	public function update(elapsed:Float)
	{
		super.update(elapsed);

		scale.x = CoolUtil.fpsLerp(scale.x, selected ? 1 : 0.7, 0.2);
		scale.y = CoolUtil.fpsLerp(scale.y, selected ? 1 : 0.7, 0.2);

		if (name == "x")
		{
			if (FlxG.keys.justPressed.SHIFT)
				loadGraphic(Paths.image('credits/socials/icons/twitter'));
			else if (FlxG.keys.justReleased.SHIFT)
				loadGraphic(Paths.image('credits/socials/icons/$name'));
		}
	}

	function lerpPosition(curSelected:Int)
	{
		this.x = CoolUtil.fpsLerp(this.x, originX + -125 * curSelected, 0.2);
	}

	public function openSocial():Void
	{
		#if linux
		Sys.command('/usr/bin/xdg-open $link &');
		#else
		FlxG.openURL(link);
		#end
	}
}