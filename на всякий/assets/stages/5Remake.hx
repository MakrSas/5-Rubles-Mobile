import flixel.addons.effects.FlxSkewedSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxTimerManager;
import flixel.util._FlxColor.FlxColor_Impl_;
import game.backend.assets.AssetsPaths;
import game.objects.TwistSprite;
import game.objects.improvedFlixel.FlxBGSprite;
import game.objects.improvedFlixel.FlxCenteredSpriteGroup;

static var EVENING = 2;
static var NIGHT = 1;
static var CLASSIC = 0;

final towari = [
	"бп = Бомжиха Пукович" => 6,
	"пасылока из алиикспресс" => 3,
	"криспы ксав" => 4,
	"мистик мармелад" => 5
];

final towariArr = [for (i in towari.keys()) i];

final bottles = [
	"explod" => 5,
	"gazirovkin" => 5,
	"klovan" => 4,
	"red key" => 4,
	"viola malina" => 5,
	"pepse" => 4
];

final bottlesArr = [for (i in bottles.keys()) i];

final discountsArr:Map<String, Bool> = [];
for (i in bottlesArr)
{
	discountsArr.set(i, FlxG.random.bool(20));
}

static final RICH_BORDER_L = -656.45;
static final RICH_BORDER_R = 2343.55; // hopka.x - 1800
// static final richIdleAnims = ["idle0", "idle1", "idle2", "idle3", "idle4"];
static final richIdleAnimsChances = [45, 35, 5, 4, 1, 10];
// static final richWalkAnims = ["walk0", "walk1"];
static final richWalkAnimsChances = [95, 5];

var curSong = PlayState.SONG?.song.toLowerCase();

var rawStageType:String = switch(curSong)
{
	case "bezdariamalgamatmix":	NIGHT;
	case "bezdarinaisonjimix":	EVENING;
	default:					CLASSIC;
}
if (!ClientPrefs.shaders || ClientPrefs.lowQuality)
	rawStageType = CLASSIC;

var isNaisojiMix = rawStageType == EVENING;
var isAnalgamatMix = rawStageType == NIGHT;

static function getRanObject(arr)
	return arr[FlxG.random.int(0, arr.length - 1)];

static final __weightsHelper = [];
static function getRandomIndex(weights, ?exclude)
{
	if (exclude != null && exclude.length != 0)
	{
		__weightsHelper.splice(0, __weightsHelper.length);
		for (i in 0...weights.length)
			__weightsHelper.push(exclude.contains(i) ? 0 : weights[i]);

		weights = __weightsHelper;
	}
	return FlxG.random.weightedPick(weights);
}

var balls = [];

var rootPath = "pyaterochka4/";

var sky:FlxSprite;
var bg:FlxSprite;
var adds:FlxSprite;
var cashboxfar:FlxSprite;
var baseShader:Null<FlxShader>;
var charsShader:Null<FlxShader>;
var shelvesShader:Null<FlxShader>;
var lights:FlxSprite;
var rich:Character;

var hopka:Character;
var hopkaSleeper:FunkinSprite;

var xiavi:Character;
var viola:Character;
var introCard:FlxSprite;

var richTimerManager:FlxTimerManager = new FlxTimerManager();
add(richTimerManager);

static function getRichRandomIdle(?exclude) return "idle" + getRandomIndex(richIdleAnimsChances, exclude);
static function getRichRandomWalk(?exclude) return "walk" + getRandomIndex(richWalkAnimsChances, exclude);

function richPlayAnim(rich, anim, ?flip)
{
	rich.extraData.flip = flip;
	rich.playAnim(flip ? (anim + "-flip") : anim, true);
}

function startRichTimer(rich, time)
{
	new FlxTimer(richTimerManager).start(time, (_) -> doThingsRich(rich));
}

function doThingsRich(rich:Character)
{
	rich.extraData.playingFenefeIdle = false;
	// смертельное анимирование
	if (isDead && !rich.extraData.skipDeathAnim)
	{
		rich.velocity.x = 0;
		final char = (isAnalgamatMix ? gf : boyfriend);
		final flip = ((rich.x + rich.relativeX) >= (char.x + char.width / 2));
		richPlayAnim(rich, FlxG.random.bool(10) ? "idle4" : "death", flip);
		return;
	}

	if (rich.stunned)
		return;

	final flip = FlxG.random.bool();
	rich.anim.timeScale = FlxG.random.float(0.9, 1.3);

	var newTask = FlxG.random.int(0, 4, FlxG.random.bool(20) ? null : [rich.extraData.task]);
	rich.extraData.task = newTask;
	switch (newTask)
	{
		case 1 | 2: // walk
			var halfWidth = rich.width / 2;
			var BORDER_L = RICH_BORDER_L + halfWidth;
			var BORDER_R = RICH_BORDER_R - halfWidth;
			var time = FlxG.random.int(3, 5);

			var posX = rich.x + rich.relativeX;
			rich.velocity.x = (FlxG.random.int(130, 150) * rich.anim.timeScale);
			if (flip && (posX >= BORDER_R || posX <= BORDER_L))
				flip = !flip;
			if (!flip)
				rich.velocity.x *= -1;

			// дополнительная проверка чтобы они не уходили за границы
			var dist = (rich.velocity.x * time);
			var dest = posX + dist;
			var outOfBoundsLeft = dest <= BORDER_L && rich.velocity.x < 0;
			var outOfBoundsRight = dest >= BORDER_R && rich.velocity.x > 0;
			if (outOfBoundsLeft || outOfBoundsRight)
			{
				// 40% шанс что рич все таки пойдут к краю
				var diff = Math.abs(posX - dist);
				if (FlxG.random.bool(40) && diff > 100 && !outOfBoundsRight)
				{
					time = (rich.velocity.x / diff * 1.01);
				}
				else
				{
					flip = !flip;
					rich.velocity.x *= -1;
				}
			}

			richPlayAnim(rich, getRichRandomWalk(), flip);
			startRichTimer(rich, time);

		default: // idle
			rich.velocity.x = 0;
			final anim = getRichRandomIdle();
			richPlayAnim(rich, anim, flip);

			var time = (rich.curNumFrames / (rich.anim.framerate * rich.anim.timeScale));
			switch (anim)
			{
				case "idle0": // подметание
					time *= FlxG.random.int(3, 4);

				case "idle3": // фнф айдл лол
					time *= FlxG.random.int(1, 4);
					rich.extraData.playingFenefeIdle = true;

				case "idle4": // крутой танец оуе оуе
					time *= FlxG.random.int(4, 10);
			}
			startRichTimer(rich, time);
	}
}

function spawnRich()
{
	rich = addHxObject(new Character(0, 328, "rich-uborshik"));
	// rich.animateAtlas.color = 0xdfdfdf;
	rich.debugMode = true;
	rich.shader = charsShader;
	var halfWidth = rich.width / 2;
	rich.x = FlxG.random.float(RICH_BORDER_L + halfWidth, RICH_BORDER_R - halfWidth);
	// ну типо иногда им будет похуй хехе))))
	rich.extraData.skipDeathAnim = FlxG.random.bool(20);
	doThingsRich(rich);
}

//var d5rkWalk:FlxSprite;
function spawnD5rk() {
	var d5rkWalk = new FlxSprite();
	// d5rkWalk.scrollFactor.set(.95, .95);
	d5rkWalk.frames = Paths.getSparrowAtlas("characters/bezdari/d5rkwalked"); // огобля
	d5rkWalk.animation.addByPrefix("cycle", "d5rkwalked", 24, true);
	d5rkWalk.animation.play("cycle", true);
	d5rkWalk.scale.set(1.4, 1.4);
	d5rkWalk.updateHitbox();
	d5rkWalk.shader = charsShader;

	d5rkWalk.flipX = FlxG.random.bool();
	d5rkWalk.x = d5rkWalk.flipX ? -1200 : 3600;
	d5rkWalk.y = 783 - d5rkWalk.height - 20;
	d5rkWalk.velocity.x = FlxG.random.int(150, 200);
	if (!d5rkWalk.flipX)
		d5rkWalk.velocity.x *= -1;

	d5rkWalk.moves = false;
	final dlinna = inst.length / 1000;
	new FlxTimer().start(FlxG.random.int(dlinna * 0.35, dlinna * 0.75), _ -> d5rkWalk.moves = true);
	addBehindObject(d5rkWalk, rich); // addHxObject
}

var goffySoundsMap:Array<FlxSound> = [];
var onUpdatePost = null;

function spawnMan(isLostel:Bool = false)
{
	var manSpawn:Null<Float> = FlxG.random.bool(70) ? null : FlxG.random.int(20, 200);
	if (manSpawn != null) {
		var flip = FlxG.random.bool(50);
		var multSign = flip ? -1 : 1;
		var man:FlxSprite = addHxObject(new FlxSprite(0 - manSpawn * 100 * multSign, 291.6));
		man.frames = isLostel ? Paths.getSparrowAtlas("characters/bezdari/loste") : AssetsPaths.getSparrowAtlasAlt("assets/weeks/man");
		man.animation.addByPrefix("walk", "walk", 24, true);
		man.animation.play("walk");
		if (isLostel)
			man.y -= 70;
		man.flipX = !isLostel;
		// man.flipX = true;
		if (flip)
			man.flipX = !man.flipX;
		man.shader = charsShader;
		var goofy = FlxG.random.bool(50);
		man.animation.timeScale = goofy ? FlxG.random.float(5.9, 6.2) : FlxG.random.float(0.9, 1.2);
		// man.animation.timeScale = FlxG.random.float(5.9, 6.2);
		man.x *= man.animation.timeScale;
		man.velocity.x = 230 * multSign * man.animation.timeScale;
		if (goofy) {
			var goofySound = FlxG.sound.load(AssetsPaths.getPath('sounds/goofy-ah-run.ogg'), 1., true, null, false);
			goofySound.play();
			goofySound.proximity(0, 0, man, 2500);
			goofySound.update();
			goffySoundsMap.push(goofySound);
			if (onUpdatePost == null)
			{
				onUpdatePost = (e) ->
				{
					for (sound in goffySoundsMap)
					{
						sound._radius = FlxG.camera.viewWidth * 0.6;
						// FlxG.camera.scroll
						sound.setPosition(FlxG.camera.viewLeft + FlxG.camera.viewWidth * 0.5, FlxG.camera.viewTop + FlxG.camera.viewHeight * 0.5);
					}
				}
			}
		}
	}
}

function spawnNapitki(x:Float) {
	final group = new FlxGroup();
	group.active = false;
	addHxObject(group);

	var curY:Float = -37;
	var priceTagFrames = Paths.getSparrowAtlas(rootPath + "pricetag");
	for (i in 0...3) {
		final bottleName = getRanObject(bottlesArr);
		var graphic = Paths.image(rootPath + "tovari/" + bottleName);
		if (graphic != null) {
			final offY = 180 - graphic.height;
			final len = bottles.get(bottleName);
			for (i in 0...len) {
				if (FlxG.random.bool(4)) continue;
				final bt = new FlxSprite(x + (i / len) * 320, curY + offY, graphic);
				bt.scale.x *= 0.95;
				bt.scale.y *= 0.95;
				bt.shader = baseShader;
				bt.active = false;
				bt.origin.y = bt.frameHeight;
				group.add(bt);
			}
		}
		var priceTag = new FlxSprite(x + 220, curY + 170);
		priceTag.active = false;
		priceTag.frames = priceTagFrames;
		priceTag.animation.addByPrefix("", "", 0, false);
		priceTag.animation.frameIndex = discountsArr.get(bottleName) ? 1 : 0;
		priceTag.shader = baseShader;
		addHxObject(priceTag);
		curY += 203;
	}
}

function onCreate()
{
	baseShader = switch (rawStageType) {
		case EVENING:	constructHSBCShader(-25, 0,   0,	0);
		case NIGHT:		constructHSBCShader(15,	 -30, -65,	-10);
		default:		null;
	};
	charsShader = switch (rawStageType) {
		case EVENING:	constructHSBCShader(-6,	-40, 26,	13);
		case NIGHT:		constructHSBCShader(5,	-40, -35,	-30);
		default:		null;
	};
	shelvesShader = switch (rawStageType) {
		case EVENING:	constructHSBCShader(-25, 0,	  -16,			0);
		case NIGHT:		constructHSBCShader(-26, -30, -65 - 16,		-10);
		default:		constructHSBCShader(0,	 0,	  -10 - 16,		10);
	};

	sky = new FlxSprite(-830.69, -62.12, Paths.image(rootPath + 'outside' +
		switch (rawStageType) {
			case EVENING: "-eve";
			case NIGHT: "-night";
			default: "";
		}
	));
	sky.scrollFactor.set(0.8, 1.0);
	addHxObject(sky);

	addHxObject(bg = new FlxSprite(-4668.63 + 1442.75, -1280 + 512.85, Paths.image(rootPath + switch (rawStageType) {
			case EVENING: "bgEve";
			case NIGHT: "bgNight";
			default: "bg";
		})));

	addWithShader(adds = new FlxSprite(300, -320), false,
		switch (rawStageType) {
			case NIGHT:	constructHSBCShader(0, 0, -45, 0);
			default:	baseShader;
		}
	);
	adds.frames = Paths.getSparrowAtlas(rootPath + "ad");
	adds.scale.set(0.8, 0.8);
	adds.animation.addByPrefix("", "", 0, false);
	updateAddsScreen();

	spawnNapitki(1485);
	spawnNapitki(1910);

	spawnMan(false);
	spawnMan(true);

	spawnRich();

	addWithShader(new FlxSprite(-1410, -40, Paths.image(rootPath + "polki3")), false, shelvesShader).scale.set(0.74, 0.81);

	var cashboxShader = switch (rawStageType) {
			case EVENING:	constructHSBCShader(-25, 0, 0, 0);
			case NIGHT:		constructHSBCShader(15, -35, -65, -10);
			default:		constructHSBCShader(0, 0, -10, 15);
		};
	addWithShader(cashboxfar = new FlxSprite(685, 324, Paths.image(rootPath + 'cassa lenta 2')), false, cashboxShader);
	addWithShader(new FlxSprite(845, -520, Paths.image(rootPath + 'cassa naves 2')), false, cashboxShader);


	if (!isAnalgamatMix)
	{
		addWithShader(hopka = new Character(1730, 210, "hopka_bg"), false,
			switch (rawStageType) {
				case EVENING:	constructHSBCShader(25, 0, 0, 0);
				case NIGHT:		constructHSBCShader(0, 0, -45, 15);
				default:		null;
			}
		);
		hopka.moves = false; // прикован
		//hopka.visible = !isAnalgamatMix;
	}
	else
	{
		hopkaSleeper = new FunkinSprite(1690, 240);
		hopkaSleeper.loadAtlas("pyaterochka4/hopka_sleeper");
		hopkaSleeper.addAnimation("y", "hopka_sleep", null, null, 24, 0, true);
		hopkaSleeper.playAnim("y", true);
		hopkaSleeper.shader = constructHSBCShader(0, 0, -45, 15);
		insert(members.indexOf(cashboxfar) + 1, hopkaSleeper);
	}

	var strangeScale = 1 / 0.965;
	addWithShader(new FlxSprite(-1110, -60, Paths.image(rootPath + "polki1")), false, shelvesShader).scale.set(strangeScale, strangeScale);
	addWithShader(new FlxSprite(-2530, -60, Paths.image(rootPath + "polki1")), false, shelvesShader).scale.set(strangeScale, strangeScale);
	addWithShader(new FlxSprite(-4000, -40, Paths.image(rootPath + "polki2")), false, shelvesShader).scale.set(1.14 / 0.97, 1.24 / 0.97);
	addWithShader(new FlxSprite(-2200, -40, Paths.image(rootPath + "polki3")), false, shelvesShader).scale.set(1.14, 1.24);

	addWithShader(new FlxSprite(1085, 430, Paths.image(rootPath + 'cassa lenta 1')), false, cashboxShader);
	addWithShader(new FlxSprite(1455, -420, Paths.image(rootPath + 'cassa naves 1')), false, cashboxShader);

	addWithShader(new FlxSprite(-1500, 575, Paths.image(rootPath + 'cleaning stuff')), true, baseShader);
	if (rawStageType != EVENING)
	{
		addWithShader(lights = new FlxSprite(-3000, -775, Paths.image(rootPath + 'light')), true,
			switch (rawStageType) {
				case NIGHT:		constructHSBCShader(69, 100, -60, -25);
				default:		null;
			}
		);
		lights.alpha = switch (rawStageType) {
				case NIGHT:		0.45;
				default:		0.3;
			}
		lights.blend = BlendMode.ADD;
		lights.scale.set(0.84, 0.84);
	}

	introCard = new FlxSprite(0, 0, Paths.image(rootPath + "logo"));
	// introCard.scrollFactor.set(1.6, 1.6);
	introCard.alpha = 0.00001;
	introCard.scale.set(1.5, 1.5); // 0.5
	introCard.updateHitbox();
	// introCard.screenCenter();
	// introCard.camera = camHUD;
	add(introCard); // addBehindObject

	var frontShelf = new FlxSprite(-4850, 140, Paths.image(rootPath + "polki3"));
	frontShelf.scale.set(2.3, 2.2);
	frontShelf.color = FlxColor_Impl_.getDarkened(FlxColor.WHITE, 0.31);
	frontShelf.scrollFactor.set(0.85, 1.0);
	addWithShader(frontShelf, true, shelvesShader);


	xiavi = new Character(-750, 260, "xiavier-bg");
	xiavi.moves = false;
	// xiavi.alpha = 0.1;

	viola = new Character(-400, 285, "viola-bg");
	viola.moves = false;
	if (FlxG.random.bool())
	{
		viola.x += 75;
		var scale = 0.93;
		// viola.y += 45;
		viola.scale.set(viola.scale.x * scale, viola.scale.y * scale);
		for (offset in viola.animOffsets)
			offset.set(Math.ffloor(offset.x * scale), Math.ffloor(offset.y * scale));
	}

	addWithShader(viola, false, charsShader);
	addWithShader(xiavi, false, charsShader);
	viola.color = xiavi.color = FlxColor_Impl_.getDarkened(FlxColor.WHITE, 0.15);


	var oldCreateCountSprite = createCountSprite;
	createCountSprite = (name:String, sound:String) ->
	{
		var countdown = oldCreateCountSprite(name, sound);
		if (countdown != null)
			countdown.camera = camOther;
		return countdown;
	}
}

function onCreatePost()
{
	reorder(gfGroup, members.indexOf(cashboxfar) + 1);
	// for (group in [gfGroup, dadGroup, bfGroup])
	// {
	// 	group.forEach(i -> i.shader = charsShader);
	// }
	for (char in [gf, dad, boyfriend])
	{
		char.shader = charsShader;
	}
	var scoreGroup = variables.get("scoreGroup");
	if (scoreGroup != null)
	{
		remove(scoreGroup, true);
		addAheadObject(scoreGroup, gfGroup);
		if (isNaisojiMix)
		{
			scoreGroup.x -= 250;
			scoreGroup.y -= 60;
		}
		else
		{
			scoreGroup.x += 270;
			scoreGroup.y -= 50;
		}
	}


	// с декабря по февраль
	if (/*true ||*/ (Date.now().getMonth() + 1) % 12 < 3)
	{
		var frames = Paths.getSparrowAtlas("pyaterochka4/balls");
		var maxIndex = frames.numFrames - 1;

		var minMult = 0.825;
		var maxMult = 1.1;
		var maxBalls = FlxG.random.int(9, 10);
		var ballPropertyList = [];
		for (i in 0...maxBalls)
		{
			var prop = {
				scale: 0.6,
				scroll: 1,
				offsetY: 80,
				behind: true
			}
			if (i < 4)
			{
				prop.scale = 0.95;
				prop.scroll = 1.4;
				prop.offsetY = -80;
				prop.behind = false;
			}
			prop.scale *= FlxG.random.float(minMult, maxMult);
			prop.scroll *= FlxG.random.float(0.96, 1.14);
			prop.offsetY *= FlxG.random.float(minMult, maxMult);
			ballPropertyList.push(prop);
		}

		// не позволяем 3 подряд одного типа
		while (true)
		{
			var sort = false;
			var count = 0;
			var lastBehind = ballPropertyList[0].behind;
			for (prop in ballPropertyList)
			{
				if (lastBehind == prop.behind)
				{
					if (++count == 3)
					{
						sort = true;
						break;
					}
				}
				else
					count = 0;

				lastBehind = prop.behind;
			}

			if (sort)
			{
				// FlxG.random.shuffle(ballPropertyList);
				var maxValidIndex = ballPropertyList.length - 1;
				for (i in 0...maxValidIndex)
				{
					var j = FlxG.random.int(i, maxValidIndex);
					var tmp = ballPropertyList[i];
					ballPropertyList[i] = ballPropertyList[j];
					ballPropertyList[j] = tmp;
				}
			}
			else
			{
				// cnfdbv byltrcs ahtqvjd
				// да блять
				var last = -1;
				for (prop in ballPropertyList)
				{
					prop.frame = FlxG.random.int(0, maxIndex, [last]);
					last = prop.frame;
				}
				break;
			}
		}

		// trace("\n" + ballPropertyList.join("\n"));

		for (i => prop in ballPropertyList)
		{
			var progress = i / maxBalls;
			var ball = new FlxSprite(-2505.2 + 600 * i, -709.6 * prop.scale + prop.offsetY);
			ball.scrollFactor.set(prop.scroll, FlxG.random.float(1.05, 1.15));
			ball.frames = frames;
			ball.frame = frames.frames[prop.frame];
			ball.scale.x = ball.scale.y = prop.scale;
			ball.updateHitbox();
			ball.origin.y = ball.frameHeight * FlxG.random.float(0.1, 0.25);
			ball.angle = FlxG.random.float(3.25, 1.25);
			if (FlxG.random.bool())
				ball.angle *= -1;

			FlxTween.num(ball.scale.x * FlxG.random.float(0.75, 0.925), ball.scale.x, FlxG.random.float(2.6, 5.6),
				{ease: FlxEase.sineInOut, type: PINGPONG, loopDelay: FlxG.random.float(0.2, 0.4)}, ball.scale.set_x).percent = progress;
			FlxTween.num(ball.angle, -ball.angle, FlxG.random.float(2.6, 5.6),
				{ease: FlxEase.sineInOut, type: PINGPONG, loopDelay: FlxG.random.float(0.2, 0.4)}, ball.set_angle).percent = progress;

			if (rawStageType == EVENING)
				addHxObject(ball, true);
			else
				(prop.behind ? addBehindObject : addAheadObject)(ball, lights);
			balls.push(ball);
		}
	}

	switch (rawStageType) {
		case EVENING:
			var theme = new FlxBGSprite();
			theme.color = 0xFFF6B394;
			theme.alpha = 0.69;
			theme.blend = MULTIPLY;
			add(theme);
		case NIGHT:
			var ving = new TwistSprite(0, 0, Paths.image(rootPath + "vignette"));
			// ving.camera = camHUD;
			ving.alpha = 0.8;
			ving.zoomFactor = 0;
			ving.scrollFactor.set(0, 0);
			ving.drawAlways = true;
			ving.scale.set(1.2, 1.2);
			ving.screenCenter();
			add(ving);
			// insert(0, ving);
	}
	spawnD5rk();


	var hasCamPosScript = false;
	var hasCamZoomScript = false;
	for (script in scriptPack.hscriptArray)
	{
		// trace(script.scriptName);
		if (script.scriptName == "Set Camera Position.hx")
			hasCamPosScript = true;
		else if (script.scriptName == "Set Default Zoom.hx")
			hasCamZoomScript = true;

		if (hasCamPosScript && hasCamZoomScript)
			break;
	}

	if (!hasCamPosScript)
	{
		trace("loading Set Camera Position");
		loadHScript(AssetsPaths.getPath("custom_events/Set Camera Position.hx"));
	}
	if (!hasCamZoomScript)
	{
		trace("loading Set Default Zoom");
		loadHScript(AssetsPaths.getPath("custom_events/Set Default Zoom.hx"));
	}

	isCameraOnForcedPos = true;
	snapCamFollowToPos(-2063.85, 654.825);
	FlxG.camera.snapToTarget();
	FlxG.camera.zoom *= 0.9;
	camHUD.alpha = 0;
	camControls.alpha = 0;
	introCard.setPosition(
		FlxG.camera.viewLeft + (FlxG.camera.viewWidth - introCard.width) * 0.5,
		FlxG.camera.viewTop + (FlxG.camera.viewHeight - introCard.height) * 0.5
	);
}

// интро в скрипте чтобы не ломать луп песни!
function onSongStart()
{
	var crochetSec = Conductor.crochet / 1000.0;
	FlxTween.num(introCard.alpha, 1.0, crochetSec * 2.0, {
		// startDelay: crochetSec,
		onComplete: _ ->
		{
			FlxTween.num(introCard.alpha, 0.0, crochetSec * 2.0, {
				startDelay: crochetSec * 4.0,
				onComplete: _ -> {
					introCard.kill();
				}
			}, introCard.set_alpha);
		}
	}, introCard.set_alpha);
	new FlxTimer().start(crochetSec * 8.0, _ ->
	{
		triggerEventNote("Set Camera Position", "", (crochetSec * 8.0) + ",quadinout", "");
		triggerEventNote("Set Default Zoom", "", "20,quadinout", "");
		isCameraOnForcedPos = false;
	});
	for (cam in [camHUD, camControls])
		FlxTween.num(cam.alpha, 1.0, crochetSec * 4.0, {startDelay: crochetSec * 8.0}, cam.set_alpha);
}

var adjustColorShaderRaw = Assets.getText(AssetsPaths.fragShader("adjustColor"));

function constructHSBCShader(hue:Float = 0, saturation:Float = 0, brightness:Float = 0, contrast:Float = 0)
{
	var shader = new FlxRuntimeShader(adjustColorShaderRaw);
	shader.setFloat("hue", hue);
	shader.setFloat("saturation", saturation);
	shader.setFloat("brightness", brightness);
	shader.setFloat("contrast", contrast);
	shader.preload();
	return shader;
}

function addWithShader(obj:FlxBasic, front:Bool = false, shader:FlxShader = null)
{
	obj.shader ??= shader;
	return addHxObject(obj, front);
}
var _addsTimer:FlxTimer = new FlxTimer();
_addsTimer.cancel(); // update logic

function danceShit(ref:Int)
{
	danceCharacter(xiavi, ref, xiavi.danceEveryNumBeats);
	if (!isAnalgamatMix)
		danceCharacter(hopka, ref, hopka.danceEveryNumBeats);

	if (rich.extraData.playingFenefeIdle == true)
		danceCharacter(rich, ref, rich.danceEveryNumBeats);
	if (ref % 8 == 0 && _addsTimer.finished)
	{
		updateAddsScreen();
	}
}

function onStepHit()
{
	if (!xiavi.stunned && FlxG.random.bool(0.05))
	{
		xiavi.playAnim("laugh");
		xiavi.specialAnim = true;
	}
	if (!viola.stunned && FlxG.random.bool(0.05))
	{
		viola.playAnim("look");
		viola.specialAnim = true;
	}
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "")
	{
		if (isAnalgamatMix)
		{
			if (value1 == "rich_moveTo")
			{
				var pos = -350 + FlxG.random.float(-10, 10);
				var posX = rich.x + rich.relativeX;
				var flip = (posX < pos);
				rich.stunned = true;
				rich.anim.timeScale = FlxG.random.float(0.8, 1.1);
				richPlayAnim(rich, getRichRandomWalk(), flip);

				var dist = Math.abs(posX - pos);
				var time = (dist / 170 / rich.anim.timeScale);
				// привет математика 5 класс вентана граф
				rich.velocity.x = (dist / time);
				if (!flip)
					rich.velocity.x *= -1;

				new FlxTimer(richTimerManager).start(time, _ ->
				{
					rich.velocity.x = 0;
					rich.anim.timeScale = 1;
					// FlxG.random.bool(richIdleAnimsChances[3]) ? "idle3" : "idle0"
					richPlayAnim(rich, getRichRandomIdle([1, 2, 4]));
				});
			}
			else
			{
				richPlayAnim(rich, "woof", FlxG.random.bool());
				camFollow.x = rich.x + 160;
				camFollow.y = rich.y + 80;
				defaultCamZoom = 1;
				cameraSpeed = 2;
				isCameraOnForcedPos = true;
				// camHUD.visible = false;
				FlxTween.num(1, 0, Conductor.stepCrochet / 1000 * 2, null, camHUD.set_alpha);
			}
		}
		else if (isNaisojiMix)
		{
			hopka.playAnim("meow", true);
			hopka.stunned = true;
			// camHUD.visible = false;
			FlxTween.num(1, 0, Conductor.stepCrochet / 1000 * 2, null, camHUD.set_alpha);
		}
	}
}

function updateAddsScreen()
{
	if (adds != null)
		adds.animation.frameIndex = FlxG.random.int(0, adds.animation.numFrames - 1, [adds.animation.frameIndex]);
	_addsTimer.start(FlxG.random.int(6, 12) * 4 * Conductor.crochet / 1000); // вычесляет время от случайного колич. секций
}

function onBeatHit(beat:Int) danceShit(beat);
function onCountdownTick(tick:Int) danceShit(tick);

function onGameOverStart()
{
	remove(lights);
	GameOverSubstate.instance.add(lights);
	richTimerManager.completeAll();

	for (ball in balls)
		if (ball.scale.x > 0.85)
			addAheadObject(ball, lights);
		else
			addBehindObject(ball, lights);

	function playDeathAnim(char)
	{
		char.playAnim("death", true);
		char.stunned = true;
	}
	if (!isAnalgamatMix)
		playDeathAnim(hopka);

	playDeathAnim(xiavi);
	playDeathAnim(viola);

	if (isAnalgamatMix)
		gf.shader = null;
	else
		boyfriend.shader = null;
}