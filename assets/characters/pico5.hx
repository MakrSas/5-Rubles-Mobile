if (isPlayer)
{
	function onGameOverStart()
	{
		// GameOverSubstate.instance.moveCamera = true;
		GameOverSubstate.instance.camFollowPos.x += 180;
		GameOverSubstate.instance.camFollowPos.y += 20;
		game.defaultCamZoom = 0.675;
		FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom, "target.x": GameOverSubstate.instance.camFollowPos.x, "target.y": GameOverSubstate.instance.camFollowPos.y},
			10 / 24, {startDelay: 4 / 24, ease: FlxEase.quadInOut/*, onStart: _ -> GameOverSubstate.instance.moveCamera = true*/});

		// не спрашивайте
		new FlxTimer().start(24 / 24, _ ->
		{
			FlxG.camera.shake(0.0125, 3 / 24, null, true, X);
			GameOverSubstate.instance.camFollowPos.x += 240;
			GameOverSubstate.instance.camFollowPos.y += 100;
			game.defaultCamZoom += 0.05;
		});
	}

	function onGameOverConfirm(restart:Bool)
	{
		if (restart)
		{
			GameOverSubstate.instance.camFollowPos.x += 70;
			GameOverSubstate.instance.camFollowPos.y += 30;
		}
	}
}
else
	dispose();
