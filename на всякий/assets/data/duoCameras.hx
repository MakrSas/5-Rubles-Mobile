import flixel.FlxBasic;
import flixel.FlxObject;
import game.objects.FlxLayerGroup;
import game.objects.game.CoolCamera;

public var camPlayer:CoolCamera;
public var camOpponent:CoolCamera;

public var camFollowPosPlayer:FlxObject;
public var camFollowPosOpponent:FlxObject;

var camPlayerModule:MoveCameraModule;
var camOpponentModule:MoveCameraModule;

// var jpegShaderPlayer:FlxRuntimeShader;
// var jpegShaderOpponent:FlxRuntimeShader;
var jpegShader:FlxRuntimeShader;
var opponentLayerdGroup:FlxLayerGroup;

var gameOverConfig:Dynamic;
var defaultStageZoom = defaultCamZoom;

// для редар микса - rich
// или нет? - redar
public function flipCameras()
{
	var temp = camPlayer.x;
	camPlayer.x = camOpponent.x;
	camOpponent.x = temp;
}
public function flipMoveCameraModules()
{
	var temp = camPlayerModule;
	camPlayerModule = camOpponentModule;
	camOpponentModule = temp;
	updateCameraPositions();
}

function onCreate()
{
	// отрубить основной скрипт на камеру т.к. этот скрипт его воссоздает
	var moveCamScript = scriptPack.getHScript("scripts/moveCam");
	if (moveCamScript != null)
	{
		importHScriptClasses(moveCamScript);
		// moveCamScript.dispose();
		moveCamScript.call("onDestroy");
		moveCamScript.destroy();
		scriptPack.hscriptArray.remove(moveCamScript);
	}

	camPlayer = new CoolCamera();
	camOpponent = new CoolCamera();
	camPlayer.width = camPlayer.x = camOpponent.width = FlxG.width / 2.0;
	camPlayer.defaultZoom = camPlayer.zoom = camOpponent.defaultZoom = camOpponent.zoom = defaultCamZoom;
	FlxG.cameras.insert(camPlayer, 1, true);
	FlxG.cameras.insert(camOpponent, 1, true);

	insert(0, camFollowPosPlayer = new FlxObject(0.0, 0.0, 2.0, 2.0));
	insert(0, camFollowPosOpponent = new FlxObject(0.0, 0.0, 2.0, 2.0));

	camPlayer.follow(camFollowPosPlayer, null, Math.POSITIVE_INFINITY);
	camOpponent.follow(camFollowPosOpponent, null, Math.POSITIVE_INFINITY);

	insert(0, camPlayerModule = new MoveCameraModule([camPlayer]));
	insert(0, camOpponentModule = new MoveCameraModule([camOpponent]));

	setVar("camPlayer", camPlayer);
	setVar("camOpponent", camOpponent);
	setVar("camFollowPosPlayer", camFollowPosPlayer);
	setVar("camFollowPosOpponent", camFollowPosOpponent);

	if (ClientPrefs.shaders)
	{
		function setupShader()
		{
			var jpegShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("jpeg" + (true ? "_lite" : "")))); // ClientPrefs.lowQuality
			// if (ClientPrefs.lowQuality)
			// {
				jpegShader.setFloat("cellSize", 0);
				jpegShader.setFloat("colors", 256);
				// jpegShader.setFloat("crustFactor", 0.4);
			// }
			// else
			// {
			//	jpegShader.glVersion = "110";
			//	jpegShader.setFloat("Q", 24);
			//	jpegShader.setInt("BS", 1);
			// }
			return jpegShader;
		}

		// setVar("jpegShaderPlayer", jpegShaderPlayer = setupShader());
		// setVar("jpegShaderOpponent", jpegShaderOpponent = setupShader());
		setVar("jpegShader", jpegShader = setupShader());
		// camPlayer.setFilters([new ShaderFilter(jpegShaderPlayer)]);
		// camOpponent.setFilters([new ShaderFilter(jpegShaderOpponent)]);
		camOpponent.setFilters([new ShaderFilter(jpegShader)]);
	}

	var old_cameraZooming = cameraZooming;
	cameraZooming = (elapsed:Float) ->
	{
		old_cameraZooming();
		if (camZooming)
		{
			var lerpFactor = 0.052083 * camZoomingDecay;
			// if (!camPlayer.tweeningZoom)
				camPlayer.zoom = CoolUtil.fpsLerp(camPlayer.zoom, camPlayer.defaultZoom, lerpFactor);
			// if (!camOpponent.tweeningZoom)
				camOpponent.zoom = CoolUtil.fpsLerp(camOpponent.zoom, camOpponent.defaultZoom, lerpFactor);
		}
	}
}

function onCreatePost()
{
	gameOverConfig = getVar("gameOverConfig");
	FlxG.camera.visible = false;
	updateCameraPositions();

	var scoreGroup = getVar("scoreGroup");
	scoreGroup.cameras = [camHUD];
	scoreGroup.scale.set(0.8, 0.8);
	scoreGroup.x += 120.0;
	scoreGroup.y += 80.0;

	// if (ClientPrefs.shaders && !ClientPrefs.lowQuality)
	// {
	// 	opponentLayerdGroup = new FlxLayerGroup();
	// 	opponentLayerdGroup.shader = jpegShader;
	// 	opponentLayerdGroup.cameras = opponentStrumLine.cameras;
	// 	addBehindObject(opponentLayerdGroup, opponentStrumLine);
	// 	// addAheadObject(opponentLayerdGroup, new FlxBasic());
	// 	remove(opponentStrumLine);
	// 	opponentLayerdGroup.add(opponentStrumLine);
	// }
}

function onUpdatePost(elapsed:Float)
{
	if (opponentLayerdGroup != null)
		opponentLayerdGroup.basicDraw = isDead || (jpegShader.getFloat("colors") >= 255 && jpegShader.getFloat("cellSize") == 0);
	// trace(isDead, jpegShader.getFloat("colors"), jpegShader.getFloat("cellSize"));
	if (isDead)
	{
		if (!gameOverConfig.active)
			return;

		if (GameOverSubstate.instance?.moveCamera)
		{
			camPlayer.zoom = CoolUtil.fpsLerp(camPlayer.zoom, camPlayer.defaultZoom, 0.04 * camZoomingDecay);
			camOpponent.zoom = CoolUtil.fpsLerp(camOpponent.zoom, camOpponent.defaultZoom, 0.04 * camZoomingDecay);
		}
	}
	else
	{
		// пусто
	}
}

function onBeatHit(beat:Int)
{
	if (isDead)
	{
		// пусто
	}
	else
	{
		if (ClientPrefs.camZooms && camZooming && camZoomingFreq > 0 && beat % camZoomingFreq == camZoomingOffset)
		{
			var factor = 0.015 * camZoomingMult;
			// if (!camGame.tweeningZoom)
				camPlayer.zoom += factor;
			// if (!camHUD.tweeningZoom)
				camOpponent.zoom += factor;
		}
	}
}

function onSectionHit(sec:Int)
{
	if (isDead)
	{
		if (!gameOverConfig.active)
			return;

		if (gameOverConfig.cameraZooming)
		{
			var factor = 0.015 * defaultCamZoom;
			camPlayer.zoom += factor;
			camOpponent.zoom += factor;
		}
	}
	else
	{
		if (curSection >= PlayState.SONG.notes.length) // PlayState.SONG.notes[curSection] == null
			return;

		// updateCameraPositions();

		if (ClientPrefs.camZooms && addZoomOnSection && camZooming && camZoomingFreq == 0)
		{
			var factor = 0.015 * camZoomingMult;
			// if (!camGame.tweeningZoom)
				camPlayer.zoom += factor;
			// if (!camHUD.tweeningZoom)
				camOpponent.zoom += factor;
		}
	}
}

public function updateCameraPositions()
{
	var camPos = setCharCamOffset("boyfriend");
	camFollowPosPlayer.setPosition(camPos.x, camPos.y);
	camPos = setCharCamOffset("dad");
	camFollowPosOpponent.setPosition(camPos.x, camPos.y);
	camPlayer.followLerp = camOpponent.followLerp = FlxG.camera.followLerp;
	camPlayer.snapToTarget();
	camOpponent.snapToTarget();
}

function opponentNoteHit(note:Note)	moveCam(note);
function goodNoteHit(note:Note)		moveCam(note);

function moveCam(note:Note)
{
	if (note.mustPress || note.noteType.indexOf("BFNote") != -1)
		camPlayerModule.notePress(note);
	else
		camOpponentModule.notePress(note);
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "Flash New":
				if (!ClientPrefs.flashing)
					return;

				var val1 = CoolUtil.getDefault(Std.parseFloat(value1), 1);
				var val2 = CoolUtil.getDefault(Std.parseInt(value2), 0xFFFFFFFF);
				final cam = switch (StringTools.trim(value3.toLowerCase()))
				{
					case "camplayer" | "player" | "p": camPlayer;
					case "camopponent" | "opponent" | "o": camOpponent;
					default: null;
				}
				if (cam != null)
					cam.flash(val2, val1);

		case "":
			switch (value1)
			{
				case "lag":
					var sep = value2.split(",");
					var qual = CoolUtil.getDefault(Std.parseFloat(sep[0]), 24);
					var size = CoolUtil.getDefault(Std.parseFloat(sep[1]), 0);
					var time = CoolUtil.getDefault(Std.parseFloat(value3), 0) * Conductor.stepCrochet / 1000;
					tweenJPEGQuality(qual, time);
					tweenJPEGSize(size, time);

				case "outro":
					camOpponent.fade(FlxColor.BLACK, 0.8, false, () -> camOpponent.visible = false);
			}
	}
}

var tweenEase = FlxEase.sineIn;
var qualityTween:FlxTween;
var sizeTween:FlxTween;

function tweenJPEGQuality(to:Float, time:Float)
{
	function toColorSpace(ease = false):Float
		return 256 * (ease ? FlxEase.circOut : FlxEase.linear)(to / 24);

	if (qualityTween != null)
		qualityTween.cancel();

	var from;
	var func;
	if (ClientPrefs.shaders)
	{
		// if (ClientPrefs.lowQuality)
		// {
			to = toColorSpace();
			from = jpegShader.getFloat("colors"); // jpegShaderOpponent
			func = jpegShader.setFloat.bind("colors", _); // jpegShaderOpponent
		// }
		// else
		// {
		//	from = jpegShader.getFloat("Q"); // jpegShaderOpponent
		//	func = jpegShader.setFloat.bind("Q", _); // jpegShaderOpponent
		// }
	}
	else
	{
		to = (-256 + toColorSpace(true)) / 3;
		from = camOpponent.canvas.transform.__colorTransform.redOffset;
		func = o ->
		{
			camOpponent.canvas.transform.__colorTransform.redOffset = o;
			camOpponent.canvas.transform.__colorTransform.greenOffset = o;
			camOpponent.canvas.transform.__colorTransform.blueOffset = o;
		};
	}
	qualityTween = FlxTween.num(from, to, time, {ease: tweenEase, onComplete: _ -> qualityTween = null}, func);
}

function tweenJPEGSize(to:Float, time:Float)
{
	if (!ClientPrefs.shaders)
		return;

	if (sizeTween != null)
		sizeTween.cancel();

	var from;
	var func;
	// if (ClientPrefs.lowQuality)
	// {
		from = jpegShader.getFloat("cellSize"); // jpegShaderOpponent
		func = s -> jpegShader.setFloat("cellSize", Std.int(s)); // jpegShaderOpponent
	// }
	// else
	// {
	//	from = jpegShader.getInt("BS"); // jpegShaderOpponent
	//	func = s -> jpegShader.setInt("BS", Std.int(s)); // jpegShaderOpponent
	// }
	sizeTween = FlxTween.num(from, to, time, {ease: tweenEase, onComplete: _ -> sizeTween = null}, func);
}

function onGameOverStart()
{
	var time = 0.9;
	// camOpponent.freezeDraws = true;
	camOpponent.fade(FlxColor.BLACK, time, false, () -> camOpponent.visible = false);
	tweenJPEGSize(camOpponent.width / 8, time);
	tweenJPEGQuality(0.1, time);
	camPlayer.defaultZoom = defaultStageZoom;
	// camOpponent.defaultZoom = defaultStageZoom;
}

function onGameOverConfirm(restart:Bool)
{
	if (restart)
	{
		new FlxTimer().start(0.7, _ -> camPlayer.fade(FlxColor.BLACK, 2.0, false));
		if (gameOverConfig.active)
		{
			var factor = 1.1;
			camPlayer.defaultZoom *= factor;
			// camOpponent.defaultZoom *= factor;
		}
	}
}