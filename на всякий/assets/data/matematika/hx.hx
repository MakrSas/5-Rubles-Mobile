import game.objects.improvedFlixel.FlxCustomBGSprite;

var fade:FlxCustomBGSprite;

function getSleepTimer():Float
	return FlxG.random.float(18 / 24, 26 / 24);

function getRandomOffset():Float
	return FlxG.random.float(-40, 40);

// хррррррр мимимимимимими
var sleepGroup:FlxGroup;
var sleepTimer = getSleepTimer();
var image:FlxSprite;
var confetti:FlxSprite;

function onCreatePost()
{
	fade = new FlxCustomBGSprite();
	fade.color = FlxColor.BLACK;
	// fade.camera = camGame;
	camHUD.alpha = 0;
	camControls.alpha = 0;
	add(fade);

	sleepGroup = new FlxGroup();
	// addAheadObject(sleepGroup, boyfriendGroup);
	addBehindBF(sleepGroup);

	image = new FlxSprite(0, 0, Paths.image("dog"));
	image.setGraphicSize(FlxG.width, FlxG.height);
	image.updateHitbox();
	image.camera = camOther;
	image.alpha = 0.000001;
	add(image);

	confetti = new FlxSprite(-1, -1).loadGraphic(Paths.image("confetti"), true, 200, 113);
	confetti.animation.add("confetti", [for (i in 0...confetti.numFrames) i], 12);
	confetti.setGraphicSize(FlxG.width + 2, FlxG.height + 2);
	confetti.updateHitbox();
	// confetti.antialiasing = false;
	confetti.camera = camOther;
	confetti.alpha = 0.000001;
	add(confetti);
}

function onUpdatePost(elapsed:Float)
{
	var anim = boyfriend.curAnimName;
	var sleepAnim = anim == "sleep";
	if (sleepAnim || anim == "snooze")
	{
		sleepTimer -= elapsed;
		if (sleepTimer < 0)
		{
			sleepTimer += getSleepTimer();
			spawnSleepThing(sleepAnim);
		}
	}
}

function spawnSleepThing(sleepAnim:Bool)
{
	var z = sleepGroup.recycle(FlxSprite, spriteConstructor);
	z.setup();
	z.setPosition(
		boyfriend.x + boyfriend.width - boyfriend.__drawingOffset.x + getRandomOffset() - 80 + (sleepAnim ? 20 : 0),
		boyfriend.y - boyfriend.__drawingOffset.y + getRandomOffset() + 180 + (sleepAnim ? 150 : 0)
	);
}

function spriteConstructor():ZSprite
	return new ZSprite();

var doneIntro = false;
function onSongStart()
{
	if (doneIntro)
		return;

	isCameraOnForcedPos = true;
	new FlxTimer().start(0.25, _ ->
	{
		var crochetSec = Conductor.crochet / 1000.0;
		var ease = t -> 1.0 - Math.pow(1.0 - t, 1.5);
		FlxTween.num(1, 0.0, crochetSec * 22.0, {ease: ease, onComplete: _ -> fade.kill()}, fade.set_alpha);
	});
	doneIntro = true;
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "")
	{
		switch (value1)
		{
			case "show_hud":
				isCameraOnForcedPos = false;
				for (cam in [camHUD, camControls])
					FlxTween.num(0.0, 1.0, 0.5, null, cam.set_alpha);
				moveCameraSection();

			case "yayy":
				confetti.alpha = 1;
				confetti.animation.play("confetti");
				FlxTween.num(0.0, 1.0, 2.5, null, image.set_alpha);
		}
	}
}

// ZOV ZOV ГОЙДА ZА НАШИХ!!!!!!!!
class ZSprite extends FlxSprite
{
	var lifespan:Float;
	var speed:Float;
	var offsetTween:FlxTween;

	public function new()
	{
		super();
		frames = Paths.getSparrowAtlas("basement/z");
		animation.addByPrefix("z", "ЗЭД");
		animation.play("z");
		antialiasing = true;
		alpha = 0;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		lifespan -= elapsed;
		if (lifespan < 0)
			kill();

		var delta = elapsed * speed;
		scale.x = scale.y = scale.x + delta / 7;
		alpha += delta * (lifespan < (1 / speed) ? -1 : 1);
	}

	public function setup()
	{
		speed = FlxG.random.int(1.4, 2.6);
		lifespan = FlxG.random.int(30, 35) / 24 + (1 / speed);

		scale.x = scale.y = FlxG.random.float(0.85, 0.95);
		scrollFactor.x = scrollFactor.y = FlxG.random.float(0.95, 1.05);
		velocity.set(FlxG.random.float(160, 200), -FlxG.random.float(100, 140));
		drag.x = velocity.x / 6;
		drag.y = velocity.y / 2;

		var ox = FlxG.random.float(30, 50) * (FlxG.random.bool() ? -1 : 1);
		offsetTween = FlxTween.num(-ox, ox, FlxG.random.float(26, 30) / 24, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG}, offset.set_x);
		// offsetTween.percent = 0.5;
	}

	override public function kill()
	{
		super.kill();
		offsetTween?.cancel();
		offsetTween = null;
	}

	override public function destroy()
	{
		super.destroy();
		offsetTween?.cancel();
		offsetTween = null;
	}
}