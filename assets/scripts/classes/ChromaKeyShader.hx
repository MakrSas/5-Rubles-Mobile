import flixel.addons.display.FlxRuntimeShader;
import flixel.graphics.FlxGraphic;
import game.shaders.RuntimePostEffectShader;
import openfl.display.Bitmap;
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;

class ChromaKeyShader extends FlxRuntimeShader // TODO: Version of RuntimePostEffectShader for use in texture atlases
{
	public var bgTexture:ShaderInput<Bitmap>;
	public var bgFrameData:ShaderParameter<Float>;
	public var bgFrameUV:ShaderParameter<Float>;
	public var bgScale:ShaderParameter<Float>;
	public var bgOffset:ShaderParameter<Float>;
	public var spriteFrameData:ShaderParameter<Float>;
	public var spriteFrameUV:ShaderParameter<Float>;
	public var spriteFlipX:ShaderParameter<Bool>;
	public var spriteFlipY:ShaderParameter<Bool>;

	var lastFrame:FlxFrame;
	var sprite:FlxSprite;

	public function new(overlayImagePath:String)
	{
		super(Assets.getText(AssetsPaths.fragShader("chromaKey")));

		bgTexture = getBitmapInput("bgTexture");
		bgFrameData = getFloatParameter("bgFrameData");
		bgFrameUV = getFloatParameter("bgFrameUV");
		bgScale = getFloatParameter("bgScale");
		bgOffset = getFloatParameter("bgOffset");
		spriteFrameData = getFloatParameter("spriteFrameData");
		spriteFrameUV = getFloatParameter("spriteFrameUV");
		spriteFlipX = getBoolParameter("spriteFlipX");
		spriteFlipY = getBoolParameter("spriteFlipY");

		bgTexture.wrap = 2; // REPEAT
		// FlxG.signals.postUpdate.addOnce(() ->
		// {
			uploadImage(Paths.image(overlayImagePath));
		// });
	}

	public function uploadImage(graphic:FlxGraphic)
	{
		uploadFrame(graphic?.imageFrame?.frame);
	}

	public function uploadFrame(frame:FlxFrame)
	{
		var oldPixels = bgTexture.input;
		var pixels = frame?.parent?.bitmap;
		if (pixels != oldPixels)
			setFrameData(bgFrameData, bgFrameUV, frame);

		bgTexture.input = pixels;
	}

	public function updateSprite(sprite:FlxSprite)
	{
		// bgTexture.filter = (FlxSprite.allowAntialiasing && (sprite != null && sprite.camera.antialiasing || sprite.antialiasing)) ? FlxSprite.defaultTextureFilter : 5; // NEAREST
		spriteFlipX.value = [sprite?.checkFlipX()];
		spriteFlipY.value = [sprite?.checkFlipY()];

		var frame = sprite?.frame;
		if (frame != lastFrame)
			setFrameData(spriteFrameData, spriteFrameUV, frame);

		lastFrame = frame;
	}

	public function setScale(?x:Float, ?y:Float)
	{
		x ??= 1;
		bgScale.value = [x, y ?? x];
	}

	public function setOffset(?x:Float, ?y:Float)
	{
		bgOffset.value = [x ?? 0, y ?? 0];
	}

	function setFrameData(dataParam:ShaderParameter<Float>, uvParam:ShaderParameter<Float>, frame:FlxFrame)
	{
		if (frame == null)
		{
			dataParam.value = [0, 0, 1, 1];
			uvParam.value = [0, 0, 1, 1];
		}
		else
		{
			// frame.sourceSize.x, frame.sourceSize.y
			dataParam.value = [frame.offset.x, frame.offset.y, frame.parent.width, frame.parent.height];
			uvParam.value = [frame.uv.x, frame.uv.y, frame.uv.width, frame.uv.height];
			// trace("\n\n" + frame + "\n" + dataParam.value + "\n" + uvParam.value + "\n\n");
		}
	}
}