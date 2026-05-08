package game.mobile.objects;

#if TOUCH_CONTROLS
import game.objects.FunkinSprite;
import game.objects.improvedFlixel.FlxCamera;
import game.backend.utils.ClientPrefs;
import game.backend.utils.CoolUtil;
import game.backend.utils.Controls;
import game.states.playstate.PlayState;

import flixel.input.touch.FlxTouch;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxG;

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;

enum abstract HintStatus(Int) from Int to Int
{
	var RELEASED = 0;
	var PRESSED = 1;
}

class MobileHint extends FunkinSprite
{
	static final HINT_ALPHA:Array<Float> = [0.00001, 0.3];
	static final BUTTON_HINT_ALPHA:Array<Float> = [0.72, 1.0];
	static final BUTTON_NAMES:Array<String> = ["left", "down", "up", "right"];

	public var ignoreZone:Array<FunkinSprite> = [];

	public var currentTouch:FlxTouch;

	public var status:HintStatus = HintStatus.RELEASED;

	public var noteIndex:Int;

	var useButtonStyle:Bool = false;
	var idleButtonGraphic:FlxGraphic;
	var pressedButtonGraphic:FlxGraphic;
	var buttonGraphicSize:Int = 0;
	var lastVisualStatus:HintStatus = HintStatus.RELEASED;

	public function new(x:Float = 0, y:Float = 0, width:Int, height:Int, color:FlxColor, noteIndex:Int, ?useButtonStyle:Bool = false, ?buttonSize:Int = 0):Void
	{
		super(x, y);

		this.noteIndex = noteIndex;
		this.useButtonStyle = useButtonStyle;

		if (useButtonStyle && buttonSize > 0 && createButtonGraphic(buttonSize))
		{
			this.alpha = BUTTON_HINT_ALPHA[0];
		}
		else
		{
			this.useButtonStyle = false;
			this.alpha = HINT_ALPHA[1];
			this.loadGraphic(createHintGraphic(width, height, color));
		}
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		handleTouch();

		final alphaValues:Array<Float> = useButtonStyle ? BUTTON_HINT_ALPHA : HINT_ALPHA;
		this.alpha = CoolUtil.fpsLerp(this.alpha, alphaValues[status], 0.3, elapsed);

		if (useButtonStyle)
			updateButtonVisual();
	}

	private function handleTouch():Void
	{
		final overlaps:Bool = checkOverlap();

		if (currentTouch == null) return;

		if (currentTouch.justReleased)
		{
			performRelease();
		}

		if (status == HintStatus.PRESSED && !overlaps)
		{
			performRelease(true);
		}
	}

	private function checkOverlap():Bool
	{
		for (camera in cameras)
		{
			for (touch in FlxG.touches.list)
			{
				final worldPos:FlxPoint = touch.getWorldPosition(camera, this._point);
				var ignoredByZone:Bool = false;

				for (object in ignoreZone)
				{
					if (object == null || !object.exists)
						continue;
					final ignoredWorldPos:FlxPoint = touch.getWorldPosition(camera, object._point);

					if (object.overlapsPoint(ignoredWorldPos, true, camera))
					{
						ignoredByZone = true;
						break;
					}
				}
				if (ignoredByZone)
					continue;

				if (overlapsPoint(worldPos, true, camera))
				{
					handleStatus(touch);
					return true;
				}
			}
		}

		return false;
	}

	private function handleStatus(touch:FlxTouch):Void
	{
		if (touch != null && (touch.justPressed || (touch.pressed && status == HintStatus.RELEASED)))
		{
			currentTouch = touch;
			performPress();
		}
	}

	private function performPress():Void
	{
		this.status = HintStatus.PRESSED;
		handleInput(this.noteIndex);
		updateButtonVisual();
	}

	private function performRelease(out:Bool = false):Void
	{
		if (!out) currentTouch = null;

		this.status = HintStatus.RELEASED;
		handleInput(this.noteIndex, true);
		updateButtonVisual();
	}

	private inline function getMobileButtonGraphic(name:String):FlxGraphic
	{
		return Paths.image('mobileUI/$name');
	}

	private function createButtonGraphic(buttonSize:Int):Bool
	{
		final noteName:String = BUTTON_NAMES[noteIndex % BUTTON_NAMES.length];
		idleButtonGraphic = getMobileButtonGraphic(noteName);
		pressedButtonGraphic = getMobileButtonGraphic('$noteName (2)');

		if (idleButtonGraphic == null && pressedButtonGraphic != null)
			idleButtonGraphic = pressedButtonGraphic;
		if (pressedButtonGraphic == null && idleButtonGraphic != null)
			pressedButtonGraphic = idleButtonGraphic;

		if (idleButtonGraphic == null)
			return false;

		loadGraphic(idleButtonGraphic);
		antialiasing = ClientPrefs.globalAntialiasing;
		setGraphicSize(buttonSize, buttonSize);
		updateHitbox();
		buttonGraphicSize = buttonSize;
		updateButtonVisual();
		return true;
	}

	private function updateButtonVisual():Void
	{
		if (!useButtonStyle)
			return;
		if (lastVisualStatus == status)
			return;

		lastVisualStatus = status;
		if (status == HintStatus.PRESSED && pressedButtonGraphic != null)
			loadGraphic(pressedButtonGraphic);
		else if (idleButtonGraphic != null)
			loadGraphic(idleButtonGraphic);

		if (buttonGraphicSize > 0)
		{
			setGraphicSize(buttonGraphicSize, buttonGraphicSize);
			updateHitbox();
		}
	}

	// Taken from https://github.com/FunkinDroidTeam/Funkin/blob/develop/source/funkin/mobile/ui/FunkinHitbox.hx
	// - sector
	private function createHintGraphic(width:Int, height:Int, color:FlxColor = 0xFFFFFFFF):FlxGraphic
	{
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(width, height, 0, 0, 0);

		var shape:Shape = new Shape();
		shape.graphics.beginGradientFill(RADIAL, [color, color], [0, 1], [60, 255], matrix, PAD, RGB, 0);
		shape.graphics.drawRect(0, 0, width, height);
		shape.graphics.endFill();

		var graphicData:BitmapData = new BitmapData(width, height, true, 0);
		graphicData.draw(shape, true);
		return FlxGraphic.fromBitmapData(graphicData, false, null, false);
	}

	@:access(game.states.playstate.PlayState)
	private static function handleInput(noteIndex:Int, shouldRelease:Bool = false):Void
	{
		if (PlayState.instance == null || Controls.instance == null) return;

		var bind:Array<Int> = Controls.instance.keyboardBinds.get(PlayState.instance.keysArray[noteIndex]);
		var key:Int = PlayState.getKeyFromEvent(PlayState.instance.keysArray, bind[0]);
		if (shouldRelease)
			PlayState.instance.keyReleased(key);
		else
			PlayState.instance.keyPressed(key);
	}
}

class MobileHitbox extends FlxTypedSpriteGroup<MobileHint>
{
	static final NOTE_COLORS:Array<FlxColor> = [FlxColor.PURPLE, FlxColor.CYAN, FlxColor.LIME, FlxColor.RED];

	var hintWidth:Int = Math.floor(FlxG.width / 4);
	var useVSliceLayout:Bool = false;

	public function new(x:Float = 0, y:Float = 0, ?useVSliceLayout:Bool)
	{
		super(x, y);

		this.useVSliceLayout = useVSliceLayout ?? (FlxG.onMobile && ClientPrefs.vSliceControls);
		createHitbox();
	}

	private function createHitbox():Void
	{
		if (useVSliceLayout)
			createVSliceHitbox();
		else
			createClassicHitbox();
	}

	private function createClassicHitbox():Void
	{
		for (i in 0...4)
		{
			final hint:MobileHint = new MobileHint(hintWidth * i, 0, hintWidth, FlxG.height, NOTE_COLORS[i], i);
			add(hint);
		}
	}

	private function createVSliceHitbox():Void
	{
		final minSize:Float = Math.min(FlxG.width, FlxG.height);
		final buttonSize:Int = Std.int(Math.max(64, minSize * 0.15));
		var spacing:Float = Math.max(24, buttonSize * 0.85);
		final maxSpacing:Float = (FlxG.width - buttonSize * 4) / 3;
		if (maxSpacing < spacing)
			spacing = Math.max(8, maxSpacing);
		final totalWidth:Float = buttonSize * 4 + spacing * 3;
		final startX:Float = (FlxG.width - totalWidth) * 0.5;
		final marginBottom:Float = Math.max(12, minSize * 0.06);
		final posY:Float = FlxG.height - buttonSize - marginBottom;

		for (i in 0...4)
		{
			final posX:Float = startX + i * (buttonSize + spacing);
			final hint:MobileHint = new MobileHint(posX, posY, buttonSize, buttonSize, NOTE_COLORS[i], i, true, buttonSize);
			add(hint);
		}
	}
}
#end