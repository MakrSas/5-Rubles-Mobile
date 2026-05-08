// import flixel.util.FlxColorTransformUtil;

var GF:String = "gf";
var BF:String = "boyfriend";
var DAD:String = "dad";

var config = {
	active: true,
	fadeAlpha: 0.8,
	fadeSpeed: 1,
	cameraZooming: true,
}
setVar("gameOverConfig", config);

var fadeList:Array<FlxSprite> = [];
function applyFade(s:FlxSprite)
{
	if (s is FlxSprite)
	{
		if (!fadeList.contains(s))
			fadeList.push(s);
	}
	else
	{
		final t = 'WARNING!!! $s is not a FlxSprite instance!';
		Log(t, TColor.YELLOW);
		// throw t;
	}
	return s;
}
setVar("gameOverApplyFade", applyFade);

// песни на которых игрок редиректится на другого персонажа
final redirect = [
	"bezdariamalgamatmix" => GF,
];

var daPlayer = (redirect[PlayState.SONG.song.toLowerCase()] ?? BF);

function onCreatePost()
{
	if (daPlayer != BF)
	{
		var char = (daPlayer == GF) ? gf : dad;
		// GameOverSubstate.applyFromCharacter(char);
		if (char.gameoverProperties != null)
		{
			@:bypassAccessor GameOverSubstate.characterName = char.gameoverProperties.char;
			GameOverSubstate.deathSoundName = char.gameoverProperties.startSound;
			GameOverSubstate.loopSoundName = char.gameoverProperties.music;
			GameOverSubstate.endSoundName = char.gameoverProperties.confirmSound;
			GameOverSubstate.loopSoundBPM = char.gameoverProperties.bpm;
		}
	}
}

function onCreateGameOver()
{
	if (!config.active)
		return;

	switch (daPlayer)
	{
		case GF:
			removeFromGroup(gf, gfGroup);
			boyfriend.stunned = false;

			var temp = boyfriend;
			boyfriend = gf;
			gf = temp;

		case DAD:
			removeFromGroup(dad, dadGroup);
			boyfriend.stunned = false;

			var temp = boyfriend;
			boyfriend = dad;
			dad = temp;

		default:
			removeFromGroup(boyfriend, boyfriendGroup);
	}

	boyfriend.hasMissAnimations = false;
	boyfriend.stunned = true;
	boyfriend.skipDance = true;
	boyfriend.holdTimer = 0;
	moveCameraChar("boyfriend");

	if (GameOverSubstate.characterName != null && boyfriendMap.exists(GameOverSubstate.characterName))
		removeFromGroup(boyfriendMap.get(GameOverSubstate.characterName), boyfriendGroup);
}

function onGameOverStart()
{
	if (!config.active)
		return;

	camHUD.visible = camOther.visible = false;
	FlxG.state.persistentDraw = true;
	Conductor.bpmChangeMap.resize(0);
}

function onGameOverConfirm(restart:Bool)
{
	if (!config.active)
		return;

	if (restart)
	{
		// FlxTween.cancelTweensOf(FlxG.camera, ["zoom"]);
		// FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.15}, 2.5, {ease: FlxEase.circOut});
		defaultCamZoom *= 1.15;
		// return;
	}
	// else
}

var lerpVal = 0.04;
var bgColor_alpha = 0;
function onUpdate(elapsed:Float)
{
	if (!inGameOver())
		return;

	if (bgColor_alpha != config.fadeAlpha)
	{
		bgColor_alpha = CoolUtil.fpsLerp(bgColor_alpha, config.fadeAlpha, lerpVal * config.fadeSpeed);
		GameOverSubstate.instance?.bgColor = FlxColor.fromRGBFloat(0, 0, 0, bgColor_alpha);
		if (fadeList.length != 0)
		{
			var f = 1 - bgColor_alpha;
			var fadeColor = FlxColor.fromRGBFloat(f, f, f);
			// var f = -255 * bgColor_alpha;
			for (s in fadeList)
			{
				s.color = fadeColor;
				// FlxColorTransformUtil.setOffsets(s.colorTransform, f, f, f, 0);
			}
		}
	}

	if (GameOverSubstate.instance?.moveCamera)
		FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, defaultCamZoom, lerpVal * camZoomingDecay);
}

function onUpdatePost(elapsed:Float)
{
	if (!inGameOver())
		return;

	for (basic in FlxG.state.members)
		if (basic != null && basic.exists && basic.active)
			basic.update(elapsed);
}

// function onStepHit(step:Int) {}

function onBeatHit(beat:Int)
{
	if (inGameOver())
		danceCharacters(beat);
}

function onSectionHit(section:Int)
{
	if (inGameOver() && config.cameraZooming)
		FlxG.camera.zoom += 0.015 * defaultCamZoom;
}

function removeFromGroup(obj:FlxObject, group:FlxSpriteGroup)
{
	group.remove(obj);
	obj.x += group.x;
	obj.y += group.y;
}

function inGameOver() return config.active && isDead; // && GameOverSubstate.instance != null
