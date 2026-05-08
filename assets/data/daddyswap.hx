function onCreatePost()
{
	var temp = dad.x;
	dad.x = boyfriend.x;
	boyfriend.x = temp;
	temp = dad.y;
	dad.y = boyfriend.y;
	boyfriend.y = temp;

	// flipHealthBar();

	dad.cameraPos.x = -(dad.cameraPos.x) - 250.0;
	boyfriend.cameraPos.x = -(boyfriend.cameraPos.x) - 250.0;
	dad.flipX = !dad.flipX;
	boyfriend.flipX = !boyfriend.flipX;

	dadCamOffset.x -= -90;
	var tempPoint = dadCamOffset;
	dadCamOffset = bfCamOffset;
	bfCamOffset = tempPoint;

	var duoCamsScript = scriptPack.getHScript("data/duoCameras.hx");
	if (duoCamsScript != null)
	{
		duoCamsScript.getVar("flipMoveCameraModules")();
	}
	moveCameraSection();
	dispose();
}