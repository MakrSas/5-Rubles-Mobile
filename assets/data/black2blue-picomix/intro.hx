static var fail = false;

function killMarm()
{
	@:bypassAccessor gf.idleSuffix = "-scared";
	gf.alive = false;
	gf.dance(true);
	vocalsDAD.destroy();
	iconP2.visible = false;

	var trx = getVar("trx");
	trx.animation.play("тая СМЕРТЬ");
	trx.alive = false;

	for (event in eventNotes)
	{
		if ((event[1] == "Play Animation" && event[3] == "dad") || (event[1] == "Alt Idle Animation"))
			eventNotes.remove(event);
	}

	function disableNote(note:Note)
		note.ignoreNote = true;

	for (note in opponentStrumLine.spawnedNotes)
		disableNote(note);
	for (note in opponentStrumLine.unspawnNotes)
		disableNote(note);
}

var skipCutscene = PlayState.seenCutscene || PlayState.chartingMode;
// дебагинг
// skipCutscene = false;
if (skipCutscene)
{
	function onCreatePost()
	{
		if (fail)
		{
			dad.skipDance = true;
			dad.playAnim("picomix_intro_fail");
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

		music = FlxG.sound.load(Paths.music("cutscenes/b2b/" + (fail ? "pico_music_fail" : "music")), 1, false, null, true);
		sound = FlxG.sound.load(Paths.sound("cutscenes/b2b/pico_audio" + (fail ? "_fail" : "")), 1, false, null, true);

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
			setCharCamOffset("dad", true);
			camFollowPos.setPosition(camFollow.x, camFollow.y);
			FlxG.camera.snapToTarget();
			camHUD.alpha = 0;
			camControls.alpha = 0;
			updateCameraPosition = false;

			dad.playAnim("picomix_intro" + (fail ? "_fail" : ""));
			dad.pauseAnimation();
			dad.skipDance = true;
			boyfriend.animation.finish();
		});
		// РЕАЛЬНОЕ начало катсцены
		addCutsceneEvent(1, () ->
		{
			FlxG.camera.fade(FlxColor.BLACK, 3.8, true);
			FlxG.camera.zoom = defaultCamZoom + 0.75;
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.2}, 2.2, {ease: FlxEase.smoothStepInOut});
			camFollowPos.x -= 380;
			camFollowPos.y += 60;
			FlxTween.tween(camFollowPos, {x: camFollowPos.x + 60, y: camFollowPos.y - 20}, 2.4, {ease: FlxEase.smoothStepInOut});
			music.play();
			sound.play();
			dad.resumeAnimation();
		});
		// пушка звук
		addCutsceneEvent(70, () ->
		{
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.03}, 0.8, {ease: FlxEase.elasticOut});
			FlxTween.tween(camFollowPos, {x: camFollowPos.x + 25, y: camFollowPos.y - 5}, 0.2, {ease: FlxEase.cubeOut});
		});
		// привет пицо 5 рублейл!!
		addCutsceneEvent(86, () ->
		{
			setCharCamOffset("boyfriend", true);
			var ease = CoolUtil.easeCombine([FlxEase.quartIn, FlxEase.backOut]);
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.12}, 0.6, {ease: ease});
			FlxTween.tween(camFollowPos, {x: camFollow.x + 60, y: camFollow.y + 60}, 0.75, {ease: ease});
		});
		// фак ю
		addCutsceneEvent(110, () ->
		{
			boyfriend.playAnim("hey");
			boyfriend.specialAnim = true;
			boyfriend.heyTimer = 1.2;
		});
		// обратно на марма, в шоках уже
		addCutsceneEvent(130, () ->
		{
			setCharCamOffset("dad", true);
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.11}, 0.75, {ease: FlxEase.cubeInOut});
			FlxTween.tween(camFollowPos, {x: camFollow.x - 160, y: camFollow.y - 40}, 0.85, {ease: FlxEase.cubeInOut});
		});
		// непонимание
		addCutsceneEvent(175, () ->
		{
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.06}, 0.6, {ease: FlxEase.quadInOut});
			FlxTween.tween(camFollowPos, {x: camFollowPos.x - 30, y: camFollowPos.y + 30}, 0.65, {ease: FlxEase.quadInOut});
		});
		// фнф айдол
		addCutsceneEvent(202, () ->
		{
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.05}, 0.8, {ease: FlxEase.elasticOut});
			FlxTween.tween(camFollowPos, {x: camFollowPos.x - 35, y: camFollowPos.y + 20}, 1, {ease: FlxEase.elasticOut});
		});

		if (fail)
		{
			// ВАТАФАК
			addCutsceneEvent(210, () ->
			{
				FlxTween.cancelTweensOf(FlxG.camera);
				FlxTween.cancelTweensOf(camFollowPos);
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.2}, 0.75, {ease: FlxEase.elasticOut});
				FlxTween.tween(camFollowPos, {x: camFollowPos.x - 120, y: camFollowPos.y + 120}, 0.15, {
					onComplete: _ -> FlxTween.tween(camFollowPos, {x: camFollowPos.x + 20}, 0.6, {ease: FlxEase.quadOut})
				});
				FlxG.camera.shake(0.01, 3 / 24); // , null, true, 0x01
				killMarm();
				cutsceneEvents[cutsceneEvents.length - 1].time += 100 / 24;
			});
			// погибб...
			addCutsceneEvent(240, () ->
			{
				var ease = CoolUtil.easeCombine([FlxEase.quartIn, FlxEase.elasticOut]);
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.08}, 2.125, {ease: ease});
				FlxTween.tween(camFollowPos, {x: camFollowPos.x - 160, y: camFollowPos.y + 130}, 2.075, {ease: ease});
			});
		}
		else
		{
			addCutsceneEvent(214, () -> dad.skipDance = false);
		}

		// концовка
		addCutsceneEvent(214, () ->
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
			new FlxTimer().start(crochetSec, _ ->
			{
				FlxTween.num(FlxG.camera.zoom, defaultCamZoom, crochetSec * 4, {ease: FlxEase.sineInOut}, FlxG.camera.set_zoom);
				FlxTween.tween(camFollowPos, {x: camFollow.x, y: camFollow.y}, crochetSec * 3.5,
					{ease: FlxEase.quadInOut, onComplete: _ -> updateCameraPosition = true});
			});
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