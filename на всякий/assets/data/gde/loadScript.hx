loadHScript(AssetsPaths.getPath("data/smert_vikluchit.hx"));
var multiShit = loadHScript(AssetsPaths.getPath("data/multiShit.hx"));
if (!middleScrollMode)
{
	var old_onCountdownStarted = multiShit.variables.get("onCountdownStarted");
	multiShit.variables.set("onCountdownStarted", () ->
	{
		old_onCountdownStarted();
		multiShit.getVar("changePosition")("gf", true);
	});
}
dispose();