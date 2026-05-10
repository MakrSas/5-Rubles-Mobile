package game.shaders;

import openfl.utils.Assets;

class RuntimeRainShader extends RuntimePostEffectShader
{
	public var intensity(get, set):Float;
	public var rainColor(get, set):Array<Float>;
	public var spriteMode(get, set):Bool;
	public var puddleY(get, set):Float;
	public var puddleScaleY(get, set):Float;

	public function new(?path:String)
	{
		path ??= AssetsPaths.fragShader("rain");
		super(Assets.exists(path) ? Assets.getText(path) : null, null, null);

		intensity = 0.0;
		rainColor = [0.75, 0.81, 0.9];
		spriteMode = false;
		puddleY = 0.0;
		puddleScaleY = 1.0;
		setFloat("uTime", 0.0);
		setInt("numLights", 0);
	}

	public function update(elapsed:Float):Void
	{
		setFloat("uTime", getFloat("uTime") + elapsed);
	}

	function get_intensity():Float
		return getFloat("uIntensity");

	function set_intensity(value:Float):Float
	{
		setFloat("uIntensity", value);
		return value;
	}

	function get_rainColor():Array<Float>
		return getFloatArray("uRainColor");

	function set_rainColor(value:Array<Float>):Array<Float>
	{
		setFloatArray("uRainColor", value);
		return value;
	}

	function get_spriteMode():Bool
		return getBool("uSpriteMode");

	function set_spriteMode(value:Bool):Bool
	{
		setBool("uSpriteMode", value);
		return value;
	}

	function get_puddleY():Float
		return getFloat("uPuddleY");

	function set_puddleY(value:Float):Float
	{
		setFloat("uPuddleY", value);
		return value;
	}

	function get_puddleScaleY():Float
		return getFloat("uPuddleScaleY");

	function set_puddleScaleY(value:Float):Float
	{
		setFloat("uPuddleScaleY", value);
		return value;
	}
}
