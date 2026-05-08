class SkipPrompt extends FlxSprite
{
	public var skipped = false;

	var wait = 0;
	var alphaTarget = 0;
	var inputCheckAny:()->Bool;
	var inputCheckPress:()->Bool;
	var onPressed:()->Void;

	public function new(inputCheckAny:()->Bool, inputCheckPress:()->Bool, onPressed:()->Void)
	{
		super();
		frames = Paths.getSparrowAtlas("skipPrompt");
		__globalScript__.getVar("inputTypeChange").add(updateFrame);
		updateFrame(0, __globalScript__.getVar("inputType"));
		setPosition(FlxG.width - width - 16, FlxG.height - height - 10);
		this.inputCheckAny = inputCheckAny;
		this.inputCheckPress = inputCheckPress;
		this.onPressed = onPressed;
		moves = alive = false;
		alpha = 0;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		elapsed /= FlxG.timeScale;
		wait = Math.max(wait - elapsed, 0);
		if (wait == 0)
			alpha += elapsed / 0.6 * FlxMath.numericComparison(alphaTarget, alpha);

		if (skipped)
		{
			if (alpha == 0)
				exists = false;

			return;
		}

		if (alive)
		{
			if (inputCheckPress())
			{
				onPressed();
				disable();
				frame = frames.frames[frames.numFrames - 1];
				wait = 0.4;
				alpha = 1;
			}
		}
		else if (inputCheckAny())
		{
			alphaTarget = 1;
			alive = true;
		}
	}

	override public function destroy()
	{
		super.destroy();
		__globalScript__.getVar("inputTypeChange").remove(updateFrame);
	}

	public function disable()
	{
		alphaTarget = 0;
		skipped = true;
	}

	function updateFrame(prevInput:Int, newInput:Int)
	{
		if (!skipped)
			frame = frames.frames[newInput];
	}
}