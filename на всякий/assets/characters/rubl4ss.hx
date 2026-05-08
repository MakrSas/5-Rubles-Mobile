if (isPlayer && PlayState.SONG.song.toLowerCase() != "bezdariamalgamatmix")
{
	import game.backend.system.song.Song;
	// import flixel.addons.transition.FlxTransitionableState;

	// тоилет тиви!!
	if (FlxG.random.bool(18))
	{
		// GameOverSubstate.loopSoundName = "audio_2024-06-11_00-54-29";
		this.gameoverProperties[2] = "audio_2024-06-11_00-54-29";
		getVar("gameOverConfig").cameraZooming = false;
	}

	function onGameOverStart()
	{
		GameOverSubstate.instance.camFollowPos.x -= 120;
		GameOverSubstate.instance.camFollowPos.y += 120;
		game.defaultCamZoom = 0.6;

		if (FlxG.random.bool(4)) // it is bf secret death reference?
		{
			final sang = "choki-choki";
			var a = Song.loadFromJson(sang, sang);
			if (a == null)
				return;

			GameOverSubstate.instance.allowSkip = false;
			GameOverSubstate.deathSoundName = GameOverSubstate.loopSoundName = null;
			new FlxTimer().start(1.4, _ ->
				FlxTween.tween(GameOverSubstate.instance.boyfriend, {"scale.x": GameOverSubstate.instance.boyfriend.scale.x * 3.5}, 0.5,
					{
						ease: FlxEase.cubeIn,
						onComplete: _ ->
						{
							PlayState.deathCounter = 0;
							PlayState.SONG = a;
							// FlxTransitionableState.skipNextTransOut = true;
							FlxG.resetState();
						}
					}));
		}
	}

	function onGameOverConfirm(restart:Bool)
	{
		if (restart)
		{
			new FlxTimer().start(0.5, _ ->
			{
				GameOverSubstate.instance.camFollowPos.x += 120;
				GameOverSubstate.instance.camFollowPos.y -= 120;
			});
		}
	}
}
else
	dispose();
