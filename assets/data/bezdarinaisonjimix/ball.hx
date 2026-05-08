/*
var active = false;
// run it from cmd like "D:stuff>TwistEngine.exe ball", then you can see BALL and console with traces lol
for (arg in Sys.args())
{
	switch(arg)
	{
		case "ball" | "balls":
			active = true;
			break;
	}
}
if (!active)
{
	dispose();
	return;
}
*/

import flixel.FlxObject;
import flixel.text.FlxTextBorderStyle;

var ballAcceleration = 6000;
var minX = -FlxG.width * 2 - 440;
var maxY = FlxG.height + 480;
var maxX = FlxG.width * 2 + 360;
var minY = -FlxG.height;
var isSelected:Bool = false;

var ball:FlxSprite;
var trigger:FlxObject;
var dragTxt:FlxText;

var daTween;
var startedShit = false;

function onCreatePost()
{
	// потому что на релизе порядок скриптов летит в пизду одаода!!
	// Math.min(boyfriend.x, dad.x), Math.min(boyfriend.y, dad.y)
	trigger = new FlxSprite(-144, 385).makeGraphic(1, 1);
	trigger.scale.set(250, 580);
	trigger.updateHitbox();
	trigger.immovable = true;
	trigger.visible = false;
	add(trigger);

	ball = new FlxSprite(900, 0, Paths.image("Russia-Coin-5-1997-a"));
	ball.acceleration.y = ballAcceleration;
	ball.angle = FlxG.random.int(0, 360);
	ball.drag.x = 125;
	ball.immovable = false;
	ball.elasticity = 0.85;
	add(ball);

	dragTxt = new FlxText(0, 0, 0, FlxG.onMobile ? "TOUCH to drag!" : "Drag with MOUSE!", 46);
	dragTxt.alignment = "center";
	dragTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK, 4);
	dragTxt.alpha = 0;
	add(dragTxt);

	// нормальная коллизия (Я НЕНАВИЖУ ФЛИКСЕЛЬ КСТА!!!)
	FlxG.worldBounds.set(minX, minY, Math.abs(minX - maxX), Math.abs(minY - maxY));
	FlxG.mouse.visible = true;
}

/*function onSongStart()
{
	startedShit = true;
	daTween = FlxTween.num(0, 1, 0.4, {onComplete: _ -> daTween = null}, dragTxt.set_alpha);
}*/

function onUpdate(elapsed)
{
	if (FlxG.mouse.justPressed)
	{
		isSelected = CoolUtil.mouseOverlapping(ball);
		if (isSelected)
			dragTxtTimer = 0.4;
	}
	else if (FlxG.mouse.justReleased && isSelected)
	{
		mouseReleased();
	}
	else if (FlxG.keys.justPressed.SPACE && !isSelected)
	{
		dragTxtTimer = 0.4;
		ball.acceleration.y = ballAcceleration;
		ball.velocity.set(FlxG.random.int(-6000, 6000), FlxG.random.int(-500, 6000));
	}

	ball.angularVelocity = ball.velocity.x;
}

// окей эта система работает гораздо лучше
// bounces per second
var bps = 0;
var bpsTimer = 0;

var hps = 0;
var hpsTimer = 0;

var initiateBlowJob = false;

var dragTxtTimer = 3.4;

function onCollide(obj1, obj2) {
	hps++;
	// trace(hps);
	if (hps > 4)
		initiateBlowJob = true;

	if (obj1.touching == 0x0100 || obj2.touching == 0x0100)
		ball.velocity.set(FlxG.random.int(400, 1000) * (FlxG.random.bool() ? 1 : -1), -1500);

	FlxG.sound.play(Paths.sound("coin_hit")).pitch = FlxG.random.float(0.8, 1.2);
	boyfriend.playAnim("hit", true);
	boyfriend.specialAnim = true;
	health -= 0.024 * FlxG.random.float(1, 1.1) * Math.sqrt(ball.velocity.x * ball.velocity.x + ball.velocity.y * ball.velocity.y) / 200;
}

// перенес коллизию в пост апдейт чтобы учитывалась новая позиция с уже примененной велосити
function onUpdatePost(elapsed)
{
	bpsTimer += elapsed;
	if (bpsTimer >= 1)
	{
		bpsTimer -= 1;
		bps = 0;
	}

	hpsTimer += elapsed;
	if (hpsTimer >= 1)
	{
		hpsTimer -= 1;
		hps = 0;
	}

	if (startedShit && dragTxt.alive)
	{
		dragTxtTimer -= elapsed;
		if (dragTxtTimer <= 0.4)
		{
			if (daTween != null)
				daTween.cancel();
			dragTxt.alpha -= elapsed * 2.5;
			if (dragTxt.alpha == 0)
				dragTxt.kill();
		}
	}

	if (isSelected)
	{
		ball.velocity.set();
		ball.setPosition(FlxG.mouse.x - ball.width / 2, FlxG.mouse.y - ball.height / 2);
	}
	else
	{
		// левая коллизия
		if (ball.x < FlxG.worldBounds.left)
		{
			ball.x += (Math.abs(ball.x) - Math.abs(FlxG.worldBounds.left)) * ball.elasticity;
			ball.velocity.x *= -ball.elasticity;
		}
		// правая коллизия
		else if (ball.x + ball.width > FlxG.worldBounds.right)
		{
			ball.x -= (Math.abs(ball.x) - Math.abs(FlxG.worldBounds.right) + ball.width) * ball.elasticity;
			ball.velocity.x *= -ball.elasticity;
		}

		// нижняя коллизия
		if (ball.y + ball.height > FlxG.worldBounds.bottom)
		{
			ball.y -= (Math.abs(ball.y) - Math.abs(FlxG.worldBounds.bottom) + ball.height) * ball.elasticity;
			ball.velocity.y *= -ball.elasticity;
			bps++;
		}
		// верхняя коллизия
		else if (ball.y < FlxG.worldBounds.top)
		{
			ball.y += (Math.abs(ball.y) - Math.abs(FlxG.worldBounds.top));
			ball.velocity.y = -ball.velocity.y;
		}

		if (!isDead)
		{
			FlxG.collide(ball, trigger, onCollide);
		}
	}

	if (bps > 10 && Math.abs(ball.y + ball.height - FlxG.worldBounds.bottom) < 0.1)
	{
		ball.acceleration.y = 0;
		ball.velocity.y = 0;
		ball.y = FlxG.worldBounds.bottom - ball.height;
	}

	dragTxt.x = ball.x - (dragTxt.width - ball.width) * 0.5;
	dragTxt.y = ball.y - dragTxt.height - 20;

	if (!startedShit && dragTxt.isOnScreen())
	{
		startedShit = true;
		daTween = FlxTween.num(0, 1, 0.4, {startDelay: 0.4, onComplete: _ -> daTween = null}, dragTxt.set_alpha);
	}
}

function onGameOverStart()
{
	dragTxt.kill();
	remove(ball);
	GameOverSubstate.instance.add(ball);

	if (initiateBlowJob)
	{
		importHScriptClasses("scripts/classes/ExplosionSprite.hx");
		trace("BOOOOOOOOOOOM!!!!!!!!");
		var boom = new ExplosionSprite(
			GameOverSubstate.instance.boyfriend.x - GameOverSubstate.instance.boyfriend.width / 2,
			GameOverSubstate.instance.boyfriend.y - GameOverSubstate.instance.boyfriend.height / 5
		);
		#if !DEV_BUILD
		boom.animation.callback = (_, f, _) -> if (f > 13) Sys.exit(0);
		#end
		boom.animation.play("boom");
		boom.scale.set(12, 12);
		boom.updateHitbox();
		GameOverSubstate.instance.add(boom);
		FlxG.camera.shake(0.05, boom.animation.curAnim.frameDuration * boom.animation.curAnim.numFrames);
		FlxG.sound.play(Paths.sound("explosion"));

		#if DEV_BUILD
		if (ClientPrefs.displErrs && !ClientPrefs.displErrsWindow)
			throw "ВЗОРВИСЬ!!!";
		#end
	}
}

function mouseReleased()
{
	isSelected = false;
	ball.acceleration.y = ballAcceleration;
	ball.velocity.set(FlxG.mouse.deltaX * 50, FlxG.mouse.deltaY * 50);
}

function onResume()
{
	FlxG.mouse.visible = true;
}

function onPause()
{
	if (isSelected)
		mouseReleased();
}
