if (isPlayer)
{
	// испортить психику??
	function onGameOverStart()
	{
		GameOverSubstate.instance.camFollowPos.x -= 240;
		GameOverSubstate.instance.camFollowPos.y -= 40;
		game.defaultCamZoom = 0.75;
	}
}
else
	dispose();