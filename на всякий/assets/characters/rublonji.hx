if (isPlayer && PlayState.SONG.song.toLowerCase() != "bezdariamalgamatmix")
{
	import game.backend.system.song.Song;
	// import flixel.addons.transition.FlxTransitionableState;

	function onGameOverStart()
	{
		GameOverSubstate.instance.camFollowPos.y += 200;
		GameOverSubstate.instance.moveCamera = true;
		game.defaultCamZoom = 0.6;

		if (FlxG.random.bool(4)) // it is bf secret death reference?
		{
			final sang = "bezdari-picomix";
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
}
else
	dispose();
