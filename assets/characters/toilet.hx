import flixel.math.FlxAngle;

static var tvMatrixData:Array<Array<Float>> = [
	[1.0307464599609376, 0, 0, 0.990753173828125, -4.05, 1.8], // 0
	null,
	[0.968902587890625, 0.013092041015625, -0.013580322265625, 1.00445556640625, 6.75, -10.2], // 2
	null,
	[0.95880126953125, 0.0074615478515625, -0.0078582763671875, 1.009246826171875, 6.95, -5.7], // 4
	null,
	[1.0101318359375, 0, 0, 0.9862060546875, -1.35, 2.65], // 6
	null,
	[1, 0, 0, 1, 0, 0], // 8
	null, null, null, null, null, null,
	[1.0307464599609376, 0, 0, 0.990753173828125, -4.05, 1.8], // 15
	null,
	[0.9689178466796875, -0.0119476318359375, 0.01239013671875, 1.00445556640625, 1.75, -6.95], // 17
	null,
	[0.958831787109375, -0.0052947998046875, 0.0055694580078125, 1.009246826171875, 4.4, -4], // 19
	null,
	[1.0101318359375, 0, 0, 0.9862060546875, -1.35, 2.65], // 21
	null,
	[1, 0, 0, 1, 0, 0], // 23
	null, null, null, null, null, null
];
static var bgColorData = [0xFF9E80DD, 0xFF6FC5E5, 0xFFDDD480, 0xFFDD8080, 0xFF88DD80, 0xFF8180DD];

var bg:FlxSprite;
var tv:TVScreen;
var curColor = FlxG.random.int(0, bgColorData.length - 1);

function onCreate()
{
	var charX = x - game.gfGroup.x;
	var charY = y - game.gfGroup.y;

	bg = new FlxSprite(charX + 124, charY - 14).makeGraphic(222, 161);
	bg.offset.set(-40, -150);
	// bg.scale.set(222, 161);
	// bg.updateHitbox();
	// nextBGColor();
	bg.color = bgColorData[curColor];

	tv = new TVScreen(charX, charY);
	tv.x += 146 * tv.scale.x;
	tv.y += 152 * tv.scale.y;
	tv.offset.set(-32, -3);
	// animation.callback = (n, f, _) -> applyMatrix(_danceLeft ? f : f + 15);

	setVar("gf_bg", bg);
	setVar("gf_tv", tv);
}

function onCreatePost()
{
	game.gfGroup.insert(0, bg);
	game.gfGroup.add(tv);

	var old_danceCharacters = game.danceCharacters;
	game.danceCharacters = curBeat ->
	{
		old_danceCharacters(curBeat);
		game.danceCharacter(tv, curBeat, tv.danceEveryNumBeats);
	}
}

function preNoteMiss(daNote:Note, strumLine:StrumLine)
{
	if (!daNote.noMissAnimation && game.combo > 5)
	{
		tv.playAnim("sad", true);
		tv.specialAnim = true;
	}
}

function noteMissPress(direction:Int)
{
	if (!game.boyfriend.stunned && game.combo > 20)
	{
		tv.playAnim("sad", true);
		tv.specialAnim = true;
	}
}

function onBeatHit(curBeat:Int) onBeat(curBeat);
function onCountdownTick(tick:Int) onBeat(tick);

function onBeat(beat:Int)
{
	if (ClientPrefs.flashing || beat % 2 == 0)
		nextBGColor();
}

function nextBGColor()
{
	curColor = (curColor + 1) % bgColorData.length;
	// bg.color = bgColorData[curColor];
}

var curFrame = -1;
function onUpdatePost(elapsed:Float)
{
	var tvColor = FlxColor.interpolate(bg.color, bgColorData[curColor], ClientPrefs.flashing ? 1 : 1 - Math.pow(0.95, elapsed * 60));
	tvColor = FlxColor.multiply(tvColor, color);
	bg.color = tvColor;
	tv.color = color;
	// bg.shader = tv.shader = shader;

	if (animation.curAnim.curFrame != curFrame)
	{
		curFrame = animation.curAnim.curFrame;
		applyMatrix(_danceLeft ? curFrame : curFrame + 15);
	}
}

function onGameOverStart()
{
	tv.skipDance = true;
	tv.playAnim("sad");
}

/*function onGameOverConfirm(restart:Bool)
{
	if (restart)
		tv.playAnim("imgay");
}*/

function applyMatrix(frame:Int)
{
	var matrix:Array<Float>;
	for (i => mat in tvMatrixData)
	{
		if (i > frame)
			break;

		if (mat != null)
			matrix = mat;
	}

	tv.transformMatrix.a = matrix[0];
	tv.transformMatrix.b = matrix[1];
	tv.transformMatrix.c = matrix[2];
	tv.transformMatrix.d = matrix[3];
	tv.transformMatrix.tx = matrix[4];
	tv.transformMatrix.ty = matrix[5];
}

class TVScreen extends Character
{
	public function new(x:Float, y:Float)
	{
		super(x, y, "tv");
		// matrixExposed = true;
	}

	override function drawComplex(camera:FlxCamera)
	{
		_frame.prepareMatrix(_matrix, 0, checkFlipX(), checkFlipY());
		// if (matrixExposed)
			_matrix.concat(transformMatrix);
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		// if (!matrixExposed)
			updateSkewToMatrix(_matrix);

		if (frameOffsetAngle == null || frameOffsetAngle == angle)
		{
			_matrix.translate(-__drawingOffset.x, -__drawingOffset.y);
		}
		else
		{
			var angleOff = (-angle + frameOffsetAngle) * FlxAngle.TO_RAD;
			_matrix.rotate(angleOff);
			_matrix.translate(-__drawingOffset.x, -__drawingOffset.y);
			_matrix.rotate(-angleOff);
		}

		getScreenPosition(_point, camera);
		_matrix.translate(_point.x - offset.x + origin.x, _point.y - offset.y + origin.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.ffloor(_matrix.tx);
			_matrix.ty = Math.ffloor(_matrix.ty);
		}

		doAdditionalMatrixStuff(_matrix, camera);

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}
}