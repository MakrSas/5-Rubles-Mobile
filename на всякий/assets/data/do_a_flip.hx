function onCreatePost()
{
	if (!middleScrollMode)
	{
		var diff = (playerStrums.position.x - opponentStrums.position.x);
		playerStrums.position.x -= diff;
		opponentStrums.position.x += diff;
		for (strum in playerStrums.members)
			strum.x -= diff;
		for (strum in opponentStrums.members)
			strum.x += diff;
	}
	flipHealthBar();
	dispose();
}