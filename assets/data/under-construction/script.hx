import flixel.util.FlxSort;
import flixel.effects.particles.FlxTypedEmitter;
import flixel.effects.particles.FlxEmitterMode;
import haxe._Int64.Int64_Impl_ as Int64; // haxe.Int64

importHScriptClasses("scripts/classes/LoopingGroup.hx");

var psychHudScript = scriptPack.getHScript("data/psychHUD");
var twistHudScript = scriptPack.getHScript("scripts/hud");
// сосал?
PauseSubState.songName = "pauseSosal";

static final ZOOM_SPEED = 1.5;
var endingImage:FlxSprite;

var dynomite:FlxAnimate;
var lyricNai:Character;

var colorShader:FlxRuntimeShader;
var colorFilter:ShaderFilter;

function onCreate()
{
	dynomite = new FlxAnimate(-54.75, -89.25, AssetsPaths.getPath("images/under_construction/phase1/dunamite"));
	dynomite.scrollFactor.set(0.78, 0.94);
	dynomite.anim.addBySymbol("idle", "дунамите", 0, false);
	dynomite.anim.addBySymbol("prep", "псссссс", 0, false);
	dynomite.anim.addBySymbol("boom", "ВЗРЫВ", 0, false);
	dynomite.anim.onComplete.add((name, symbol) ->
	{
		// name выдает название символа почему-то???
		if (dynomite.anim.curAnimName == "prep") // name
		{
			dynomite.anim.play("boom");
			explosion.alpha = 1;
			explosion.animation.play("boom", true);
			FlxG.camera.shake(0.006, 26 / 24);
			new FlxTimer().start(1 / 24, _ ->
			{
				var speed = 1666;
				dad.velocity.x = dad.angularVelocity = -speed;
				boyfriend.velocity.x = boyfriend.angularVelocity = speed;
				FlxG.camera.fade(0x66FFFFFF, 2 / 24, false, () -> FlxG.camera.fade(0x66FFFFFF, 1 / 24, true));
			});
		}
	});
	dynomite.anim.play("idle");

	explosion = new FlxSprite(-1000, -600);
	explosion.frames = Paths.getSparrowAtlas("under_construction/phase1/explode");
	explosion.animation.addByPrefix("boom", "взрів какашки", 24, false);
	explosion.animation.play("boom");
	explosion.alpha = 0.000001;
	explosion.scale.set(2.5, 2.5);
	explosion.updateHitbox();

	if (ClientPrefs.shaders)
	{
		colorShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("jpeg_lite")));
		colorShader.setFloat("cellSize", 0);
		colorShader.setFloat("colors", 256);
		colorShader.setFloat("crustFactor", 0);
		colorFilter = new ShaderFilter(colorShader);
	}

	lyricNai = new Character(0, 0, "nailyric", true);
	lyricNai.setPosition(FlxG.width - lyricNai.width + 560, FlxG.height - lyricNai.height + 140);
	lyricNai.scrollFactor.set();
	lyricNai.origin.set(FlxG.width / 2 - lyricNai.x, FlxG.height / 2 - lyricNai.y);
	lyricNai.playAnim("singRIGHT");
	lyricNai.alive = false;
	graphicCache.cache(lyricNai.graphic);
}

function onCreatePost()
{
	endingImage = new FlxSprite();
	endingImage.camera = camOther;
	endingImage.kill();
	// endingImage.alpha = 0;
	// endingImage.angularVelocity = ZOOM_SPEED * FlxG.random.int(-1, 1, [0]);
	add(endingImage);

	// initiate nayebal_loxa protocol
	songLength = 198000;
}

var addVideoShit = false;
function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "Play Video":
			var normalizedVideoName = value1 == null ? "" : StringTools.replace(StringTools.replace(value1.toLowerCase(), " ", "_"), ".mp4", "");
			if (normalizedVideoName == "liriki_final")
				addVideoShit = true;

		case "Switch BG":
			var id = Std.parseInt(value1);
			switch id
			{
				case 1:
					if (ClientPrefs.shaders)
						FlxG.camera.filters.push(colorFilter);
			}

		case "":
			switch (value1)
			{
				// нуя - richTrash21
				case "ХАХА НАЕБАЛ!!!":
					var updateTimeTextPsych = psychHudScript.getVar("updateTimeTextPsych");
					var updateTimeTextTwist = twistHudScript.getVar("updateTimeTextTwist");
					FlxTween.num(songLength, inst.length, Conductor.crochet / 1000 * 18, {ease: FlxEase.sineInOut}, t ->
					{
						songLength = t;
						if (healthbarStyle == "psych")
							updateTimeTextPsych();
						else
							updateTimeTextTwist();
					});

				case "ВЗОРВИСЬ":
					dynomite.anim.play("prep");
					if (ClientPrefs.shaders)
						FlxTween.num(256, 1, 0.5, null, c -> colorShader.setFloat("colors", c));

				case "ending":
					var duration = 5;
					camOther.fade(FlxColor.BLACK, duration, false, () ->
					{
						var isBad = ratingPercent < 0.75;
						var imageName:String = isBad ? "bad" : "good";
						endingImage.loadGraphic(Paths.image('under_construction/$imageName'));
						endingImage.setGraphicSize(FlxG.width);
						endingImage.screenCenter();
						endingImage.revive();

						if (isBad)
						{
							var emitter = new FlxTypedEmitter(0, -200);
							emitter.loadParticles(Paths.image("under_construction/dust"), 20); // спизжено из фанкбокса, могу себе позволись
							emitter.launchMode = FlxEmitterMode.SQUARE;
							emitter.setSize(FlxG.width, 150);
							emitter.velocity.set(10, 120, -10, 10);
							emitter.acceleration.set(10, 180, -10, 10);
							emitter.alpha.set(0.2, 0.7, -1, -1);
							emitter.lifespan.set(30, 30); // умерают прямо на глазах пиздец
							emitter.keepScaleRatio = true;
							emitter.scale.set(0.25, 0.25, 1, 1);
							emitter.color.set(FlxColor.BLACK, FlxColor.BLACK);
							emitter.drag.set(0);
							emitter.start(false, 0.6);
							emitter.camera = camOther;
							addAheadObject(add(emitter));
						}
						else
						{
							var loop = addAheadObject(new LoopingGroup(0, FlxG.width, 0, FlxG.height), endingImage);
							for (i in 0...10)
							{
								var dust = new DustParticle(FlxG.random.float(loop.x, loop.width), FlxG.random.float(loop.y, loop.height));
								dust.camera = camOther;
								loop.add(dust);
							}
						}

						// trace(ratingPercent, imageName);
						FlxG.camera.visible = camHUD.visible = camControls.visible = false;
						camOther.fade(FlxColor.BLACK, duration, true);
					});

				case "ending2":
					camOther.fade(FlxColor.BLACK, 8);
			}
	}
}

function onUpdatePost(elapsed:Float)
{
	if (endingImage.alive)
	{
		endingImage.scale.x += elapsed * (1.5 / FlxG.width);
		endingImage.scale.y = endingImage.scale.x;
	}

	if (addVideoShit)
	{
		addVideoShit = false;

		function onTimeChanged(time64:Int64)
		{
			var time = Int64.toInt(time64) / 1000;
			var frame = time * 24;

			if (frame > 524 && camHUD.alpha == 0)
				for (cam in [camHUD, camControls])
					FlxTween.num(0, 1, 18 / 24, {ease: FlxEase.cubeInOut}, cam.set_alpha)/*.update((frame - 524) / 24)*/;

			if (frame > 546 && lyricNai.ID == 0)
			{
				lyricNai.ID = 1;
				lyricNai.alpha = 1;
				FlxTween.tween(lyricNai, {
					"scale.x": 1,
					"scale.y": 1,
					"offset.x": lyricNai.offset.x + FlxG.width / 2.5,
					"offset.y": lyricNai.offset.y - FlxG.height / 2.5
				}, 32 / 24, {ease: FlxEase.sineInOut})/*.update((frame - 547) / 24)*/;
			}
			else if (frame > 1047 && lyricNai.ID == 1)
			{
				lyricNai.ID = 2;
				var time = 15 / 24;
				// var elapsed = (frame - 1047) / 24;
				FlxTween.tween(lyricNai, {
					"scale.x": 1.6,
					"scale.y": 1.6,
					"offset.x": lyricNai.offset.x - FlxG.width / 2.5,
					// "offset.y": lyricNai.offset.y + FlxG.height / 2.5,
				}, time, {ease: FlxEase.cubeIn})/*.update(elapsed)*/;
				FlxTween.color(lyricNai, time, FlxColor.WHITE, FlxColor.BLACK)/*.update(elapsed)*/;
			}
		}

		FlxG.camera.stopFX();
		dad.visible = boyfriend.visible = false;
		var curPhase = getVar("curPhase") - 1;
		getVar("bgs")[curPhase].exists = false;
		getVar("fgs")[curPhase].exists = false;

		lyricNai.scale.x = lyricNai.scale.y = 1.9;
		lyricNai.offset.x -= FlxG.width / 2.5;
		lyricNai.offset.y += FlxG.height / 2.5;
		lyricNai.alive = true;
		lyricNai.ID = 0;

		var time = 0.7;
		for (cam in [camHUD, camControls])
			FlxTween.num(1, 0, time, {ease: FlxEase.cubeInOut}, cam.set_alpha);

		var strumOffset = FlxG.width / 2;
		for (i => strum in opponentStrums.members)
			FlxTween.num(strum.x, strum.x - strumOffset * (middleScrollMode && i > 1 ? -1 : 1), time, {ease: FlxEase.cubeIn}, strum.set_x);

		var video = getVar("play_video");
		if (video == null || video.bitmap == null)
		{
			addVideoShit = true;
			return;
		}
		video.bitmap.onTimeChanged.add(onTimeChanged);
		video.bitmap.onEndReached.add(() ->
		{
			FlxG.camera._fxFadeColor = FlxColor.BLACK;
			FlxG.camera._fxFadeAlpha = 1;
			camHUD.alpha = 1;
			dad.visible = boyfriend.visible = true;
			lyricNai.kill();

			for (i => strum in opponentStrums.members)
				FlxTween.num(strum.x, strum.x + strumOffset * (middleScrollMode && i > 1 ? -1 : 1), 1.2, {ease: FlxEase.backOut}, strum.set_x);

			video.bitmap.onTimeChanged.remove(onTimeChanged);
		}, true);
		addAheadObject(lyricNai, video);
	}
}

function onGameOverStart()
{
	// Если игрок ЛОХ ЕБАНЫЙ ХАХАХХА СДОХНУТЬ В КОНЦОВКЕ ПИЗДЕЦ
	FlxG.camera.alpha = camHUD.alpha = 1;
	endingImage.kill();
	camHUD.stopFX();
	camOther.stopFX();
	if (lyricNai.alive)
	{
		lyricNai.kill();
		var curPhase = getVar("curPhase") - 1;
		getVar("bgs")[curPhase].exists = true;
		getVar("fgs")[curPhase].exists = true;
		dad.visible = boyfriend.visible = true;
	}
}
class DustParticle extends FlxSprite
{
	static function getTimer():Float
		return FlxG.random.float(0.5, 2);

	var timer = 0;

	public function new(x = 0, y = 0)
	{
		super(x, y, Paths.image("under_construction/dust"));
		scale.x = scale.y = FlxG.random.float(0.2, 1.2);
		updateHitbox();
		alpha = FlxG.random.float(0.6, 1);
		blend = BlendMode.ADD;
		maxVelocity.x = maxVelocity.y = 40;
		velocity.set(FlxG.random.float(-maxVelocity.x, maxVelocity.x), FlxG.random.float(-maxVelocity.y, maxVelocity.y));
		randAcceleration();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		timer -= elapsed;
		if (timer <= 0)
		{
			timer += getTimer();
			randAcceleration();
		}
	}

	function randAcceleration()
		acceleration.set(FlxG.random.float(-maxVelocity.x, maxVelocity.x), FlxG.random.float(-maxVelocity.y, maxVelocity.y));
}