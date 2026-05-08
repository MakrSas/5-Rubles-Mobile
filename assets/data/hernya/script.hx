import game.objects.improvedFlixel.FlxCustomBGSprite;

loadHScript("data/iconSwap.hx");
loadHScript("data/do_a_flip.hx");
importHScriptClasses("scripts/classes/ExplosionSprite.hx");

var juzt:Character = getVar("5juztexds_char");

function onGameOverStart()
{
	remove(_fade);
	GameOverSubstate.instance.add(_fade);
	onSongStart();
	if (introTween != null)
	{
		introTween.manager._tweens.remove(introTween);
		FlxTween.globalManager._tweens.push(introTween);
		introTween.manager = FlxTween.globalManager;
	}
}

var blockInput = true;
var firstNote:Note;
function preKeyPress()
{
	if (blockInput)
	{
		if (Conductor.songPosition > firstNote.strumTime || firstNote.isOnScreen(playerStrumLine.camera))
		{
			ClientPrefs.ghostTapping = FlxG.save.data.ghostTapping;
			blockInput = false;
		}
		else
		{
			ClientPrefs.ghostTapping = true;
			moveCameraChar("bf");
			boyfriend.playAnim("hi", true);
			boyfriend.specialAnim = true;
			return Function_Stop;
		}
	}
}

function onPause()
{
	if (blockInput)
	{
		ClientPrefs.ghostTapping = FlxG.save.data.ghostTapping;
	}
}

function onUpdate()
{
	if (FlxG.keys.justPressed.SPACE)
	{
		boyfriend.playAnim("hey", true);
		boyfriend.specialAnim = true;
	}
}

var _fade:FlxCustomBGSprite;
var komp:Character;
var boom:ExplosionSprite;
function onCreatePost()
{
	iconHealthGF.y = iconHealthJuzt.y = iconP2.y;

	_fade = new FlxCustomBGSprite();
	_fade.color = FlxColor.BLACK;
	_fade.cameras = [camGame];
	camHUD.alpha = 0;
	camControls.alpha = 0;
	add(_fade);

	komp = getVar("komp_char");
	if (komp != null)
	{
		boom = new ExplosionSprite(komp.x + 230.0, komp.y + 100.0);
		boom.animation.callback = (n, f, i) -> if (f > 1) komp.visible = false;
		boom.animation.play("boom");
		boom.scale.set(7.0, 7.0);
		boom.updateHitbox();
		boom.kill();
		add(boom);
	}

	firstNote = playerStrumLine.unspawnNotes[0];
	blockInput = (firstNote != null);
}

var introTween:FlxTween;
var doneIntro = false;
function onSongStart()
{
	if (doneIntro)
		return;

	isCameraOnForcedPos = true;
	new FlxTimer().start(0.25, _ ->
	{
		var crochetSec = Conductor.crochet / 1000.0;
		var ease = t -> 1.0 - Math.pow(1.0 - t, 1.5);
		introTween = FlxTween.num(1, 0.0, crochetSec * 22.0, {ease: ease, onComplete: _ -> _fade.kill()}, _fade.set_alpha);
		if (!isDead)
			FlxTween.num(defaultCamZoom + 0.3, defaultCamZoom, crochetSec * 29.0, {ease: ease}, z -> camGame.zoom = defaultCamZoom = z);
	});
	doneIntro = true;
}

var iconHealthGF = new HealthIcon(gf.healthIcon, false);
var iconHealthJuzt = new HealthIcon(juzt == null ? 'face' : juzt.healthIcon);
iconsGroup.insert(0, iconHealthJuzt);
iconHealthGF.alpha = iconHealthJuzt.alpha = 0;

var pushIcon = getVar("pushIcon");
pushIcon(iconHealthGF);
pushIcon(iconHealthJuzt);

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "")
	{
		switch (value1)
		{
			case "komp_bom_bom":
				boom?.revive();
			case "show_hud":
				isCameraOnForcedPos = false;
				for (cam in [camHUD, camControls])
					FlxTween.num(0.0, 1.0, 0.08, null, cam.set_alpha);
				moveCameraSection();
		}
	}
}