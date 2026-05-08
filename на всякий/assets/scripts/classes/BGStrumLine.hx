import game.objects.game.notes.StrumGroup;
import game.objects.game.notes.StrumLine;

class BGStrumLine extends StrumLine
{
	public var targetAlpha:Float;
	public var showCheck:() -> Bool;
	public var forceStatus:Null<Bool>;

	var lastShown = false;
	var showDelay = 0.0;
	var alpha = -1.0;

	public function new(targetAlpha:Float, showCheck:() -> Bool)
	{
		super(0);
		downScroll = false;
		onSpawnNote.add(i -> i.scrollFactor.set(0.9, 0.9));
		this.targetAlpha = targetAlpha;
		this.showCheck = showCheck;
		FlxG.signals.postUpdate.add(preUpdate);
	}

	override public function destroy()
	{
		super.destroy();
		if (FlxG.signals.postUpdate.has(preUpdate))
			FlxG.signals.postUpdate.remove(preUpdate);
	}

	function preUpdate()
	{
		if (active && exists && (forceStatus != null || FlxG.state.persistentUpdate || FlxG.state.subState == null))
			updateAlpha(FlxG.elapsed);
	}

	/*override public*/ function updateAlpha(elapsed:Float) // update
	{
		// super.update(elapsed);

		var showStrums = forceStatus ?? showCheck();
		if (lastShown != showStrums && !showStrums)
			showDelay = (Conductor.crochet + Conductor.stepCrochet) / 1000.0;

		if (showDelay > 0.0)
		{
			showDelay -= elapsed;
		}
		else
		{
			setAlpha(alpha + (showStrums ? elapsed * 4.0 : -elapsed * 3.0));
		}
		lastShown = showStrums;
	}

	function setAlpha(value:Float)
	{
		value = FlxMath.bound(value, 0.0, targetAlpha);
		if (value == alpha)
			return;

		for (strum in strumNotes.members)
		{
			strum.alpha = value;
			strum.visible = (value != 0.0);
		}
		alpha = value;
	}
}

// отсановить вызовы скрипта в плейстейте
// dispose();