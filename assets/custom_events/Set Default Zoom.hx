import flixel.tweens.FlxTweenManager;

using game.backend.utils.CoolUtil;
using StringTools;

public var cameraTweenManager = new FlxTweenManager();
var _tweens:Map<Int, FlxTween> = [];
var _defaultZoom:Float;

function onCreatePost()
{
	_defaultZoom = defaultCamZoom;
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "Set Default Zoom")
	{
		var options = parseOptions(value1, value2, value3);

		if (_tweens.exists(options.camera.ID))
		{
			_tweens[options.camera.ID].cancel();
			_tweens.remove(options.camera.ID);
		}

		if (options.time > 0.0)
		{
			_tweens[options.camera.ID] = cameraTweenManager.num(options.camera.zoom, options.defaultZoom + options.addedZoom, options.time, {
				// не обновлять только что добавленные твины!
				// startDelay: FlxG.elapsed,
				ease: options.ease.getFlxEaseByString(),
				onComplete: _ -> _tweens.remove(options.camera.ID)
			}, z -> options.funcDefaultZoom(options.camera.zoom = z));
		}
		else
			options.funcDefaultZoom(options.defaultZoom + options.addedZoom);
	}
}

public function parseOptions(value1:String, value2:String, value3:String)
{
	var options = {
		camera: FlxG.camera,
		defaultZoom: _defaultZoom,
		// curDefZoom: defaultCamZoom,
		funcDefaultZoom: set_defaultCamZoom
	}

	switch (value3?.toLowerCase()?.trim())
	{
		case "camhud" | "hud":
			options.camera = camHUD;
			options.defaultZoom = 1.0;
			// options.curDefZoom = defaultCamHUDZoom;
			options.funcDefaultZoom = set_defaultCamHUDZoom;

		// поддержка двойных камер
		case "camplayer" | "player" | "p" /*| "left" | "l"*/:
			if (variables.exists("camPlayer"))
			{
				var camPlayer = getVar("camPlayer");
				options.camera = camPlayer;
				options.funcDefaultZoom = z -> camPlayer.defaultZoom = z * mainDefaultZoom;
			}

		case "camopponent" | "opponent" | "o" /*| "right" | "r"*/:
			if (variables.exists("camOpponent"))
			{
				var camOpponent = getVar("camOpponent");
				options.camera = camOpponent;
				options.funcDefaultZoom = z -> camOpponent.defaultZoom = z * mainDefaultZoom;
			}

		default:
			if (variables.exists("camPlayer") && variables.exists("camOpponent"))
			{
				var camPlayer = getVar("camPlayer");
				var camOpponent = getVar("camOpponent");
				options.camera = camPlayer;
				options.funcDefaultZoom = z ->
				{
					/*camPlayer.zoom =*/ camOpponent.zoom = z;
					camPlayer.defaultZoom = camOpponent.defaultZoom = z * mainDefaultZoom;
				}
			}
	}

	var params:Array<String> = sortParams(value2.split(","));
	options.addedZoom = Std.parseFloat(value1).getDefault(0.0);
	options.time = Std.parseFloat(params[0]).getDefault(10.0) * Conductor.stepCrochet / 1000.0;

	if (options.time > 0)
	{
		var easeStr:String = params[1]?.trim();
		if (easeStr == null || easeStr.length == 0)
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
		options.ease = easeStr;
	}
	return options;
}

function onUpdatePost(elapsed:Float)
{
	cameraTweenManager.update(elapsed);
}

function onCreateGameOver()
{
	// cameraTweenManager.clear();
	for (tween in _tweens)
		tween.cancel();
}

function onDestroy()
{
	cameraTweenManager.destroy();
}

static final __NUMBER_REGEX = ~/^\s*[+-]?\d+?(\.\d+)?\s*$/;
function sortParams(params:Array<String>):Array<String>
{
	if (params.length != 0)
	{
		var timeParam = params[0];
		if (!__NUMBER_REGEX.match(timeParam))
		{
			params[0] = params[1];
			params[1] = timeParam;
		}
	}
	return params;
}