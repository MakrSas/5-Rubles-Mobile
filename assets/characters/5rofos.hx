if (isPlayer)
{
	function onGameOverStart()
	{
		var bfCamPos = getCameraPosition();
		var posX = bfCamPos.x + 150;
		var posY = bfCamPos.y - 100;
		FlxTween.tween(FlxG.camera, {
			zoom: FlxG.camera.zoom + 0.05,
			"scroll.x": posX - FlxG.width / 2,
			"scroll.y": posY - FlxG.height / 2
		}, 5 / 24, {ease: FlxEase.cubeOut});
		GameOverSubstate.instance.camFollow.setPosition(posX, posY);
		GameOverSubstate.instance.camFollowPos.x += 600;
		GameOverSubstate.instance.camFollowPos.y += 100;
		game.defaultCamZoom = 0.8;
	}

	var shakeTheScreen = true;
	function onUpdate(elapsed:Float)
	{
		if (game.isDead && GameOverSubstate.instance != null && GameOverSubstate.instance.boyfriend.animation.curAnim.name == "firstDeath"
			&& GameOverSubstate.instance.boyfriend.animation.curAnim.curFrame > 16 && shakeTheScreen)
		{
			FlxG.camera.shake(0.0125, 5 / 24);
			shakeTheScreen = false;
		}
	}

	function onGameOverConfirm(restart:Bool)
	{
		if (restart)
			getVar("gameOverConfig").fadeAlpha = 1;
	}
}
else
	dispose();
