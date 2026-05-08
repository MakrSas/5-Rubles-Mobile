importHScriptClasses("scripts/classes/ChromaKeyShader.hx");
shader = new ChromaKeyShader("characters/fake png shit");

var prevFrame = null;
function onUpdatePost(elapsed:Float)
{
	if (frame != prevFrame)
	{
		shader.updateSprite(this);
		shader.setOffset(__drawingOffset.x, __drawingOffset.y);
		prevFrame = frame;
	}
}