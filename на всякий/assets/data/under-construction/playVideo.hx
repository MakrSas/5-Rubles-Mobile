import haxe._Int64.Int64_Impl_ as Int64; // haxe.Int64
import game.objects.VideoSprite;
import game.mobile.utils.TouchUtil;
importHScriptClasses("scripts/classes/SkipPrompt.hx");

using StringTools;

var myVideoPlayer:VideoSprite;
var skipText:SkipPrompt;

function onCreate()
{
	skipCountdown = true;
	camHUD.fade(FlxColor.BLACK, 0.0, false);
	camHUD._fxFadeAlpha = 1.0;

	myVideoPlayer = new VideoSprite();
	myVideoPlayer.camera = camOther;
	myVideoPlayer.load(Paths.video("uc intro"), [VideoSprite.muted]);
	myVideoPlayer.kill();
	add(myVideoPlayer);

	skipText = new SkipPrompt(
		() -> myVideoPlayer.alive && (controls.ANY || TouchUtil.justPressed),
		() -> myVideoPlayer.alive && !controls.PAUSE && (controls.ACCEPT || FlxG.keys.justPressed.Z || TouchUtil.justPressed),
		() ->
		{
			myVideoPlayer.bitmap.time = Int64.ofInt(skipTime);
			setSongTime(skipTime);
		}
	);
	skipText.camera = camOther;
	add(skipText);

	// myVideoPlayer.bitmap.onEndReached.add(onFinishIntroVideo, true); // оно всё ещё отстаёт, бе бе бе - Redar
	// let graphic change first and then revive the sprite
	myVideoPlayer.bitmap.onFormatSetup.add(() ->
	{
		if (myVideoPlayer.bitmap == null)
			return;

		myVideoPlayer.revive();
		myVideoPlayer.bitmap.time = Int64.ofInt(Std.int(Conductor.songPosition));
		// trace(myVideoPlayer.bitmap.time);
		if (paused)
			onPause();
		// startSong();
		// var targetTime = Conductor.songPosition;
		// myVideoPlayer.vSynsPos = () -> return Math.floor(Conductor.songPosition - targetTime); // боль
	}, true);
	myVideoPlayer.bitmap.onEncounteredError.add(err ->
	{
		skipText.kill();
		Log(err, RED);
	});
}

function onFinishIntroVideo()
{
	/*
	myVideoPlayer.exists = false;
	FlxTween.num(myVideoPlayer.alpha, 0, myVideoPlayer.alpha / 2, {
		ease: FlxEase.cubeInOut,
		onComplete: _ -> {
			camHUD.fade(FlxColor.TRANSPARENT, 0.0, true);
			camHUD.flash(FlxColor.WHITE, 1.5);
			myVideoPlayer.exists = false;
		}
	}, myVideoPlayer.set_alpha);
	*/
	if (ClientPrefs.flashing)
	{
		camHUD.fade(FlxColor.TRANSPARENT, 0.0, true);
		camHUD.flash(FlxColor.WHITE, 0.8);
	}
	else
	{
		camHUD.fade(FlxColor.TRANSPARENT, 1.3, true);
	}
	ClientPrefs.ghostTapping = FlxG.save.data.ghostTapping;
	myVideoPlayer.kill();
}

function onEvent(name:String, value1:String, value2:String, value3:String, strumTime:Float)
{
	switch (name)
	{
		case "":
			switch (value1)
			{
				case "UC-introFlash":
					onFinishIntroVideo();
			}
	}
}

var skipTime = 30000;
function onUpdatePost(elapsed:Float)
{
	if (!skipText.skipped && Conductor.songPosition > skipTime)
		skipText.disable();

	if (myVideoPlayer.alive)
	{
		#if DEV_BUILD
		if (controls.DEBUG_SKIP_TIME)
		{
			myVideoPlayer.bitmap.time = Int64.addInt(myVideoPlayer.bitmap.time, Math.round(elapsed * 1000 + (FlxG.keys.pressed.SHIFT ? 20000 : 10000) * playbackRate));
		}
		#end
	}
}

function preKeyPress()
{
	if (Conductor.songPosition < skipTime || myVideoPlayer.alive)
	{
		ClientPrefs.ghostTapping = true;
		return Function_Stop;
	}
}

function onPause()
{
	if (Conductor.songPosition < skipTime || myVideoPlayer.alive)
	{
		ClientPrefs.ghostTapping = FlxG.save.data.ghostTapping;
	}
}

function onSongStart() myVideoPlayer.play();
function onPause() if (myVideoPlayer.alive) myVideoPlayer.pause();
function onResume() if (myVideoPlayer.alive) myVideoPlayer.resume();
function onGameOverStart() if (myVideoPlayer.alive) myVideoPlayer.stop();