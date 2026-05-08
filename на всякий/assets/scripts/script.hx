import flixel.group.FlxTypedSpriteGroup;
import flixel.tweens.FlxTweenManager;
import flixel.FlxState;

import game.backend.utils.Highscore;
import game.backend.system.states.MusicBeatState;
import game.objects.FlxExtendedSprite;
import game.objects.transitions.StateTransition;
import game.objects.transitions.VanilaTransition;
import game.objects.transitions.StickersTransition;
import game.mobile.utils.TouchUtil;

static final bonusSongList = [
	"add-me-in-5rubles",
	"matematika",
	"under-construction",
	"jopotr4ss-d4rk", "jopotr4ss-leebert", "jopotr4ss-puk", "jopotr4ss-rofos", "jopotr4ss-simon"
];

#if RELEASE_BUILD
static
#end
final mixUnlock = [
	// {graphic: "path", offsetX: null, offsetY: null}
	"rofls" => {graphic: "rofls_PivoMix_available", offsetX: 10.0, offsetY: 15.0},
	"bezdari" => {graphic: "bezdari_mixes_available", offsetY: 10.0},
	"hernya" => {graphic: "hernya_MoruMix_available", offsetY: 10.0},
	"nokia" => {graphic: "nokia_RedarMix_available", offsetY: 30.0},
	"rubls" => {graphic: "rubls_PicoMix_available", offsetY: 10.0},
	"black2blue" => {graphic: "b2b_PicoMix_available", offsetY: 10.0},
];

final curSong = Highscore.formatSong(PlayState.SONG.song, "");
curPortrait = switch (curSong)
{
	case "bezdarinaisonjimix":							"bezdari-naisonjimix";
	case "bezdariamalgamatmix":							"bezdari";
	case "hernyamorumix":								"hernya";
	case "roflspivomix":								"rofls";
	case "under-construction":							"uc";
	// case "nokiaredarmix":								"nokia";
	default:											curSong;
}

// allowMissOpponent = true;
countDownSeconds = null;
// GameOverSubstate.characterName = null;
var showingMixUnlock = false;
var lemtaFunk = true;
function onEndSong()
{
	var isJopotr4ssDirtySave = StringTools.startsWith(curSong, "jopotr4ss-") && FlxG.save.data.completedOneOfJopotr4ss != true;
	if (lemtaFunk && (!PlayState.isStoryMode || PlayState.storyPlaylist.length < 2))
	{
		var prevTransition = Main.transition.curTransition;
		Main.transition.curTransition = StickersTransition;
		StateTransition.finishCallback = () -> Main.transition.curTransition = prevTransition;
		lemtaFunk = false;

		if (bonusSongList.contains(curSong))
			FlxG.signals.preStateSwitch.addOnce(() ->
			{
				if (FlxG.game._nextState != null && FlxG.game._nextState is FlxState)
					FlxG.game._nextState.destroy();
				FlxG.game._nextState = new MusicBeatState("MenuState");
			});
	}
	// trace(isJopotr4ssDirtySave, curSong, StringTools.startsWiths(curSong, "jopotr4ss-"), FlxG.save.data.completedOneOfJopotr4ss);

	if (!isJopotr4ssDirtySave && FlxG.save.data.rubles5UnlockedSong.contains(curSong))
		return;

	FlxG.save.data.completedOneOfJopotr4ss = FlxG.save.data.completedOneOfJopotr4ss == true || isJopotr4ssDirtySave;
	if (!FlxG.save.data.rubles5UnlockedSong.contains(curSong))
		FlxG.save.data.rubles5UnlockedSong.push(curSong);
	FlxG.save.flush();

	if (!mixUnlock.exists(curSong))
		return;

	var timer = 0.4;
	camOther.fade(FlxColor.BLACK, timer, false, () ->
	{
		FlxG.camera.visible = camHUD.visible = false;

		var data = mixUnlock.get(curSong);
		var unlock = new FlxSprite();
		unlock.frames = Paths.getSparrowAtlas("availabe_screens/" + data.graphic);
		unlock.animation.addByPrefix("loop", "loop", 24.0);
		unlock.animation.play("loop");
		add(unlock).camera = camOther;

		// final ratio1 = unlock.width / unlock.height;
		// final ratio2 = FlxG.width / FlxG.height;
		// unlock.setGraphicSize(ratio1 >= ratio2 ? FlxG.width * 0.95 : 0.0, ratio2 >= ratio1 ? FlxG.height * 0.95 : 0.0);
		// unlock.updateHitbox();
		unlock.screenCenter();
		unlock.offset.x -= data.offsetX;
		unlock.offset.y -= data.offsetY;

		camOther.fade(FlxColor.BLACK, timer, true, null, true);
		camOther.bgColor = FlxColor.BLACK;
		showingMixUnlock = true;
	}, true);
	transitioning = true;
}

function onUpdate(elapsed:Float)
{
	if (showingMixUnlock && (controls.BACK || controls.ACCEPT || TouchUtil.justPressed))
	{
		showingMixUnlock = false;
		transitioning = false;
		endSong();
	}
}

spawnCountDownSprite = (swagCounter:Int) ->
{
	var sprite:FlxSprite = switch (swagCounter)
	{
		case 0: createCountSprite(null, "intro3");
		case 1: createCountSprite("ready", "intro2");
		case 2: createCountSprite("set", "intro1");
		case 3: createCountSprite("go", "introGo");
		default: null;
	}

	if (sprite == null)
		return;

	var scaleFactor:Float = 1.2;
	sprite.scale.x *= scaleFactor * 1.1 * 0.8;
	sprite.scale.y *= scaleFactor * 1.1 * 0.8;

	if (swagCounter < 3)
		scaleFactor = 1.0 / scaleFactor;
	else
		FlxTween.tween(sprite, {alpha: 0.0}, Conductor.crochet / 980.0, {ease: FlxEase.cubeIn});

	FlxTween.tween(sprite, {"scale.x": sprite.scale.x * scaleFactor, "scale.y": sprite.scale.y * scaleFactor}, Conductor.crochet / 1000.0,
	{
		ease: FlxEase.quartOut,
		onComplete: _ ->
		{
			remove(sprite, true);
			sprite.destroy();
		}
	});
	// FlxTween.tween(sprite, {y: sprite.y - posY, "scale.x": 0.95, "scale.y": 0.95}, Conductor.crochet / 2000, {ease: FlxEase.backOut});
}

final placement:Float = FlxG.width * 0.6;
// for score popups recycling
public var scoreGroup:FlxTypedSpriteGroup;
function onCreatePost()
{
	scoreGroup = new FlxTypedSpriteGroup();
	// scoreGroup.cameras = [camHUD];
	scoreGroup.x += 150.0;
	scoreGroup.scrollFactor.set(0.9, 0.9);
	scoreGroup.ID = 0;
	// addBehindObject(scoreGroup, sustainNotes);
	addBehindDad(scoreGroup);
	setVar('scoreGroup', scoreGroup);
	// popUpCombo(1);
	camGame.followLerp = 0.36;
	__globalScript__.setVar("openDiscordSubMenu", bonusSongList.contains(curSong));
}

showCombo = true;
public var popUpTweenManager = add(new FlxTweenManager());
final placement:Float = FlxG.width * 0.35;
popUpCombo = (daRating:Rating) ->
{
	var scaleMult:Float	  = 0.7;
	var numScale:Float	  = 0.4;
	var pixelShitPart1:String = "";
	var pixelShitPart2:String = "";
	var antialiasing:Bool = true;
	if (PlayState.isPixelStage)
	{
		scaleMult = PlayState.daPixelZoom * 0.85;
		numScale  = PlayState.daPixelZoom * 0.75;
		pixelShitPart1 = 'pixelUI/';
		pixelShitPart2 = '-pixel';
		antialiasing = false;
	}

	if (!ClientPrefs.comboStacking)
	{
		popUpTweenManager.clear();
		scoreGroup.forEachAlive(spr -> spr.kill());
	}

	if (showRating)
	{
		final rating = scoreGroup.recycle(FlxExtendedSprite);
		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.antialiasing = antialiasing;
		rating.setScale(scaleMult);
		rating.updateHitbox();
		rating.x = placement - 40.0;
		rating.screenCenter(Y).y -= 30.0;
		switch(daRating.image)
		{
			case "good":
				rating.x -= 12.3;
				rating.y += 27.1;
			case "bad":
				rating.x += 46.6;
				rating.y += 60.05;
			case "shit":
				rating.x += 46.3;
				rating.y += 81.85;
		}
		rating.acceleration.y = 550.0;
		rating.velocity.set(-FlxG.random.int(1, 10), -FlxG.random.int(140, 175));
		// rating.visible = showRating;
		popUpTweenManager.num(1.0, 0.0, 0.2, {onComplete: _ -> rating.kill(), startDelay: Conductor.crochet / 1000.0}, rating.set_alpha);

		rating.ID = scoreGroup.ID++;
		groupShit(scoreGroup, rating);
	}

	if (showCombo && combo >= maxCombo) // > 69 // nice
	{
		final comboSpr = scoreGroup.recycle(FlxExtendedSprite);
		comboSpr.loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.antialiasing = antialiasing;
		comboSpr.setScale(scaleMult * 0.9);
		comboSpr.updateHitbox();
		comboSpr.x = placement + 35;
		comboSpr.screenCenter(Y).y += 105.0;
		comboSpr.acceleration.y = FlxG.random.int(200, 300);
		comboSpr.velocity.set(FlxG.random.int(1, 10), -FlxG.random.int(140, 160));
		// comboSpr.visible = showCombo;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		popUpTweenManager.num(1.0, 0.0, 0.2, {onComplete: _ -> comboSpr.kill(), startDelay: Conductor.crochet / 1000.0}, comboSpr.set_alpha);
		comboSpr.ID = scoreGroup.ID++;
		groupShit(scoreGroup, comboSpr);
		popUpTweenManager.tween(comboSpr, {x: comboSpr.x - 40 /*, alpha: 0*/}, Math.min(0.5, Conductor.crochet / 1000.0), {
			ease: FlxEase.expoOut,
			type: BACKWARD
		});
	}

	if (showComboNum)
	{
		var tempCombo = combo;
		var seperatedScore = [];
		while (tempCombo != 0)
		{
			seperatedScore.unshift(tempCombo % 10);
			tempCombo = Math.floor(tempCombo / 10);
		}

		var graph = Paths.image(pixelShitPart1 + 'nums' + pixelShitPart2);
		for (scoreInt => str in seperatedScore) // Std.string(combo).split("")
		{
			final numScore = scoreGroup.recycle(FlxExtendedSprite);
			numScore.loadGraphic(graph, true, Math.floor(graph.width / 10), graph.height);
			// numScore.animation.add("a", [for (i in 0...Std.int(graph.width / 10)) i], 24.0, false);
			numScore.animation.frameIndex = str;
			numScore.antialiasing = antialiasing;
			// numScore.cameras = [camHUD];
			numScore.setScale(numScale);
			numScore.updateHitbox();
			numScore.x = placement + (numScore.width - 5) * (
				scoreInt
				- Math.max(seperatedScore.length - 1, 1.5)
			) - 20;
			numScore.screenCenter(Y).y += 120.0;

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.set(FlxG.random.float(-5.0, 5.0), -FlxG.random.int(140, 160));

			popUpTweenManager.num(1.0, 0.0, 0.2, {onComplete: _ -> numScore.kill(), startDelay: Conductor.crochet / 1000.0}, numScore.set_alpha);
			numScore.ID = scoreGroup.ID++;

			groupShit(scoreGroup, numScore);
			// if (numScore.x > xThing)
			//	xThing = numScore.x;
		}
	}
	scoreGroup.sort((index, obj1, obj2) -> obj1.ID > obj2.ID ? -index : obj2.ID > obj1.ID ? index : 0);
	// comboSpr.x = xThing + 50;
	// trace(combo);
}

function groupShit(group:FlxSpriteGroup, object:FlxObject)
{
	object._cameras = group._cameras;
	object.acceleration.x *= group.scale.x;
	object.acceleration.y *= group.scale.y;
	object.velocity.x *= group.scale.x;
	object.velocity.y *= group.scale.y;
	object.scale.x *= group.scale.x;
	object.scale.y *= group.scale.y;
	object.updateHitbox();
	object.x = (object.x + group.x) * group.scale.x;
	object.y = (object.y + group.y) * group.scale.y;
}