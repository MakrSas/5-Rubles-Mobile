var isMoruMix = PlayState.SONG.song.toLowerCase() == "hernyamorumix";
var iconsMap:Map<String, HealthIcon> = [];
setVar("iconsMap", iconsMap);

function pushIcon(icon:HealthIcon)
{
	iconsMap.set(icon.char, icon);
	iconsGroup.add(icon);
}
setVar("pushIcon", pushIcon);
pushIcon(iconP1);
pushIcon(iconP2);

var lastTarget = null;
function onCreatePost() lastTarget = _camTarget;

// var komp = getVar("komp_char");
var juzt = getVar(isMoruMix ? "5juztexds-flipped_char" : "5juztexds_char");
function onUpdatePost(elapsed:Float)
{
	if (lastTarget == _camTarget)
		return;

	onChangeFocusChar(switch (_camTarget)
	{
		case "dad" | "opponent": dad;
		case "gf" | "girlfriend": gf;
		case "bf" | "boyfriend": boyfriend;
		// case "komp" | "комп": komp;
		case "juzt" | "джаст": juzt;
		default: null;
	});
	lastTarget = _camTarget;
}

var _leTweene:FlxTween;
var _leTweenePlayer:FlxTween;
var healthBar = getVar("healthBar");
function onChangeFocusChar(char:Character)
{
	if (char == null)
		return;

	var isPlayer = (char.isPlayer || (isMoruMix && char == gf));
	var newIcon = iconsMap.get(char.healthIcon);
	if (newIcon == null)
		return;

	if (_leTweene != null)
		_leTweene.finish();
	if (_leTweenePlayer != null)
		_leTweenePlayer.finish();

	var oldIcon = (isPlayer ? iconP1 : iconP2);
	if (oldIcon == newIcon || oldIcon.isPlayer != newIcon.isPlayer)
		return;

	trace("snap", newIcon.char);
	var targetYOld = oldIcon.iconOffsets[1];
	var targetYNew = newIcon.iconOffsets[1];
	var isRight = (isPlayer != healthBar.leftToRight);
	var oldColorBar = (isRight ? healthBar.rightBar : healthBar.leftBar).color;
	var colorHealthBar = (isRight ? i -> colorRight(oldColorBar, char.healthColor, i) : i -> colorLeft(oldColorBar, char.healthColor, i));

	var offsetY = 90.0;
	var tween = FlxTween.num(0.0, 1.0, Conductor.crochet * 0.0039, {ease:FlxEase.elasticOut, onComplete: _ -> {
		if (isPlayer)
		{
			iconP1 = newIcon;
			_leTweenePlayer = null;
		}
		else
		{
			iconP2 = newIcon;
			_leTweene = null;
		}
		oldIcon.iconOffsets[1] = targetYOld;
		oldIcon.set_alpha(0.0);
		newIcon.iconOffsets[1] = targetYNew;
		newIcon.set_alpha(1.0);
		colorHealthBar(1.0);
	}}, i -> {
		var invert = (1.0 - i);
		oldIcon.iconOffsets[1] = targetYOld + offsetY * i;
		oldIcon.set_alpha(invert);
		newIcon.iconOffsets[1] = targetYNew - offsetY * invert;
		newIcon.set_alpha(i);
		colorHealthBar(FlxMath.bound(i, 0.0, 1.0));
	});

	if (isPlayer)
		_leTweenePlayer = tween;
	else
		_leTweene = tween;
}

function colorLeft(from:FlxColor, to:FlxColor, i:Float) healthBar.leftBar.color = FlxColor.interpolate(from, to, i);
function colorRight(from:FlxColor, to:FlxColor, i:Float) healthBar.rightBar.color = FlxColor.interpolate(from, to, i);