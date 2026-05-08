loadHScript("data/duoCameras.hx");

var allowErectBg = true;
var isRedarMix = game.SONG.song.toLowerCase() == "nokiaredarmix";
var isErectBg = (allowErectBg && isRedarMix && ClientPrefs.shaders);

var directoryMix = "nokia/mix/";

var camPlayer:CoolCamera;
var camOpponent:CoolCamera;
var redarBG:FlxSpriteGroup;
var zorkaBG:FlxSpriteGroup;
var palka:TwistSprite;
var zorkaLight:FlxSprite;
var redarLight:FlxSprite;
var redarVign:FlxSprite;

function onCreate()
{
	camPlayer = getVar("camPlayer");
	camOpponent = getVar("camOpponent");

	var dadGrRef = dadGroup;
	var bfGrRef = boyfriendGroup;

	if (isRedarMix)
	{
		dadGrRef = boyfriendGroup;
		bfGrRef = dadGroup;
	}

	redarBG = new FlxSpriteGroup(dadGrRef.x - 246, dadGrRef.y - 247);
	redarBG.add(new FlxSprite(527.05 - 10.8, 0, Paths.image('nokia/wall'))).scrollFactor.set(0.82, 0.82);
	redarBG.add(new FlxSprite(622.45 - 10.8, 256 - 32.8, Paths.image('nokia/behind-stand-and-teto'))).scrollFactor.set(0.88, 0.88);
	redarBG.add(new FlxSprite(0, 0, Paths.image('nokia/outsideStore')));
	if (isErectBg)
	{
		redarLight = redarBG.add(new FlxSprite(-1.95, 102.9, Paths.image(directoryMix + 'window-light')));
		redarVign = redarBG.add(new FlxSprite(-3.9, 35.25, Paths.image(directoryMix + 'redarGradient')));
		redarVign.blend = SUBTRACT;
		redarLight.blend = ADD;
	}
	addHxObject(redarBG);

	zorkaBG = new FlxSpriteGroup(bfGrRef.x - 150, bfGrRef.y - 307);
	var sky = zorkaBG.add(new FlxSprite(-110, -135, Paths.image((isErectBg ? directoryMix : "nokia/") + "Sky")));
	sky.scrollFactor.set(0.15, 0.15);
	zorkaBG.add(new FlxSprite(1221.6 - 1100.5, 134.9 - 70, Paths.image('nokia/faraway'))).scrollFactor.set(0.2, 0.2);
	zorkaBG.add(new FlxSprite(1110.9 - 1000, 317.5 - 27.25, Paths.image('nokia/house-behind'))).scrollFactor.set(0.7, 0.82);
	zorkaBG.add(new FlxSprite(0, 0, Paths.image('nokia/dvor')));
	// по идее лопата должа быть перед зорькой, но камера бг и так не широкий так что как-то пофигу -redar
	zorkaBG.add(new FlxSprite(964 - 978.5, 832.4 - 27.25, Paths.image('nokia/shovel-front'))).scrollFactor.set(1.32, 1.32);
	if (isErectBg)
	{
		zorkaVign = zorkaBG.add(new FlxSprite(-3.9, 35.25, Paths.image(directoryMix + 'zorkaGradient')));
		zorkaLight = zorkaBG.add(new FlxSprite(945.75 - 878.5, 35.25 - 27.25, Paths.image(directoryMix + 'light-from-sky')));
		zorkaLight.scrollFactor.set(1.32, 1.32);
		zorkaLight.blend = ADD; // OVERLAY
		zorkaVign.blend = SUBTRACT;
	}
	addHxObject(zorkaBG);

	if (isRedarMix)
	{
		dadGrRef.camera = camPlayer;
		bfGrRef.camera = camOpponent;
	}
	else
	{
		dadGrRef.camera = camOpponent;
		bfGrRef.camera = camPlayer;
	}
	redarBG.camera = dadGrRef.camera;
	zorkaBG.camera = bfGrRef.camera;

	var shaders = [];
	if (isErectBg)
	{
		var shaderRaw = Assets.getText(AssetsPaths.fragShader("adjustColor"));
		function makeAdjustColor(brightness:Float, contrast:Float, saturation:Float, hue:Float)
		{
			var shader = new FlxRuntimeShader(shaderRaw);
			shader.setFloat("brightness", brightness);
			shader.setFloat("contrast", contrast);
			shader.setFloat("saturation", saturation);
			shader.setFloat("hue", hue);
			return shader;
		}

		// шейдер редара
		shaders.push(makeAdjustColor(-72, -23, -42, -25));
		// шейдер зорьки
		shaders.push(makeAdjustColor(-44, -4, -17, -14));
	}

	for (i => sprGroup in [redarBG, zorkaBG])
	{
		var atRedarBG = sprGroup == redarBG;
		sprGroup.scale.set(sprGroup.scale.x * 1.2, sprGroup.scale.y * 1.2);
		sprGroup.moves = false;
		sprGroup.origin.set(sprGroup.width / 2, sprGroup.height / 2);
		for (spr in sprGroup)
		{
			spr.x += sprGroup.x * (spr.scrollFactor.x - 1) / sprGroup.scale.x;
			spr.y += sprGroup.y * (spr.scrollFactor.y - 1) / sprGroup.scale.y;
			spr.origin.set(sprGroup.origin.x - spr.x + sprGroup.x, sprGroup.origin.y - spr.y + sprGroup.y);
			if (isErectBg)
			{
				spr.shader = shaders[i];
				if (atRedarBG)
					spr.setColorTransform(0.57, 0.57, 0.57, 1, 20, -7);
				else
					spr.setColorTransform(0.74, 0.74, 0.74, 1, -5, -11);
			}
		}
	}

	if (isErectBg)
	{
		for (i in [redarLight, redarVign, zorkaLight, zorkaVign, sky])
		{
			i.setColorTransform();
			i.shader = null;
		}
		redarVign.alpha = 0.48;
		redarLight.alpha = 0.24;
		zorkaLight.alpha = 0.12; // 0.3
	}
}

function onCreatePost()
{
	palka = new TwistSprite(0, 0, Paths.image("nokia/poloska"));
	palka.frames = Paths.getSparrowAtlas("nokia/poloska");
	palka.animation.addByPrefix("loopPalka", "палкааа", 24, true);
	palka.animation.play("loopPalka");
	palka.camera = camHUD;
	palka.zoomFactor = 0;
	palka.screenCenter(XY);
	palka.x += 5;
	insert(0, palka);

	// getVar("gameOverApplyFade")(palka);

	if (isErectBg)
	{
		var shaderRaw = Assets.getText(AssetsPaths.fragShader("dropShadow"));
		function makeRimLight(multColor:Array<Float>, offset:Array<Float>, blend:Int, hue:Float, saturation:Float, brightness:Float, contrast:Float):FlxRuntimeShader
		{
			var shader = new FlxRuntimeShader(shaderRaw);
			shader.setFloatArray("multColor", multColor);
			shader.setFloatArray("offset", offset);
			shader.setInt("iBlendMode", blend);
			shader.setBool("rimLightMode", true);
			shader.setFloat("hue", hue);
			shader.setFloat("saturation", saturation);
			shader.setFloat("brightness", brightness);
			shader.setFloat("contrast", contrast);
			return shader;
		}

		dad.setColorTransform(1, 1, 1, 1, 11, -13, 0, 0);
		var zorkaShader = makeRimLight([186 / 255, 154 / 255, 121 / 255, 1], [20, -20], HARDLIGHT, 3, -17, -12, -8);
		dad.shader = zorkaShader;

		boyfriend.setColorTransform(0.77, 0.77, 0.77);
		var redarShader = makeRimLight([104 / 255, 76 / 255, 66 / 255, 0.21], [25, -25], ADD, -20, -16, -8, 0);
		boyfriend.shader = redarShader;

		function rectToArray(rect:FlxRect):Array<Float>
			return [rect.x, rect.y, rect.width, rect.height];

		dad.animation.callback = (_, _, _) -> zorkaShader.setFloatArray("frameUv", rectToArray(dad.frame.uv));
		boyfriend.animation.callback = (_, _, _) -> redarShader.setFloatArray("frameUv", rectToArray(boyfriend.frame.uv));
		dad.animation.callback(null, null, null);
		boyfriend.animation.callback(null, null, null);
	}
}

function onGameOverStart()
{
	remove(palka);
	GameOverSubstate.instance.add(palka);
	palka.camera = camOther;
	camOther.visible = true;
	var colorTransform = palka.colorTransform;
	FlxTween.num(1.0, 0.0, 0.9, {ease: FlxEase.sineInOut}, i -> {
		// colorTransform.redOffset = colorTransform.greenOffset = colorTransform.blueOffset = i;
		palka.color = FlxColor.fromRGBFloat(i, i, i);
	});
	boyfriend.shader = null;
}

// function onGameOverConfirm(restart:Bool)
// {
// 	if (!getVar("gameOverConfig").active)
// 		return;

// 	if (restart)
// 	{ // todo: better palka trans
// 		// trace("fuck");
// 		// var colorTransform = palka.colorTransform;
// 		// FlxTween.num(colorTransform.redOffset, -50.0, 2.0, null, i -> {
// 		// 	colorTransform.redOffset = colorTransform.greenOffset = colorTransform.blueOffset = i;
// 		// });
// 	}
// 	// else
// }