var twistHudScript = scriptPack.getHScript("scripts/hud");
var globalScript = scriptPack.getHScript("scripts/script");

if (twistHudScript == null || globalScript == null)
{
	dispose();
	return;
}

import openfl.display.FPS;
// import openfl.display3D.Context3DMipFilter;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.text.FlxText.FlxTextBorderStyle;

import game.backend.data.StructureOptionsData;
import game.objects.Bar;
import game.objects.FlxExtendedSprite;
import game.objects.game.notes.Note;
import game.objects.game.notes.NoteSplash;
import game.objects.improvedFlixel.FlxFixedText;

spawnCountDownSprite = swagCounter ->
{
	final sprite = switch (swagCounter)
	{
		case 0: createCountSprite(null, "classic/3");
		case 1: createCountSprite("ready", "classic/2");
		case 2: createCountSprite("set", "classic/1");
		case 3: createCountSprite("go", "classic/go");
		default: null;
	}

	if (sprite == null)
		return;

	FlxTween.tween(sprite, {/*y: spr.y + 100.0,*/ alpha: 0.0}, Conductor.crochet / 1000,
	{
		ease: FlxEase.cubeInOut,
		onComplete: _ ->
		{
			remove(sprite, true);
			sprite.destroy();
		}
	});
}

public var fps:FPS;

var botplayTxt:FlxFixedText;
var healthBarBar:Bar;
var scoreTxt:FlxFixedText;
var scoreGroup:FlxTypedSpriteGroup;
var popUpTweenManager:FlxTweenManager;

var timeTextText:FlxFixedText;
var timeBarBar:Bar;

function onCreatePost()
{
	Main.applicationScreen.stage.addChildAt(fps = new FPS(10, 3, 0xFFFFFF), Main.applicationScreen.stage.getChildIndex(Main.fpsVar));
	fps.visible = false;

	healthBarBar = twistHudScript.getVar("healthBarBar");
	scoreGroup = globalScript.getVar("scoreGroup");
	popUpTweenManager = globalScript.getVar("popUpTweenManager");

	// scoreTxt = twistHudScript.getVar('scoreTxt');
	scoreTxt = new FlxText(100, healthBarBar.y + 36, FlxG.width, "");
	scoreTxt.setFormat(Paths.font("VCR OSD Mono Cyr.ttf"), 18, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	scoreTxt.borderSize = 1.2;
	scoreTxt.screenCenter(X);
	scoreTxt.antialiasing = false;

	// кэширование
	Paths.music("breakfast");
	graphicCache.cacheGraphic(Paths.getSparrowAtlas('classicUI/noteSplashes')?.parent);
	graphicCache.cacheGraphic(Paths.image('classicUI/bad'));
	graphicCache.cacheGraphic(Paths.image('classicUI/combo'));
	graphicCache.cacheGraphic(Paths.image('classicUI/good'));
	graphicCache.cacheGraphic(Paths.image('classicUI/shit'));
	graphicCache.cacheGraphic(Paths.image('classicUI/sick'));
	for (i in 0...10)
		graphicCache.cacheGraphic(Paths.image('classicUI/num$i'));

	// TODO: таймбар говна
	timeTextText = new FlxFixedText(PlayState.STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
	timeTextText.setFormat(Paths.font("VCR OSD Mono Cyr.ttf"), 32, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	timeTextText.alpha = 0;
	timeTextText.borderSize = 2;
	timeTextText.active = false;
	// timeTextText.visible = !ClientPrefs.hideTime;
	if(ClientPrefs.downScroll) timeTextText.y = FlxG.height - 45;

	timeBarBar = new Bar(0, 0, 'timeBar', function() return songPercent);
	timeBarBar.x = timeTextText.x;
	timeBarBar.y = timeTextText.y + (timeTextText.height / 4);
	timeBarBar.alpha = 0;
	timeBarBar.smoothFactor = 0.0;
	timeBarBar.leftToRight = true;
	// timeBarBar.visible = !ClientPrefs.hideTime;
	timeBarBar.bg.color = FlxColor.BLACK;
	timeBarBar.remove(timeBarBar.bg, true);
	timeBarBar.insert(0, timeBarBar.bg);
	timeBarBar.barWidth = Std.int(timeBarBar.bg.width - 7);
	timeBarBar.barHeight = Std.int(timeBarBar.bg.height - 8);
	timeBarBar.barOffset.set(4, 4);
	// timeBarBar.leftBar.pixelPerfectRender = true;
	// timeBarBar.leftBar.pixelPerfectPosition = true;
	// timeBarBar.rightBar.pixelPerfectRender = true;
	// timeBarBar.rightBar.pixelPerfectPosition = true;
	// timeBarBar.bg.scale.y = 0.98;

	botplayTxt = new FlxFixedText(0, timeBarBar.y + 55, 0, "BOTPLAY", 32);
	botplayTxt.setFormat(Paths.font("VCR OSD Mono Cyr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	botplayTxt.borderSize = 1.25;
	botplayTxt.visible = cpuControlled;
	botplayTxt.active = false;
	if(ClientPrefs.downScroll)
		botplayTxt.y = timeBarBar.y - 78;
	botplayTxt.screenCenter(X);
	botplayTxt.camera = camHUD;

	// супер тупой фикс лага лол
	// var splash = grpNoteSplashes.add(new NoteSplash());
	// splash.setupNoteSplash(FlxG.width / 2.0, FlxG.height / 2.0, 0, "classicUI/noteSplashes");
	// splash.alpha = 0.000001;

	switchHud("psych");

	// ДЕГРАДАЦИЯ ОПЦИЙ!!!
	var visualUiOptions = StructureOptionsData.data.get("VISUAL UI");
	if (visualUiOptions != null)
	{
		findOptionAndAttachVisible(visualUiOptions, "noteSplashes.*", checkVisibleOption);
		findOptionAndAttachVisible(visualUiOptions, "holdCovers", checkVisibleOption);
		findOptionAndAttachVisible(visualUiOptions, "instaKillLastHoldNote", checkVisibleOption);
		findOptionAndAttachVisible(visualUiOptions, "comboStacking", checkVisibleOption);
		findOptionAndAttachVisible(visualUiOptions, "showFPS.*", checkVisibleOption);
	}
	// лагает и того не стоит
	/*var graphicsOptions = StructureOptionsData.data.get("GRAPHICS");
	if (graphicsOptions != null)
	{
		findOptionAndAttachVisible(graphicsOptions, "globalMipMapsEnable", checkVisibleOption);
	}*/
	StructureOptionsData.onChangePre.add(onChangeOption);
	StructureOptionsData.onChangePost.add(onChangeOptionPost);
}

var canBeInvisibleOptions:Array<Dynamic> = [];
function findOptionAndAttachVisible(struct:Array<Dynamic>, pathToVariableName:String, func:Void -> Bool)
{
	if (pathToVariableName.length == 0) return;
	var toFind = null; // null = each
	if (pathToVariableName != "*")
	{
		toFind = pathToVariableName.substring(0, pathToVariableName.indexOf("."));
		if (toFind.length == 0)
			toFind = pathToVariableName;
	}
	// trace(toFind, pathToVariableName);
	for (i in struct)
	{
		if (toFind == null || i.variableName == toFind)
		{
			if (toFind == null || i.variableName == pathToVariableName)
			{
				i.checkVisible = func;
				canBeInvisibleOptions.push(i);
			}
			else if (i.things != null)
			{
				findOptionAndAttachVisible(i.things, pathToVariableName.substring(toFind.length + 1, pathToVariableName.length), func);
			}
			if (toFind != null)
				break;
		}
	}
}

function checkVisibleOption() return healthbarStyle != "psych";

function onChangeOption(data)
{
	if (healthbarStyle == "psych")
	{
		switch (data.variableName) {
			case "strumsNotesOverlap" | "noteSplashesScale" | "splashAlpha":
				StructureOptionsData.cancelNextCallback |= true;
		}
	}
}

function onChangeOptionPost(data)
{
	if (healthbarStyle == "psych")
	{
		switch (data.variableName) {
			// case "globalMipMapsEnable":
			// 	FlxSprite.defaultMipFilter = Context3DMipFilter.MIPNONE;
			case "showFPS":
				fps.visible = ClientPrefs.showFPS;
				Main.fpsVar.visible = false;
		}
	}
}

var oldCameraZoom = cameraZooming;
var oldPlayMissSound = playMissSound;
var oldPopUpCombo = popUpCombo;
var alreadyPreloaded:Bool = false;
function onClearHud()
{
	if (!alreadyPreloaded && healthbarStyle == "twist")
	{
		trace("duh");
		healthBarGroup.forEach(i -> graphicCache.cacheGraphic(i.graphic), true);
		timeBarGroup.forEach(i -> graphicCache.cacheGraphic(i.graphic), true);
		trace("duh");
		alreadyPreloaded = true;
	}
}
function onUpdateHud()
{
	updateVisualBySettings();

	if (healthbarStyle == "psych")
	{
		healthBarBar.antialiasing = false;
		healthBarBar.smoothFactor = 0.0;

		timeBarGroup.add(timeBarBar);
		timeBarGroup.add(timeTextText);

		healthBarGroup.add(healthBarBar);
		healthBarGroup.add(iconsGroup);
		healthBarGroup.add(scoreTxt);
		// healthBarGroup.add(botplayTxt);
		addAheadObject(botplayTxt, strumLineNotes);

		// эмуляция FlxBar'а без использования FlxBar'а лол
		healthBarBar.remove(healthBarBar.bg, true);
		healthBarBar.insert(0, healthBarBar.bg);
		@:bypassAccessor healthBarBar.barWidth = Std.int(healthBarBar.bg.width - 8);
		@:bypassAccessor healthBarBar.barHeight = Std.int(healthBarBar.bg.height - 8);
		healthBarBar.barOffset.set(4, 4);
		healthBarBar.updateBar();
		// healthBarBar.leftBar.pixelPerfectRender = true;
		// healthBarBar.leftBar.pixelPerfectPosition = true;
		// healthBarBar.rightBar.pixelPerfectRender = true;
		// healthBarBar.rightBar.pixelPerfectPosition = true;
		// healthBarBar.bg.scale.y = 0.98;

		// if (scoreGroup != null)
		// {
		// 	remove(scoreGroup, true);
		// 	add(scoreGroup);
		// }

		updateScore = updateScorePsych;
		healthBarUpdate = healthBarUpdatePsych;
		cameraZooming = cameraZoomingPsych;
		beatIcons = beatIconsPsych;
		playMissSound = playMissSoundPsych;
		popUpCombo = popUpComboPsych;

		updateTimeTextPsych();

		updateColorsInHealthBar = twistHudScript.getVar("updateColorsInHealthBarTwist");
		flipHealthBar = twistHudScript.getVar("flipHealthBarTwist");
		for (icon in iconsGroup.members)
		{
			icon.y = healthBarBar.centerPoint.y - 75.0;
		}

		if (middleScrollMode)
			for (strum in opponentStrums.members)
				strum.visible = false;

		for (i in strumLines)
		{
			// i.noteSplashes.forEach(j -> j.loadAnims(i.noteSplashes.defaultTexture));
			i.noteSplashes.offset.set(20, 20);
			@:bypassAccessor i.enableHoldCovers = false;
			@:bypassAccessor i.instaKillLastHoldNote = false;
			@:bypassAccessor i.enableOverlapSustainNotes = false;
			i.updateSustainNotesOrder();
			i.updateVisibleHoldCovers();
		}
		playerStrumLine.noteSplashes.defaultTexture = "classicUI/noteSplashes";
	}
	else
	{
		remove(botplayTxt, true);

		for (i in strumLines)
		{
			// i.noteSplashes.forEach(j -> j.loadAnims(i.noteSplashes.defaultTexture));
			i.noteSplashes.offset.set(0, 10);
			@:bypassAccessor i.enableHoldCovers = null;
			@:bypassAccessor i.enableOverlapSustainNotes = null;
			@:bypassAccessor i.instaKillLastHoldNote = null;
			i.updateSustainNotesOrder();
			i.updateVisibleHoldCovers();
		}
		playerStrumLine.noteSplashes.defaultTexture = PlayState.SONG.splashSkin;

		cameraZooming = oldCameraZoom;
		playMissSound = oldPlayMissSound;
		popUpCombo = oldPopUpCombo;
		if (middleScrollMode)
			for (strum in opponentStrums.members)
				strum.visible = true;

		if (healthBarBar != null)
		{
			healthBarBar.antialiasing = true;
			// назад стандартные настройки
			healthBarBar.remove(healthBarBar.bg, true);
			healthBarBar.add(healthBarBar.bg);
			@:bypassAccessor healthBarBar.barWidth = Std.int(healthBarBar.bg.width - 6);
			@:bypassAccessor healthBarBar.barHeight = Std.int(healthBarBar.bg.height - 6);
			healthBarBar.barOffset.set(3, 3);
			healthBarBar.updateBar();
			// healthBarBar.leftBar.pixelPerfectRender = null;
			// healthBarBar.leftBar.pixelPerfectPosition = false;
			// healthBarBar.rightBar.pixelPerfectRender = null;
			// healthBarBar.rightBar.pixelPerfectPosition = false;
			// healthBarBar.bg.scale.y = 1;
		}

		// if (scoreGroup != null)
		// {
		// 	remove(scoreGroup, true);
		// 	addBehindDad(scoreGroup);
		// }
	}
}

var lastPauseSong = PauseSubState.songName;
function onPause()
{
	if (healthbarStyle == "psych")
	{
		lastPauseSong = PauseSubState.songName;
		PauseSubState.songName = "breakfast";
	}
}

function onResume()
{
	if (healthbarStyle == "psych")
	{
		PauseSubState.songName = lastPauseSong;
	}
}

function onSongStart()
{
	FlxTween.tween(timeBarBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
	FlxTween.tween(timeTextText, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
}

// почему в психе миссы играли только когда ты без гостапа играешь????
function noteMissPress(direction:Int)
{
	if (healthbarStyle == "psych")
	{
		FlxG.sound.play(Paths.soundRandom('classic/missnote', 1, 3), FlxG.random.float(0.1, 0.2));
	}
}

/*
function onSpawnNoteSplash(strum:StrumNote, data:Int, note:Note)
{
	if (healthbarStyle == "psych" && note != null)
	{
		var oldOptScale = ClientPrefs.noteSplashesScale;
		var oldOptAlpha = ClientPrefs.splashAlpha;
		ClientPrefs.noteSplashesScale = 1;
		ClientPrefs.splashAlpha = 0.6;
		var splash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(strum.x, strum.y, data, "classicUI/noteSplashes", note);
		splash.offset.set(10, 10);
		@:bypassAccessor splash.angle = 0;
		splash._sinAngle = 0;
		splash._cosAngle = 1;
		// splash.animation._curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		splash.setPosition(strum.x - Note.swagWidth * 0.95, strum.y - Note.swagWidth);
		ClientPrefs.noteSplashesScale = oldOptScale;
		ClientPrefs.splashAlpha = oldOptAlpha;
		return Function_Stop;
	}
}
*/

function onDestroy()
{
	updateVisualBySettings("twist");
	Main.applicationScreen.stage.removeChild(fps);
	StructureOptionsData.onChangePre.remove(onChangeOption);
	StructureOptionsData.onChangePost.remove(onChangeOptionPost);
	// if (healthbarStyle != "psych")
	// {
		timeTextText.destroy();
		timeBarBar.destroy();
	// }
	for (i in canBeInvisibleOptions)
	{
		i.checkVisible = null;
	}
}

function updateVisualBySettings(?forseStyle:String)
{
	forseStyle ??= healthbarStyle;
	if (forseStyle != "psych")
	{
		if (fps != null)
			fps.visible = false;
		Main.fpsVar.visible = ClientPrefs.showFPS;
		// FlxSprite.defaultMipFilter = ClientPrefs.globalMipMapsEnable ? Context3DMipFilter.MIPLINEAR : Context3DMipFilter.MIPNONE;
	}
	else
	{
		if (fps != null)
			fps.visible = ClientPrefs.showFPS;
		Main.fpsVar.visible = false;
		// FlxSprite.defaultMipFilter = Context3DMipFilter.MIPNONE;
	}
}

var scoreTxtTween:FlxTween;
function updateScorePsych(miss:Bool = false, ?start:Bool = false)
{
	if (scoreTxt == null)
		return;

	var totalText = 'Score: $songScore | Misses: $songMisses | Rating: $ratingName';
	if (ratingName != '?')
		totalText += ' (${Math.floor(ratingPercent * 100)}%)';

	scoreTxt.text = totalText;

	if (ClientPrefs.scoreZoom && !(miss || start))
	{
		scoreTxtTween?.cancel();
		scoreTxt.scale.x = 1.1;
		scoreTxt.scale.y = 1.1;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}
}

function healthBarUpdatePsych(elapsed:Float)
{
	if (!startingSong && !paused)
	{
		final curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.noteOffset);
		final prevTime = songPercent * songLength;
		songPercent = curTime / songLength;
		if (prevTime % 1000 > curTime % 1000)
		{
			updateTimeTextPsych();
		}
	}
	if (botplayTxt.visible)
	{
		botplaySine += elapsed;
		botplayTxt.colorTransform.alphaMultiplier = (1 - Math.sin(Math.PI * botplaySine)) / 2;
	}

	for (icon in iconsGroup.members)
	{
		// so retro.....
		icon.setGraphicSize(Std.int(FlxMath.lerp(150 * icon.baseScale * icon.data.scale, icon.width, FlxMath.bound(1 - (elapsed * 30), 0, 1))));
		icon.updateHitbox();
		icon.updateMidPointScale();
		icon.offset.x -= icon.data.offsets[0] + icon.iconOffsetsAnim[0];
		icon.offset.y -= icon.data.offsets[1] + icon.iconOffsetsAnim[1];

		var iconOffset:Int = 26;

		icon.x = healthBarBar.x + healthBarBar.width * FlxMath.remapToRange(healthBarBar.percent,
			0.0, 100.0,
			1.0, 0.0
		);
		if (icon.isPlayer)
			icon.x -= iconOffset;
		else
			icon.x -= icon.width - iconOffset;
	}
}

public function updateTimeTextPsych()
{
	var secondsTotal:Int = Math.floor(((1 - songPercent) * songLength) / 1000);
	if(secondsTotal < 0) secondsTotal = 0;

	var minutesRemaining:Int = Math.floor(secondsTotal / 60);
	var secondsRemaining:String = Std.string(secondsTotal % 60);
	if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
	timeTextText.text = minutesRemaining + ':' + secondsRemaining;
}

function popUpComboPsych(daRating:Rating)
{
	if (scoreGroup == null)
		return;
	// мы конечно ретро тут, НО НЕ НАСТОЛЬКО!
	final coolText_x = FlxG.width * 0.35; // FlxG.width * 0.55

	if (showRating)
	{
		var rating:FlxExtendedSprite = scoreGroup.recycle(FlxExtendedSprite);
		rating.loadGraphic(Paths.image("classicUI/" + daRating.image));
		rating.screenCenter();
		rating.x = coolText_x - 40;
		rating.y -= 60;
		rating.x += scoreGroup.x;
		rating.y += scoreGroup.y;
		rating.acceleration.y = 550;
		rating.velocity.y = -FlxG.random.int(140, 175);
		rating.velocity.x = -FlxG.random.int(0, 10);
		// rating.visible = !ClientPrefs.hideHud;
		rating.ID = scoreGroup.ID++;

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();

		popUpTweenManager.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.kill(); // destroy
				rating.alpha = 1.0;
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	// дада даже этот баг вернули привет привет
	final brokenCombo = Math.max(combo - 1, 0);
	if (showCombo && (brokenCombo >= 10 || brokenCombo == 0) && combo >= maxCombo)
	{
		var comboSpr:FlxExtendedSprite = scoreGroup.recycle(FlxExtendedSprite);
		comboSpr.loadGraphic(Paths.image("classicUI/combo"));
		comboSpr.screenCenter();
		comboSpr.x = coolText_x;
		comboSpr.x += scoreGroup.x;
		comboSpr.y += scoreGroup.y;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y = -150;
		// comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.ID = scoreGroup.ID++;

		comboSpr.velocity.x = FlxG.random.int(1, 10);

		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.updateHitbox();

		popUpTweenManager.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.kill(); // destroy
				comboSpr.alpha = 1.0;
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	if (showComboNum && brokenCombo >= 10 || brokenCombo == 0)
	{
		var seperatedScore:Array<Int> = [];

		if(brokenCombo >= 1000) {
			seperatedScore.push(Math.floor(brokenCombo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(brokenCombo / 100) % 10);
		seperatedScore.push(Math.floor(brokenCombo / 10) % 10);
		seperatedScore.push(brokenCombo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxExtendedSprite = scoreGroup.recycle(FlxExtendedSprite);
			numScore.loadGraphic(Paths.image('classicUI/num' + i));
			numScore.screenCenter();
			numScore.x = coolText_x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.x += scoreGroup.x;
			numScore.y += scoreGroup.y;

			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y = -FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			// numScore.visible = !ClientPrefs.hideHud;
			numScore.ID = scoreGroup.ID++;

			popUpTweenManager.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.kill(); // destroy
					numScore.alpha = 1.0;
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
	}
	/*
		trace(combo);
		trace(seperatedScore);
		*/

	scoreGroup.sort((index, obj1, obj2) -> obj1.ID > obj2.ID ? -index : obj2.ID > obj1.ID ? index : 0);
}

function cameraZoomingPsych(elapsed:Float)
{
	if (camZooming)
	{
		camGame.zoom = FlxMath.lerp(camGame.zoom, camGame.defaultZoom, elapsed * 3.125 * camZoomingDecay);
		camHUD.zoom = FlxMath.lerp(camHUD.zoom, camHUD.defaultZoom, elapsed * 3.125 * camZoomingDecay);
	}
}

function beatIconsPsych()
{
	for (icon in iconsGroup.members)
	{
		icon.setGraphicSize(Std.int(175 * icon.baseScale * icon.data.scale));
		icon.updateHitbox();
		icon.offset.x -= icon.data.offsets[0] + icon.iconOffsetsAnim[0];
		icon.offset.y -= icon.data.offsets[1] + icon.iconOffsetsAnim[1];
	}
}

function onBotplayChange(e)
{
	botplayTxt.visible = e;
}

function playMissSoundPsych()
{
	// FlxG.sound.play(Paths.soundRandom('missnoteClassic', 1, 3), FlxG.random.float(0.1, 0.2));
}