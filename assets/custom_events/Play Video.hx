import game.objects.VideoSprite;
import hxvlc.flixel.FlxVideoSprite;
import haxe._Int64.Int64_Impl_ as Int64; // haxe.Int64

using StringTools;

var preloadedVideos:Map<String, FlxVideoSprite> = [];
var curVideo:FlxVideoSprite;

function onCreatePost()
{
	for (event in eventNotes)
	{
		if (event[1] != "Play Video")
			continue;

		var name = event[2];
		if (!preloadedVideos.exists(name))
			preloadedVideos.set(name, preloadVideo(name, optionsFromString(event[3]), cameraFromString(event[4])));
	}
}

var lastRate = -1;
function onUpdate(elapsed:Float)
{
	#if DEV_BUILD
	if (curVideo != null)
	{
		var newRate = FlxG.timeScale;
		if (lastRate != newRate)
			curVideo.bitmap.rate = lastRate = newRate;
	}
	#end
}

function onUpdatePost(elapsed:Float)
{
	#if DEV_BUILD
	if (curVideo != null)
	{
		if (controls.DEBUG_SKIP_TIME)
		{
			// curVideo.bitmap.time = Int64.addInt(curVideo.bitmap.time, Math.round(elapsed * 1000 + (FlxG.keys.pressed.SHIFT ? 20000 : 10000) * playbackRate));
			curVideo.bitmap.time = Int64.ofInt(Std.int(Conductor.songPosition - triggerTime));
		}
	}
	#end
}

var triggerTime = 0;
function onEvent(name:String, value1:String, value2:String, value3:String, strumTime:Float)
{
	if (name == "Play Video")
	{
		var newVideo = preloadedVideos.get(value1);
		if (newVideo == null)
		{
			newVideo = loadVideo(value1, optionsFromString(value2), cameraFromString(value3));
			preloadedVideos.set(value1, newVideo);
		}

		lastRate = -1;
		clearCurVideo();
		newVideo.revive();
		remove(newVideo, true);
		// 😔😔
		if (newVideo.camera == FlxG.camera)
			add(newVideo);
		else
			insert(0, newVideo);

		if (newVideo.play())
		{
			if (!newVideo.bitmap.onEndReached.has(clearCurVideo))
				newVideo.bitmap.onEndReached.add(clearCurVideo, true);

			triggerTime = strumTime ?? Conductor.songPosition;
			newVideo.bitmap.onFormatSetup.add(onSetupVideo.bind(newVideo, triggerTime), true);
		}
		else
		{
			newVideo = null;
			Log('Не удалось загрузить видео "$value1"!', TColor.RED);
		}

		// replace(curVideo, newVideo);
		setVideo(newVideo);
	}
}

function onSetupVideo(newVideo:FlxVideoSprite, strumTime:Float)
{
	// Log("onSetupVideo", TColor.BLUE);
	// синхронизация видео с текущим временем
	// в случае если видео по идее уже прошло просто заканчивает его
	// var newTime = Int64.ofInt(Math.round(Conductor.songPosition - strumTime));
	// trace(newVideo.bitmap.time, newTime, newVideo.bitmap.length);
	// newVideo.bitmap.time = newTime;
}

function clearCurVideo()
{
	if (curVideo == null)
		return;

	// curVideo.stop();
	curVideo.kill();
	remove(curVideo, true);
	setVideo(null);
}

function setVideo(video:FlxVideoSprite)
{
	setVar("play_video", curVideo = video);
}

function onPause() curVideo?.pause();
function onResume() curVideo?.resume();
function onGameOverStart() clearCurVideo();

function onDestroy()
{
	remove(curVideo);
	for (video in preloadedVideos)
	{
		video.parseStop();
		video.destroy();
	}
}

function preloadVideo(file:String, options:Array<String>, camera:FlxCamera):FlxVideoSprite
{
	var video = loadVideo(file, options, camera);
	video.bitmap.onFormatSetup.add(() ->
	{
		video.pause();
		video.bitmap.time = Int64.ofInt(0);
	}, true);
	video.play();
	return video;
}

function resolveVideoPath(file:String):String
{
	if (file == null)
		return null;

	var normalized = file.trim();
	if (normalized.length < 1)
		return Paths.video(file);

	if (normalized.endsWith(".mp4"))
		normalized = normalized.substr(0, normalized.length - 4);

	var variants:Array<String> = [normalized];
	var underscored = normalized.replace(" ", "_");
	var spaced = normalized.replace("_", " ");
	if (!variants.contains(underscored)) variants.push(underscored);
	if (!variants.contains(spaced)) variants.push(spaced);

	for (variant in variants)
	{
		var path = Paths.video(variant);
		if (Assets.exists(path))
			return path;
	}

	return Paths.video(normalized);
}
function loadVideo(file:String, options:Array<String>, camera:FlxCamera):FlxVideoSprite
{
	if (options == null)
		options = [VideoSprite.muted];
	else if (!options.contains(VideoSprite.muted))
		options.push(VideoSprite.muted);

	var video = new FlxVideoSprite();
	var resolvedPath = resolveVideoPath(file);
	video.load(resolvedPath, options);
	video.bitmap.onEndReached.add(() ->
	{
		// video.stop();
		video.kill();
		// Log("onEndReached", TColor.RED);
	});
	video.bitmap.onEncounteredError.add(err -> {
		Log(file + ": " + err, TColor.RED);
	});
	video.scrollFactor.set();
	video.camera = camera;
	video.kill();
	return video;
}

function cameraFromString(str:String):FlxCamera
{
	if (str != null)
		str = str.toLowerCase().trim();

	return switch (str)
	{
		case "camgame" | "game" | "0":	  FlxG.camera;
		case "camhud" | "hud" | "1":	  camHUD;
		// case "camother" | "other" | "2":  camOther;
		default:						  camOther; // FlxG.camera;
	}
}

function optionsFromString(str:String):Array<String>
{
	if (str == null)
		return null;

	var options = str.split(",");
	for (k => v in options)
		options[k] = v.trim();
	return options;
}
