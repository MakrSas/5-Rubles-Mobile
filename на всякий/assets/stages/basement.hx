import flixel.group.FlxGroup;

import game.backend.data.StructureOptionsData;
import game.objects.game.notes.Note;
import game.objects.game.BGSprite;

using StringTools;

importHScriptClasses("scripts/classes/BGStrumLine.hx");

var hopk:Character;
var hopkaStrumLine:BGStrumLine;
var hopkaStrums:StrumNotes;

var fullHDtoHD:Float = FlxG.width/1920;

var fadeList:Array<FlxSprite> = [];

var startClockTime:Float = Date.fromString("23:10:00").getTime() / 60;

var arrow:BGSprite;
var smallArrow:BGSprite;

function onCreate()
{
	camGame.bgColor = 0xFF161419;

	var temp = addHxObject(new FlxSprite(620, 280, Paths.image("basement/6cbinv.jpg")));
	temp.scale.set(2., 2.);
	temp.updateHitbox();
	temp.screenCenter();
	temp.y += 2600;
	temp.scrollFactor.set();
	temp.alpha = 0.02;
	temp.blend = 1;

	addHxObject(new BGSprite("basement/bgwa",-800, -400, 0.8, 0.8));
	var clock = addHxObject(new BGSprite("basement/clocks", 718, -269, 0.8, 0.8));
	function setupArrow(arrow:FlxSprite)
	{
		arrow.setPosition(
			clock.x + (clock.width - arrow.width) / 2,
			clock.y + clock.height / 2 - arrow.frameHeight * (arrow.scale.y + 1) / 2
		);
		arrow.origin.y = arrow.frameHeight - 2.5;
	}
	arrow = new BGSprite("basement/arrow", 832, -230, 0.8, 0.8);
	arrow.updateHitbox();
	setupArrow(arrow);
	// arrow.angle = (2 / 12) * 360;
	addHxObject(arrow);
	smallArrow = new BGSprite("basement/lesser-arrow", 832, -200, 0.8, 0.8);
	smallArrow.updateHitbox();
	setupArrow(smallArrow);
	// smallArrow.angle = (11 / 12) * 360;
	addHxObject(smallArrow);
	var clockOverlay = addHxObject(new BGSprite("basement/clocks-light", 756, -232, 0.8, 0.8));
	if (!ClientPrefs.lowQuality)
	{
		clockOverlay.blend = OVERLAY; // TODO: отрендерить блики и часы вместе
	}

	hopk = new Character(300, 50, "hopka_math");
	hopk.scrollFactor.set(0.815, 0.815);
	addHxObject(hopk);
	setVar(hopk.curCharacter + "_char", hopk);
	startCharacterLua(hopk);

	hopkaStrumLine = new BGStrumLine(0.75, () -> _camTarget == "hopka");
	hopkaStrums = hopkaStrumLine.strumNotes;
	hopkaStrumLine.spawnTime *= 1.55;
	setupStrumLine(hopkaStrumLine);


	addHxObject(new BGSprite("basement/lampi",-110 + 130, -690, 0.9, 0.9));
	var lampslight = addHxObject(new BGSprite("basement/lampi-svet",-800 + 130, -220 + 50, 0.9, 0.9));
	lampslight.alpha = .08;
	lampslight.blend = BlendMode.ADD; //УЖАС УЖАС УЖАС

	addHxObject(new BGSprite("basement/stol", -825+90, 730));
	fadeList.push(addHxObject(new BGSprite("basement/redar-mon", 450+105, 865), true));
	var fgShits = addHxObject(new BGSprite("basement/fg-shits", -950, 600, 1.1, 0.9), true);
	fgShits.zoomFactor = 1.1;
	fadeList.push(fgShits);
	//fgShits.scale.set(fullHDtoHD, fullHDtoHD);
	//fgShits.updateHitbox();

}

function onCreatePost()
{
	hopkaStrums.position.set(hopk.x + hopk.width / 1.14, hopk.y + 10);
	for (strum in hopkaStrums.generateStrums(["left", "down", "up", "right"], false)) // постоянный апскрол лол
	{
		// strumLineNotes.add(strum);
		strum.playAnim("static");
		strum.scrollFactor.set(0.9, 0.9);
		strum.visible = ClientPrefs.opponentStrums;
	}
	hopkaStrumLine.setAlpha(0);
	hopkaStrums.updateStrumsPos(null, null, true, false);
	addAheadObject(hopkaStrumLine, hopk);
	hopkaStrumLine.downScroll = false;

	var scoreGroup = getVar("scoreGroup");
	scoreGroup.x += 470;
	scoreGroup.y += 40;

	var oldDanceCharacters = danceCharacters;
	danceCharacters = beat ->
	{
		oldDanceCharacters(beat);
		danceCharacter(hopk, beat, hopk.danceEveryNumBeats);
	}

	var oldSetCharCamOffset = setCharCamOffset;
	setCharCamOffset = (char:String, moveCamera:Bool) ->
	{
		var charMidpoint:FlxPoint = oldSetCharCamOffset(char, moveCamera);
		switch (char)
		{
			case "hopka" | "норка" | "хопка":
				var point = hopk.getCameraPosition();
				// trace(char, point);
				charMidpoint.set(point.x, point.y);
				charMidpoint.x += 150;
				charMidpoint.y += 100;
		}
		if (moveCamera)
			camFollow?.set(charMidpoint.x, charMidpoint.y);

		return charMidpoint;
	}

	var oldCreateCountSprite = createCountSprite;
	createCountSprite = (name, sound) ->
	{
		var countdown = oldCreateCountSprite(name, 'matematika/$sound');
		if (countdown != null)
			countdown.camera = camOther;

		return countdown;
	}
}

var minuteDivision:Float = 360 / 60;
var hourDivision:Float = minuteDivision / 12;
// function onBeatHit(beat:Int)
// {
// 	if (beat % 2 == 0)
// 	{
// 		arrow.angle += minuteDivision;
// 		smallArrow.angle += hourDivision;
// 	}
// }

function onUpdatePost(elapsed) {
	var seconds = (startClockTime + songPercent * songLength) / 1000;
	arrow.angle = Math.floor(seconds) * minuteDivision;
	smallArrow.angle = seconds * hourDivision;
}

function hopkaNote(note:Note) // s
{
	note.animSuffix = note.noteType.endsWith("-alt") ? "-alt" : "";
	note.noAnimation = note.noMissAnimation = true;
	note.extraData.set("char", hopk);
	hopkaStrumLine.addNote(note);
}
function onCreateNote(note:Note)
{
	if (note.tail != null && note.tail.length > 0)
		for (t in note.tail)
			t.noAnimation = true;

	if (note.noteType.startsWith("HopkNote"))
	{
		hopkaNote(note);
		for (i in note.tail)
		{
			hopkaNote(i);
		}
		return "pipi";
	}
}

function opponentNoteHit(note:Note, strumLine) checkNoteOnHit(note);

function checkNoteOnHit(note:Note)
{
	var overridechar = note.extraData.get("char");
	if (overridechar == null)
		return;

	if (note.noteType.endsWith("hey"))
	{
		// работает как "Hey!" нота, но для норки
		overridechar.playAnim("hey", true);
		overridechar.specialAnim = true;
		overridechar.heyTimer = 0.6;
	}
	else
	{
		overridechar.holdTimer = 0;
		if (!note.isSustainNote)
			overridechar.sing(singAnimations[note.noteData] + note.animSuffix, !note.isSustainNote, note.nextNote != null);
	}
}

function onGameOverStart()
{
	hopkaStrumLine.forceStatus = false;
	var applyFade = getVar("gameOverApplyFade");
	for (item in fadeList)
	{
		applyFade(item);
		remove(item);
		GameOverSubstate.instance.add(item);
	}
}
