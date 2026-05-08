if (isPlayer)
{
	var dam = FlxG.random.bool(10);

	if (dam)
	{
		import flixel.addons.transition.FlxTransitionableState;

		game.graphicCache.cache(Paths.getSparrowAtlas("hernya_market/punch").parent);
		getVar("gameOverConfig").active = false;

		function onGameOverStart()
		{
			@:bypassAccessor GameOverSubstate.loopSoundName = GameOverSubstate.endSoundName = null;
			var damSpr:FlxSprite = new FlxSprite();
			damSpr.frames = Paths.getSparrowAtlas("hernya_market/punch");
			damSpr.animation.addByPrefix("anim", "смэрть", 24, false);
			damSpr.animation.play("anim");
			damSpr.scrollFactor.set();
			damSpr.setGraphicSize(FlxG.width * 1.05);
			damSpr.updateHitbox();
			damSpr.camera = game.camOther;
			// damSpr.animation.timeScale = 0.9;
			FlxG.camera.visible = false;
			game.camOther.visible = true;
			FlxTransitionableState.skipNextTransIn = true;
			GameOverSubstate.instance.allowSkip = false;
			GameOverSubstate.instance.add(damSpr.screenCenter());
			// damSpr.animation.callback = (name:String, frameNumber:Int, frameIndex:Int) -> {if(frameNumber > 14) Sys.exit();};
			damSpr.animation.finishCallback = _ -> FlxG.resetState(); // Sys.exit()
			return Function_Stop;
		}
	}
	else
	{
		import flxanimate.effects.FlxColorEffect;

		function onGameOverStart()
		{
			var bfCamPos = GameOverSubstate.instance.boyfriend.getCameraPosition();
			GameOverSubstate.instance.camFollowPos.x = bfCamPos.x - 160;
			GameOverSubstate.instance.camFollowPos.y = bfCamPos.y + 60;
			game.defaultCamZoom = 0.7;
		}

		var colorEffect = new FlxColorEffect();

		var zvonok:FlxLayer;
		var mikroo:FlxLayer;
		var stoltop:FlxLayer;

		function onCreatePost()
		{
			// Я ЕБАЛ FLXANIMATE КСТАТИ КТО НЕ ЗНАЛ
			// - рич
			var symbol = anim.symbolDictionary.get("sprait/expo/og/umer");
			zvonok = symbol.timeline.get("zvonok");
			mikroo = symbol.timeline.get("mikroo");
			stoltop = symbol.timeline.get("stoltop");
			zvonok.onFrameUpdate = applyFrameFade;
			mikroo.onFrameUpdate = applyFrameFade;
			stoltop.onFrameUpdate = applyFrameFade;
		}

		// внимание, очень хуевый код!!!
		// но на что не пойдешь ради нормальной работы с flxanimate😔😔
		function onUpdatePost(_)
		{
			if (!game.isDead)
				return;

			var mult = ((GameOverSubstate.instance?.bgColor ?? FlxColor.TRANSPARENT) >> 24) & 0xff;
			mult = 1 - (mult / 255);
			colorEffect.c_Transform.redMultiplier = colorEffect.c_Transform.greenMultiplier = colorEffect.c_Transform.blueMultiplier = mult;
			applyLayerFade(zvonok);
			applyLayerFade(mikroo);
			applyLayerFade(stoltop);
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
}
else
	dispose();