if (true && PlayState.SONG.song.toLowerCase() == "hernyamorumix" && ClientPrefs.shaders)
{
	import flxanimate.effects.FlxColorEffect;

	var colorEffect = new FlxColorEffect();

	function onCreate()
	{
		colorEffect.c_Transform.redMultiplier = colorEffect.c_Transform.greenMultiplier = colorEffect.c_Transform.blueMultiplier = 0.5;
	}

	// внимание, очень хуевый код!!!
	// но на что не пойдешь ради нормальной работы с flxanimate😔😔
	function onUpdatePost(_)
	{
		var symbol = anim.curSymbol;
		var stol = symbol.timeline.get("Layer_2");
		applyLayerFade(stol);
		if (stol.onFrameUpdate == null)
			stol.onFrameUpdate = applyFrameFade;
	}

	function applyLayerFade(layer:FlxLayer)
	{
		applyFrameFade(null, layer._currFrame ?? layer.get(0));
	}

	function applyFrameFade(_, frame:FlxKeyFrame)
	{
		if (frame.colorEffect == null)
			frame.colorEffect = colorEffect;
	}
}
else
	dispose();