using StringTools;
using game.backend.utils.CoolUtil;

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "Flash")
	{
		final ass = value1.split(",");
		var duration = Std.parseFloat(ass[0]).getDefault(1.0);
		var color = ass[1].colorFromString();
		var cameraString = ass[2];
		var camera = switch (cameraString == null ? null : cameraString.trim().toLowerCase())
		{
			case "other" | "camother" | "2": camOther;
			case "hud" | "camhud" | "1": camHUD;
			default: camGame;
		}

		// да, флэш это теперь фейд ин
		camera.fade(color, duration, value2.trim().toLowerCase() != "fade", null, true);
	}
}