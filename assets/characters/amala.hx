if (isPlayer || PlayState.SONG.song.toLowerCase() == "bezdariamalgamatmix")
{
	import game.backend.system.song.Song;
	// import flixel.addons.transition.FlxTransitionableState;

	function onGameOverStart()
	{
		GameOverSubstate.instance.boyfriend.getGraphicMidpoint(GameOverSubstate.instance.camFollowPos);
		var bfCamPos = GameOverSubstate.instance.boyfriend.getCameraPosition();
		GameOverSubstate.instance.camFollowPos.x = bfCamPos.x + 100;
		GameOverSubstate.instance.camFollowPos.y = bfCamPos.y + 20;
		GameOverSubstate.instance.moveCamera = true;
		game.defaultCamZoom = 0.7;

		if (FlxG.random.bool(4)) // it is bf secret death reference?
		{
			final sang = "gde";
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
