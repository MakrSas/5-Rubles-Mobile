var multiShit = loadHScript(AssetsPaths.getPath("data/multiShit.hx"));
var old_onCountdownStarted = multiShit.variables.get("onCountdownStarted");
multiShit.variables.set("onCountdownStarted", () ->
{
	old_onCountdownStarted();

	var gfStrums = getVar("gfStrums");
	var temp = gfStrums.position.x;
	gfStrums.position.x = opponentStrums.position.x;
	opponentStrums.position.x = temp;
	gfStrums.updateStrumsPos(null, null, true, false);
	opponentStrums.updateStrumsPos(null, null, true, false);
});

var introCard:FlxSprite;
function onCreate()
{
	var hasCamPosScript = false;
	var hasCamZoomScript = false;
	for (script in scriptPack.hscriptArray)
	{
		// trace(script.scriptName);
		if (script.scriptName == "Set Camera Position.hx")
			hasCamPosScript = true;
		else if (script.scriptName == "Set Default Zoom.hx")
			hasCamZoomScript = true;

		if (hasCamPosScript && hasCamZoomScript)
			break;
	}

	if (!hasCamPosScript)
	{
		trace("loading Set Camera Position");
		loadHScript(AssetsPaths.getPath("custom_events/Set Camera Position.hx"));
	}
	if (!hasCamZoomScript)
	{
		trace("loading Set Default Zoom");
		loadHScript(AssetsPaths.getPath("custom_events/Set Default Zoom.hx"));
	}

	introCard = new FlxSprite(280.0, -5790.0, Paths.image("cxodka/introCard"));
	introCard.scrollFactor.set(1.6, 1.6);
	introCard.alpha = 0.00001;
	introCard.scale.set(0.85, 0.85); // 0.5
	introCard.updateHitbox();
	// introCard.screenCenter();
	// introCard.camera = camHUD;

	var oldCreateCountSprite = createCountSprite;
	createCountSprite = (name:String, sound:String) ->
	{
		var countdown = oldCreateCountSprite(name, sound);
		if (countdown != null)
			countdown.camera = camOther;
		return countdown;
	}
}

function onCreatePost()
{
	add(introCard); // addBehindObject

	isCameraOnForcedPos = true;
	snapCamFollowToPos(936.25, -3264.55);
	FlxG.camera.snapToTarget();
	FlxG.camera.zoom *= 1.35;
	camHUD.alpha = 0;
	camControls.alpha = 0;
}

// интро в скрипте чтобы не ломать луп песни!
function onSongStart()
{
	var crochetSec = Conductor.crochet / 1000.0;
	FlxTween.num(introCard.alpha, 1.0, crochetSec * 3.0, {
		startDelay: crochetSec,
		onComplete: _ ->
		{
			new FlxTimer().start(crochetSec * 13.0, _ ->
			{
				FlxTween.num(introCard.alpha, 0.0, crochetSec * 6.0, {
					startDelay: crochetSec / 2.0,
					onComplete: _ -> introCard.kill()
				}, introCard.set_alpha);
				triggerEventNote("Set Camera Position", "820,450", (crochetSec * 20.0) + ",quadinout", "");
				triggerEventNote("Set Default Zoom", "", "90,quadinout", "");
			});
		}
	}, introCard.set_alpha);
	for (cam in [camHUD, camControls])
		FlxTween.num(cam.alpha, 1.0, crochetSec, {startDelay: crochetSec * 45.0}, cam.set_alpha);
}