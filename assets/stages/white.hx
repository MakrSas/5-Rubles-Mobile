FlxG.camera.bgColor = FlxColor.WHITE;
function onDestroy() FlxG.camera.bgColor = FlxColor.BLACK;
function onCreatePost()
{
	remove(gfGroup);
	addAheadObject(gfGroup, boyfriendGroup);
	remove(dadGroup);
	addAheadObject(dadGroup, boyfriendGroup);
	getVar("scoreGroup").visible = false;
}