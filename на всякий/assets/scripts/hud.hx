import flixel.util.FlxStringUtil;
import flixel.FlxBasic;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextFormat;
import flixel.addons.effects.FlxClothSprite;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxSort;
import flixel.group.FlxTypedSpriteGroup;

import game.backend.utils.native.Windows;
import game.objects.Bar;
import game.objects.FlxExtendedSprite;
import game.objects.improvedFlixel.FlxFixedText;

function onSongStart()
{
	/*
		inst.setFilter("LOWPASS").setFilterVar("GAIN", 0.8).setFilterVar("GAINHF", 0.05).setEffect("REVERB").setEffectVar("DECAY TIME", 7.5).setEffectVar("GAINHF", 0.25);
		if (vocals != null)
			vocals.setFilter("LOWPASS").setFilterVar("GAIN", 0.5).setFilterVar("GAINHF", 0.25).setEffect("REVERB").setEffectVar("DECAY TIME", 10.5).setEffectVar("GAINHF", 0.5);
		if (vocalsDAD != null)
			vocalsDAD.setFilter("LOWPASS").setFilterVar("GAIN", 0.5).setFilterVar("GAINHF", 0.15).setEffect("REVERB").setEffectVar("DECAY TIME", 10.5).setEffectVar("GAINHF", 0.5);
	 */
}

var numsFrames = Paths.getSparrowAtlas("hudTextStuff");
static var numsArr = {
	var myArr:Array<String> = [for (i in 0...10) Std.string(i) + "0000"];
	myArr.push("minus0000");
	myArr;
};

final mainNumsScale = 0.94;

class NumSprite extends FlxSprite
{
	public function new(x = 0, y = 0, startNum = 0)
	{
		super(x, y);
		frames = numsFrames;
		animation.addByNames("nums", numsArr, 0);
		animation.play("nums");
		updateNum(startNum);
	}

	public function updateNum(num:Int = 0)
	{
		var curAnim = animation._curAnim;
		if (curAnim.curFrame != num)
		{
			curAnim.curFrame = num;
			updateHitbox();
		}
	}
}

// TODO: Allow FlxSpriteGroup extensions
class NumsGroup extends FlxBasic // https://www.youtube.com/watch?v=eHz5v3I07zg - Redar13
{
	static var _dotWidth = 7;
	static var _numWidth = 24;
	static var _targetHeight = 27;

	public var group:FlxSpriteGroup = new FlxSpriteGroup(0, 0);
	public var icon:FlxSprite;
	public var targetNums = 0;
	public var seperated = [];
	public var curNums = 0;
	public var curNumsInt = 0;
	public var updateTextFactor = 0.3;
	public var numSprs = [];
	public var dotSprs = [];
	public var minusMode = false;
	// var mapRand = [for (i in 0...50) FlxG.random.float(0.5, 2) * FlxG.random.sign()]; // todo: shake nums?
	public var numsX:Float = 0;
	public var baseScale:Float = mainNumsScale;
	public var onRecycleNums:() -> Void = null;

	var options;

	public function new(x = 0, y = 0, myOptions = {
		dotsTex: null,
		startNums: 0,
		countDots: null,
		delayDots: 0,
		minLength: null,
		icon: null,
		scale: null,
	})
	{
		super();
		group.setPosition(x, y);

		options = myOptions;
		options.countDots ??= 1;
		options.minLength ??= 1;
		if (options.dotsTex)
			options.delayDots ??= 2;
		if (options.scale != null)
			baseScale = options.scale;

		var _x = 0;
		if (options.icon != null)
		{
			icon = new FlxSprite(_x * baseScale, 0);
			icon.frames = numsFrames;
			icon.animation.addByPrefix("idle", options.icon, 24, true);
			icon.animation.play("idle");
			icon.scale.set(baseScale, baseScale);
			icon.updateHitbox();
			centerSpr(icon);
			group.add(icon);

			_x += icon.width + 4;

			var dDots = new FlxSprite(_x * baseScale, 0);
			dDots.frames = numsFrames;
			dDots.animation.addByPrefix("idle", "doubledot", 24, true);
			dDots.animation.play("idle");
			dDots.scale.set(baseScale, baseScale);
			dDots.updateHitbox();
			centerSpr(dDots);
			group.add(dDots);
			_x += dDots.width + 2;
		}
		numsX = _x;
		for (spr in group.members)
		{
			spr.moves = false;
		}
		recycleNums(1);
		targetNums = options.startNums ?? 0;
		updateTextInner();
		group.scale.set(baseScale, baseScale);
	}

	public function getWidth() // Returns the width from the live sprites
	{
		var minX:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		for (member in group.group.members)
		{
			if (member == null || !member.alive)
				continue;

			minX = Math.min(minX, member.x);
			maxX = Math.max(maxX, member.x + member.width);
		}
		return maxX - minX;
	}

	function centerSpr(spr)
	{
		spr.y = (_targetHeight * baseScale - spr.height) / 2;
		return spr;
	}

	function recycleNums(length:Int)
	{
		length--;
		var i = numSprs.length;
		while (length < i)
		{
			numSprs[--i].kill();
		}
		i = dotSprs.length;
		while (length < i)
		{
			dotSprs[--i].kill();
		}
		var _numWidth = _numWidth * baseScale;
		var curX = numsX;
		var dotIndex = 0;
		for (i in 0...length + 1)
		{
			var num = numSprs[i];
			if (num == null)
			{
				num = new NumSprite(0, 0, 0);
				num.active = false;
				num.moves = false;
				num.scale.set(baseScale, baseScale);
				numSprs.push(num);
				group.add(num);
				centerSpr(num).y += group.y;
			}
			else
			{
				num.revive();
			}
			num.x = group.x + curX;
			curX += _numWidth;
			if (options.dotsTex != null
				&& (options.countDots == 0 || Std.int((length - i) / options.delayDots) <= options.countDots)
				&& (options.delayDots == 0 || (length - i) % options.delayDots == 0 && i != length)
			)
			{
				var dot = dotSprs[dotIndex++];
				if (dot == null)
				{
					dot = new FlxSprite(0, 0);
					dot.frames = numsFrames;
					dot.animation.addByPrefix("this", options.dotsTex, 0);
					dot.animation.play("this");
					dot.scale.set(baseScale, baseScale);
					dot.updateHitbox();
					dot.active = false;
					dot.moves = false;
					dotSprs.push(dot);
					group.add(dot);
					if (options.dotsTex == "dot")
						dot.y = group.y + _targetHeight * baseScale - dot.height;
					else
						centerSpr(dot).y += group.y;
				}
				else
				{
					dot.revive();
				}
				dot.x = group.x + curX + (_dotWidth - dot.frameWidth) / 2 / 1.5;
				curX += _dotWidth;
			}
		}
		if (onRecycleNums != null)
			onRecycleNums();
	}

	public override function update(elapsed)
	{
		if (curNumsInt != targetNums)
		{
			var old = curNumsInt;
			curNums = CoolUtil.fpsLerp(curNums, targetNums, updateTextFactor, elapsed);
			curNumsInt = Math.round(curNums);
			if (old != curNumsInt)
				updateTextInner(false);
		}
		super.update(elapsed);
	}

	public function updateTextInner(snap = true)
	{
		if (snap)
		{
			curNums = targetNums;
			curNumsInt = Math.round(curNums);
		}
		final isNegative = curNumsInt < 0;
		final curNumsAbs = Math.abs(curNumsInt);
		final strNum = Std.string(curNumsAbs);
		final digits = strNum.length;
		seperated.resize(0);
		if (minusMode)
		{
			for (i in 0...digits)
				seperated.push(10);
		}
		else
		{
			// for (i in 0...digits)
			// 	seperated.push(StringTools.fastCodeAt(strNum, i) - 48);
			for (i in 0...digits)
				seperated.push(Std.int(curNumsAbs / Math.pow(10, digits - 1 - i)) % 10);
		}

		if (isNegative)
		{
			seperated.insert(0, 10); // minus
			digits++;
		}

		var minDigits = Math.max(options.minLength, digits);
		if (minDigits != numSprs.length)
		{
			recycleNums(minDigits);
		}

		var i = seperated.length - minDigits;

		// trace(seperated, i, Std.string(curNumsAbs));
		for (spr in numSprs)
		{
			if (spr.alive)
			{
				spr.updateNum(seperated[i++] ?? 0);
				centerSpr(spr).y += group.y;
				// spr.color = isNegative ? 0xbcc5a29b : 0xffffffff;
			}
		}
	}

	public function updateText(nums, snap = true)
	{
		// targetNums = Math.round(Math.abs(nums));
		targetNums = nums;
		if (snap && curNums != targetNums)
			updateTextInner();
		// updateHitbox();
	}
}

// songLoops = true;
public var timeTxtFormat = new FlxTextFormat();
public var botplayTxt = new FlxText(0, 10, 0, "BOTPLAY");
public var scoreTxt:FlxFixedText;
public var timeText:FlxFixedText;
public var mainTimeNumsGroup:NumsGroup;
public var slash:FlxSprite;
public var songLengthNumsGroup:NumsGroup;
public var ratingNumsGroup:NumsGroup;
public var scoreNumsGroup:NumsGroup;
public var missesNumsGroup:NumsGroup;
public var numsGroups:Array<NumsGroup> = [];
public var leftDot:FlxSprite;
public var rightDot:FlxSprite;
public var healthBarBar:Bar;
public var offsetDisplaySongLength:Float = 0;
var doScoreLerp = false;

function goodNoteHit(n)
{
	if (healthbarStyle == "twist" && !n.isSustainNote)
	{
		doScoreLerp = n.tail.length != 0;
		scoreNumsGroup.updateTextFactor = doScoreLerp ? (n.getLastSustainNote().strumTime - n.strumTime) / 1000.0 / (n.tail.length - 0.5) : 1;
	}
}

function onCreate()
{
	PauseSubState.songName = "5pause";

	// healthBar
	healthBarBar = new Bar(0, FlxG.height * (ClientPrefs.downScroll ? 0.09 : 0.89), 'healthBar', () -> health, 0, 2);
	healthBarBar.screenCenter(X);
	healthBarBar.setColors(FlxColor.RED, FlxColor.LIME);

	timeText = new FlxFixedText(0, 0, 0, "");
	timeText.setFormat(Paths.font("VCR OSD Mono Cyr.ttf"), 16, FlxColor.WHITE, null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	timeText.borderSize = 1.2;

	timeTxtFormat = new FlxTextFormat();
	timeText.addFormat(timeTxtFormat, 0, 1);
	timeTxtFormat.format.size = timeText.size - 2;

	botplayTxt = new FlxText(0, 10, 0, "BOTPLAY");
	botplayTxt.setFormat(Paths.font("VCR OSD Mono Cyr.ttf"), 18, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
	botplayTxt.borderSize = 1.2;
	botplayTxt.x = FlxG.width - 10 - botplayTxt.width;
	botplayTxt.visible = cpuControlled;

	slash = new FlxSprite();
	slash.frames = numsFrames;
	slash.animation.addByPrefix("this", "slash", 0);
	slash.animation.play("this");
	slash.scale.set(mainNumsScale, mainNumsScale);
	slash.updateHitbox();
	slash.moves = false;

	leftDot = new FlxSprite();
	leftDot.frames = numsFrames;
	leftDot.animation.addByPrefix("this", "bigdot", 0);
	leftDot.animation.play("this");
	leftDot.scale.set(mainNumsScale, mainNumsScale);
	leftDot.updateHitbox();
	leftDot.moves = false;

	rightDot = new FlxSprite();
	rightDot.frames = numsFrames;
	rightDot.animation.addByPrefix("this", "bigdot", 0);
	rightDot.animation.play("this");
	rightDot.scale.set(mainNumsScale, mainNumsScale);
	rightDot.updateHitbox();
	rightDot.moves = false;

	missesNumsGroup = new NumsGroup(0, healthBarBar.y + 40, {
		icon: "miss"
	});
	add(missesNumsGroup);

	scoreNumsGroup = new NumsGroup(0, healthBarBar.y + 40, {
		icon: "score"
	});
	add(scoreNumsGroup);

	ratingNumsGroup = new NumsGroup(0, healthBarBar.y + 40, {
		dotsTex: "dot",
		delayDots: 2,
		icon: "percent"
	});
	add(ratingNumsGroup);

	mainTimeNumsGroup = new NumsGroup(0, healthBarBar.y - 35, {
		dotsTex: "doubledot",
		delayDots: 2,
		minLength: 3,
		icon: "time"
	});
	add(mainTimeNumsGroup);

	songLengthNumsGroup = new NumsGroup(0, healthBarBar.y - 35, {
		dotsTex: "doubledot",
		delayDots: 2,
		minLength: 3
	});
	add(songLengthNumsGroup);

	var paddingDots = 7.5;
	ratingNumsGroup.onRecycleNums = scoreNumsGroup.onRecycleNums = missesNumsGroup.onRecycleNums = () ->
	{
		missesNumsGroup.group.x = (FlxG.width - missesNumsGroup.getWidth()) / 2;
		leftDot.setPosition(
			missesNumsGroup.group.x - paddingDots - leftDot.width,
			missesNumsGroup.group.y + 8
		);
		rightDot.setPosition(
			missesNumsGroup.group.x + missesNumsGroup.getWidth() + paddingDots,
			missesNumsGroup.group.y + 8
		);
		scoreNumsGroup.group.x = leftDot.x - paddingDots - scoreNumsGroup.getWidth();
		ratingNumsGroup.group.x = rightDot.x + rightDot.width + paddingDots;
	}
	missesNumsGroup.onRecycleNums();

	setVar('healthBar', healthBarBar);
	setVar('botplayTxt', botplayTxt);
	// setVar('scoreTxt', scoreTxt);
	setVar('timeText', timeText);
	setVar('songLengthNumsGroup', songLengthNumsGroup);
	setVar('mainTimeNumsGroup', mainTimeNumsGroup);
	setVar('scoreNumsGroup', scoreNumsGroup);
	setVar('ratingNumsGroup', ratingNumsGroup);
	setVar('missesNumsGroup', missesNumsGroup);
	numsGroups.push(mainTimeNumsGroup);
	numsGroups.push(songLengthNumsGroup);
	numsGroups.push(scoreNumsGroup);
	numsGroups.push(ratingNumsGroup);
	numsGroups.push(missesNumsGroup);

	// healthBarGroup.visible = false;
}

function onCreatePost()
{
	// Precache
	cachePopUpScore();
	cacheCountdown();
	cachePause();

	// // супер тупой фикс лага лол
	// var splash = grpNoteSplashes.members[0];
	// splash.setupNoteSplash(FlxG.width / 2.0, FlxG.height / 2.0, 0);
	// splash.alpha = 0.000001;

	// mainDefaultZoom = 0.5;
	switchHud("twist");
	songLengthNumsGroup.updateTextInner(true);

	graphicCache.cacheGraphic(numsFrames?.parent);
}

function onUpdateHud()
{
	if (healthbarStyle == "twist")
	{
		for (i in numsGroups)
			i.exists = true;
		healthBarBar.smoothFactor = 2.9;

		healthBarGroup.add(healthBarBar);
		healthBarGroup.add(timeText);
		// healthBarGroup.add(scoreTxt);
		healthBarGroup.add(iconsGroup);
		healthBarGroup.add(slash);
		healthBarGroup.add(leftDot);
		healthBarGroup.add(rightDot);
		healthBarGroup.add(missesNumsGroup.group);
		healthBarGroup.add(scoreNumsGroup.group);
		healthBarGroup.add(ratingNumsGroup.group);
		healthBarGroup.add(songLengthNumsGroup.group);
		// songLengthNumsGroup.minusMode = songLoops;
		healthBarGroup.add(mainTimeNumsGroup.group);
		healthBarGroup.add(botplayTxt);

		updateColorsInHealthBar = updateColorsInHealthBarTwist;
		flipHealthBar = flipHealthBarTwist;
		updateScore = updateScoreTwist;
		healthBarUpdate = healthBarUpdateTwist;

		updateTimeTextTwist();

		beatIcons = beatIconsTwist;
		for (icon in iconsGroup.members)
		{
			icon.y = healthBarBar.centerPoint.y - 75.0;
		}
		onUpdateHealthPost(health);
	}
	else
	{
		iconsGroup.sort(idSort);
		for (i in numsGroups)
			i.exists = false;
	}
}

public var scoreTxtTween:FlxTween;

public function updateScoreTwist(miss:Bool = false, ?start:Bool = false)
{
	// if (scoreTxt == null)
	// 	return;

	if (miss)
		scoreNumsGroup.updateTextFactor = 0.3;
	scoreNumsGroup.updateText(songScore, !(doScoreLerp || miss) || start);

	ratingNumsGroup.updateText(Math.ffloor(CoolUtil.quantize(ratingPercent * 100, 100) * 100), start);
	missesNumsGroup.updateText(songMisses);

	// var text:String = 'Score: ' + songScore + ' • ' + (instakillOnMiss ? '' : 'Misses: ' + songMisses + ' • ') + 'Rating: ' + ratingName;

	// scoreTxt._formatRanges[0].range.start = text.length - ratingName.length;
	// scoreTxt._formatRanges[0].range.end = text.length;
	// accFormat.borderColor = FlxColor.interpolate(FlxColor.RED, FlxColor.GREEN, // ratingPercent);
	// accFormat.format.color = FlxColor.getLightened(accFormat.borderColor, 0.5);

	// text = text + (ratingName == '?' ? '' : ' (' + CoolUtil.quantize(ratingPercent * 100, 100) + '%)') + '\n';
	// scoreTxt.text = text;

	/*
		if (ClientPrefs.scoreZoom && !(miss || start))
		{
			if (scoreTxt == null)
				return;

			// scoreTxt._formatRanges[0].range.start = text.length - ratingName.length;
			// scoreTxt._formatRanges[0].range.end = text.length;
			// accFormat.borderColor = FlxColor.interpolate(FlxColor.RED, FlxColor.GREEN, // ratingPercent);
			// accFormat.format.color = FlxColor.getLightened(accFormat.borderColor, 0.5);
			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
				scoreTxtTween.destroy();
			}

			scoreTxt.scale.set(0.955, 0.955);
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2);
		}
	 */
}

public function healthBarUpdateTwist(elapsed:Float)
{
	if (botplayTxt.visible)
	{
		botplaySine += elapsed;
		botplayTxt.colorTransform.alphaMultiplier = (1.0 - Math.sin(Math.PI * botplaySine)) / 2.0;
	}

	if (!startingSong && !paused)
	{
		final curTime:Float = Math.max(0.0, Conductor.songPosition - ClientPrefs.noteOffset);
		final prevTime = songPercent * songLength;
		songPercent = curTime / songLength;
		// Math.floor(curTime / 1000.0) > Math.floor(prevTime / 1000.0)
		if (prevTime % 1000.0 > curTime % 1000.0)
		{
			updateTimeTextTwist();
		}
	}

	// if (!startingSong && !paused && updateTime){
	// 	final curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.noteOffset);
	// 	songPercent = (curTime / songLength);
	//
	// 	timeTxt.text = FlxStringUtil.formatTime(Math.max(Math.floor((ClientPrefs.timeBarType == 'Time Elapsed' ? curTime : (songLength - curTime)) / 1000), 0), false);
	// }

	for (icon in iconsGroup.members)
	{
		icon.scale.y = icon.scale.x = CoolUtil.fpsLerp(icon.scale.x, icon.baseScale * icon.data.scale, FlxEase.sineOut(curDecBeat > 0.0 ? (curDecBeat % 1.0) : 1.0));
		// icon.scale.y = icon.scale.x = CoolUtil.fpsLerp(icon.scale.x, icon.baseScale * icon.data.scale, Conductor.crochet / 1500.0);
		icon.offset.x = icon.iconOffsets[0] - (icon.data.offsets[0] + icon.iconOffsetsAnim[0]);
		icon.offset.y = icon.iconOffsets[1] - (icon.data.offsets[1] + icon.iconOffsetsAnim[1]);
		icon.x = healthBarBar.centerPoint.x - 26.0; // bf
		icon.origin.x = icon.data.offsetsPointScale[0] * (icon.scale.x / icon.data.scale - 1.0);
		icon.origin.y = icon.data.offsetsPointScale[1] * (icon.scale.y / icon.data.scale - 1.0);
		if (icon.isPlayer == iconsGroup.flipX)
		{
			icon.origin.x = icon.frameWidth - icon.origin.x;
			icon.x -= 96.0;
		}
		// icon.y = healthBarBar.centerPoint.y - 75.0;
	}
}

var loopCount = -1;
function onSongGenerated()
{
	loopCount++;
	if (songLoops && loopCount > 0)
	{
		songPercent = (loopSongBounds == null) ? 0.0 : loopSongBounds.start / songLength;
		updateTimeTextTwist();
	}
}

function formatTimeToCursed(sec:Float):Float {
	return Math.ffloor(sec % 60.0 + Math.ffloor(sec / 60.0) * 100.0);
}

public function updateTimeTextTwist()
{
	var curTime = (songPercent * songLength);
	if (songLoops && loopCount > 0)
	{
		curTime += (loopCount * songLength);
		if (loopSongBounds != null)
			curTime -= (loopCount * (loopSongBounds.start + (songLength - loopSongBounds.end)));
	}
	/*
	timeText.text = game.SONG.display
		+ ": "
		+ FlxStringUtil.formatTime(curTime / 1000.0)
		+ " / "
		+ (songLoops ? "--:--" : FlxStringUtil.formatTime(songLength / 1000.0));
	final range = timeText._formatRanges[0].range;
	range.start = game.SONG.display.length + 2;
	range.end = timeText.text.length;
	timeText.setPosition(healthBarBar.x
		+ (healthBarBar.flipped ? 10 : healthBarBar.width - timeText.width - 5), healthBarBar.y
		- timeText.height
		- 5);
	*/

	mainTimeNumsGroup.updateText(formatTimeToCursed(curTime / 1000.0));
	songLengthNumsGroup.updateText(formatTimeToCursed(songLength / 1000.0 - offsetDisplaySongLength));

	if (healthBarBar.flipped)
	{
		mainTimeNumsGroup.group.x = healthBarBar.x + 4;
		slash.x = mainTimeNumsGroup.group.x + mainTimeNumsGroup.getWidth();
		mainTimeNumsGroup.centerSpr(slash).y += mainTimeNumsGroup.group.y;
		songLengthNumsGroup.group.x = slash.x + slash.width;
	}
	else
	{
		songLengthNumsGroup.group.x = healthBarBar.x + (healthBarBar.width - songLengthNumsGroup.getWidth()) - 4;
		slash.x = songLengthNumsGroup.group.x - slash.width - 2;
		songLengthNumsGroup.centerSpr(slash).y += songLengthNumsGroup.group.y;
		mainTimeNumsGroup.group.x = slash.x - mainTimeNumsGroup.getWidth() - 2;
	}
}

function onUpdateHealthPost(health:Float)
{
	if (healthbarStyle == "twist")
		iconsGroup.sort(iconSort, 1); // FlxSort.DESCENDING
}

function iconSort(order:Int, iconA:HealthIcon, iconB:HealthIcon)
{
	var animName = iconA.animation.curAnim?.name ?? "";
	var transAnim = StringTools.contains(animName, "->");
	return if (!transAnim && StringTools.startsWith(animName, "win"))
		order;
	else if (!transAnim && StringTools.startsWith(animName, "lose"))
		-order;
	else
		idSort(-order, iconA, iconB);
}

function idSort(order:Int, basicA:FlxBasic, basicB:FlxBasic)
{
	return FlxSort.byValues(order, basicA.ID, basicB.ID);
}

function beatIconsTwist()
{
	for (icon in iconsGroup.members)
	{
		icon.onBeatScale();
	}
}

function onBotplayChange(e)
{
	botplayTxt.visible = e;
}

public function updateColorsInHealthBarTwist(start:Bool)
{
	healthBarBar.setColors(dadColor, bfColor);
}

public function flipHealthBarTwist()
{
	iconsGroup.flipX = healthBarBar.flipped = !iconsGroup.flipX;
	updateTimeTextTwist();
}