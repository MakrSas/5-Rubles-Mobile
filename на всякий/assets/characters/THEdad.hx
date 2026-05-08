function onUpdate(elapsed:Float)
{
	animation.timeScale = (animation.curAnim.frameDuration * animation.curAnim.numFrames) / (Conductor.crochet / 1000 * danceEveryNumBeats);
}