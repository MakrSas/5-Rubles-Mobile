import flixel.tweens.FlxTweenManager;

using game.backend.utils.CoolUtil;
using StringTools;

var cameraTweenManager = new FlxTweenManager();
var _tweens:Map<Int, FlxTween> = [];
var _defaultZoom:Float;

function onCreatePost()
{
	_defaultZoom = defaultCamZoom;
}

function onSongGenerated()
{
	for (event in eventNotes)
		if (event[1] == "GOIDA ZOOM")
			event[0] -= Math.max(Std.parseFloat(sortParams(event[3].split(","))[1]).getDefault(10) * Conductor.stepCrochet, 0);
}

/*function eventEarlyTrigger(name:String, value1:String, value2:String, value3:String, time:Float)
{
	if (name == "GOIDA ZOOM")
		return Math.max(Std.parseFloat(sortParams(value2.split(","))[1]).getDefault(10) * Conductor.stepCrochet, 0);

	return 0;
}*/

function onEvent(name:String, value1:String, value2:String, value3:String, strumTime:Float)
{
	if (name != "GOIDA ZOOM") return;

	var camera:FlxCamera;
	var defaultZoom:Float;
	var curDefZoom:Float;
	switch (value3 == null ? value3 : value3.toLowerCase().trim())
	{
		case "camhud":
			camera = camHUD;
			defaultZoom = 1;
			curDefZoom = defaultCamHUDZoom;

		default:
			camera = camGame;
			defaultZoom = _defaultZoom;
			curDefZoom = defaultCamZoom;
	}

	if (_tweens.exists(camera.ID))
	{
		_tweens[camera.ID].cancel();
		_tweens.remove(camera.ID);
	}

	var params:Array<String> = sortParams(value2.split(","));
	var time:Float = Std.parseFloat(params[1]).getDefault(10) * Conductor.stepCrochet / 1000;
	var easeStr:String = params[2];
	if (easeStr == null || (easeStr = easeStr.trim()).length == 0)
	{
		// дефолт
		easeStr = "cubeout";
	}
	else
	{
		easeStr = easeStr.toLowerCase().replace("outin", "inout");
		if (easeStr != "linear" && !easeStr.endsWith("out") && !easeStr.endsWith("in"))
			easeStr += "out"; // auto ease out if wasnt specified
	}

	var zoomParams:Array<String> = value1.split(",");
	var addZoom = Std.parseFloat(zoomParams[0]).getDefault(0);
	var bumpZoom = Std.parseFloat(zoomParams[1]).getDefault(0.05);
	_tweens[camera.ID] = cameraTweenManager.num(camera.zoom, defaultZoom + addZoom, time, {
		// startDelay: FlxG.elapsed,
		ease: easeStr.getFlxEaseByString(),
		onComplete: _ ->
		{
			switch (params[0])
			{
				case "mode2":
					// ГОЙДААААААААА!!!!!! (ничего не происходит)

				default:
					switch (camera)
					{
						case camHUD: defaultCamHUDZoom = camera.zoom;
						default: defaultCamZoom = camera.zoom;
					}
			}

			if (ClientPrefs.camZooms && camZooming)
				camera.zoom += bumpZoom;
		}
	}, camera.set_zoom);
	// trace(value1, value2, value3, params, zoomParams, strumTime);
}

function onUpdatePost(elapsed:Float)
{
	cameraTweenManager.update(elapsed);
}

function onDestroy()
{
	cameraTweenManager.destroy();
}

static final __MODE_REGEX = ~/^\s*mode\d+\s*$/i;
static final __NUMBER_REGEX = ~/^\s*[+-]?\d+?(\.\d+)?\s*$/;
static function sortParams(params:Array<String>):Array<String>
{
	var param = params[0];
	if (__MODE_REGEX.match(param))
		params[0] = param.toLowerCase().trim();

	if (params.length > 1)
	{
		param = params[1];
		if (!__NUMBER_REGEX.match(param))
		{
			params[1] = params[2];
			params[2] = param;
		}
	}
	return params;
}