static final MODE_CLEAR = -1;
static final MODE_NEW = 0;
static final MODE_OVERRIDE = 1;
static final MODE_ADD = 2;
static final DEFAULT_OFFSET_Y = 40;

var posY = FlxG.height / 3 * 2.35;
var textGroup:FlxGroup;
var dictionary:Map<String, String> = [
	// "Ты меня затмил," => "GYATTTTTTT"
];

function loadSubtitles(newDictionary:Map<String, String>)
{
	for (id => string in newDictionary)
		dictionary.set(id, string);
}
setVar("loadSubtitles", loadSubtitles);

function onCreatePost()
{
	textGroup = new FlxGroup();
	textGroup.camera = camOther;
	textGroup.ID = 0;
	// addAheadObject(textGroup, strumLineNotes);
	add(textGroup);
}

function constructor()
{
	return new SubtitleText();
}

function onEvent(name:String, value1:String, value2:String, value3:String, strumTime:Float)
{
	switch (name)
	{
		case "Subtitles":
			var newText = StringTools.replace(dictionary.exists(value1) ? dictionary.get(value1) : value1, "\\n", "\n");
			var color = switch value2
			{
				case "bf" | "boyfriend": boyfriend.healthColor;
				case "dad" | "opponent": dad.healthColor;
				case "gf" | "girlfriend": gf.healthColor;
				default: CoolUtil.colorFromString(value2);
			}
			var mode = switch StringTools.trim(value3.toLowerCase())
			{
				case "clear" | "c": MODE_CLEAR;
				case "new" | "n" | "": MODE_NEW;
				case "override" | "o": MODE_OVERRIDE;
				case "add" | "a": MODE_ADD;
				default: CoolUtil.getDefault(Std.parseInt(value3), MODE_NEW);
			}
			// trace(newText, StringTools.hex(color, 6), mode);

			if (newText == "")
				mode = MODE_CLEAR;
			else if (mode == MODE_OVERRIDE && textGroup.countLiving() == 0)
				mode = MODE_NEW;

			function getLastAlive():SubtitleText
				textGroup.getLast(basic -> basic.alive);

			function finishTweensOf(object:Dynamic)
				FlxTween.forEachTweensOf(object, null, t -> t.finish());

			switch mode
			{
				case MODE_CLEAR:
					textGroup.forEachAlive(otherText ->
					{
						FlxTween.completeTweensOf(otherText);
						otherText.fade(true, 0, Conductor.stepCrochet / 1000 * 3 / 2);
					});

				case MODE_OVERRIDE:
					var text = getLastAlive();
					if (text != null)
					{
						text.text = newText;
						text.color = color;
						text.screenCenter(X);
						text.y = posY - text.height / 2;
					}
					// textGroup.forEachAlive(finishTweensOf);

				default:
					var isAdd = mode == MODE_ADD;
					var time = Conductor.stepCrochet / 1000 * 3;
					var ease = FlxEase.sineOut;
					var wait = time / 2;

					var offsetY = getLastAlive()?.height ?? DEFAULT_OFFSET_Y;
					var text = textGroup.recycle(FlxText, constructor);
					text.ID = textGroup.ID++;
					text.text = newText;
					text.color = color;
					text.screenCenter(X);
					text.y = posY - text.height / 2;
					text.alpha = 0.1;
					text.offset.y = -offsetY;

					finishTweensOf(text);
					FlxTween.tween(text, {alpha: 1}, wait);
					FlxTween.tween(text, {"offset.y": 0}, time, {ease: ease});
					textGroup.sort((index, obj1, obj2) -> obj1.ID > obj2.ID ? -index : obj2.ID > obj1.ID ? index : 0);
					textGroup.forEachAlive(otherText -> if (otherText != text)
					{
						finishTweensOf(otherText);
						if (isAdd)
							FlxTween.tween(otherText, {alpha: otherText.alpha - 0.2}, wait, {startDelay: wait});
						else
							otherText.fade(true, wait, wait);

						FlxTween.tween(otherText, {"offset.y": otherText.offset.y + text.height + 4}, time, {ease: ease});
					});
			}
	}
}

function onGameOverStart()
{
	textGroup.exists = false;
}

class SubtitleText extends FlxText
{
	var fading = false;
	var wait = 0;
	var timer = 0;

	public function new()
	{
		super(0, 0, 0, "", 28);
		setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		font = Paths.font("VCR OSD Mono Cyr.ttf");
		alignment = "center";
		alpha = 0.1;
	}

	public function fade(once:Bool, wait:Float, timer:Float)
	{
		if (once && fading)
			return;

		fading = true;
		this.wait = wait;
		this.timer = timer;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (fading)
		{
			wait = Math.max(wait - elapsed, 0);
			if (wait == 0)
				alpha -= elapsed / timer;
		}
		if (alpha == 0)
		{
			kill();
			fading = false;
			wait = 0;
			timer = 0;
			alpha = 0.1;
		}
	}
}