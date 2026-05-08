function onUpdatePost(elapsed:Float)
{
	var suffix = StringTools.startsWith(boyfriend.curAnimName, "singDOWN") || !gf.alive ? "-scared" : "";
	if (inCutscene || gf.idleSuffix == "sleep" || gf.idleSuffix == suffix)
		return;

	var frame = gf.curFrame;
	@:bypassAccessor gf.idleSuffix = suffix;
	gf.dance();
	gf.curFrame = frame;
}