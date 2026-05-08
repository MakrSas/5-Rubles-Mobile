var sound:FlxSound = FlxG.sound.load(Paths.sound("epigando_kids_EP1"), 0.0, true);
// sound.proximity(0, 0, this.interp.scriptObject, 2500);
sound.play();

var maxDelay = 1 / 24 * 1000;
var prevFrame = -1;
function onUpdatePost(elapsed)
{
	var frame = curFrame;
	if (prevFrame > frame)
		prevFrame = -1;

	if (curAnimName == "idle" && prevFrame != frame)
	{
		if (frame != 0)
		{
			sound.volume = 1.0;
			var curFramePos = frame * animateAtlas.anim.frameDelay * 1000;
			var diff = Math.abs(sound.time - curFramePos);
			if (diff > maxDelay)
			{
				trace(diff + "ms apart!!! (sound.time: " + sound.time + ", frame.time: " + Std.int(curFramePos) + ")");
				sound.time = curFramePos;
			}
		}
		prevFrame = frame;
	}

	// проксимити плохо сочетается с атласом :(
	// sound._radius = FlxG.camera.viewWidth * 0.6;
	// sound.setPosition(FlxG.camera.viewLeft + FlxG.camera.viewWidth * 0.5, FlxG.camera.viewTop + FlxG.camera.viewHeight * 0.5);
}