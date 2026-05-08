import game.objects.game.BGSprite;
addHxObject(new BGSprite('ГовноИКал', -1839.6, -736.5));
FlxG.camera.bgColor = FlxColor.WHITE;
function onDestroy() FlxG.camera.bgColor = FlxColor.BLACK;