import openfl.geom.ColorTransform;

import flixel.FlxObject;
import flixel.input.keyboard.FlxKey;
import flixe.tween.FlxTween;
import flixel.effects.particles.FlxTypedEmitter;
import flixel.effects.particles.FlxEmitterMode;

import game.backend.utils.Highscore;
import game.objects.ParallaxSprite;
import game.objects.game.BGSprite;
import game.objects.improvedFlixel.FlxBGSprite;
import game.shaders.RuntimePostEffectShader;

importHScriptClasses("scripts/classes/LoopingGroup.hx");

function getRandomFactor():Float
	return FlxG.random.float(0.9, 1.1);

function forEachOptims(i:FlxBasic)
{
	if (i.graphic != null)
		graphicCache.cacheGraphic(i.graphic);
	i.active = i.forEach != null || i.animation?._curAnim != null;
	if (i.moves != null)
	{
		i.moves = hasVelocity(i) || hasAcceleration(i);
		i.active = i.active || i.moves;
	}
	if (i.forEach != null && !Std.isOfType(i, FlxTypedEmitter))
		i.forEach(forEachOptims); // погружение
}

function hasVelocity(basic:FlxBasic)
	return basic.velocity == null ? false : basic.velocity.x != 0 || basic.velocity.y != 0;

function hasAcceleration(basic:FlxBasic)
	return basic.acceleration == null ? false : basic.acceleration.x != 0 || basic.acceleration.y != 0;

// фаза 1 - против артёма
// фаза 2 - московский проспект руины
// фаза 3 - пятерочка кошмар
// фаза 4 - космос бг (раньше тут была монета...)
// фаза 5 - космос бг но В ОГОНЕ
var bgs:Array<FlxGroup> = [];
var fgs:Array<FlxGroup> = [];

var bgSpaceShader:RuntimePostEffectShader;

var mColorShader:FlxRuntimeShader;
// var nColorShader:FlxRuntimeShader;

var mDropShader:FlxRuntimeShader;
var nDropShader:FlxRuntimeShader;

var heatwaveShader:FlxRuntimeShader;
var heatwaveFilter:ShaderFilter;

var phaseTwoShader:FlxRuntimeShader;
// var phaseTwoShader1:FlxRuntimeShader;
// var phaseTwoShader2:FlxRuntimeShader;
// var phaseTwoShader3:FlxRuntimeShader;
// var phaseTwoShader4:FlxRuntimeShader;

var isUC = Highscore.formatSong(PlayState.SONG.song, "") == "under-construction";

function onCreate()
{
	if (ClientPrefs.shaders)
	{
		var adjustColor = Assets.getText(AssetsPaths.fragShader("adjustColor"));
		function makeAdjustColorShader(brightness = 0, contrast = 0, saturation = 0, hue = 0):FlxRuntimeShader
		{
			var shader = new FlxRuntimeShader(adjustColor);
			shader.setFloat("brightness", brightness);
			shader.setFloat("contrast", contrast);
			shader.setFloat("saturation", saturation);
			shader.setFloat("hue", hue);
			return shader;
		}

		var saturation = -20;
		mColorShader = makeAdjustColorShader(0, 0, saturation, 0);
		// nColorShader = makeAdjustColorShader(0, 0, saturation, 0);

		if (isUC)
		{
			var dropShadow = Assets.getText(AssetsPaths.fragShader("dropShadow"));
			mDropShader = new FlxRuntimeShader(dropShadow);
			nDropShader = new FlxRuntimeShader(dropShadow);

			bgSpaceShader = new RuntimePostEffectShader(Assets.getText(AssetsPaths.fragShader("spaceBG")));

			heatwaveShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("heatwave")));
			heatwaveShader.setFloat("speed", 6.5);
			heatwaveShader.setFloat("waves", 60);
			heatwaveShader.setFloat("amplitude", 0.0007);
			heatwaveFilter = new ShaderFilter(heatwaveShader);

			// phaseTwoShader1 = makeAdjustColorShader(-15, -12, -42, 0);
			// phaseTwoShader2 = makeAdjustColorShader(-8, -12, -30, 0);
			// phaseTwoShader3 = makeAdjustColorShader(-15, -12, -22, 0);
			// phaseTwoShader4 = makeAdjustColorShader(33, -12, -22, 0);

			// тест, потом надо нормальные шейдеры
			phaseTwoShader = makeAdjustColorShader(-15, -12, -42, 0);
		}

		FlxG.camera.setFilters([]);
		camHUD.setFilters([]);
	}

	createPhaseOne();
	if (isUC)
	{
		createPhaseTwo();
		createPhaseThree();
		createPhaseFour();
		createPhaseFive();
	}

	for (i in 0...bgs.length)
	{
		var bg = bgs[i];
		addBehindGF(bg);
		bg.forEach(forEachOptims);

		var fg = fgs[i];
		addAheadObject(fg, boyfriendGroup);
		fg.forEach(forEachOptims);
	}

	setVar("bgs", bgs);
	setVar("fgs", fgs);
}

var curPhase = -1;
function switchPhase(id:Int, ?flag:String)
{
	if (!FlxMath.inBounds(id, 1, bgs.length))
		return;

	// trace(id, flag);
	curPhase = id;
	setVar("curPhase", id);
	for (i in 0...bgs.length)
	{
		var exists = (i + 1) == id;
		bgs[i].exists = exists;
		fgs[i].exists = exists;
	}

	if (ClientPrefs.shaders)
	{
		dad.setColorTransform();
		boyfriend.setColorTransform();
		dad.shader = boyfriend.shader = null;
		dad.animation.callback = boyfriend.animation.callback = null;
		FlxG.camera.filters.resize(0);
		camHUD.filters.resize(0);

		switch id
		{
			case 1:
				dad.shader = mColorShader;
				boyfriend.shader = mColorShader; // nColorShader

			case 2:
				function setShit(obj:FlxObject, shader:FlxShader, colorMult:Float)
				{
					obj.setShader != null ? obj.setShader(shader) : obj.shader = shader;
					obj.setColorTransform(colorMult, colorMult, colorMult);
				}

				if (flag == "дождь")
				{
					var func = setShit.bind(_, phaseTwoShader, 0.62);
					bgs[1].forEach(func);
					fgs[1].forEach(func);
					func(dad);
					func(boyfriend);
				}
				else
				{
					var func = setShit.bind(_, null, 1);
					bgs[1].forEach(func);
					fgs[1].forEach(func);
				}

			case 4 | 5:
				dad.shader = mDropShader;
				boyfriend.shader = nDropShader;

				function rectToArray(rect:FlxRect):Array<Float>
					return [rect.x, rect.y, rect.width, rect.height];

				dad.animation.callback = (_, _, _) -> mDropShader.setFloatArray("frameUv", rectToArray(dad.frame.uv));
				boyfriend.animation.callback = (_, _, _) -> nDropShader.setFloatArray("frameUv", rectToArray(boyfriend.frame.uv));
				dad.animation.callback(null, null, null);
				boyfriend.animation.callback(null, null, null);

				var multColor = [0.168, 0.117, 0.082, 0.5];
				var offset = [20, -20];

				if (id == 5)
				{
					FlxG.camera.filters.push(heatwaveFilter);
					camHUD.filters.push(heatwaveFilter);

					var r = 80, g = 10, b = 10;
					dad.setColorTransform(1, 1, 1, 1, r, g, b);
					boyfriend.setColorTransform(1, 1, 1, 1, r, g, b);
					multColor[3] = 0.8;
					offset = [0, -40];
				}

				mDropShader.setFloatArray("multColor", multColor);
				mDropShader.setFloatArray("offset", offset);
				nDropShader.setFloatArray("multColor", multColor);
				nDropShader.setFloatArray("offset", offset);
		}
	}

	switch id
	{
		case 2:
			dad.scrollFactor.set(0.95, 0.98);
			boyfriend.scrollFactor.set(0.95, 0.98);

			#if DISCORD_RPC
			curPortrait = "uc_burned";
			resetRPC();
			#end

		default:
			dad.scrollFactor.set(1, 1);
			boyfriend.scrollFactor.set(1, 1);
	}
}

function onCreatePost()
{
	// закоментированно потому что прекэшинг 😔😔
	switchPhase(1);

	var scoreGroup = getVar("scoreGroup");
	if (scoreGroup != null)
	{
		scoreGroup.x += 580;
		scoreGroup.y += 120;
	}
}

function onUpdatePost(elapsed:Float)
{
	#if DEV_BUILD
	if (FlxG.keys.justPressed.ANY)
	{
		var key = FlxG.keys.firstJustPressed() - FlxKey.F1 + 1;
		if (key >= 1 && key <= 12)
			switchPhase(key);
	}
	#end
	if (ClientPrefs.shaders)
	{
		switch (curPhase)
		{
			case 4:
				bgSpaceShader.updateViewInfo(FlxG.camera, FlxG.camera.width, FlxG.camera.height);
				bgSpaceShader.data.iTime.value[0] += elapsed;

			case 5:
				heatwaveShader.setFloat("iTime", heatwaveShader.getFloat("iTime") + elapsed);
		}
	}
}

function onBeatHit(beat:Int)
{
	switch (curPhase)
	{
		case 4:
			phaseFourJbj.dance();

		case 5:
			phaseFiveJbj.dance();
	}
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "Switch BG":
			var id = Std.parseInt(value1);
			if (id != null)
				switchPhase(id, value2);
	}
}

function onGameOverStart()
{
	dad.setColorTransform();
	boyfriend.setColorTransform();
	dad.shader = boyfriend.shader = null;
	dad.animation.callback = boyfriend.animation.callback = null;
	FlxG.camera.filtersEnabled = camHUD.filtersEnabled = false;
	if (/*(startTimer != null && !startTimer.finished) &&*/ curPhase == -1)
		switchPhase(1);
}

function createPhaseOne()
{
	// фаза 1
	var path = "under_construction/phase1";
	var phaseOneBG = new FlxGroup();
	var phaseOneFG = new FlxGroup();

	var tumanBG = new TumanEmitter('$path/fog', 1, -1000, 3200, -380, 380, 1, 0.15, 2.6, 4.8);
	tumanBG.scrollFactor.set(0.76, 0.95);
	tumanBG.velocity.set(40, 120);

	var sky = phaseOneBG.add(new BGSprite('$path/sky', -1126.4, -1368.35, 0.4, 0.86));
	sky.scale.x = 3775;
	sky.updateHitbox();
	phaseOneBG.add(new BGSprite('$path/buildings', -1171, -852.95, 0.6, 0.89));
	phaseOneBG.add(new BGSprite('$path/wall', -1458.5, 9.55, 0.7, 0.92));
	phaseOneBG.add(new BGSprite('$path/bg', -1115.15, -485.15, 0.75, 0.93));
	// phaseOneBG.add(new BGSprite('$path/dunamite', -54.75, -89.25, 0.78, 0.94));
	phaseOneBG.add(tumanBG);
	phaseOneBG.add(new BGSprite('$path/bushes', -1013.55, 391.25, 0.96, 0.98));
	phaseOneBG.add(new BGSprite('$path/floor', -1259.8, -60.4));
	final lamp = phaseOneBG.add(new BGSprite('$path/lamp', 2075.65, -234.35, 1, 1, ["lamp norm"], true));
	lamp.animation.callback = (a, i, n) -> lamp.animation.timeScale = getRandomFactor();

	var tumanFG = new TumanEmitter('$path/fog', 1, -1000, 3200, 480, 1420, 1.35, 0.075, 1.6, 3);
	tumanFG.scrollFactor.set(1.4, 1.15);
	tumanFG.velocity.set(110, 250);

	phaseOneFG.add(tumanFG);

	// насрать туманом заранее
	// СРАЛИ ДАЛЬШЕ ЧЕМ ВИДЕЛИ!!!
	var mult = ClientPrefs.lowQuality ? 4 : 1;
	var tx = FlxG.random.float(1000, 1200);
	for (_ in 0...Std.int(FlxG.random.int(9, 11) / mult))
	{
		tumanBG.spawnTuman().x += tx * getRandomFactor();
		tx += FlxG.random.float(200, 500) * mult;
	}
	tx = FlxG.random.float(1000, 1200);
	for (_ in 0...Std.int(FlxG.random.int(10, 13) / mult))
	{
		tumanFG.spawnTuman().x += tx * getRandomFactor();
		tx += FlxG.random.float(200, 500) * mult;
	}

	bgs.push(phaseOneBG);
	fgs.push(phaseOneFG);
}

function createPhaseTwo()
{
	// фаза 2
	var path = "under_construction/phase2";
	var phaseTwoBG = new FlxGroup();
	var phaseTwoFG = new FlxGroup();

	var farScrollFactorX = 0.85;
	var farScrollFactorY = 1;

	var tumanBG = new TumanEmitter("under_construction/phase1/fog", 1, -1000, 3000, -140, 460, 1, 0.12, 2.8, 5.2);
	tumanBG.scrollFactor.set(0.76, 0.95);
	tumanBG.velocity.set(40, 120);

	// TODO: оптимизировать небо
	var sky = phaseTwoBG.add(new BGSprite('$path/sky', -1162.25, -727.1, 0.6, 0.86));
	sky.scale.x = 4105.95;
	sky.updateHitbox();
	var clouds = phaseTwoBG.add(new BGSprite('$path/clouds', -1263.8, -740.95, farScrollFactorX - 0.1, farScrollFactorY - 0.1));
	var building_left = phaseTwoBG.add(new BGSprite('$path/building_left', -1150.95, -239.1, farScrollFactorX - 0.02, farScrollFactorY - 0.05));
	var building_right = phaseTwoBG.add(new BGSprite('$path/building_right', 2180.6, -277.35, farScrollFactorX - 0.02, farScrollFactorY - 0.05));
	var moscow_zwizdet = phaseTwoBG.add(new BGSprite('$path/moscow_zwizdet', -250.9, -278.85, farScrollFactorX, farScrollFactorY));
	phaseTwoBG.add(tumanBG);

	// лень пусть так будет
	// а еще я устал время floor пятого утра спасити
	for (x in [-553.95, 433.3, 1211, 2421.3])
		for (i in (ClientPrefs.lowQuality ? 1...2 : 0...3))
			phaseTwoBG.add(new BGSprite('$path/flag', x + 88.25 * i, 220.9, farScrollFactorX, farScrollFactorY, ["flag"], true));

	var pol = phaseTwoBG.add(new ParallaxSprite(-1097.4, 362.35, Paths.image('$path/base')));
	pol.fixate(0, -1000, farScrollFactorX, farScrollFactorY, 1.05, 1.05);
	pol.pointOne.x -= 100;

	var tumanFG = new TumanEmitter("under_construction/phase1/fog", 1, -1400, 3400, 280, 1220, 1.35, 0.082, 1.5, 2.9);
	tumanFG.scrollFactor.set(1.425, 1.325);
	tumanFG.velocity.set(110, 250);

	phaseTwoFG.add(tumanFG);
	var sone_front = phaseTwoFG.add(new BGSprite('$path/stone_front', 1993.5, 930.95, 1.14, 1.08));

	// насрать туманом заранее
	// СРАЛИ ДАЛЬШЕ ЧЕМ ВИДЕЛИ!!!
	var mult = ClientPrefs.lowQuality ? 4 : 1;
	var tx = FlxG.random.float(1000, 1200);
	for (_ in 0...Std.int(FlxG.random.int(9, 11) / mult))
	{
		tumanBG.spawnTuman().x += tx * getRandomFactor();
		tx += FlxG.random.float(200, 500) * mult;
	}
	tx = FlxG.random.float(1000, 1200);
	for (_ in 0...Std.int(FlxG.random.int(10, 13) / mult))
	{
		tumanFG.spawnTuman().x += tx * getRandomFactor();
		tx += FlxG.random.float(200, 500) * mult;
	}

	bgs.push(phaseTwoBG);
	fgs.push(phaseTwoFG);
}

function createPhaseThree()
{
	// фаза 3
	var path = "under_construction/phase3";
	var phaseThreeBG = new FlxGroup();
	var phaseThreeFG = new FlxGroup();

	phaseThreeBG.add(new BGSprite('$path/bgSky', 391.8, 81.1, 0.8, 0.95)); // из оригинального бг
	phaseThreeBG.add(new BGSprite('$path/bg_all_in_one', -1052.2, -517.1));
	phaseThreeBG.add(new BGSprite('$path/drinks_shelves', 1919.9, 115.95));
	phaseThreeBG.add(new BGSprite('$path/cashDesk', 1208.9, -349.7)); // не судьба...

	var lamp = phaseThreeFG.add(new BGSprite('$path/lamp', 504.05, -256.7));
	phaseThreeFG.add(new BGSprite('$path/vign', -1102.2, -417.1, 1.2, 1.2));
	phaseThreeFG.add(new LampLight(101.15, -354, '$path/lamp_on', lamp));

	bgs.push(phaseThreeBG);
	fgs.push(phaseThreeFG);
}

var phaseFourJbj:BGSprite;
function createPhaseFour()
{
	// фаза 4
	var path = "under_construction/phase4";
	var phaseFourBG = new FlxGroup();
	var phaseFourFG = new FlxGroup();

	function randAngle(spr:FlxSprite, a:Float)
		spr.angle = FlxG.random.float(-a, a);

	if (bgSpaceShader != null)
	{
		var bgSpace = new FlxBGSprite();
		bgSpace.shader = bgSpaceShader;
		phaseFourBG.add(bgSpace);
	}

	var loopBG = new LoopingGroup(-1080, 2800, -450, 2200);

	function setupShit(spr:FlxSprite)
	{
		spr.setPosition(loopBG.x + FlxG.random.float(0, loopBG.width), loopBG.y + 300 + FlxG.random.float(0, loopBG.height - 1600));
		randAngle(spr, 45);
		spr.scale.x = spr.scale.y = FlxG.random.float(0.85, 1.15);
		spr.updateHitbox();
		spr.scrollFactor.set(0.9 * FlxG.random.float(0.9, 1) * spr.scale.x, 0.975 * FlxG.random.float(0.9, 1) * spr.scale.y);
		spr.velocity.set(FlxG.random.float(60, 100) * spr.scrollFactor.x, FlxG.random.float(-15, 15) * spr.scrollFactor.y);
		spr.angularVelocity = spr.velocity.x / 16 * FlxG.random.int(-1, 1, [0]);
	}

	var frames = Paths.getSparrowAtlas('$path/stuff_bg');
	var maxFramesID = frames.numFrames - 1;
	var usedFrames = [];
	for (i in 0...Std.int(frames.numFrames * (ClientPrefs.lowQuality ? 0.5 : 1)))
	{
		var shit = new FlxSprite();
		var frameID = FlxG.random.int(0, maxFramesID, usedFrames);
		shit.frames = frames;
		shit.frame = frames.frames[frameID];
		usedFrames.push(frameID);
		setupShit(shit);
		shit.x -= shit.width / 2;
		shit.y -= shit.height / 2;
		loopBG.add(shit);
	}
	loopBG.sort(scaleSort);

	phaseFourJbj = new BGSprite('$path/jbj', 900.75, 740.6, 0.85, 0.95, ["джбдж"], false);
	setupShit(phaseFourJbj);
	phaseFourJbj.angle = 0;
	loopBG.add(phaseFourJbj);
	loopBG.update(FlxG.random.float(2, 6));
	phaseFourBG.add(loopBG);
	phaseFourBG.add(new BGSprite('$path/platforms', -409, 1040));

	var loopFG = new LoopingGroup(-1080, 2800, -450, 2200);

	var frames = Paths.getSparrowAtlas('$path/stones_front');
	var maxFramesID = frames.numFrames - 1;
	var lastFrame = -1;
	for (i in 0...Std.int(frames.numFrames * (ClientPrefs.lowQuality ? 1 : 2)))
	{
		var shit = new FlxSprite();
		var frameID = FlxG.random.int(0, maxFramesID, [lastFrame]);
		lastFrame = frameID;
		shit.frames = frames;
		shit.frame = frames.frames[frameID];

		shit.setPosition(loopFG.x + FlxG.random.float(0, loopFG.width), loopFG.y + 1600 + FlxG.random.float(0, loopFG.height - 2000));
		randAngle(shit, 45);
		shit.scale.x = shit.scale.y = FlxG.random.float(0.85, 1.15);
		shit.updateHitbox();
		shit.scrollFactor.set(1.3 * FlxG.random.float(0.9, 1) * shit.scale.x, 1.085 * FlxG.random.float(0.9, 1) * shit.scale.y);
		shit.velocity.set(FlxG.random.float(40, 60) * shit.scrollFactor.x, 0); // FlxG.random.float(-10, 10) * shit.scrollFactor.y
		shit.angularVelocity = shit.velocity.x / 16 * FlxG.random.int(-1, 1, [0]);

		shit.x -= shit.width / 2;
		shit.y -= shit.height / 2;
		loopFG.add(shit);
	}

	loopFG.sort(scaleSort);
	loopFG.update(FlxG.random.float(2, 6));
	phaseFourFG.add(loopFG);

	bgs.push(phaseFourBG);
	fgs.push(phaseFourFG);
}

var phaseFiveJbj:BGSprite;
function createPhaseFive()
{
	// фаза 4
	var path = "under_construction/phase5";
	var phaseFiveBG = new FlxGroup();
	var phaseFiveFG = new FlxGroup();

	function randAngle(spr:FlxSprite, a:Float)
		spr.angle = FlxG.random.float(-a, a);

	var bg = phaseFiveBG.add(new BGSprite('$path/bg', -887.1, -473.05, 0.6, 0.85));
	bg.scale.x = 3677;
	bg.updateHitbox();
	var fire = phaseFiveBG.add(new BGSprite('$path/fire', -888.7, -721.55, 0.725, 0.91, ["fire"], true));
	fire.scale.x = fire.scale.y = 2;
	fire.updateHitbox();

	var loopBG = new LoopingGroup(-1080, 2800, -450, 2200);

	function setupShit(spr:FlxSprite)
	{
		spr.setPosition(loopBG.x + FlxG.random.float(0, loopBG.width), loopBG.y + 800 + FlxG.random.float(0, loopBG.height - 2000));
		randAngle(spr, 45);
		spr.scale.x = spr.scale.y = FlxG.random.float(0.85, 1.15);
		spr.updateHitbox();
		spr.scrollFactor.set(0.9 * FlxG.random.float(0.9, 1) * spr.scale.x, 0.975 * FlxG.random.float(0.9, 1) * spr.scale.y);
		spr.velocity.set(FlxG.random.float(80, 140) * spr.scrollFactor.x, FlxG.random.float(-10, 10) * spr.scrollFactor.y);
		spr.angularVelocity = spr.velocity.x / 16 * FlxG.random.int(-1, 1, [0]);
	}

	var frames = Paths.getSparrowAtlas('$path/stuff_bg');
	var maxFramesID = frames.numFrames - 1;
	var lastFrame = -1;
	for (i in 0...Std.int(frames.numFrames * (ClientPrefs.lowQuality ? 2 : 12)))
	{
		var shit = new FlxSprite();
		var frameID = FlxG.random.int(0, maxFramesID, [lastFrame]);
		lastFrame = frameID;
		shit.frames = frames;
		shit.frame = frames.frames[frameID];
		setupShit(shit);
		shit.x -= shit.width / 2;
		shit.y -= shit.height / 2;
		loopBG.add(shit);
	}
	loopBG.sort(scaleSort);

	phaseFiveJbj = new BGSprite('$path/jbj', 900.75, 740.6, 0.85, 0.95, ["джбдж"], false);
	setupShit(phaseFiveJbj);
	phaseFiveJbj.angle = 0;
	loopBG.add(phaseFiveJbj);
	loopBG.update(FlxG.random.float(2, 6));
	phaseFiveBG.add(loopBG);
	phaseFiveBG.add(new BGSprite('$path/platforms', -409 - 311, 1040 - 360));

	var loopFG = new LoopingGroup(-1080, 2800, -450, 2200);

	var emitter = new FlxTypedEmitter(loopFG.x, loopFG.y + loopFG.height - 400);
	emitter.loadParticles(Paths.image('$path/dustParticle'), ClientPrefs.lowQuality ? 100 : 400); // спизжено из фанкбокса, могу себе позволись
	emitter.launchMode = FlxEmitterMode.SQUARE;
	emitter.setSize(loopFG.width, 200);
	emitter.velocity.set(-100, -550, 100, -100);
	emitter.acceleration.set(-100, -550, 100, -100);
	emitter.alpha.set(0.5, 1, -1, -1);
	emitter.lifespan.set(6, 12); // умерают прямо на глазах пиздец
	emitter.keepScaleRatio = true;
	emitter.scale.set(1, 1, 4, 4);
	emitter.color.set(0xFFFFCC00, 0xFFFF9900);
	emitter.drag.set(0);
	emitter.start(false, ClientPrefs.lowQuality ? 0.2 : 0.01);
	phaseFiveFG.add(emitter);

	var frames = Paths.getSparrowAtlas('$path/stones_front');
	var maxFramesID = frames.numFrames - 1;
	var lastFrame = -1;
	for (i in 0...Std.int(frames.numFrames * (ClientPrefs.lowQuality ? 1 : 2)))
	{
		var shit = new FlxSprite();
		var frameID = FlxG.random.int(0, maxFramesID, [lastFrame]);
		lastFrame = frameID;
		shit.frames = frames;
		shit.frame = frames.frames[frameID];

		shit.setPosition(loopFG.x + FlxG.random.float(0, loopFG.width), loopFG.y + 1600 + FlxG.random.float(0, loopFG.height - 2000));
		randAngle(shit, 45);
		shit.scale.x = shit.scale.y = FlxG.random.float(0.85, 1.15);
		shit.updateHitbox();
		shit.scrollFactor.set(1.3 * FlxG.random.float(0.9, 1) * shit.scale.x, 1.085 * FlxG.random.float(0.9, 1) * shit.scale.y);
		shit.velocity.set(FlxG.random.float(60, 100) * shit.scrollFactor.x, 0); // FlxG.random.float(-10, 10) * shit.scrollFactor.y
		shit.angularVelocity = shit.velocity.x / 16 * FlxG.random.int(-1, 1, [0]);

		shit.x -= shit.width / 2;
		shit.y -= shit.height / 2;
		loopFG.add(shit);
	}

	loopFG.sort(scaleSort);
	loopFG.update(FlxG.random.float(2, 6));
	phaseFiveFG.add(loopFG);
	phaseFiveFG.add(new FlxBGSprite().makeGraphic(1, 1, 0x0BFF6600));

	bgs.push(phaseFiveBG);
	fgs.push(phaseFiveFG);
}

function scaleSort(order:Int, sprA:FlxSprite, sprB:FlxSprite)
	return sprA.scale.x < sprB.scale.x ? order : sprA.scale.x > sprB.scale.x ? -order : 0;

// TODO: немного переписать чтобы не было так говяно
class TumanEmitter extends FlxObject
{
	static final JUMP_CHANCE = 1 / 4096 * 100; // шайни покемон шанс лол, удачи братан

	var group:FlxGroup;
	var scale:Float;
	var alpha:Float;

	var minTime:Float;
	var maxTime:Float;
	var timer = 0;
	var spawnTime:Float;
	var lastY:Float;

	var texture:String;
	var maxIndex:Int;

	var shader:FlxShader;
	var colorTransform:ColorTransform;

	public function new(texture:String, maxIndex:Int, startX:Float, endX:Float, startY:Float, endY:Float, scale:Float, alpha:Float, minTime:Float, maxTime:Float)
	{
		super(startX, startY, endX - startX, endY - startY);
		group = new FlxGroup();
		this.texture = texture;
		this.maxIndex = maxIndex;
		this.scale = scale;
		var mult = ClientPrefs.lowQuality ? 4 : 1;
		this.minTime = minTime * mult;
		this.maxTime = maxTime * mult;
		spawnTime = getSpawnTime();
		this.alpha = alpha;
		colorTransform = new ColorTransform();
	}

	var goofyTweensOfGoofySprites:Map<FlxSprite, FlxTween> = [];
	public function spawnTuman():FlxSprite
	{
		final tuman = group.recycle(FlxSprite);
		var newTexture = texture + FlxG.random.int(0, maxIndex);
		if (tuman.graphic == null || tuman.graphic.assetsKey.indexOf(newTexture) == -1)
			tuman.loadGraphic(Paths.image(newTexture));

		tuman.scrollFactor.set(FlxG.random.float(scrollFactor.x, scrollFactor.x * 1.2), FlxG.random.float(scrollFactor.y, scrollFactor.y * 1.01));
		tuman.scale.set(FlxG.random.float(scale, scale * 1.3), FlxG.random.float(scale, scale * 1.3));
		tuman.updateHitbox();
		tuman.x = (FlxG.random.float(x, x * 1.2) - tuman.width);

		var diff = 30;
		// do {
			tuman.y = FlxG.random.float(y, y + height);
		// } while (lastY != null && FlxMath.equal(lastY, tuman.y, diff));
		var delta = tuman.y - lastY;
		var deltaAbs = Math.abs(delta);
		if (deltaAbs < diff)
			tuman.y += (diff - deltaAbs) * FlxMath.signOf(delta);
		lastY = tuman.y;

		tuman.velocity.x = FlxG.random.float(velocity.x, velocity.y);
		@:bypassAccessor tuman.alpha = Math.max(FlxG.random.float(this.alpha, this.alpha * 2), 0);
		tuman.colorTransform.alphaMultiplier = tuman.alpha;
		tuman.flipX = FlxG.random.bool();
		tuman.flipY = FlxG.random.bool();
		tuman.blend = BlendMode.ADD;
		tuman.moves = true;

		if (FlxG.random.bool(JUMP_CHANCE))
		{
			var tween = FlxTween.tween(tuman, {y: tuman.y - FlxG.random.float(80, 120)}, FlxG.random.float(0.4, 0.8),
			{
				type: FlxTween.PINGPONG,
				onComplete: t -> t.ease = (t.backward ? FlxEase.sineOut : FlxEase.sineIn), ease: FlxEase.sineIn
			});
			goofyTweensOfGoofySprites.set(tuman, tween);
		}

		tuman.shader = shader;
		tuman.setColorTransform(colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, tuman.alpha * colorTransform.alphaMultiplier);

		return tuman;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		group.update(elapsed);

		final right = (x + width);
		for (tuman in group.members)
		{
			if (/*tuman.exists &&*/ tuman.alive && tuman.x > right)
			{
				if (goofyTweensOfGoofySprites.exists(tuman))
				{
					goofyTweensOfGoofySprites.get(tuman).cancel();
					goofyTweensOfGoofySprites.remove(tuman);
				}
				tuman.kill();
			}
		}

		timer += elapsed;
		if (timer >= spawnTime)
		{
			timer -= spawnTime;
			spawnTime = getSpawnTime();
			spawnTuman();
		}
	}

	override public function draw()
	{
		super.draw();
		group.draw();
	}

	override public function destroy()
	{
		super.destroy();
		group?.destroy();
		group = null;
	}

	override function updateMotion(elapsed:Float) {}

	function getSpawnTime():Float
	{
		return FlxG.random.float(minTime, maxTime);
	}

	function setShader(shader:FlxShader)
	{
		this.shader = shader;
		for (spr in group.members)
			spr.shader = shader;
	}

	function setColorTransform(?redMultiplier:Float, ?greenMultiplier:Float, ?blueMultiplier:Float, ?alphaMultiplier:Float)
	{
		var oldAlphaMult = colorTransform.alphaMultiplier;
		colorTransform.redMultiplier = redMultiplier ?? 1;
		colorTransform.greenMultiplier = greenMultiplier ?? 1;
		colorTransform.blueMultiplier = blueMultiplier ?? 1;
		colorTransform.alphaMultiplier = alphaMultiplier ?? 1;
		for (spr in group.members)
			spr.setColorTransform(colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, spr.alpha / oldAlphaMult * colorTransform.alphaMultiplier);
	}
}

class LampLight extends FlxSprite
{
	var targetAlpha:Float;
	var alphaTimer:Float;
	var lamp:FlxSprite;

	public function new(x = 0, y = 0, texture:String, ?parent:FlxSprite)
	{
		super(x, y, Paths.image(texture));
		blend = BlendMode.ADD;
		alpha = randomAlpha();
		targetAlpha = randomAlpha();
		alphaTimer = randomTimer();
		lamp = parent;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		alpha = CoolUtil.fpsLerp(alpha, targetAlpha, 0.12);
		if (lamp != null)
		{
			var c = Math.floor(191.25 + 63.75 * (1 - alpha));
			lamp.color = FlxColor.fromRGB(c, c, c);
		}

		alphaTimer -= elapsed;
		if (alphaTimer <= 0)
		{
			targetAlpha = randomAlpha();
			alphaTimer += randomTimer();
		}
	}

	override function set_alpha(value:Float):Float
	{
		@:bypassAccessor alpha = FlxMath.bound(value, 0, 1);
		colorTransform.alphaMultiplier = alpha;
		// dirty = true;
		return alpha;
	}

	function randomAlpha():Float
		return FlxG.random.float(0.45, 0.9);

	function randomTimer():Float
		return FlxG.random.float(0.075, 0.35);
}
