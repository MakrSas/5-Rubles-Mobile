import game.backend.utils.PathUtil;
import game.objects.improvedFlixel.FlxBGSprite;
import game.objects.game.BGSprite;

importHScriptClasses("scripts/classes/WalkingDude.hx");

var walkingDudesGrp:WalkingDudesGroup;
var lamps = new BGSprite('KrasnBeloe/lamps', -1058.57, -608.21);
var fade = new FlxBGSprite().makeGraphic(1, 1);
fade.color = FlxColor.BLACK;
fade.alpha = 0;

var allowErectBg = true;
var isPicoMix = game.SONG.song.toLowerCase() == "rubls-picomix";
var isErectBg = (allowErectBg && isPicoMix && ClientPrefs.shaders);

var hsvShader:FlxRuntimeShader;
var hsvCharsShader:FlxRuntimeShader;
var hsvLightShaderPlayer:FlxRuntimeShader;
var hsvLightShaderGf:FlxRuntimeShader;
var hsvLightShaderOpponent:FlxRuntimeShader;

if (isErectBg)
{
	var adjustColor = Assets.getText(AssetsPaths.fragShader("adjustColor"));

	hsvShader = new FlxRuntimeShader(adjustColor);
	hsvShader.setFloat("brightness", -40);
	hsvShader.setFloat("saturation", -62);
	hsvShader.setFloat("hue", -26);

	hsvCharsShader = new FlxRuntimeShader(adjustColor);
	hsvCharsShader.setFloat("brightness", -17);
	hsvCharsShader.setFloat("saturation", -62);
	hsvCharsShader.setFloat("hue", -26);

	var dropShadow = Assets.getText(AssetsPaths.fragShader("dropShadow"));
	function makeLightShader():FlxRuntimeShader
	{
		var hsvLightShader = new FlxRuntimeShader(dropShadow);
		hsvLightShader.setFloat("brightness", -17);
		hsvLightShader.setFloat("saturation", -62);
		hsvLightShader.setFloat("hue", -26);
		hsvLightShader.setFloatArray("multColor", [1, 1, 0.81, 1]);
		hsvLightShader.setInt("iBlendMode", 5);
		hsvLightShader.setFloatArray("offset", [10, -20]);
		hsvLightShader.setBool("rimLightMode", true);
		return hsvLightShader;
	}

	hsvLightShaderPlayer = makeLightShader();
	hsvLightShaderGf = makeLightShader();
	// hsvLightShaderGf.setFloatArray("offset", [0, -20]);
	hsvLightShaderOpponent = makeLightShader();
}

function addWithShader(obj:FlxBasic, front:Bool = false)
{
	// if (isErectBg)
		obj.shader = hsvShader;
	return addHxObject(obj, front);
}

function onCreatePost()
{
	var dir = "KrasnBeloe/" + (isErectBg ? "pico/" : "");
	addWithShader(new BGSprite("KrasnBeloe/floor", -2276.65 + 443, -695.24 + 1242));
	addHxObject(new BGSprite(dir + "inside", -2276.65 + 1280 + 537, -695.24 - 15 + 133 + 318, 0.85, 0.97));
	if (!isErectBg)
		addHxObject(new BGSprite("KrasnBeloe/mathew", 943.7, 136.3, 0.9, 0.985, ["мэтью фон"], true));
	addHxObject(new BGSprite(dir + "wall", -1504 - 300, -695.24));
	addHxObject(fade);
	lamps.alpha = isErectBg ? 0.4 : 0.1;
	lamps.shader = hsvCharsShader;
	addHxObject(lamps, true).blend = BlendMode.ADD;

	var scoreGroup = getVar('scoreGroup');
	scoreGroup.y += 20;
	scoreGroup.x += 200;

	var data = [
		{
			image: "KrasnBeloe/FGDudes",
			anims: ["ккчлуннаяпоходка"],
			offsetY: -50,
			jumpDurationMult: 1.2,
		},
		{
			image: "KrasnBeloe/FGDudes",
			anims: [(isPicoMix ? "быфенд" : "писогейпоходка")],
			offsetY: -100,
		},
		{
			image: "KrasnBeloe/FGDudes",
			anims: ["смпоходкагея"],
		}
	];
	walkingDudesGrp = new WalkingDudesGroup(data, -1300, 2700, 440, 500, 0.7, 30, 70);
	walkingDudesGrp.setShader(hsvCharsShader);
	addHxObject(walkingDudesGrp, true);
	graphicCache.cacheGraphic(Paths.image("KrasnBeloe/FGDudes"));

	if (isErectBg)
	{
		var overlay = new FlxBGSprite().makeGraphic(1, 1);
		overlay.color = 0xFF9197BD;
		overlay.blend = BlendMode.SUBTRACT;
		overlay.alpha = 0.1;
		add(overlay);

		dad.shader = hsvLightShaderPlayer;
		gf.shader = hsvLightShaderGf; // hsvCharsShader
		getVar("gf_bg").shader = hsvCharsShader;
		getVar("gf_tv").shader = hsvCharsShader;
		boyfriend.shader = hsvLightShaderOpponent;

		function rectToArray(rect:FlxRect):Array<Float>
			return [rect.x, rect.y, rect.width, rect.height];

		dad.animation.callback = (_, _, _) -> hsvLightShaderPlayer.setFloatArray("frameUv", rectToArray(dad.frame.uv));
		gf.animation.callback = (_, _, _) -> hsvLightShaderGf.setFloatArray("frameUv", rectToArray(gf.frame.uv));
		boyfriend.animation.callback = (_, _, _) -> hsvLightShaderOpponent.setFloatArray("frameUv", rectToArray(boyfriend.frame.uv));

		// walkingDudesGrp.active = true;
		// var bar = getVar("healthBar");
		// bar.leftBar.shader = bar.rightBar.shader = hsvCharsShader;
		// iconP1.shader = iconP2.shader = hsvCharsShader;
	}
}

var targetAlpha = 0;
function onEvent(name, value1, value2, value3)
{
	if (name.length == 0 && StringTools.trim(value1.toLowerCase()) == "fade")
	{
		switch (value2)
		{
			case "in":
				targetAlpha = 0.5;
			case "out":
				targetAlpha = 0;
			case "sex":
				targetAlpha = 0.8;
		}

		dura = CoolUtil.getDefault(Std.parseFloat(value3), 0.04);
	}
}

function onUpdate(e)
{
	if (fade.alpha != targetAlpha)
		fade.alpha = CoolUtil.fpsLerp(fade.alpha, targetAlpha, dura);
}

function onUpdatePost(e)
{
	if (isDead)
	{
		walkingDudesGrp.fade(((GameOverSubstate.instance?.bgColor ?? FlxColor.TRANSPARENT) >> 24) & 0xff);
	}
}

function onBeatHit(beat:Int)
{
	if (beat % 2 == 0)
	{
		walkingDudesGrp.dance(true);
	}
}

function onGameOverStart()
{
	targetAlpha = 0;
	remove(lamps);
	GameOverSubstate.instance.add(lamps);
	remove(walkingDudesGrp);
	GameOverSubstate.instance.add(walkingDudesGrp);
	boyfriend.shader = null;
}
