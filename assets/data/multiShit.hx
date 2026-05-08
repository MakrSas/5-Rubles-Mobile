import game.backend.system.song.Conductor;
import game.objects.game.notes.StrumLine;
import game.objects.game.notes.StrumGroup;
import game.objects.game.notes.Note;
import game.backend.utils.Highscore;

// defines
var BF = "bf";
var DAD = "dad";
var GF = "gf";

var playerScaleNotes:Float = 0.9; // 0.925
var opponentsScaleNotes:Float = 0.7; // playerScaleNotes * 0.8 = 0.85 * 0.8 // 0.775
var opponentsAlphaNotes:Float = 0.65;

var curSong = Highscore.formatSong(PlayState.SONG.song, "");
var playbleChar:String = switch (curSong)
{
	case "bezdarinaisonjimix":	DAD;
	case "bezdariamalgamatmix":	GF;
	default:					BF;
};

middleScrollMode |= playbleChar == GF;
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
	add(gfStrumLine);
}
function onCountdownStarted()
{
	var targetAlpha:Float = opponentsAlphaNotes;
	// if (middleScrollMode)
	//	targetAlpha *= 0.35;
	// if (!ClientPrefs.opponentStrums)
	//	targetAlpha = 0;
	var spawnFuck = null;
	if (!PlayState.isStoryMode && !skipArrowStartTween)
	{
		spawnFuck = _animateIntroStrumNote.bind(gfStrums, targetAlpha, _, _);
	}
	for (strum in gfStrums.generateStrums(["left", "down", "up", "right"], {
		downScroll: ClientPrefs.downScroll,
		funcIn: spawnFuck
	}))
	{
		strumLineNotes.add(strum);
		strum.playAnim("static");
	}

	changePosition(playbleChar);

	gfStrums.scaleNoteFactor = opponentsScaleNotes;
	opponentStrums.scaleNoteFactor = opponentsScaleNotes;
	playerStrums.scaleNoteFactor = playerScaleNotes;
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

public function changePosition(playableChar:String, update = false)
{
	gfStrums.position.x = FlxG.width / 2;
	if (middleScrollMode || playableChar == GF)
	{
		var offset = FlxG.width / 3;
		playerStrums.position.x = opponentStrums.position.x = gfStrums.position.x;
		gfStrums.position.x += offset;
		opponentStrums.position.x -= offset;
	}
	else
	{
		var deafultOpponentPos = FlxG.width / 4;
		var deafultPlayerPos = deafultOpponentPos * 3;
		if (playbleChar == DAD)
		{
			var offset = FlxG.width / 1.9;
			var offset2 = 50;
			var offset3 = 15;
			playerStrums.position.x = deafultPlayerPos - offset + offset3;
			opponentStrums.position.x = deafultOpponentPos + offset + offset2 + offset3;
			gfStrums.position.x += offset2 + offset3;
		}
		else
		{
			playerStrums.position.x = deafultPlayerPos;
			opponentStrums.position.x = deafultOpponentPos - 100;
			gfStrums.position.x -= 80;
		}
	}


	if (update)
	{
		gfStrums.updateStrumsPos(null, null, true, false);
		opponentStrums.updateStrumsPos(null, null, true, false);
		playerStrums.updateStrumsPos(null, null, true, false);
	}
}

function onCreateNote(note:Note)
{
	// if ((Conductor.songPosition - note.strumTime) > noteKillOffset)
	// 	return;

	var charData:String;
	switch (playbleChar)
	{
		case GF:
			charData = (note.noteType.indexOf("BFNote") == -1) ? DAD : GF;
			if (note.mustPress && charData != GF)
				note.gfNote = true;
			if (note.gfNote)
				charData = BF;

		default:
			charData = note.gfNote || (note.noteType.indexOf("GF") != -1) ? GF : note.mustPress ? BF : DAD;
	}
	note.mustPress = charData == BF;
	note.noteSplashDisabled = !note.mustPress;
	// trace(charData, note.noteType);
	if (charData == GF)
	{
		gfStrumLine.addNote(note);
		gfStrumLine.addNotes(note.tail);
		return "pisi";
	}
	return null;
}

var healthBar = getVar("healthBar");
final isGFPlayer = (playbleChar == GF);
var iconsMap:Map<String, HealthIcon> = [];
function pushIcon(icon) {
	iconsMap.set(icon.char, icon);
}

function onCreatePost()
{
	pushIcon(iconP1);
	pushIcon(iconP2);

	var iconHealthGF = new HealthIcon(gf.healthIcon, isGFPlayer);
	iconHealthGF.y = iconP2.y;
	iconsGroup.add(iconHealthGF);
	iconHealthGF.alpha = isGFPlayer ? 1 : 0;
	pushIcon(iconHealthGF);
	iconHealthGF.flipX = healthBar.flipped;

	if (isGFPlayer)
	{
		iconP1.isPlayer = !iconP1.isPlayer;
		iconP1.flipX = !iconP1.flipX;
		iconP1.changeIcon(boyfriend.healthIcon);
		onChangeFocusChar(boyfriend, true);
		(healthBar.flipped ? healthBar.leftBar : healthBar.rightBar).color = gf.healthColor;
	}

	lastTarget = _camTarget;
}

var lastTarget = null;
var _leTweene:FlxTween;

function onUpdatePost(elapsed:Float)
{
	if (lastTarget == _camTarget)
		return;

	var char = switch (_camTarget)
	{
		case "dad" | "opponent":	dad;
		case "gf" | "girlfriend":	gf;
		default:					boyfriend;
	};
	if (isGFPlayer ? char != gf : !char.isPlayer)
		onChangeFocusChar(char, false);
	lastTarget = _camTarget;
}

function onChangeFocusChar(char:Character, snap:Bool = false)
{
	if (char == null)
		return;

	var newIcon = iconsMap.get(char.healthIcon);
	if (newIcon == null)
		return;

	if (_leTweene != null)
		_leTweene.finish(); // cancel

	var oldIcon = iconP2;
	if (oldIcon == newIcon)
		return;

	var targetYOld = oldIcon.iconOffsets[1];
	var targetYNew = newIcon.iconOffsets[1];
	var oldColorBar = (healthBar.flipped ? healthBar.rightBar : healthBar.leftBar).color;
	var offsetY = 90;
	if (char == (isGFPlayer ? boyfriend : gf))
		offsetY = -offsetY;
	var colorHealthBar = i -> {
		(healthBar.flipped ? healthBar.rightBar : healthBar.leftBar).color = FlxColor.interpolate(oldColorBar, char.healthColor, i);
	};
	_leTweene = FlxTween.num(0, 1, 0.4, {ease:FlxEase.backOut, onComplete: _ -> {
		iconP2 = newIcon;
		oldIcon.iconOffsets[1] = targetYOld;
		oldIcon.set_alpha(0);
		newIcon.iconOffsets[1] = targetYNew;
		newIcon.set_alpha(1);
		_leTweene = null;
		colorHealthBar(1);
	}}, i -> {
		var invert = (1 - i);
		oldIcon.iconOffsets[1] = targetYOld + offsetY * i;
		oldIcon.set_alpha(invert);
		newIcon.iconOffsets[1] = targetYNew - offsetY * invert;
		newIcon.set_alpha(i);
		colorHealthBar(FlxMath.bound(i, 0, 1));
	});
	if (snap)
		_leTweene.finish();
}
