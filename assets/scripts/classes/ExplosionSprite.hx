// import flixel.util._FlxSignal.FlxSignal0; // private class

class ExplosionSprite extends FlxSprite
{
	static var tileWidth:Int = 71;

	// public var onEndAnim:FlxSignal0;

	public function new(X = 0.0, Y = 0.0)
	{
		super(X, Y);

		// onEndAnim = new FlxSignal0();
		var graph = Paths.image("explosion");
		loadGraphic(graph, true, tileWidth, graph.height);
		animation.add("boom", [for (i in 0...Std.int(graph.width / tileWidth)) i], 24.0, false);
		antialiasing = false;
	}

	override function updateAnimation(elapsed:Float)
	{
		super.updateAnimation(elapsed);
		if (animation.finished)
		{
			kill();
			animation.callback = null;
			animation.finishCallback = null;
			// onEndAnim.dispatch0();
			// onEndAnim.removeAll();
		}
	}

	override public function destroy()
	{
		super.destroy();
		// onEndAnim?.destroy();
		// onEndAnim = null;
	}
}

// отсановить вызовы скрипта в плейстейте
// dispose();