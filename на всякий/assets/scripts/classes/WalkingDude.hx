import openfl.geom.ColorTransform;

// import flixel.util.FlxColorTransformUtil;
import flixel.group.FlxGroup;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxSort;

import game.objects.game.BGSprite;

class WalkingDude extends TwistSprite
{
	public var jumpStrength:Float = 20;
	public var jumpDuration:Float = FlxG.random.float(1.1, 2.5);
	public var jumpDurationMult:Float = 1.0;
	public var jumpEase:FlxEase = FlxEase.cubeIn;
	public var offsetY:Float = 0;
	public var jumpTimingFactor:Float = 0.5;

	var _jumpTimer:Float = FlxG.random.float(0, 2);
	var _idleAnims:Array<String>;
	var _charData:Array<Dynamic>;

	public function new(x = 0, y = 0)
	{
		super(x, y);
		active = true;
	}

	public function switchCharater(data:{
		image:String,
		anims:Array<String>,
		hasFlippedAnims:Bool,
		flippedImage:String,
		offsetY:Float,
		jumpDurationhMult:Float,
		jumpEase:FlxEase,
		jumpStrength:Float,
		jumpTimingFactor:Float,
	})
	{
		_lastIdleIndx = -1;
		_charData = data;
		_jumpTimer = FlxG.random.float(0, 2);

		jumpDurationMult = data.jumpDurationhMult ?? 1.0;
		jumpEase = data.jumpEase ?? FlxEase.cubeIn;
		jumpStrength = data.jumpStrength ?? 20.0;
		jumpTimingFactor = data.jumpTimingFactor ?? 0.5;
		offsetY = data.offsetY ?? 0.0;
		flipX = FlxG.random.bool();

		if (data.anims != null && data.anims.length != 0)
		{
			_idleAnims = [];
			frames = Paths.getSparrowAtlas(data.image);
			for (i in data.anims)
			{
				addAnimation(i, i, null, null, 24, 0, false);
				if (!_charData.hasFlippedAnims || StringTools.endsWith(i, "-flipped") == flipX)
					_idleAnims.push(i);
			}
			animation.play(data.anims[0]);
		}
		else
		{
			_idleAnims = null;
			loadGraphic(Paths.image((flipX && data.flippedImage != null) ? data.flippedImage : data.image));
		}
	}

	public function getData()
	{
		return _charData;
	}

	public override function update(elapsed)
	{
		_jumpTimer = FlxMath.mod(_jumpTimer + elapsed / jumpDuration * jumpDurationMult, 1.0);
		super.update(elapsed);
	}

	public override function draw()
	{
		var _offsetY;
		if (FlxMath.equal(jumpStrength, 0))
			_offsetY = 0;
		else
		{
			_offsetY = _jumpTimer > jumpTimingFactor ?
				jumpEase(FlxMath.remapToRange(_jumpTimer, jumpTimingFactor, 1, 1, 0))
			:
				jumpEase(FlxMath.remapToRange(_jumpTimer, 0, jumpTimingFactor, 0, 1));
			_offsetY *= jumpStrength;
		}
		_offsetY -= this.offsetY;
		offset.y -= _offsetY;
		super.draw();
		offset.y += _offsetY;
	}

	var _lastIdleIndx = -1;

	public function dance(forceplay:Bool = false)
	{
		if (_idleAnims != null)
			playAnim(_idleAnims[_lastIdleIndx = FlxMath.mod(_lastIdleIndx + 1, _idleAnims.length - 1)], forceplay);
	}
}

class WalkingDudesGroup extends flixel.FlxObject
{
	public var minTime:Float;
	public var maxTime:Float;
	public var spawnTime:Float;
	public var baseScale:Float;
	public var zoomFactor:Float;

	var _timer:Float;
	var _group:FlxGroup;
	var _lastY;

	var characters:Array<Dynamic>;
	var _activeCharacters:Array<Dynamic>;

	var shader:FlxShader;
	var colorTransform:ColorTransform;

	public function new(characters:Array<Dynamic>, startX:Float = 0, endX:Float = 1, startY:Float = 0, endY:Float = 1, baseScale:Float = 1,
			minTime:Float = 30, maxTime:Float = 70)
	{
		super(startX, startY, endX - startX, endY - startY);
		colorTransform = new ColorTransform();
		_timer = 0.0;
		zoomFactor = 0.85;
		_activeCharacters = [];
		this.baseScale = baseScale;
		this.minTime = minTime;
		this.maxTime = maxTime;
		_group = new FlxGroup();
		velocity.set(100, 200);
		this.characters = characters;
		spawnTime = getSpawnTime();
	}

	public function spawnGuy():WalkingDude
	{
		if (_activeCharacters.length >= characters.length)
			return;

		final guy = _group.recycle(null, constructGuy);
		var randCharData = characters[FlxG.random.int(0, characters.length - 1, [for (char in _activeCharacters) characters.indexOf(char)])];
		guy.switchCharater(randCharData);
		_activeCharacters.push(randCharData);

		var diff = 20;
		//do {
			guy.y = FlxG.random.float(y, y + height);
		//} while (_lastY != null && FlxMath.equal(_lastY, guy.y, diff));
		var delta = guy.y - _lastY;
		var deltaAbs = Math.abs(delta);
		if (deltaAbs < diff)
			guy.y += (diff - deltaAbs) * FlxMath.signOf(delta);
		_lastY = guy.y;

		guy.scale.x = guy.scale.y = FlxMath.remapToRange(_lastY, y, y + height, 0.85, 1.15) * baseScale;
		guy.updateHitbox();

		guy.zoomFactor = zoomFactor;

		if (guy.flipX)
			guy.x = FlxG.random.float(x, x * 1.2);
		else
			guy.x = FlxG.random.float(x + width, (x + width) * 1.2) - guy.width;
		guy.velocity.x = -FlxG.random.float(velocity.x, velocity.y) * guy._facingHorizontalMult * guy.jumpDurationMult;
		guy.jumpDuration = 150 / Math.abs(guy.velocity.x);
		guy.scrollFactor.y = FlxMath.remapToRange(_lastY, y, y + height, 0.55, 1.05);
		guy.moves = true;

		guy.shader = shader;
		guy.setColorTransform(colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, colorTransform.alphaMultiplier);

		// todo: затемненине чуваков сразу?

		_group.sort(FlxSort.byY, FlxSort.ASCENDING);
		return guy;
	}

	function constructGuy()
	{
		return new WalkingDude(0, 0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		_group.update(elapsed);

		final right = (x + width);
		final left = x;
		for (guy in _group.members)
		{
			if (/*guy.exists &&*/ guy.alive && (!guy.flipX && guy.x < left || guy.flipX && guy.x > right))
			{
				var data = guy.getData();
				// trace(data);
				guy.kill();
				_activeCharacters.remove(data);
			}
		}

		_timer += elapsed;
		if (_timer >= spawnTime)
		{
			_timer -= spawnTime;
			spawnTime = getSpawnTime();
			var guy = spawnGuy();
			// trace(guy);
		}
	}

	override public function draw()
	{
		super.draw();
		_group.draw();
	}

	override public function destroy()
	{
		super.destroy();
		_group?.destroy();
		_group = null;
	}

	override function updateMotion(elapsed:Float) {}

	function getSpawnTime()
	{
		return FlxG.random.float(minTime, maxTime);
	}

	public function dance(forceplay:Bool = true)
	{
		for (guy in _group.members)
		{
			if (guy.alive)
			{
				guy.dance(forceplay);
			}
		}
	}

	// var _fade:Float = 0;
	// var _fadeColor:FlxColor = 0;
	public function fade(factor:Float)
	{
		// if (_fade != factor)
		// {
			// _fade = factor;
			// var fo = -factor;
			var ff = 1 - factor / 255;
			// var fadeColor = FlxColor.fromRGBFloat(ff, ff, ff);
			// _fadeColor = fadeColor;
			for (s in _group.members)
			{
				// FlxColorTransformUtil.setOffsets(s.colorTransform, fo, fo, fo, 0);
				// s.color = fadeColor;
				s.setColorTransform(
					colorTransform.redMultiplier * ff,
					colorTransform.greenMultiplier * ff,
					colorTransform.blueMultiplier * ff,
					colorTransform.alphaMultiplier
				);
			}
		// }
	}

	function setShader(shader:FlxShader)
	{
		this.shader = shader;
		for (spr in _group.members)
			spr.shader = shader;
	}

	function setColorTransform(?redMultiplier:Float, ?greenMultiplier:Float, ?blueMultiplier:Float, ?alphaMultiplier:Float)
	{
		colorTransform.redMultiplier = redMultiplier ?? 1;
		colorTransform.greenMultiplier = greenMultiplier ?? 1;
		colorTransform.blueMultiplier = blueMultiplier ?? 1;
		colorTransform.alphaMultiplier = alphaMultiplier ?? 1;
		for (spr in _group.members)
			spr.setColorTransform(colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, colorTransform.alphaMultiplier);
	}
}
