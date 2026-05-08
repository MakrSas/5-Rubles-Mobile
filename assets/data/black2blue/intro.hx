static var fail = false;

function killMarm()
{
	@:bypassAccessor gf.idleSuffix = "-scared";
	gf.dance(true);
	vocalsDAD.destroy();
	iconP2.visible = false;

	for (event in eventNotes)
	{
		if (event[1] == "Play Animation" && event[3] == "dad")
			eventNotes.remove(event);
	}

	function disableNote(note:Note)
		note.ignoreNote = true;

	for (note in opponentStrumLine.spawnedNotes)
		disableNote(note);
	for (note in opponentStrumLine.unspawnNotes)
		disableNote(note);
}

// TODO: раскоментировать на v2.0
var skipCutscene = /*!PlayState.isStoryMode ||*/ PlayState.seenCutscene || PlayState.chartingMode;
// дебагинг
// skipCutscene = false;
if (skipCutscene)
{
	function onCreatePost()
	{
		if (fail)
		{
			dad.skipDance = true;
			dad.playAnim("bfmix_intro_fail");
			dad.anim.finish();
			killMarm();
		}
		// dispose();
	}
}
else
{
	// import game.backend.utils.FlxObjectTools;
	import game.mobile.utils.TouchUtil;
	importHScriptClasses("scripts/classes/SkipPrompt.hx");

	var fgBop:BGSprite;
	var redar:BGSprite;
	var music:FlxSound;
	var sound:FlxSound;
	var skipText:SkipPrompt;
	var playCutscene = true;

	// var censor:FlxSprite;

	var cutsceneTimer = 0;
	var cutsceneEvents:Array<{time:Float, callback:() -> Void}> = [];

	function addCutsceneEvent(frame:Float, func:()->Void)
	{
		cutsceneEvents.push({time: frame / 24, callback: func});
	}

	function onCreate()
	{
		fail = FlxG.random.bool(7);

		fgBop = getVar("fgBop");
		redar = getVar("redar");
		music = FlxG.sound.load(Paths.music("cutscenes/b2b/music" + (fail ? "_fail" : "")), 1, false, null, true);
		sound = FlxG.sound.load(Paths.sound("cutscenes/b2b/audio" + (fail ? "_fail" : "")), 1, false, null, true);

		skipText = new SkipPrompt(
			() -> controls.ANY || TouchUtil.justPressed,
			() -> controls.ACCEPT || FlxG.keys.justPressed.Z || TouchUtil.justPressed,
			() ->
			{
				FlxG.timeScale = 4 * playbackRate;
				music.pitch = music.pitch;
				sound.pitch = sound.pitch;
			}
		);
		skipText.camera = camOther;
		add(skipText);

		// add(censor = FlxObjectTools.makeSolid(new FlxSprite(-220, 360), 500, 460, FlxColor.BLACK));
		canPause = false;
		startedCountdown = true;

		// начало катсцены
		addCutsceneEvent(0, () ->
		{
			FlxG.camera._fxFadeAlpha = 1;
			FlxG.camera._fxFadeColor = FlxColor.BLACK;
			camFollowPos.setPosition(camFollow.x, camFollow.y);
			FlxG.camera.snapToTarget();
			camHUD.alpha = 0;
			camControls.alpha = 0;
			updateCameraPosition = false;

			dad.playAnim("bfmix_intro" + (fail ? "_fail" : ""));
			dad.pauseAnimation();
			dad.skipDance = true;
			boyfriend.animation.finish();

			fgBop?.alpha = FlxMath.EPSILON;
			redar?.alpha = FlxMath.EPSILON;
		});
		// РЕАЛЬНОЕ начало катсцены
		addCutsceneEvent(1, () ->
		{
			FlxG.camera.fade(FlxColor.BLACK, 3.8, true);
			FlxG.camera.zoom = defaultCamZoom + 0.55;
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.3}, 4.2, {ease: FlxEase.smoothStepInOut});
			music.play();
			sound.play();
		});
		// перевод камеры на марма
		addCutsceneEvent(30, () ->
		{
			setCharCamOffset("dad", true);
			FlxTween.tween(camFollowPos, {x: camFollow.x, y: camFollow.y}, 2, {ease: FlxEase.quadInOut});
		});
		// проигрывание анимации
		addCutsceneEvent(41, () -> dad.resumeAnimation());

		if (fail)
		{
			// АХУЕТЬ ЧТО С НИМ
			addCutsceneEvent(75, () ->
			{
				FlxTween.cancelTweensOf(FlxG.camera);
				FlxTween.cancelTweensOf(camFollowPos);
				var ease = CoolUtil.easeCombine([FlxEase.quartIn, FlxEase.elasticOut]);
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.15}, 0.6, {ease: ease});
				FlxTween.tween(camFollowPos, {x: camFollowPos.x - 280, y: camFollowPos.y + 260}, 0.55, {ease: ease});
			});
			// причина тряски?
			addCutsceneEvent(83, () ->
			{
				FlxG.camera.shake(0.01, 3 / 24); // , null, true, 0x01
				killMarm();
			});
			// песни не будет :(
			addCutsceneEvent(191, () ->
			{
				// clearNotesBefore(inst.length);
				// eventNotes.resize(0);
				// finishSong(true);
			});
		}
		else
		{
			// зум на марма когда он начал доставать микро
			addCutsceneEvent(138, () ->
			{
				// FlxTween.num(censor.alpha, 0, 0.5, null, censor.set_alpha);
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.075}, 1.6, {ease: FlxEase.smoothStepInOut});
				FlxTween.tween(camFollowPos, {x: camFollowPos.x - 135, y: camFollowPos.y - 15}, 1.4, {ease: FlxEase.quadInOut});
			});
			// фнф айдол
			addCutsceneEvent(189, () ->
			{
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.05}, 0.8, {ease: FlxEase.elasticOut});
				FlxTween.tween(camFollowPos, {x: camFollowPos.x - 35, y: camFollowPos.y + 20}, 1, {ease: FlxEase.elasticOut});
			});
			addCutsceneEvent(214 + 1, () -> dad.skipDance = false);
		}

		// концовка
		addCutsceneEvent(215, () ->
		{
			skipText.disable();
			FlxG.timeScale = playbackRate;
			music.pitch = music.pitch;
			sound.pitch = sound.pitch;

			paused = false;
			canPause = true;
			PlayState.seenCutscene = true;
			startedCountdown = false;
			startCountdown();
			moveCameraSection();

			var crochetSec = Conductor.crochet / 1000;
			for (cam in [camHUD, camControls])
				FlxTween.num(cam.alpha, 1, crochetSec * 2.5, null, cam.set_alpha);
			FlxTween.num(FlxG.camera.zoom, defaultCamZoom, crochetSec * 5, {ease: FlxEase.sineInOut}, FlxG.camera.set_zoom);
			FlxTween.tween(camFollowPos, {x: camFollow.x, y: camFollow.y}, crochetSec * 4.5,
				{ease: FlxEase.quadInOut, onComplete: _ -> updateCameraPosition = true});

			FlxTween.num(fgBop?.alpha, 1, crochetSec * 2.5, {startDelay: crochetSec / 2, ease: FlxEase.quadIn}, fgBop?.set_alpha);
			FlxTween.num(redar?.alpha, 1, crochetSec * 2.5, {startDelay: crochetSec / 2, ease: FlxEase.quadIn}, redar?.set_alpha);
		});
	}

	function onStartCountdown()
	{
		if (playCutscene)
		{
			paused = true;
			inCutscene = true;
			playCutscene = false;
			startedCountdown = false;
			return Function_Stop;
		}
		// dispose();
	}

	function onUpdatePost(elapsed:Float)
	{
		if (cutsceneEvents.length != 0)
		{
			cutsceneTimer += elapsed;
			while (cutsceneEvents[0] != null && cutsceneEvents[0].time <= cutsceneTimer)
				cutsceneEvents.shift().callback();
		}
	}
}

function goodNoteHit(note:Note, strumLine:StrumLine)
{
	camZooming = true;
	dispose();
}