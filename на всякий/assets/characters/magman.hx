if (isPlayer)
{
	var baseSprScale:Float;
	var spr:FlxSprite;
	var multAlpha:Float = 1;
	var alphaSecret:Float = -10;
	var marioLol = FlxG.random.bool(10);

	// грязный фикс центра (втфффф)
	origin.set(width / 10, height / 20);
	// trace(origin, width, height);

	if (marioLol)
	{
		// GameOverSubstate.deathSoundName = "morudead-OLD";
		this.gameoverProperties[2] = "morudead-OLD";
	}

	var prevZoom = 0;
	function onUpdatePost(elapsed:Float)
	{
		if (spr != null && GameOverSubstate.instance.startedDeath)
		{
			alphaSecret = Math.min(alphaSecret + elapsed / 20 * multAlpha, 1);
			spr.alpha = alphaSecret;
			if (prevZoom != FlxG.camera.zoom)
			{
				final s = baseSprScale / FlxG.camera.zoom;
				spr.scale.set(s, s);
				prevZoom = FlxG.camera.zoom;
			}

		}
	}

	function onGameOverConfirm(restart:Bool)
	{
		if (restart)
		{
			multAlpha = -40;
			GameOverSubstate.instance.camFollowPos.y += 40;
		}
	}

	function onGameOverStart()
	{
		spr = new FlxSprite(0, 0, Paths.image("hernya_market/bilo"));
		// spr.cameras = [game.camOther];
		spr.scrollFactor.set();
		spr.setGraphicSize(0, FlxG.height);
		spr.updateHitbox();
		baseSprScale = spr.scale.x * 1.05;
		spr.alpha = 0;
		GameOverSubstate.instance.add(spr.screenCenter());

		GameOverSubstate.instance.allowSkip = false;
		GameOverSubstate.instance.moveCamera = true;
		var bfCamPos = getCameraPosition();
		GameOverSubstate.instance.camFollowPos.x = bfCamPos.x + 400; // 150
		GameOverSubstate.instance.camFollowPos.y = bfCamPos.y + 160; // 70
		GameOverSubstate.instance.cameraSpeed = 4;
		game.defaultCamZoom = 0.6;

		playAnim("hoppa");
		stunned = skipDance = true;
		holdTimer = 0;

		acceleration.y = 4000;
		velocity.y = -1500;

		angularVelocity = FlxG.random.int(30, 60) * FlxG.random.int(-1, 1, [0]) / 4;
		angularAcceleration = angularVelocity;

		acceleration.x = angularAcceleration * 8;
		velocity.x = angularVelocity * 4;
		moves = false;

		new FlxTimer().start(0.4, _ ->
		{
			moves = true;
			if (marioLol)
			{
				velocity.x *= 5;
				FlxG.sound.play(Paths.sound("umer"), 0.5);
				new FlxTimer().start(2.4, _ -> FlxG.resetState());
			}
			else
			{
				new FlxTimer().start(0.81, _ ->
				{
					GameOverSubstate.instance.cameraSpeed = 1.25;
					GameOverSubstate.instance.camFollowPos.y += 80;
					GameOverSubstate.instance.allowSkip = true;
					playAnim("death");
					angularVelocity = 0;
					angularAcceleration = 0;
					acceleration.set();
					velocity.set(60 * FlxMath.signOf(velocity.x));
					drag.x = 240;
					angle = 0;
					scale.set(FlxG.random.float(1.05, 1.075), FlxG.random.float(0.925, 0.95));
					FlxTween.tween(this, {"scale.x": 1, "scale.y": 1}, 0.1, {ease: FlxEase.quadOut});
					new FlxTimer().start(0.85, _ ->
					{
						GameOverSubstate.instance.startedDeath = true;
						if (!GameOverSubstate.instance.isEnding)
						{
							var loopSoundName = GameOverSubstate.loopSoundName;
							if (loopSoundName != null && StringTools.trim(loopSoundName).length != 0)
								FlxG.sound.playMusic(Paths.music(loopSoundName), GameOverSubstate.instance.volume);
						}
					});
				});
			}
		});
	}
}
else
	dispose();
