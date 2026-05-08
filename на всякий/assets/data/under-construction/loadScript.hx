loadHScript(AssetsPaths.getPath("data/psychHUD.hx"));
var oldCreateCountSprite = createCountSprite;
createCountSprite = (name:String, sound:String) ->
{
	var countdown = oldCreateCountSprite(name, sound);
	if (countdown != null)
		countdown.camera = camOther;
	return countdown;
}
// dispose();