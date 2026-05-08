public function toggleAltDance(alt:Bool, ?customNumBeat:Null<Int>)
{
	// trace(danceEveryNumBeats, customNumBeat);
	danceIdle = alt;
	danceEveryNumBeats = customNumBeat ?? (alt ? 1 : 2);

}

function onCreatePost()
{
	toggleAltDance(false);
	dance(true);
	// устанавливает в внутри евента быстрый доступ к переключению айдла
	game.triggerEventNote("Run Haxe Code",
		"var moruToggleAltDance = scriptPack.getHScript('morunew.hx')?.getVar('toggleAltDance');",
		"", "", 0);

	if (isPlayer)
	{
		var multAlpha = 1;
		var alphaSecret = -FlxG.random.float(5, 10);
		var marioLol = FlxG.random.bool(10);

		var spr = new FlxSprite(0, 0, Paths.image("hernya_market/bilo"));
		// spr.camera = game.camOther;
		spr.scrollFactor.set();
		spr.setGraphicSize(0, FlxG.height);
		spr.updateHitbox();
		spr.alpha = 0;
		spr.screenCenter();
		var baseSprScale = spr.scale.x * 1.05;

		var ox = (Math.abs(scale.x) * frameWidth - frameWidth) / 2;
		var oy = (Math.abs(scale.y) * frameHeight - frameHeight) / 2;
		offset.x += ox;
		offset.y += oy;
		cameraPos.x += ox;
		cameraPos.y += oy;
		origin.set(-48, -8);

		if (marioLol)
		{
			// GameOverSubstate.deathSoundName = "morudead-OLD";
			this.gameoverProperties[1] = "morudead-OLD";
		}

		var prevZoom = 0;
		onUpdatePost = elapsed ->
		{
			if (GameOverSubstate.instance?.startedDeath)
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

		onGameOverConfirm = restart ->
		{
			if (restart)
			{
				multAlpha = -40;
				GameOverSubstate.instance.camFollowPos.y += 40;
			}
		}

		onGameOverStart = () ->
		{
			GameOverSubstate.instance.add(spr.screenCenter());

			GameOverSubstate.instance.allowSkip = false;
			GameOverSubstate.instance.moveCamera = true;
			var bfCamPos = getCameraPosition();
			GameOverSubstate.instance.camFollowPos.x = bfCamPos.x + 300; // 150
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
						GameOverSubstate.instance.camFollowPos.y += 100;
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
}