FlxG.camera.bgColor = FlxColor.fromHSL(0, 0, 0.26);
addHxObject(new FlxSprite(-813.89, -772.45, Paths.image('pyaterochka2/стенка')));

addHxObject(new FlxSprite(132.31, -5.31, Paths.image('pyaterochka2/выход')));

addHxObject(new FlxSprite(-1535.31, 634.89, Paths.image('pyaterochka2/пол')));

addHxObject(new FlxSprite(-377.5, -391.34, Paths.image('pyaterochka2/clyde')));

addHxObject(new FlxSprite(-598.2, -23.94, Paths.image('pyaterochka2/polki')));

addHxObject(new FlxSprite(-897.4, -203.24, Paths.image('pyaterochka2/polki с дерьмом')));

addHxObject(new FlxSprite(804.48, 222, Paths.image('pyaterochka2/касса сзади')));

addHxObject(new FlxSprite(1283.23, -424.08, Paths.image('pyaterochka2/вывеска1')));

addHxObject(new FlxSprite(1253.71, 211.99, Paths.image('pyaterochka2/касса')));

addHxObject(new FlxSprite(1760.33, -386.48, Paths.image('pyaterochka2/вывеска2')));

addHxObject(new FlxSprite(172.36, -315.6, Paths.image('pyaterochka2/лампа')), true);

var lamp = addHxObject(new FlxSprite(-255.44, -482.6, Paths.image('pyaterochka2/лампа с светом')), true);

function onGameOverStart()
{
    remove(lamp);
    GameOverSubstate.instance.add(lamp);
}

function onDestroy() {
    FlxG.camera.bgColor = FlxColor.BLACK;
}