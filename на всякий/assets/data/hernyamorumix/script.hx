import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;

import game.backend.data.StructureOptionsData;
import game.backend.system.states.MusicBeatState;
import game.objects.improvedFlixel.FlxCustomBGSprite;
import game.objects.game.notes.Note;

loadHScript(AssetsPaths.getPath("data/iconSwap.hx"));
loadHScript(AssetsPaths.getPath("data/daddyswap.hx"));
importHScriptClasses("scripts/classes/BGStrumLine.hx");

var juzt:Character = getVar("5juztexds-flipped_char");
var _fade:FlxCustomBGSprite;
var bubu:FlxSprite;
var mic:FlxSprite;

var gfStrumLine:BGStrumLine;
var gfStrums:StrumGroup;
// var gfRegularNotes:FlxGroup;
// var gfSustainNotes:FlxGroup;

function onCreate()
{
	gfStrumLine = new BGStrumLine(0.75, () -> _camTarget == "gf" && getVar("curFocusChar") == null);
	gfStrums = gfStrumLine.strumNotes;
	setupStrumLine(gfStrumLine);
}

function onCreatePost()
{
	// var iconHealthKomp = new HealthIcon(variables.exists("komp_char") ? getVar("komp_char").healthIcon : 'face');
	var iconHealthGF = new HealthIcon(gf.healthIcon, true);
	var iconHealthJuzt = new HealthIcon(juzt?.healthIcon ?? "face");
	iconHealthGF.y = iconHealthJuzt.y = iconP2.y;
	iconsGroup.insert(0, iconHealthJuzt);
	iconHealthGF.alpha = iconHealthJuzt.alpha = 0;

	var pushIcon = getVar("pushIcon");
	pushIcon(iconHealthGF);
	pushIcon(iconHealthJuzt);

	var mixFade = 0.5;
	bubu = new FlxSprite(390, 30);
	bubu.frames = Paths.getSparrowAtlas("hernya_market/bubu");
	bubu.animation.addByPrefix("fall", "bubu-anim", 24, false);
	bubu.animation.callback = (_, n, _) ->
	{
		var mult = 1 - (mixFade * (n / (bubu.animation.curAnim.numFrames - 1)));
		bubu.setColorTransform(mult, mult, mult);
	}

	mic = new FlxSprite(-810, 250);
	mic.frames = Paths.getSparrowAtlas("hernya_market/mic");
	mic.animation.addByPrefix("fall", "micdie", 24, false);
	mic.animation.finishCallback = _ -> mic.visible = false;
	mic.setColorTransform(mixFade, mixFade, mixFade);

	addAheadObject(mic, boyfriendGroup);
	addAheadObject(bubu, boyfriendGroup);
	mic.visible = bubu.visible = false;

	// gfRegularNotes = new FlxGroup();
	// gfSustainNotes = new FlxGroup();
	gfStrumLine.spawnTime += 500;
	gfStrums.position.set(gf.x + gf.width / 2.0, gf.y - 10.0);
	gfStrums.downScroll = false;
	for (strum in gfStrums.generateStrums(["left", "down", "up", "right"], {downScroll: false})) // постоянный апскрол лол
	{
		// strumLineNotes.add(strum);
		strum.playAnim("static");
		strum.scrollFactor.set(0.9, 0.9);
		strum.visible = ClientPrefs.opponentStrums;
	}
	gfStrumLine.setAlpha(0.0);
	addAheadObject(gfStrumLine, gfGroup);
	gfStrums.updateStrumsPos(null, null, true, false);
	// addAheadObject(gfStrums, gfGroup);
	// addAheadObject(gfRegularNotes, gfStrums);
	// updateGFSustains();

	// var applyFade = getVar("gameOverApplyFade");
	// applyFade(mic);
	// applyFade(bubu);
	_fade = new FlxCustomBGSprite();
	_fade.color = FlxColor.BLACK;
	_fade.cameras = [camGame];
	camHUD.alpha = 0;
	camControls.alpha = 0;
	add(_fade);

	// StructureOptionsData.onChangePre.add(onChangeOption);
}

final halfSwagWidth = Note.swagWidth / 2;
function onCreateNote(note:Note)
{
	if (note.noteType == "GF Sing")
	{
		// note.visible = false;
		// note.useColorSwap = true; // Оптимизация лол - Redar13
		// note.colorSwap.brightness = 0.4;
		// note.multAlpha *= 0.25;
		// note.playStrum = false;
		// note.scrollFactor.set(note.parentStrum.scrollFactor.x, note.parentStrum.scrollFactor.y);

		// if (note.isSustainNote)
		// {
		// 	sustainNotes.remove(note, true);
		// 	gfSustainNotes.insert(0, note);
		// 	if (ClientPrefs.downScroll)
		// 	{
		// 		note.flipY = false;
		// 		note.correctionOffset = halfSwagWidth;
		// 	}
		// }
		gfStrumLine.addNote(note);
		gfStrumLine.addNotes(note.tail);
		return "pisi";
	}
}

// function onChangeOption(data)
// {
// 	if (data.variableName == "strumsNotesOverlap")
// 	{
// 		remove(gfSustainNotes);
// 		updateGFSustains();
// 	}
// }

function clearPressedNotes(customNoteGroup:FlxGroup)
{
	for (note in customNoteGroup.members)
	{
		if (note != null && !note.alive)
		{
			customNoteGroup.remove(note, true);
		}
	}
}

function opponentNoteHit(note:Note)
{
	// ноты скарлера дают небольшой хелф геин
	if (note.noteType == "GF Sing")
		health += note.hitHealth * healthGain * 0.4;
}

var introTween:FlxTween;
var doneIntro = false;
function onSongStart()
{
	if (doneIntro)
		return;

	isCameraOnForcedPos = true;
	snapCamFollowToPos(980.0, 180.0);
	new FlxTimer().start(0.3, _ ->
	{
		var crochetSec = Conductor.crochet / 1000.0;
		var ease = t -> 1.0 - Math.pow(1.0 - t, 1.5);
		introTween = FlxTween.num(1.0, 0.0, crochetSec * 28, {ease: ease, onComplete: _ -> _fade.kill()}, _fade.set_alpha);
		if (!isDead)
			FlxTween.num(defaultCamZoom + 0.3, defaultCamZoom, crochetSec * 29, {ease: ease}, z -> camGame.zoom = defaultCamZoom = z);
	});
	doneIntro = true;
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "Play Animation":
			if (value1 == "fnafReaction" && value2 == "dad")
			{
				mic.visible = bubu.visible = true;
				bubu.animation.play("fall");
				mic.animation.play("fall");
			}

		case "":
			if (value1 == "show_hud")
			{
				//isCameraOnForcedPos = false;
				for (cam in [camHUD, camControls])
					FlxTween.num(0.0, 1.0, 0.08, null, cam.set_alpha);
				moveCameraSection();
			}
	}
}

function onGameOverStart()
{
	remove(_fade);
	GameOverSubstate.instance.add(_fade);
	onSongStart();
	if (introTween != null)
	{
		introTween.manager._tweens.remove(introTween);
		FlxTween.globalManager._tweens.push(introTween);
		introTween.manager = FlxTween.globalManager;
	}
	gfStrumLine.forceStatus = false;
}

// function onDestroy()
// {
// 	StructureOptionsData.onChangePre.remove(onChangeOption);
// }