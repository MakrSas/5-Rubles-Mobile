class LoopingGroup extends FlxBasic
{
	public var group:FlxGroup;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;

	public function new(startX:Float, endX:Float, startY:Float, endY:Float)
	{
		super();
		group = new FlxGroup();
		x = startX;
		y = startY;
		width = endX - startX;
		height = endY - startY;
	}

	public function add(basic:FlxBasic):FlxBasic
	{
		return group.add(basic);
	}

	public function remove(basic:FlxBasic, splice = false):FlxBasic
	{
		return group.remove(basic, splice);
	}

	public function forEach(func:T->Void, recurse = false)
	{
		group.forEach(func, recurse);
	}

	public function sort(func:(Int,FlxBasic,FlxBasic)->Int, order = null)
	{
		group.sort(func, order);
	}

	override public function update(elapsed:Float)
	{
		group.update(elapsed);
		group.forEach(loopMember);
	}

	override public function draw()
	{
		group.draw();
	}

	override public function destroy()
	{
		super.destroy();
		group.destroy();
	}

	function loopMember(spr:FlxSprite)
	{
		if (spr.x + spr.width < x)
			spr.x += width + spr.width;
		else if (spr.x > x + width)
			spr.x -= width + spr.width;

		if (spr.y + spr.height < y)
			spr.y += height + spr.height;
		else if (spr.y > y + height)
			spr.y -= height + spr.height;
	}
}