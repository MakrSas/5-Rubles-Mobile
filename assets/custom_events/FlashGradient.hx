import flixel.graphics.FlxGraphic;
import flixel.util.FlxGradient;

using game.backend.utils.CoolUtil;
using StringTools;

var gradientGraphic:FlxGraphic;
var gradientGroup:FlxGroup;

function onCreatePost()
{
	gradientGraphic = FlxGraphic.fromBitmapData(FlxGradient.createGradientBitmapData(1, Std.int(FlxG.height), [FlxColor.TRANSPARENT, FlxColor.WHITE]));
	gradientGraphic.persist = true;
	// gradientGraphic.destroyOnNoUse = false;

	gradientGroup = new FlxGroup();
	gradientGroup.camera = camHUD;
	insert(0, gradientGroup);
	gradientGroup.ID = 0;

	for (event in eventNotes)
	{
		if (event[1] == "FlashGradient")
			event[0] -= Conductor.stepCrochet * 1.25;
	}

	// FlxG.cameras.cameraResized.add(onCameraResized);
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "FlashGradient")
	{
		var flashAlpha:Float = Std.parseFloat(value1).getDefault(0.25);
		var time:Float = Std.parseFloat(value2).getDefault(0.85); // 1.3

		var gradient = addGradient();
		var targetScale = gradient.scale.y;
		gradient.scale.y /= 1.5;
		FlxTween.tween(gradient, {alpha: flashAlpha, "scale.y": targetScale}, Conductor.stepCrochet / 1000.0 * 1.25,
		{
			onComplete: _ -> FlxTween.tween(gradient, {alpha: 0.0, "scale.y": gradient.scale.y / 2.0}, time, {onComplete: _ -> gradient.kill()}),
			ease: FlxEase.sineOut
		});
	}
}

function onDestroy()
{
	// FlxG.cameras.cameraResized.remove(onCameraResized);
}

function addGradient():FlxSprite
{
	var gradient = gradientGroup.recycle(null, cumstructor);
	gradient.blend = BlendMode.ADD;
	gradient.alpha = 0.0;
	resizeGradient(gradient);
	gradient.ID = gradientGroup.ID++;
	gradientGroup.sort(sort);
	return gradient;
}

function resizeGradient(gradient:FlxSprite)
{
	gradient.setPosition(0.0, 0.0); // camHUD.viewMarginLeft, camHUD.viewMarginTop
	gradient.setGraphicSize(FlxG.width, FlxG.height); // camHUD.viewWidth, camHUD.viewHeight
	gradient.updateHitbox();
	gradient.origin.y = gradient.frameHeight;
}

/*function onCameraResized(camera:FlxCamera)
{
	if (camera = camHUD)
		for (gradient in gradientGroup.members)
			if (gradient.alive)
				resizeGradient(gradient);
}*/

function cumstructor():FlxSprite
	return new FlxSprite(0.0, 0.0, gradientGraphic);

function sort(index:Int, obj1:FlxBasic, obj2:FlxBasic):Int
	return obj1.ID > obj2.ID ? -index : obj2.ID > obj1.ID ? index : 0;