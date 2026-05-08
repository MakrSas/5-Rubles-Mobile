class CharacterTrail extends FlxSprite
{
	public var group = new FlxGroup();
	public var target:Character;
	public var interval = 0.2;
	public var fadeSpeed = 1.0;
	public var enabled = false;

	var spawnTimer = 0.0;
	var countAlive = 0;

	public function new()
	{
		super();
		@:bypassAccessor alpha = 0.65;
		ID = 5;
		for (i in 0...ID)
		{
			var cache = new FlxSprite();
			group.add(cache);
			cache.kill();
			cache.ID = i;
		}
		set_color(color);
	}

	public function resetTrail()
	{
		spawnTimer = 0.0;
		for (trail in group.members)
			if (trail.alive)
				trail.kill();
	}

	public function setTarget(_target:Character)
	{
		if (_target.useAtlas)
		{
			Log("Подан атласовый персонаж [" + _target.curChatacter + "], трейл работать не будет!", TColor.RED);
			_target = null;
		}
		if (/*target != null && _target != null &&*/ target != _target)
			resetTrail();
		target = _target;
	}

	override public function update(elapsed:Float)
	{
		group.update(elapsed);
		// if (group.members[group.length - 1].alive)
		// {
		if (countAlive != 0)
		{
			var fade = elapsed * 1.75 * fadeSpeed;
			for (trail in group.members)
			{
				if (trail.alive)
				{
					trail.colorTransform.alphaMultiplier -= fade;
					if (trail.colorTransform.alphaMultiplier <= 0.0)
					{
						trail.kill();
						countAlive--;
					}
				}
			}
		}
		// }

		if (enabled && target != null)
		{
			if (interval > 0.0)
			{
				spawnTimer += elapsed;
				while (spawnTimer >= interval)
				{
					spawnTimer -= interval;
					spawnTrail();
				}
			}
			else // interval <= 0.0, т.е. спавнить каждый фрейм (пиздец)
				spawnTrail();
		}
	}

	public function spawnTrail(?fromAnim:String):Null<FlxSprite>
	{
		if (alpha <= 0.0)
		{
			// var trail = group.recycle(FlxSprite);
			// trail.alpha = 0.0;
			// return trail;
			return null;
		}

		var frame = target.frame;
		if (fromAnim != null)
		{
			if (target.animation.exists(fromAnim))
				frame = target.frames.getByIndex(target.animation.getByName(fromAnim).frames[0]);
			else
				fromAnim = null;
		}

		var trail = group.recycle(FlxSprite);
		@:bypassAccessor trail.clipRect = target.clipRect;
		trail.frame = frame;
		trail.antialiasing = target.antialiasing;
		@:bypassAccessor trail.color = FlxColor.multiply(target.healthColor, target.color);
		trail.alpha = target.alpha * alpha;
		trail.colorTransform.redOffset = trail.colorTransform.greenOffset = trail.colorTransform.blueOffset = 18.0;
		// trail.blend = BlendMode.ADD;
		target.updateTrig();
		trail._sinAngle = target._sinAngle;
		trail._cosAngle = target._cosAngle;
		@:bypassAccessor trail.angle = target.angle;
		trail.flipX = target.flipX;
		trail.flipY = target.flipY;

		var animOffset = target.getAnimOffset(fromAnim ?? target.curAnimName);
		trail.offset.set(target.offset.x + animOffset.x, target.offset.y + animOffset.y);
		trail.scrollFactor.set(target.scrollFactor.x, target.scrollFactor.y);
		trail.origin.set(target.origin.x, target.origin.y);
		trail.scale.set(target.scale.x, target.scale.y);
		trail.setPosition(target.x, target.y);

		trail.drag.set();
		trail.velocity.set(velocity.x, velocity.y); // 0.0, -100.0
		trail.acceleration.set(acceleration.x, acceleration.y); // 0.0, -600.0

		trail.ID = ID++;
		group.sort(trailSort);
		countAlive++;
		return trail;
	}

	override public function draw()
	{
		if (countAlive == 0) return;
		group._cameras = _cameras;
		group.draw();
	}

	override public function destroy()
	{
		if (group != null)
		{
			group.destroy();
			group = null;
		}
		target = null;
		enabled = false;
		super.destroy();
	}

	function trailSort(index:Int, obj1:FlxBasic, obj2:FlxBasic):Int
	{
		return obj1.ID > obj2.ID ? -index : obj2.ID > obj1.ID ? index : 0;
	}

	override function set_alpha(value:Float):Float
	{
		return @:bypassAccessor alpha = FlxMath.bound(value, 0.0, 1.0);
	}

	override function set_color(value:FlxColor):FlxColor
	{
		return @:bypassAccessor color = value & 0xffffff;
	}
}

// никогда, минус оптимизация
// class AtlasCharacterTrail extends FlxAnimate {}

// отсановить вызовы скрипта в плейстейте
// dispose();