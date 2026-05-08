loadHScript(AssetsPaths.getPath("data/multiShit.hx"));

function onCreatePost()
{
	var offset = 100;
	boyfriend.y += offset;
	// boyfriend.cameraPos.y -= offset;
	dispose();
}