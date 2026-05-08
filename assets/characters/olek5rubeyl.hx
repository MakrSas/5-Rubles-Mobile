function onGameOverStart()
{
	var bfCamPos = GameOverSubstate.instance.boyfriend.getCameraPosition();
	GameOverSubstate.instance.camFollowPos.x = bfCamPos.x + 30;
	GameOverSubstate.instance.camFollowPos.y = bfCamPos.y - 20;
	game.defaultCamZoom = 0.55;
}