import openfl.events.KeyboardEvent;

import game.objects.game.notes.StrumLine;
import game.objects.game.notes.StrumGroup;

using StringTools;

// константы KeyboardEvent'а дают null по этому костыль май фаворите!!!
static final KEY_DOWN = "keyDown"; // KeyboardEvent.KEY_DOWN
static final KEY_UP = "keyUp"; // KeyboardEvent.KEY_UP

var iconsMap:Map<String, HealthIcon> = [];
setVar("iconsMap", iconsMap);

function pushIcon(icon:HealthIcon)
{
	iconsMap.set(icon.char, icon);
	iconsGroup.add(icon);
}
setVar("pushIcon", pushIcon);

var hopka = getVar("hopka_math_char");
var iconHopk:HealthIcon;
var iconRich:HealthIcon;

function onCreatePost()
{
	// FlxG.stage.removeEventListener(KEY_DOWN, onKeyPress);
	// FlxG.stage.removeEventListener(KEY_UP, onKeyRelease);
	// FlxG.stage.addEventListener(KEY_DOWN, onKeyPressCustom);
	// FlxG.stage.addEventListener(KEY_UP, onKeyReleaseCustom);

	iconHopk = new HealthIcon(hopka.healthIcon);
	iconRich = new HealthIcon(gf.healthIcon);
	iconHopk.y = iconRich.y = iconP2.y;
	iconHopk.alpha = iconRich.alpha = 0.0;
	pushIcon(iconP1);
	pushIcon(iconP2);
	pushIcon(iconHopk);
	pushIcon(iconRich);
	lastTarget = _camTarget;

	// for (event in eventNotes)
	// 	if (event[1] == "" && event[2] == "Rich Time")
	// 	{
	// 		richTimeReal = event[0];
	// 		break;
	// 	}

	boyfriendMap.set(gf.curCharacter, gf);
	GameOverSubstate.applyFromCharacter(gf);
	gopro(boyfriend);
}

function gopro(char:Character)
{
	@:bypassAccessor GameOverSubstate.characterName = char.gameoverProperties[0];
	@:bypassAccessor GameOverSubstate.deathSoundName = char.gameoverProperties[1];
	@:bypassAccessor GameOverSubstate.loopSoundName = char.gameoverProperties[2];
	@:bypassAccessor GameOverSubstate.endSoundName = char.gameoverProperties[3];
}

var tempPlayerStrumLine;
var tempPlayerStrums;

function onKeyPressCustom(event:KeyboardEvent)
{
	// if (richTime)
	// {
	// 	// var temp = playerStrums;
	// 	// var tempLine = playerStrumLine;
	// 	// playerStrums = gfStrums;
	// 	// playerStrumLine = gfStrumLine;
	// 	// onKeyPress(event);
	// 	// playerStrums = temp;
	// 	// playerStrumLine = tempLine;
	// }
	// else
		onKeyPress(event);
}

function onKeyReleaseCustom(event:KeyboardEvent)
{
	// if (richTime)
	// {
	// 	var temp = playerStrums;
	// 	var tempLine = playerStrumLine;
	// 	playerStrums = gfStrums;
	// 	playerStrumLine = gfStrumLine;
	// 	onKeyRelease(event);
	// 	playerStrums = temp;
	// 	playerStrumLine = tempLine;
	// }
	// else
		onKeyRelease(event);
}

function onResume()
{
	if (cpuControlled || !richTime)
		return;

	for (strum in gfStrums.members)
	{
		if (strum.animation.curAnim.name == "static")
			continue;

		strum.playAnim("static");
		strum.resetAnim = 0.0;
	}
}

function onPause()
{
	ClientPrefs.ghostTapping = FlxG.save.data.ghostTapping;
}

function preKeyPress()
{
	// форсить гостапинг если редар спит
	ClientPrefs.ghostTapping = (!richTime && boyfriend.curAnimName == "snooze") ? true : FlxG.save.data.ghostTapping;
}

function onDestroy()
{
	// FlxG.stage.removeEventListener(KEY_DOWN, onKeyPressCustom);
	// FlxG.stage.removeEventListener(KEY_UP, onKeyReleaseCustom);
}

var playerScaleNotes:Float = 0.9; // 0.925
var opponentsScaleNotes:Float = 0.7; // playerScaleNotes * 0.8 = 0.85 * 0.8 // 0.775
var opponentsAlphaNotes:Float = 0.65;
var gfStrumLine:StrumLine;
var gfStrums:StrumGroup;

function onCreate()
{
	gfStrumLine = new StrumLine(false, PlayState.SONG.splashSkin, PlayState.SONG.holdCoverSkin, modManager);
	gfStrums = gfStrumLine.strumNotes;
	gfStrums.position.y = strumLine.y;
	setVar("gfStrumLine", gfStrumLine);
	setVar("gfStrums", gfStrums);
	gfStrumLine.cameras = [camHUD];
	setupStrumLine(gfStrumLine);
}

function onCountdownStarted()
{
	var targetAlpha:Float = opponentsAlphaNotes;
	// if (middleScrollMode)
	//	targetAlpha *= 0.35;
	if (!ClientPrefs.opponentStrums)
		targetAlpha = 0.0;

	var spawnFunc = null;
	if (!PlayState.isStoryMode && !skipArrowStartTween)
	{
		spawnFuck = _animateIntroStrumNote.bind(gfStrums, targetAlpha, _, _);
	}

	add(gfStrumLine);
	// gfStrumLine.exists = false;

	final halfWidth = FlxG.width / 2.0;
	gfStrums.position.x = halfWidth;
	gfStrums.position.y = strumLine.y;
	for (strum in gfStrums.generateStrums(["left", "down", "up", "right"], {
		funcIn: spawnFuck
	}))
	{
		strumLineNotes.add(strum);
		strum.playAnim("static");
	}

	var offset = FlxG.width / 3.0;
	playerStrums.position.x = gfStrums.position.x = opponentStrums.position.x = halfWidth;
	gfStrums.position.x += offset;
	opponentStrums.position.x -= offset + 20.0;

	gfStrums.scaleNoteFactor *= opponentsScaleNotes;
	opponentStrums.scaleNoteFactor *= opponentsScaleNotes;
	playerStrums.scaleNoteFactor *= playerScaleNotes;
	gfStrumLine.spawnTime /= opponentsScaleNotes;
	opponentStrumLine.spawnTime /= opponentsScaleNotes;
	playerStrumLine.spawnTime /= playerScaleNotes;
	gfStrums.updateStrumsPos(null, null, true, false);
	opponentStrums.updateStrumsPos(null, null, true, false);
	playerStrums.updateStrumsPos(null, null, true, false);

	for (index => note in opponentStrums.members)
	{
		FlxTween.cancelTweensOf(note);
		_animateIntroStrumNote(opponentStrums, targetAlpha, note, index);
	}
}

function onCreateNote(note:Note)
{
	if (note.noteType.startsWith("HopkNote") /*|| (Conductor.songPosition - note.strumTime) > noteKillOffset*/)
		return;

	var areRichTime = (note.strumTime >= richTimeReal);
	if (areRichTime && note.mustPress)
		note.gfNote = true;
	note.noteSplashDisabled = !note.mustPress;
	if (note.gfNote || note.noteType.indexOf("GF") != -1)
	{
		// note.parentStrum = gfStrums.members[note.noteDataReal];
		gfStrumLine.addNote(note);
		for (i in note.tail)
		{
			gfStrumLine.addNote(i);
			i.gfNote = note.gfNote;
			i.noteSplashDisabled = note.noteSplashDisabled;
		}
		return "pisiii";
	}
}

var richTimeReal = 79000;
var richTime = false;
function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "":
			switch (value1)
			{
				case "пов - через 5 часов выпускной":
					for (strummy in opponentStrums.members)
						FlxTween.tween(strummy, {x: strummy.x - FlxG.width / 2, angle: -360, alpha: 0, "scale.x": 0.5, "scale.y": 0.5}, 5, {ease:FlxEase.backInOut});

				case "sleepybox" | "WAKEY WAKEY":
					redarStrumsSleepToo(value1 == "sleepybox");

				case "Alt Idle":
					var beat = 2;
					var suffix = "";
					if (value2.toLowerCase().trim() == "true")
					{
						beat = 1;
						suffix = "-alt";
					}
					setCharIdleSuffix(dad, suffix, beat);
					setCharIdleSuffix(boyfriend, suffix, beat);
					setCharIdleSuffix(gf, suffix, beat);
					setCharIdleSuffix(hopka, suffix, beat);

				case "Rich Time": // богатое время
					richTime = true;
					boyfriend.hasMissAnimations = false;
					playerCharacters = [gf];
					iconRich.isPlayer = true;
					iconRich.flipX = !iconRich.flipX;
					iconRich.y = iconP1.y;
					updateHealthIcons();
					onChangeFocusChar(gf);

					for (strum in playerStrums.members)
						strum.playAnim("static");

					var fromScale = gfStrums.scaleNoteFactor;
					var toScale = 1.0; // playerStrums.scaleNoteFactor
					var fromAlpha = gfStrums.members[0].alpha;
					var toAlpha = 1; // playerStrums.members[0].alpha;
					var gfPos = {from: gfStrums.position.x, to: gfStrums.position.x - 107.0};
					// var playerPos = {from: playerStrums.position.x, to: playerStrums.position.x - 60.0};
					if (middleScrollMode)
					{
						gfPos.from = gfStrums.position.x;
						gfPos.to = playerStrums.position.x;
						// playerPos.from = playerStrums.position.x;
						// playerPos.to = gfStrums.position.x;
						toScale = playerScaleNotes;
					}

					var time = Conductor.stepCrochet / 1000.0 * 3.5;
					FlxTween.num(0.0, 1.0, time, {ease: FlxEase.backOut}, i ->
					{
						gfStrums.scaleNoteFactor = FlxMath.lerp(fromScale, toScale, i);
						gfStrums.position.x = FlxMath.lerp(gfPos.from, gfPos.to, i);
						gfStrums.updateStrumsPos(null, null, true, false);
						for (strum in gfStrums.members)
							strum.alpha = FlxMath.lerp(fromAlpha, toAlpha, i);

						// playerStrums.scaleNoteFactor = FlxMath.lerp(toScale, fromScale, i);
						// playerStrums.position.x = FlxMath.lerp(playerPos.from, playerPos.to, i);
						// playerStrums.updateStrumsPos(null, null, true, false);
						var a = FlxMath.lerp(fromAlpha, toAlpha, i);
						for (strum in playerStrums.members)
						{
							// strum.alpha = a;
							strum.color = FlxColor.fromRGBFloat(a, a, a, 1.0);
						}
					});

					if (!middleScrollMode)
					{
						var fromX = opponentStrums.position.x;
						var toX = opponentStrums.position.x + 127.0;
						var fromScale = opponentStrums.scaleNoteFactor;
						var toScale = 1.0; // playerStrums.scaleNoteFactor
						var fromAlpha = opponentStrums.members[0].alpha;
						var toAlpha = 1; // привет дед макар playerStrums.members[0].alpha; // FlxMath.lerp(fromAlpha, playerStrums.members[0].alpha, 0.5)
						FlxTween.num(0.0, 1.0, time, {/*startDelay: 1.0,*/ ease: FlxEase.quadInOut}, i ->
						{
							opponentStrums.scaleNoteFactor = FlxMath.lerp(fromScale, toScale, i);
							opponentStrums.position.x = FlxMath.lerp(fromX, toX, i);
							opponentStrums.updateStrumsPos(null, null, true, false);
							for (strum in opponentStrums.members)
								strum.alpha = FlxMath.lerp(fromAlpha, toAlpha, i);
						});
					}

					var delay = (middleScrollMode ? time * 1.25 : time / 2.0);
					for (strum in playerStrums.members)
					{
						FlxTween.cancelTweensOf(strum);
						strum.moves = true;
						strum.acceleration.y = FlxG.random.float(540.0, 840.0);
						strum.velocity.x -= FlxG.random.float(2.0, 20.0);
						if (strum.noteData == 0 || strum.noteData == 3)
							strum.velocity.x *= 2.0;
						if (strum.noteData > 1)
							strum.velocity.x = -strum.velocity.x;
						strum.angularVelocity = strum.velocity.x * 2.0;

						if (middleScrollMode)
							strum.velocity.y -= FlxG.random.float(145.0, 185.0);
						else
							strum.velocity.x -= 100.0;

						FlxTween.num(strum.alpha, 0.0, FlxG.random.float(time / 1.25, time * 1.25),
							{startDelay: FlxG.random.float(delay / 1.25, delay * 1.25), onComplete: _ -> strum.kill()}, strum.set_alpha);
					}
					// playerStrumLine.kill();
					// playerStrumLine.exists = playerStrumLine.alive = false;
					tempPlayerStrums = playerStrumLine;
					tempPlayerStrumLine = playerStrums;
					playerStrumLine.isPlayer = playerStrumLine.allowMisses = false;
					gfStrumLine.isPlayer = gfStrumLine.allowMisses = true;
					gfStrumLine.cpuControlled = playerStrumLine.cpuControlled;
					playerStrums = gfStrums;
					playerStrumLine = gfStrumLine;

					// GameOverSubstate.applyFromCharacter(gf);
					gopro(gf);
			}
	}
}

function onGameOver()
{
	if (!richTime)
		return;

	function moveToGroup(char:Character, from:FlxSpriteGroup, to:FlxSpriteGroup)
	{
		from.remove(char);
		char.x += from.x;
		char.y += from.y;
		to.add(char);
		char.x -= to.x;
		char.y -= to.y;
	}

	moveToGroup(gf, gfGroup, boyfriendGroup);
	moveToGroup(boyfriend, boyfriendGroup, gfGroup);

	var temp = gf;
	gf = boyfriend;
	boyfriend = temp;
}

function onGameOverStart()
{
	if (richTime)
	{
		GameOverSubstate.instance.camFollowPos.x -= 440;
	}
	else
	{
		// kasjdklasjkj
	}
	defaultCamZoom = 0.7;
}

function setCharIdleSuffix(char:Character, suffix:String, beat:Int)
{
	@:bypassAccessor char.idleSuffix = suffix;
	char.recalculateDanceIdle();
	char.danceEveryNumBeats = beat;
}

var lastTarget = null;
function onUpdatePost(elapsed:Float)
{
	if (lastTarget == _camTarget)
		return;

	// trace('target: $_camTarget');
	onChangeFocusChar(switch (_camTarget)
	{
		case "dad" | "opponent" | "dc": dad;
		case "gf" | "girlfriend" | "gc": gf;
		case "bf" | "boyfriend": boyfriend;
		case "hopka" | "норка": hopka;
		default: null;
	});
	lastTarget = _camTarget;
}

var _leTweene:FlxTween;
var _leTweenePlayer:FlxTween;
var healthBar = getVar("healthBar");
function onChangeFocusChar(char:Character)
{
	// редар амимир так что никакой ему больше иконки
	if (char == null || (richTime && char == boyfriend))
		return;

	var isPlayer = (char.isPlayer || (richTime && char == gf));
	var newIcon = iconsMap.get(char.healthIcon);
	if (newIcon == null)
		return;

	if (_leTweene != null)
		_leTweene.finish();
	if (_leTweenePlayer != null)
		_leTweenePlayer.finish();

	var oldIcon = (isPlayer ? iconP1 : iconP2);
	if (oldIcon == newIcon || oldIcon.isPlayer != newIcon.isPlayer)
		return;

	#if DEV_BUILD
	trace(newIcon.char);
	#end
	var targetYOld = oldIcon.iconOffsets[1];
	var targetYNew = newIcon.iconOffsets[1];
	var isRight = (isPlayer != healthBar.leftToRight);
	var oldColorBar = (isRight ? healthBar.rightBar : healthBar.leftBar).color;
	var colorHealthBar = (isRight ? i -> colorRight(oldColorBar, char.healthColor, i) : i -> colorLeft(oldColorBar, char.healthColor, i));

	var offsetY = 90.0;
	var tween = FlxTween.num(0.0, 1.0, Conductor.crochet * 0.0039, {ease:FlxEase.elasticOut, onComplete: _ -> {
		if (isPlayer)
		{
			iconP1 = newIcon;
			_leTweenePlayer = null;
		}
		else
		{
			iconP2 = newIcon;
			_leTweene = null;
		}
		oldIcon.iconOffsets[1] = targetYOld;
		oldIcon.set_alpha(0.0);
		newIcon.iconOffsets[1] = targetYNew;
		newIcon.set_alpha(1.0);
		colorHealthBar(1.0);
	}}, i -> {
		var invert = (1.0 - i);
		oldIcon.iconOffsets[1] = targetYOld + offsetY * i;
		oldIcon.set_alpha(invert);
		newIcon.iconOffsets[1] = targetYNew - offsetY * invert;
		newIcon.set_alpha(i);
		colorHealthBar(FlxMath.bound(i, 0.0, 1.0));
	});

	if (isPlayer)
		_leTweenePlayer = tween;
	else
		_leTweene = tween;
}

function colorLeft(from:FlxColor, to:FlxColor, i:Float) healthBar.leftBar.color = FlxColor.interpolate(from, to, i);
function colorRight(from:FlxColor, to:FlxColor, i:Float) healthBar.rightBar.color = FlxColor.interpolate(from, to, i);

function redarStrumsSleepToo(toSleep:Bool = true)
{
	if (toSleep)
		for (strummy in playerStrums.members)
			FlxTween.tween(strummy, {y: strummy.y + FlxG.random.float(95, 105), angle: FlxG.random.float(-16, 16), alpha: .5}, 9, {ease:FlxEase.sineIn, startDelay: FlxG.random.float(.0, .25)});
	else
		for (i => strummy in playerStrums.members)
			FlxTween.tween(strummy, {y: playerStrums.position.y, angle: 0, alpha: 1}, .4, {ease:FlxEase.backOut, startDelay: FlxG.random.float(0, .1)});
}