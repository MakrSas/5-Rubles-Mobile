loadHScript("data/do_a_flip.hx");
// loadHScript("data/daddyswap.hx");

function onCreate()
{
	var id = iconP2.ID;
	iconP2.ID = iconP1.ID;
	iconP1.ID = id;
}

function onCreatePost()
{
	/*
	var temp = dad.x + 100;
	dad.x = boyfriend.x - 150;
	boyfriend.x = temp;
	temp = dad.y;
	dad.y = boyfriend.y;
	boyfriend.y = temp;
	*/
	//dad.x -= 150;
	//boyfriend.x += 100;
	dad.cameraPos.x -= 50.0;
	boyfriend.cameraPos.x += 50.0;

	// flipHealthBar();

	// dad.cameraPos.x = -(dad.cameraPos.x) - 250.0;
	// boyfriend.cameraPos.x = -(boyfriend.cameraPos.x) - 250.0;
	// boyfriend.x += 100;
	// boyfriend.y -= 150;
	dad.flipX = !dad.flipX;
	boyfriend.flipX = !boyfriend.flipX;

	dadCamOffset.x -= 90;
	var tempPoint = dadCamOffset;
	dadCamOffset = bfCamOffset;
	bfCamOffset = tempPoint;

	var duoCamsScript = scriptPack.getHScript("data/duoCameras.hx");
	if (duoCamsScript != null)
	{
		// duoCamsScript.getVar("flipMoveCameraModules")();
		duoCamsScript.getVar("flipCameras")();
		duoCamsScript.getVar("updateCameraPositions")(false);
	}
	moveCameraSection();
	dispose();
}