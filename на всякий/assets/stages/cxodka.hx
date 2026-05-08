import game.objects.game.BGSprite;

var bgFans:FlxSprite;
var nonLocalFans:BGSprite;
var sergey:FunkinSprite;
var piss:Character;
var void:BGSprite;

function onCreate()
{
	var gradient = addHxObject(new BGSprite("cxodka/gradient", -2357.45, -3245.35, 0.6, 0.775));
	gradient.scale.x = 6764.0;
	gradient.updateHitbox();

	addHxObject(new BGSprite("cxodka/sun", 371.85, -3189.2, 0.7, 0.825));

	var clouds = addHxObject(new BGSprite("cxodka/clouds", -2440.1, -3554.2, 0.775, 0.85));
	clouds.velocity.x = FlxG.random.float(20.0, 80.0);
	clouds.x *= FlxG.random.float(0.98, 1.02);
	clouds.y *= FlxG.random.float(0.98, 1.02);
	clouds.active = true;

	addHxObject(new BGSprite("cxodka/voronezh", -1235.65, -2800.95, 0.85, 0.875));
	addHxObject(new BGSprite("cxodka/trees_bg", -1389.45, -725.7, 0.85, 0.925));
	addHxObject(void = new BGSprite("cxodka/void", 2250, -600, 0.9, 0.9, ["пошел козлик"]));
	void.kill();
	// 2250, -600
	// -850, -300

	addHxObject(new BGSprite("cxodka/floor", -1711.65, -267.2));

	bgFans = addHxObject(new FlxSprite(-106.0, -62.8));
	bgFans.ID = FlxG.random.int(0, 1);
	bgFans.frames = Paths.getSparrowAtlas("cxodka/fnfans");
	bgFans.animation.addByIndices("dance0", "fnfans", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], "", 24.0, false);
	bgFans.animation.addByIndices("dance1", "fnfans", [10, 11, 12, 13, 14, 15, 16, 17, 18, 19], "", 24.0, false);
	bgFans.animation.play("dance" + bgFans.ID);
	bgFans.scale.set(0.925, 0.925);
	bgFans.updateHitbox();

	if (FlxG.random.bool(25))
	{
		addHxObject(sergey = new FunkinSprite(-1275, -50));
		sergey.loadAtlas("cxodka/sergey vzurochi");
		sergey.playAnim("!пидарасики на форне/sergey vzurochi idle");
		sergey.addAnimation("run", "!пидарасики на форне/sergey vzurochi live reaction", null, null, 24, 0, false);
	}

	addHxObject(new BGSprite("cxodka/trees_bg_closer", -2015.5, -1720.0));

	if (FlxG.random.bool(25))
	{
		addHxObject(piss = new Character(-1400, -20, "alikpiss"));
	}

	// ФАНАТЫ

	addHxObject(nonLocalFans = new BGSprite("cxodka/REAL_fans", 735 - 483, 75 - 59, 0.995, 0.9995, ["бг люди вместе0", "бг люди вместе ПОГИБ"]));
	addHxObject(new BGSprite("cxodka/kalail", 485, 70, 0.995, 0.9995, ["КАЛИЛ"], true));

	// ФАНАТЫ
}

function onCountdownTick(tick:Int) danceAll(tick);
function onBeatHit(beat:Int) danceAll(beat);

function danceAll(ref:Int)
{
	bgFans.ID = ((bgFans.ID + 1) % 2);
	bgFans.animation.play("dance" + bgFans.ID, true); // ref % 2

	if (ref % 2 == 0)
	{
		piss?.dance();
		if (!isDead)
			nonLocalFans.dance();
	}

	if (!void.alive && FlxG.random.bool(0.65))
	{
		void.setPosition(2250, -600);
		void.velocity.set(-100, 10);
		void.revive();
	}
}

function onUpdatePost(elapsed:Float)
{
	if (void.alive && void.x < -850)
		void.kill();
}

function onGameOver()
{
	sergey?.playAnim("run");
	nonLocalFans.animation.play("бг люди вместе ПОГИБ");
}
