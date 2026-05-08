using StringTools;

var _tween:FlxTween;

static function isValidStr(s:String)
	return s != null && s.trim().length > 0;

var nextPosition = FlxPoint.get();
var splitVl1:Array<Float>;

function updateNextPos()
{
	if (camFollow == null)
		nextPosition.set(targetCharPos.x, targetCharPos.y);
	else
		nextPosition.set(camFollow.x, camFollow.y);

	if (splitVl1 != null)
	{
		if (splitVl1[0] != null)
			nextPosition.x = splitVl1[0];
		if (splitVl1[1] != null)
			nextPosition.y = splitVl1[1];
	}
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "Set Camera Position":
			var nameOfNextPos = isValidStr(value3) ? value3 : null;
			splitVl1 = isValidStr(value1) ? [for (i in value1.split(",")) CoolUtil.getDefault(Std.parseFloat(i), null)] : null;



			if (_tween != null)
			{
				var t = _tween;
				t.onComplete(t);
				t.cancel();
				// _tween = null;
			}

			if (nameOfNextPos != null)
			{
				isCameraOnForcedPos = true;
				moveCameraOnChar(nameOfNextPos, true);
				if (splitVl1 != null)
				{
					updateNextPos();
					targetCharPos.set(nextPosition.x, nextPosition.y);
					camFollow?.set(targetCharPos.x, targetCharPos.y);
				}
			}
			else if (splitVl1 != null)
			{
				isCameraOnForcedPos = true;
				updateNextPos();
				camFollow?.set(nextPosition.x, nextPosition.y);
			}
			else
			{
				isCameraOnForcedPos = false;
				updateCameraPosition = true;
				moveCameraSection();
			}

			if (isValidStr(value2) && camFollow != null)
			{
				var params:Array<String> = value2.split(",");
				var promoTime:Null<Float> = CoolUtil.getDefault(Std.parseFloat(params[0]), null);
				var promoTime2:Null<Float> = CoolUtil.getDefault(Std.parseFloat(params[1]), null);
				var time:Float = promoTime ?? promoTime2 ?? 0.5;

				var oldForsePos = isCameraOnForcedPos;
				updateCameraPosition = false;
				isCameraOnForcedPos = true;
				if (time > 0)
				{
					var easeStr:String = CoolUtil.getDefault(promoTime == null ? params[0] : null,
						CoolUtil.getDefault(promoTime2 == null ? params[1] : null, "cubeout"));
					// trace(easeStr);
					easeStr = easeStr.rtrim().toLowerCase();
					if (easeStr != "linear" && !easeStr.endsWith("out") && !easeStr.endsWith("in"))
						easeStr = easeStr + "out"; // auto set Out on "circ", "expo", "cube" or same

					_tween = FlxTween.tween(camFollowPos, {x: camFollow.x, y: camFollow.y}, time, {
						ease: CoolUtil.getFlxEaseByString(easeStr),
						onComplete: _ ->
						{
							_tween = null;
							updateCameraPosition = true;
							isCameraOnForcedPos = oldForsePos;
						}
					});
				}
				else
				{
					camFollowPos.setPosition(camFollow.x, camFollow.y);
					camera.snapToTarget();
					updateCameraPosition = true;
					isCameraOnForcedPos = oldForsePos;
				}
			}
			//debugPrint([camFollow.x, camFollow.y]);
	}
}

function onDestroy()
{
	nextPosition?.put();
}
