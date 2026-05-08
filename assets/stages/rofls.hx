import openfl.geom.ColorTransform;

import flixel.util.FlxSort;

import game.objects.improvedFlixel.FlxBGSprite;

importHScriptClasses("scripts/classes/WalkingDude.hx");
importHScriptClasses("scripts/classes/ChromaKeyShader.hx");

var allowErectBg = true;
var isPivoMix = game.SONG.song.toLowerCase() == "roflspivomix";
var isErectBg = (allowErectBg && isPivoMix && ClientPrefs.shaders);

var walkingDudesGrp:WalkingDudesGroup;
var snakeBop:BGSprite;

var juztNeatReact:BGSprite;

var tables:FlxSprite;
var fradeTarget = 0;
var fag:FaggotSpawner;

if (isErectBg)
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

	//😅
	hsvShader1 = makeAdjustColorShader(0, -36, -13, -67);
	hsvShader2 = makeAdjustColorShader(40, -36, -13, -36);
	hsvShader3 = makeAdjustColorShader(-21, -36, -13, 21);
	hsvCharsShader = makeAdjustColorShader(-11, -25, -30, -10);
	hsvMaseerShader = makeAdjustColorShader(0, 0, 0, -25);
	hsvSnakeShader = makeAdjustColorShader(0, 0, 0, 50);
}

function addObj(obj:FlxSprite, front:Bool, scrollX:Float, scrollY:Float)
{
	obj.active = false;
	obj.scrollFactor.set(scrollX, scrollY);
	return addHxObject(obj, front);
}

var offsetParameter = null;
function onCreate()
{
	var mult = isPivoMix ? 1 : 3;

	bgass = addObj(new FlxSprite(-874, -536, Paths.image("rofls/background")), false, 1.3, 1.1);
	fag = addHxObject(new FaggotSpawner(-1100, -1100 + 4200, 300, 360, 1.3, 1.1, 1.8 * mult, 4.2 * mult));
	pillars = addObj(new FlxSprite(-299, -206, Paths.image("rofls/pillars")), false, 1.225, 1.1);
	railingDOWN = addObj(new FlxSprite(-491 - 100, 250, Paths.image("rofls/railingDOWN")), false, 1.225, 1.1);
	railing = addObj(new FlxSprite(-769, -446, Paths.image("rofls/railing")), false, 1.225, 1.1);
	if (isPivoMix)
	{
		siska = addObj(new FlxSprite(-281, -603, Paths.image("rofls/light")), false, 1.22, 1.1);
		siska.blend = BlendMode.ADD;
		siska.alpha = 0.2;
		gradient1 = addObj(new FlxSprite(-488, -543, Paths.image("rofls/gradient")), false, 1.22, 1.1);
		gradient1.scale.x = 2700;
		gradient1.updateHitbox();
	}
	bullshit2 = addObj(new FlxSprite(28, -686, Paths.image("rofls/bullshit2")), false, 1.15, 1.065);
	escalator = addObj(new FlxSprite(-1224, 175, Paths.image("rofls/escalator")), false, 1.12, 1.1);
	bullshit1 = addObj(new FlxSprite(-366, -918, Paths.image("rofls/bullshit1")), false, 1.1, 1.035);

	if (isPivoMix)
	{
		import flixel.effects.particles.FlxTypedEmitter;
		import flixel.effects.particles.FlxEmitterMode;
		import flixel.effects.particles.FlxParticle;
		import game.objects.improvedFlixel.FlxCustomBGSprite;

		var bgBlack = new FlxCustomBGSprite();
		bgBlack.color = 0xff000000;
		addBehindObject(bgBlack, dadGroup);
		bgBlack.alpha = 0;

		var emitter = new FlxTypedEmitter(-550, 1200, 0);
		emitter.makeParticles(10, 10, FlxColor.WHITE, ClientPrefs.lowQuality ? 100 : 400);
		emitter.launchMode = FlxEmitterMode.SQUARE;
		emitter.setSize(FlxG.width * 3, 200);
		emitter.velocity.set(-10, -550, 10, -100);
		emitter.alpha.set(0.5, 1, -1, -1);
		emitter.lifespan.set(6, 12); //умерают прямо на глазах пиздец
		emitter.angle.set(0, 90);
		emitter.keepScaleRatio = true;
		emitter.scale.set(2, 2, 4, 4);
		emitter.angularVelocity.set(-90, 90);
		emitter.drag.set(0);
		emitter.start(false, ClientPrefs.lowQuality ? 0.2 : 0.01);
		emitter.emitting = false;

		onEvent = (name:String, value1:String, value2:String, value3:String) ->
		{
			switch (name)
			{
				case "":
					emitter.emitting = value1 != "";

				case "Dark Event In Rofls bcs i lazy":
					switch (value1)
					{
						case "1":
							final alphaFactor = 0.6;
							final time = 0.6;
							FlxTween.num(0, alphaFactor, time, null, bgBlack.set_alpha);
							FlxTween.num(1, alphaFactor, time, null, i ->
							{
								dad.setColorTransform(i, i, i);
								fradeTarget = Std.int((1 - i) * 255);
							});
							FlxTween.num(0.65, 0.65 - 0.65 * alphaFactor, time, null, i -> tables.setColorTransform(i, i, i));

						case "2":
							FlxTween.num(dad.colorTransform.redMultiplier, 1, 0.6, null, i -> dad.setColorTransform(i, i, i));

						case "3":
							var alphaFactor = 0.6;
							var time = 1.6;
							FlxTween.num(bgBlack.alpha, 0, time, null, bgBlack.set_alpha);
							FlxTween.num(0.6, 1, time, null, i -> fradeTarget = Std.int((1 - i) * 255));
							FlxTween.num(tables.colorTransform.redMultiplier, 0.65, time, null, i -> tables.setColorTransform(i, i, i));
					}

			}
		}
		addHxObject(emitter);
	}

	bgfront = new FlxSprite(-1416, -673, Paths.image("rofls/bgfront"));
	addObj(bgfront, false, 1, 1);

	snakeBop = addObj(new FlxSprite(1900, 150), false, .975, .975);
	snakeBop.active = true;
	snakeBop.scale.set(1.1, 1.1);
	snakeBop.frames = Paths.getSparrowAtlas("rofls/snake");
	snakeBop.animation.addByIndices("left", "пур снай0", [0, 1, 2, 3, 4, 5, 6, 7, 8], "", 24, false);
	snakeBop.animation.addByIndices("right", "пур снай0", [9, 10, 11, 12, 13, 14, 15, 16, 17], "", 24, false);
	snakeBop.animation.addByPrefix("YMER?", "пур снай СМЕРТЬ0", 1, false);
	snakeBop.animation.play("right", true);

	addObj(tables = new FlxSprite(-1342, 598, Paths.image("rofls/tables")), true, 1, 1);
	addAheadObject(table = new FlxSprite(488, 606, Paths.image("rofls/table")), gfGroup);

	gfGroup.visible = isPivoMix;

	if (isPivoMix)
	{
		gfGroup.x -= 950;
		juztNeatReact = addAheadObject(new FlxSprite(600, 300), table);
		juztNeatReact .scrollFactor.set(1, 1);
		juztNeatReact.frames = Paths.getSparrowAtlas("rofls/juztReact");
		juztNeatReact.animation.addByIndices("left", "happyIDLE0", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
		juztNeatReact.animation.addByIndices("right", "happyIDLE0", [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28], "", 24, false);
		juztNeatReact.animation.addByPrefix("ew", "concernedIDLE0", 24, false);
		juztNeatReact.animation.play("right", true);
		juztNeatReact.shader = new ChromaKeyShader("characters/fake png shit");

		juztNeatReact.shader.setFloat("brightness", -11);
		juztNeatReact.shader.setFloat("contrast", -25);
		juztNeatReact.shader.setFloat("saturation", -30);
		juztNeatReact.shader.setFloat("hue", -10);

		juztNeatReact.animation.callback = (_, _, _) -> juztNeatReact.shader.updateSprite(juztNeatReact);
		juztNeatReact.shader.updateSprite(juztNeatReact);
	}


	if (!isPivoMix)
		addObj(hair = new FlxSprite(396, 1000, Paths.image("rofls/hair")), false, 1, 1);
	getVar("gameOverApplyFade")(tables);


	var data = [
		{
			image: "rofls/passers",
			anims: ["рич"]
		},
		{
			image: "rofls/passers",
			anims: ["сектор"],
			offsetY: 20
		},
		{
			image: "rofls/passers",
			anims: ["норка"]
		},
		{
			image: "rofls/passers",
			anims: ["яички"],
			offsetY: -200
		},
		{
			image: "rofls/passers",
			anims: ["быфенд"]
		},
		{
			image: "rofls/passers",
			anims: ["симон"],
			offsetY: -120
		},
		{
			image: "rofls/passers",
			anims: ["альтушка"],
			offsetY: -20
		}
	];
	walkingDudesGrp = addHxObject(new WalkingDudesGroup(data, -1600, -1600 + 5270, 350, 410, 0.75, 15 * mult, 35 * mult), true);
	graphicCache.cacheGraphic(Paths.image("rofls/passers"));
}

function onCreatePost()
{
	FlxG.camera.bgColor = 0xFF383838;
	var scoreGroup = getVar("scoreGroup");
	if (isPivoMix)
	{
		scoreGroup.y -= 140;
		scoreGroup.x += 130;
	}
	else
	{
		scoreGroup.y -= 40;
		scoreGroup.x += 240;
	}

	if (isErectBg)
	{
		dad.shader = hsvCharsShader;
		boyfriend.shader = hsvCharsShader;
		gf.shader = hsvMaseerShader;
		gf.setColorTransform(0.65, 0.65, 0.65);
		snakeBop.shader = hsvSnakeShader;
		snakeBop.setColorTransform(0.65, 0.65, 0.65);
		bgfront.shader = hsvShader1;
		bgfront.setColorTransform(0.65, 0.65, 0.65);
		tables.setColorTransform(0.65, 0.65, 0.65);
		table.setColorTransform(0.65, 0.65, 0.65);
		escalator.setColorTransform(0.77, 0.77, 0.77);
		bullshit1.shader = hsvShader2;
		bullshit2.shader = hsvShader3;
		bgass.shader = hsvShader3;
		bgass.setColorTransform(0.7, 0.7, 0.7);
		pillars.shader = hsvShader3;
		pillars.setColorTransform(0.7, 0.7, 0.7);
		railingDOWN.shader = hsvShader3;
		railing.alpha = 0.5;
		//walkingDudesGrp.setShader(hsvShader1);
		walkingDudesGrp.setColorTransform(0.65, 0.65, 0.65, 1);

		var ass = new FlxBGSprite().makeGraphic(1, 1);
		ass.color = 0xFFCC9933;
		ass.blend = BlendMode.MULTIPLY;
		ass.alpha = 0.24;
		add(ass);

		// var bar = getVar("healthBar");
		// bar.leftBar.shader = bar.rightBar.shader = hsvCharsShader;
		// iconP1.shader = iconP2.shader = hsvCharsShader;
	}
}

function onUpdatePost(e)
{
	walkingDudesGrp.fade(isDead ? ((GameOverSubstate.instance?.bgColor ?? FlxColor.TRANSPARENT) >> 24) & 0xff : fradeTarget);

}

function onGameOverStart()
{
	snakeBop.animation.play("YMER?", true);
	gf.playAnim("death");
	gf.skipDance = true;
	remove(tables);
	GameOverSubstate.instance.add(tables);
	remove(walkingDudesGrp);
	GameOverSubstate.instance.add(walkingDudesGrp);
	onMoveCamera(_camTarget = "dad");
}

function onDestroy()
{
	FlxG.camera.bgColor = 0xFF000000;
}

function onCountdownTick(tick:Int) onBeatHit(tick); // да
function onBeatHit(beat:Int)
{
	var evenBeat = beat % 2 == 0;
	var quadroBeat = beat % 4 == 0;
	if (evenBeat)
	{

		if (isPivoMix)
		{
			if (_camTarget != "dad")
				juztNeatReact.animation.play((quadroBeat ? "left" : "right"), true);
			else if (_camTarget == "dad" && quadroBeat)
				juztNeatReact.animation.play("ew", true);

		}

		walkingDudesGrp.dance(true);
		if (!isDead)
			snakeBop.animation.play((quadroBeat ? "left" : "right"), true);
	}
}

function onMoveCamera(target)
{
	if (isPivoMix)
	{
		if (target != "dad" && juztNeatReact.animation.curAnim.name != "right" && juztNeatReact.animation.curAnim.name != "left")
			juztNeatReact.animation.play(((curBeat % 2 == 0) ? "left" : "right"));

		if (target == "dad" && juztNeatReact.animation.curAnim.name != "ew")
			juztNeatReact.animation.play("ew", true);
	}
}


// мне можно бебебе фагготики фогготини - rich
class FaggotSpawner extends FlxBasic
{
	static final ANIMS = ["guy", "gal", "boy", "bomb"];
	static final ANIM_WEIGHTS = [50, 45, 3, 2];

	var frames:FlxFramesCollection;
	var group:FlxGroup;
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	var scrollX:Float;
	var scrollY:Float;
	var timer:Float;

	var shader:FlxShader;
	var colorTransform:ColorTransform;
	var minTime:Float;
	var maxTime:Float;

	function getTimer():Float
		return FlxG.random.float(minTime, maxTime);

	public function new(startX:Float, endX:Float, startY:Float, endY:Float, scrollX:Float, scrollY:Float, minTime:Float, maxTime:Float)
	{
		super();
		frames = Paths.getSparrowAtlas("rofls/walkers");
		// PlayState.instance.graphicCache.cache(frames.parent);
		colorTransform = new ColorTransform();

		group = new FlxGroup();
		x = startX;
		y = startY;
		width = endX - startX;
		height = endY - startY;
		this.scrollX = scrollX;
		this.scrollY = scrollY;
		var mult = ClientPrefs.lowQuality ? 4 : 1;
		this.minTime = minTime * mult;
		this.maxTime = maxTime * mult;
		timer = getTimer();

		for (i in 0...FlxG.random.int(Std.int(5 / (minTime / 1.8)), Std.int(12 / (maxTime / 4.2))))
		{
			var walk = spawn();
			walk.x = x + 1 + FlxG.random.float(0, width - walk.width - 1);
		}
		sort();
	}

	function spawn():FlxSprite
	{
		var flip = FlxG.random.bool();
		var walk = group.recycle(FlxSprite, constructor);
		walk.animation.play(ANIMS[FlxG.random.weightedPick(ANIM_WEIGHTS)], true, FlxG.random.bool(1), -1);
		walk.animation.timeScale = FlxG.random.bool(0.4) ? FlxG.random.float(5, 6) : FlxG.random.float(0.9, 1.1);
		walk.velocity.x = FlxG.random.float(160, 200) * walk.animation.timeScale * (flip ? 1 : -1);

		walk.setPosition(x, y + FlxG.random.float(0, height));
		var scale = FlxG.random.bool(2) ? FlxG.random.float(0.4, 0.5) : FlxG.random.float(0.9, 1.05);
		scale *= FlxMath.remapToRange(walk.y, y, y + height, 0.7, 1);
		walk.scale.set(scale, scale);
		walk.updateHitbox();
		walk.offset.y += walk.height;

		walk.x += flip ? 1 : width - walk.width - 1;
		if (walk.animation.curAnim.reversed)
			flip = !flip;

		walk.flipX = flip;
		walk.shader = shader;
		walk.setColorTransform(colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, colorTransform.alphaMultiplier);
		return walk;
	}

	function constructor():FlxSprite
	{
		var spr = new FlxSprite();
		spr.scrollFactor.set(scrollX, scrollY);
		spr.frames = frames;
		for (anim in ANIMS)
			spr.animation.addByPrefix(anim, anim, 24);
		return spr;
	}

	function despawn(spr:FlxSprite)
	{
		if (spr.x + spr.width < x || spr.x > x + width)
			spr.kill();
	}

	function sort()
	{
		group.sort(sortByFoot);
	}

	function sortByFoot(order:Int, sprA:FlxSprite, sprB:FlxSprite)
	{
		return FlxSort.byValues(order, sprA.y + sprA.height - sprA.offset.y, sprB.y + sprB.height - sprB.offset.y);
	}

	override public function update(elapsed:Float)
	{
		group.update(elapsed);
		group.forEachAlive(despawn);
		timer -= elapsed;
		if (timer < 0)
		{
			timer += getTimer();
			for (i in 0...FlxG.random.int(1, 3))
				spawn();
			sort();
		}
	}

	override public function draw()
	{
		group.draw();
	}

	override public function destroy()
	{
		super.destroy();
		group.destroy();
	}

	function setShader(shader:FlxShader)
	{
		this.shader = shader;
		for (spr in group.members)
			spr.shader = shader;
	}

	function setColorTransform(?redMultiplier:Float, ?greenMultiplier:Float, ?blueMultiplier:Float, ?alphaMultiplier:Float)
	{
		colorTransform.redMultiplier = redMultiplier ?? 1;
		colorTransform.greenMultiplier = greenMultiplier ?? 1;
		colorTransform.blueMultiplier = blueMultiplier ?? 1;
		colorTransform.alphaMultiplier = alphaMultiplier ?? 1;
		for (spr in group.members)
			spr.setColorTransform(colorTransform.redMultiplier, colorTransform.greenMultiplier, colorTransform.blueMultiplier, colorTransform.alphaMultiplier);
	}
}