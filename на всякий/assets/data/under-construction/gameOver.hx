import game.backend.system.audio.EffectSound;
import flixel.effects.FlxFlicker;

var stageZoom:Float;

function onCreate()
{
	stageZoom = defaultCamZoom;
	var gameOverConfig = getVar("gameOverConfig");
	// gameOverConfig.active = false;
	gameOverConfig.cameraZooming = false;
	gameOverConfig.fadeAlpha = 1;
	gameOverConfig.fadeSpeed = 1.2;
}

var killem:Character;
var gameoverContainer:FlxGroup;
var floor:FlxSprite;
var artem:FlxSprite;
var vlad:FlxAnimate;
var light:FlxSprite;
var countdownContainer:FlxSpriteGroup;
var fade:FlxSprite;
var screamer:FlxSprite;

// TODO: подумать над увеличением таймера до 51
// PS: идея как по мне ужасная - rich
var countdown = 21;

function onCreatePost()
{
	killem = new Character(boyfriendGroup.x - 840, boyfriendGroup.y + 40, "uc-DEATH");

	var path = "under_construction/death_scene";
	gameoverContainer = new FlxGroup();

	var bg = new FlxSprite().loadGraphic(FlxG.bitmap.whitePixel);
	bg.scale.set(FlxG.width * 1.5, FlxG.height * 1.5);
	bg.color = FlxColor.BLACK;
	bg.updateHitbox();

	floor = new FlxSprite(298.5).loadGraphic(Paths.image('$path/floor'));
	floor.antialiasing = ClientPrefs.globalAntialiasing;

	artem = new FlxSprite();
	artem.antialiasing = ClientPrefs.globalAntialiasing;
	artem.frames = Paths.getSparrowAtlas('$path/aetos4ss');
	artem.animation.addByPrefix("artem", "сидит ждет", 24, false);
	artem.animation.addByPrefix("rubl4ss", "рубл4континуе", 24);

	vlad = new FlxAnimate();
	vlad.antialiasing = ClientPrefs.globalAntialiasing;
	vlad.loadAtlas(AssetsPaths.getPath('images/$path/cause_of_shaking'));
	vlad.anim.addBySymbol("vlad", "владик символы/найс онга");
	vlad.anim.addBySymbol("nai", "насонгер трясется");

	light = new FlxSprite(314, -0.3).loadGraphic(Paths.image('$path/light'));
	light.antialiasing = ClientPrefs.globalAntialiasing;

	fade = new FlxSprite().loadGraphic(FlxG.bitmap.whitePixel);
	fade.scale.set(FlxG.width * 1.5, FlxG.height * 1.5);
	fade.color = FlxColor.BLACK;
	fade.updateHitbox();
	fade.alpha = 0;

	screamer = new FlxSprite().loadGraphic(Paths.image('$path/UGLY.jpg'));
	screamer.setGraphicSize(1920, 1080);
	screamer.updateHitbox();
	screamer.visible = false;

	countdownContainer = new FlxSpriteGroup(549.35);

	var cont = new FlxSprite().loadGraphic(Paths.image('$path/continuum'));
	cont.antialiasing = ClientPrefs.globalAntialiasing;

	function makeBall(x:Float, y:Float):FlxSprite
	{
		var ball = new FlxSprite(x, y);
		ball.antialiasing = ClientPrefs.globalAntialiasing;
		ball.frames = Paths.getSparrowAtlas('$path/basketball');
		ball.animation.addByPrefix("spin", "поиграем в баскетбол?", 24);
		ball.animation.play("spin");
		return ball;
	}

	function makeNum(x:Float, y:Float):FlxSprite
	{
		var num = new FlxSprite(x, y);
		num.antialiasing = ClientPrefs.globalAntialiasing;
		num.frames = Paths.getSparrowAtlas('$path/digits');
		return num;
	}

	countdownContainer.add(cont);
	countdownContainer.add(makeBall(217.7, 152.1));
	countdownContainer.add(makeBall(512.3, 152.1));
	countdownContainer.add(makeNum(341.95, 158.15));
	countdownContainer.add(makeNum(418.75, 158.15));

	gameoverContainer.add(bg);
	gameoverContainer.add(floor);
	gameoverContainer.add(artem);
	gameoverContainer.add(vlad);
	gameoverContainer.add(light);
	gameoverContainer.add(countdownContainer);
	gameoverContainer.add(fade);
	gameoverContainer.add(screamer);
}

function onDestroy()
{
	if (isDead)
		return;

	// на перезапуске песни или если игрок ливнул с плейстейта
	killem.destroy();
	gameoverContainer.destroy();
	instFuckedUp?.destroy();
}

// тебе хоть 18 то есть?
var adult = false;
var nai = "rublonji under construction";
function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "Change Character" && value2 == nai)
	{
		GameOverSubstate.characterName = nai;
		adult = true;
	}
}

var songPos:Float;
var instFuckedUp:FlxSound;

function onGameOver()
{
	instFuckedUp = EffectSound.load(inst._sound);
	songPos = Conductor.songPosition;
}

function onGameOverStart()
{
	// сетап
	GameOverSubstate.instance.boyfriend.debugMode = true;
	GameOverSubstate.instance.allowSkip = false;
	GameOverSubstate.instance.add(killem);
	GameOverSubstate.instance.add(gameoverContainer);
	var mid = GameOverSubstate.instance.boyfriend.getMidpoint();
	GameOverSubstate.instance.camFollowPos.set(mid.x, mid.y);
	mid.put();
	defaultCamZoom = stageZoom * 1.1;

	if (!adult)
	{
		GameOverSubstate.instance.camFollowPos.x -= 120;
		GameOverSubstate.instance.camFollowPos.y += 30;
	}

	killem.alpha = FlxMath.EPSILON;
	gameoverContainer.exists = false;

	FlxTween.num(1, 0, 0.6, null, a ->
	{
		dad.alpha = a;
		var c = 1 - a;
		dad.color = FlxColor.fromRGBFloat(c, c, c);
	});

	instFuckedUp.play(true, songPos);
	FlxTween.tween(instFuckedUp, {pitch: 0.3, volume: 0.5}, 0.8, {ease: FlxEase.elasticOut});
}

function onGameOverConfirm(restart:Bool)
{
	if (restart)
	{
		FlxG.camera.stopFX();
		defaultCamZoom /= 1.15;
		alphaTarget = 1;
		artemDance();

		counting = false;
		countdownContainer.visible = false;
		for (i in 1...5)
			countdownContainer.members[i].alpha = 0;
		FlxFlicker.flicker(countdownContainer, 10, 0.12, false, true);
	}
	else
	{
		FlxG.state.persistentDraw = gameoverContainer.exists = killem.exists = GameOverSubstate.instance.boyfriend.exists = false;
	}
}

var cutsceneTimer = 0;
var cutsceneEvents:Array<{time:Float, callback:() -> Void}> = [
	{
		time: 0.5,
		callback: () ->
		{
			GameOverSubstate.instance.moveCamera = true;
		}
	},
	{
		time: 3,
		callback: () ->
		{
			killem.alpha = 1;
			killem.playAnim((adult ? "rubl4" : "artem") + "Pre");
			GameOverSubstate.instance.boyfriend.playAnim("deathLoop");
			GameOverSubstate.instance.camFollowPos.x += 80 * (adult ? -1 : 1);
			GameOverSubstate.instance.cameraSpeed = camZoomingDecay = 2.5;
			defaultCamZoom *= 1.22;

			instFuckedUp.stop();
			// FlxTween.tween(instFuckedUp, {pitch: 0.1, volume: 0.3}, 0.6);
			// FlxG.sound.play(Paths.sound("buawawawawa")).pitch = 0.85;
			FlxG.sound.play(Paths.sound("uc-death/appear"));
			var phrase = FlxG.sound.play(Paths.soundRandom("uc-death/voice", 1, 4), 1.8);
			phrase.pitch = adult ? 1 : 1.8;
			var waitTime = phrase.length / 1000 - 3.5 * ((phrase.pitch - 1) / 2 + 1);
			for (event in cutsceneEvents)
				event.time += waitTime;
		}
	},
	{
		time: 3,
		callback: () ->
		{
			killem.playAnim((adult ? "rubl4" : "artem") + "KILL");
			// instFuckedUp.stop();
			// FlxG.sound.play(Paths.sound("ANGRY")).pitch = 0.18;
			// FlxG.sound.play(Paths.sound("badnoise3"));
			FlxG.sound.play(Paths.sound("uc-death/death"), 2);
		}
	},
	{
		time: 3.08,
		callback: () ->
		{
			GameOverSubstate.instance.boyfriend.playAnim("deathConfirm");
			FlxG.camera.shake(0.004, 0.2);
			GameOverSubstate.instance.camFollowPos.x -= 40 * (adult ? -1 : 1);
			defaultCamZoom /= 1.06;
		}
	},
	{
		time: 3.63,
		callback: () ->
		{
			FlxG.sound.play(Paths.sound("sonic-exe-scream"), 0.6);
			FlxG.camera.visible = false;
		}
	},
	{
		time: 8.2,
		callback: () -> showCountdown()
	}
];
var lerpAlphaFactor = ClientPrefs.flashing ? 0.65 : 0.15;
var maxTimer = ClientPrefs.flashing ? 0.05 : 0.12;
var alphaTarget = 1;
var timer = 0;

function onUpdatePost(elapsed:Float)
{
	if (!isDead)
		return;

	if (cutsceneEvents.length != 0)
	{
		if (controls.ACCEPT)
		{
			cutsceneEvents = [];
			showCountdown();
		}
		else
		{
			cutsceneTimer += elapsed;
			while (cutsceneEvents[0] != null && cutsceneEvents[0].time <= cutsceneTimer)
				cutsceneEvents.shift().callback();
		}
	}

	if (counting)
	{
		var prevCountdown = countdown;
		countdown -= elapsed;
		if (Math.ffloor(prevCountdown) != Math.ffloor(countdown))
			updateCountdown();
	}

	if (!GameOverSubstate.instance?.isEnding)
	{
		timer += elapsed;
		if (timer > maxTimer)
		{
			var mult = countdown - 0.5;
			alphaTarget = FlxG.random.float(0.12 * mult, 0.92 * mult);
			timer -= maxTimer;
		}
	}
	fade.alpha = CoolUtil.fpsLerp(fade.alpha, 1 - alphaTarget, lerpAlphaFactor);
}

var counting = false;
function showCountdown()
{
	if (GameOverSubstate.instance == null || counting)
		return;

	// var posX = (FlxG.width - GameOverSubstate.instance.camFollow.width) / 2 * 1.5;
	// var posY = (FlxG.height - GameOverSubstate.instance.camFollow.height) / 2 * 1.5;
	// GameOverSubstate.instance.camFollow.x = GameOverSubstate.instance.camFollowPos.x = posX;
	// GameOverSubstate.instance.camFollow.y = GameOverSubstate.instance.camFollowPos.y = posY;
	FlxG.camera.focusOn(FlxPoint.weak(FlxG.width / 2 * 1.5, FlxG.height / 2 * 1.5));
	FlxG.camera.target = null;
	GameOverSubstate.instance.moveCamera = false;
	GameOverSubstate.instance.allowSkip = true;
	GameOverSubstate.instance.coolStartDeath();
	// TODO: придумать что делать с этим хз
	// var pos = FlxG.random.int(0, 7);
	// FlxG.sound.music.time = Conductor.crochet * 8 * pos;

	FlxG.camera.visible = true;
	FlxG.camera.zoom = FlxG.height / 1080;
	FlxG.camera.fade(FlxColor.BLACK, 1.6, true);
	FlxG.state.persistentDraw = false;
	gameoverContainer.exists = true;
	killem.exists = false;

	if (adult)
	{
		floor.y = 890.1;
		countdownContainer.y = 48.3;
		artem.setPosition(598, 172.4);
		vlad.setPosition(577, 536.45);
		artem.animation.play("rubl4ss");
		vlad.anim.play("nai");

		light.scale.set(1.075, 1.5);
		// light.updateHitbox();

		artem.alpha = 0;
		FlxTween.num(0, 1, 5.6, {startDelay: 0.8, ease: a -> Math.ffloor(a * 18) / 18}, artem.set_alpha);
	}
	else
	{
		floor.y = 811.8;
		countdownContainer.y = 135.7;
		artem.setPosition(436.85, 543.5);
		vlad.setPosition(1066.2, 331.05);
		artem.animation.play("artem");
		vlad.anim.play("vlad");
	}

	counting = true;
	instFuckedUp.stop();
}

function updateCountdown()
{
	var countdownSprite10 = countdownContainer.members[3];
	var countdownSprite1 = countdownContainer.members[4];
	countdownSprite10.frame = countdownSprite10.frames.frames[Math.ffloor((countdown / 10) % 10)];
	countdownSprite1.frame = countdownSprite1.frames.frames[Math.ffloor(countdown % 10)];

	if (countdown <= 0)
	{
		GameOverSubstate.instance.allowSkip = counting = false;
		FlxTween.num(1, 0.1, 0.5, {startDelay: 0.5, onComplete: _ ->
		{
			screamer.visible = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound("system/lie"), 2);
			new FlxTimer().start(0.6, () -> Sys.exit(0));
		}}, FlxG.sound.music.set_pitch);
	}
}

function artemDance()
{
	if (!adult)
		artem.animation.play("artem", true);
}

function onBeatHit(beat:Int) artemDance();