if (isPlayer)
{
	function onGameOverStart()
	{
		GameOverSubstate.instance.moveCamera = true;
		game.defaultCamZoom = 0.65;
	}
}
else
	dispose();
