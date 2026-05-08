using game.backend.utils.CoolUtil;
using StringTools;

var totalShake, timeBeat, totalBeat = 0;
var gameZ, hudZ, gameShake, hudShake = 0.0;
var shakeTime = false;

function onBeatHit()
{
	if (totalBeat > 0)
	{
		if (curBeat % timeBeat == 0)
		{
			camGame.zoom += gameZ;
			camHUD.zoom += hudZ;
			totalBeat--;

			if (shakeTime)
			{
				var factor = (1.0 / (Conductor.bpm / 120.0));
				triggerEventNote("Screen Shake", '$factor, $gameShake', '$factor, $hudShake');
			}
		}
	}
	if (totalShake > 0)
	{
		totalShake--;
		var factor = (1.0 / (Conductor.bpm / 60.0));
		triggerEventNote("Screen Shake", '$factor, $gameShake', '$factor, $hudShake');
	}
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
    switch (name)
	{
		case "MMV2 Beat Event Lol":
			var split1:Array<String> = value1.split(",");
			var gameZoom:Float = Std.parseFloat(split1[0]).getDefault(0.015);
			var hudZoom:Float = Std.parseFloat(split1[1]).getDefault(0.03);

			shakeTime = (split1.length == 4);
			if (shakeTime)
			{
				var shGame:Float = Std.parseFloat(split1[2]);
				var shHUD:Float = Std.parseFloat(split1[3]);

				if (!Math.isNaN(shGame)) gameShake = shGame;
				if (!Math.isNaN(shHUD)) hudShake = shHUD;
			}

			var split2:Array<String> = value2.split(",");
			totalBeat = Std.parseInt(split2[0]).getDefault(4);
			timeBeat = Std.parseFloat(split2[1]).getDefault(1);

		/*
		case "Screen Shake Chain":
			var split1:Array<String> = value1.split(",");
			var gmShake:Float = Std.parseFloat(split1[0]);
			var hdShake:Float = Std.parseFloat(split1[1]);

			if (!Math.isNaN(gmShake)) gameShake = gmShake;
			if (!Math.isNaN(hdShake)) hudShake = hdShake;

			totalShake = Std.parseInt(value2).getDefault(4);

		case "Cambiar Zoom Default":
			var camaraActual:Float = Std.parseFloat(value2).getDefault(defaultCamZoom);
			FlxTween.tween(FlxG.camera, {zoom: camaraActual}, 0.5, {ease: FlxEase.quadInOut});
		*/
    }
}