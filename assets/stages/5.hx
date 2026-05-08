import flixel.math.FlxPoint.FlxBasePoint as FlxPoint;
import flixel.math.FlxMath;
import game.objects.ParallaxSprite;
import game.objects.game.BGSprite;

final offsetX = -255, offsetY = -255;

function caltParallaxFactor(bg:ParallaxSprite, deSprite:FlxSprite):FlxPoint{
    final mid = FlxMath.bound(Math.abs(deSprite.y / (bg.y - deSprite.y - bg.height)), 0, 1);
    return FlxPoint.get(FlxMath.lerp(bg.pointOne.scrollFactor.x, bg.pointTwo.scrollFactor.x, mid),
                        FlxMath.lerp(bg.pointOne.scrollFactor.y, bg.pointTwo.scrollFactor.y, mid));
}

var wall:FlxSprite = new BGSprite('pyaterochka/wall', offsetX - 205.5, offsetY - 159.15);
var ceiling:FlxSprite = new BGSprite('pyaterochka/potolok', offsetX - 71.45, offsetY - 254.15);
var stuff:FlxSprite = new BGSprite('pyaterochka/hz', offsetX - 153.7, offsetY + 284.3);
var floor:ParallaxSprite = new ParallaxSprite(offsetX - 458.8, offsetY + 737.4, Paths.image('pyaterochka/floor'));
floor.fixate(0,0,1.,1.,0.5,0.9);
addHxObject(wall);
addHxObject(floor);
addHxObject(stuff);
addHxObject(ceiling);
function onCreatePost() {
    var point = caltParallaxFactor(floor, boyfriendGroup);
    boyfriendGroup.scrollFactor.set(point.x, point.y);
    point.put();
    point = caltParallaxFactor(floor, gfGroup);
    gfGroup.scrollFactor.set(point.x * 0.9, point.y); // god damn
    point.put();
    point = caltParallaxFactor(floor, dadGroup);
    dadGroup.scrollFactor.set(point.x, point.y);
    point.put();

    point = caltParallaxFactor(floor, stuff);
    stuff.scrollFactor.set(point.x, point.y);
    point.put();
    point = caltParallaxFactor(floor, ceiling);
    ceiling.scrollFactor.set(point.x*1.3, point.y*1.3);
    point.put();
    // for (i in unspawnNotes) i.destroyOnHit = i.mustPress;
}
FlxG.camera.bgColor = FlxColor.fromHSL(0, 0, 0.8);


function onDestroy() {
    FlxG.camera.bgColor = FlxColor.BLACK;
}