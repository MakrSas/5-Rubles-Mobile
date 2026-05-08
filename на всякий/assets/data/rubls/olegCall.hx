loadHScript(AssetsPaths.getPath("data/toilet_tivi.hx"));
var zvonok:FlxSprite;

function onCreatePost()
{
	zvonok = new FlxSprite();
	zvonok.antialiasing = true;
	zvonok.frames = Paths.getSparrowAtlas("KrasnBeloe/olegaloalo");
	zvonok.animation.addByPrefix("idle", "discord_call", 24);
	zvonok.animation.play("idle");
	zvonok.camera = camHUD;
	zvonok.alpha = FlxMath.EPSILON;
	zvonok.scale.set(0.9, 0.9);
	add(zvonok.screenCenter());
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "")
		switch (value1)
		{
			case "звонок":
				FlxTween.tween(zvonok, {alpha: 1, "scale.x": 1, "scale.y": 1}, 5 / 25, {ease: FlxEase.quintOut});

			case "сыбался":
				zvonok.velocity.set(FlxG.random.float(300, 520) * (FlxG.random.bool() ? -1 : 1), FlxG.random.float(-1000, -1600));
				zvonok.acceleration.y = -zvonok.velocity.y * 2;
				zvonok.angularVelocity = zvonok.velocity.x * 1.5;

				var time = zvonok.acceleration.y / 2200 * 3.5;
				FlxTween.color(zvonok, time, FlxColor.WHITE, FlxColor.fromRGB(128, 128, 128, 128));
				FlxTween.num(1, 0.85, time, null, s -> zvonok.scale.set(s, s));

				var intensity = 0.02;
				var duration = 4 / 24;
				FlxG.camera.shake(intensity, duration);
				camHUD.shake(intensity, duration);
		}
}