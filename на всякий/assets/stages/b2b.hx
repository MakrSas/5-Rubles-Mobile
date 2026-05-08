import game.objects.game.BGSprite;
importHScriptClasses("scripts/classes/ChromaKeyShader.hx");

var bgBop:BGSprite;
var fgBop:BGSprite;
var redar:BGSprite; // iPhone!!!! :D
var trx:BGSprite;
var lostel:BGSprite;

var allowErectBg = true;
var isPicoMix = game.SONG.song.toLowerCase() == "black2blue-picomix";
var isErectBg = (allowErectBg && isPicoMix && ClientPrefs.shaders);

var hsvHudShader:FlxRuntimeShader;
var hsvCharsShader:FlxRuntimeShader;
var hsvCharsShader2:FlxRuntimeShader;
var hsvCharsShader3:FlxRuntimeShader;

var onUpdatePost = null;
function onCreate()
{
	addHxObject(new FlxSprite(-3200 + 1586 + 367.125 - 180, -786.5 + 77.2 + 192.225, Paths.image("b2b/" + (isErectBg ? "pico/" : "") + "b2bBG")));
	if (!isErectBg)
	{
		bgBop = addDancer(new BGSprite("b2b/bezdare_bg", -950 - 20, -220.8 - 20, 1, 1, ["bg bop"], false), 0.85, false);
		fgBop = addDancer(new BGSprite("b2b/nebezdare_fg", 1196.9, 132.55, 1.4, 1.4, ["fg bop"], false), 1, true);
		redar = addDancer(new BGSprite("b2b/iphone_steamhappy", -1294.5, 451.1, 1.3, 1.3, ["redar_foreground"], true), 1, true);
		redar.animation.curAnim.loopPoint = 10;
		redar.zoomFactor = fgBop.zoomFactor = 0.75;
		redar.initialZoom = fgBop.initialZoom = defaultCamZoom;
		redar.drawAlways = fgBop.drawAlways = true;

		fgBop.shader = new ChromaKeyShader("characters/fake png shit");
		fgBop.shader.setScale(2.5);
		fgBop.animation.callback = (_, _, _) -> fgBop.shader.updateSprite(fgBop);
		fgBop.shader.updateSprite(fgBop);

		setVar("fgBop", fgBop);
		setVar("redar", redar);
	}
	else
	{
		//😭😭😭ПРОСТИТЕ
		hsvHudShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("adjustColor")));
		hsvHudShader.setFloat("brightness", -25);
		hsvHudShader.setFloat("contrast", -10);
		hsvHudShader.setFloat("saturation", -50);
		hsvHudShader.setFloat("hue", -4);

		var dropShadow = Assets.getText(AssetsPaths.fragShader("dropShadow"));
		function makeLightShader(offset:Array<Float>, colorAlpha:Float):FlxRuntimeShader
		{
			var shader = new FlxRuntimeShader(dropShadow);
			shader.setFloat("brightness", -25);
			shader.setFloat("contrast", -10);
			shader.setFloat("saturation", -50);
			shader.setFloat("hue", -4);
			shader.setFloatArray("multColor", [1, 1, 0.81, colorAlpha]);
			shader.setInt("iBlendMode", 5);
			shader.setFloatArray("offset", offset);
			shader.setBool("rimLightMode", true);
			return shader;
		}

		hsvCharsShader = makeLightShader([15, -15], 1);
		hsvCharsShader2 = makeLightShader([18, -18], 0.5);
		hsvCharsShader3 = makeLightShader([18, -18], 0.5);

		bgBop = addDancer(new BGSprite("b2b/pico/bg_dudes",40, -330, 1, 1, ["bg_kakashe"], false), 1, false);
		trx = addDancer(new BGSprite("b2b/pico/bg_dudes", 320, 200, 1, 1, ["тая айдл", "тая СМЕРТЬ"], false), 1, false);
		lostel = addDancer(new BGSprite("b2b/pico/bg_dudes", -640, 260, 1, 1, ["лостелпь"], false), 1, false);
		// TODO: отрендерить бг чудиков с уже наложенной hsv коррекцией
		bgBop.shader = hsvCharsShader;
		lostel.shader = hsvHudShader;
		trx.shader = makeLightShader([18, -18], 0.5);

		bgBop.animation.callback = (_, _, _) -> hsvCharsShader.setFloatArray("frameUv", rectToArray(bgBop.frame.uv));
		trx.animation.callback = (_, _, _) -> trx.shader.setFloatArray("frameUv", rectToArray(trx.frame.uv));

		setVar("trx", trx);
	}
}

function rectToArray(rect:FlxRect):Array<Float>
	return [rect.x, rect.y, rect.width, rect.height];

function onCreatePost()
{
	var scoreGroup = getVar("scoreGroup");
	scoreGroup.y += 180;
	scoreGroup.x += 40;
	if (isErectBg)
	{
		dad.shader = hsvHudShader;
		gf.shader = hsvCharsShader2;
		boyfriend.shader = hsvCharsShader3;

		gf.animation.callback = (_, _, _) -> hsvCharsShader2.setFloatArray("frameUv", rectToArray(gf.frame.uv));
		boyfriend.animation.callback = (_, _, _) -> hsvCharsShader3.setFloatArray("frameUv", rectToArray(boyfriend.frame.uv));

		// var bar = getVar("healthBar");
		// bar.leftBar.shader = bar.rightBar.shader = hsvHudShader;
		// iconP1.shader = iconP2.shader = hsvHudShader;
	}
}

function addDancer(spr:BGSprite, scale:Float, front:Bool)
{
	spr.scale.set(scale, scale);
	spr.updateHitbox();
	return front ? add(spr) : addHxObject(spr);
}

function onBeatHit(beat:Int)
{
	if (beat % 2 == 0)
	{
		// да х3
		bgBop.dance(true);
		if (!isErectBg)
		{
			fgBop.dance(true);
			redar.dance(true);
		}
		else
		{
			lostel.dance(true);
			if (trx.alive)
				trx.dance(true);
		}
	}
}

function onCountdownTick(tick:Int) onBeatHit(tick); // да

function onGameOverStart()
{
	getVar("gameOverApplyFade")(fgBop);
	remove(fgBop);
	GameOverSubstate.instance.add(fgBop);
	fgBop?.alpha = 0.5;
	if (isErectBg)
	{
		trx.shader = hsvHudShader;
		trx.animation.play("тая СМЕРТЬ");
		trx.alive = false;
	}
	gf.playAnim("sad", true);
	gf.specialAnim = true;
	gf.heyTimer = 0.6;
	boyfriend.shader = null;
}

FlxG.camera.bgColor = 0xFF989898;
function onDestroy() FlxG.camera.bgColor = FlxColor.BLACK;