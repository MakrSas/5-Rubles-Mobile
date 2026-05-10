package game.states;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.addons.display.FlxRuntimeShader;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.backend.data.jsons.WeekData;
import game.backend.utils.Highscore;
import game.objects.FlxStaticText;
import game.objects.ui.CustomList;
import game.states.FreeplayState.SongMeta;
import game.states.playstate.PlayState;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
#if TOUCH_CONTROLS
import game.mobile.utils.TouchUtil;
#end

class MobileFreeplayState extends MusicBeatState
{
	static var curSelected:Int = 0;
	static var curDifficultyIndex:Int = 0;

	public var songs:Array<SongMeta> = [];

	var bgSpr:FlxSprite;
	var camHUD:FlxCamera;
	var songList:CustomList;
	var listItems:Array<SongItemSprite> = [];

	var topBar:FlxSprite;
	var bottomBar:FlxSprite;
	var listBackdrop:FlxSprite;
	var infoBackdrop:FlxSprite;
	var infoAccent:FlxSprite;

	var sectionText:FlxStaticText;
	var titleText:FlxStaticText;
	var songCountText:FlxStaticText;
	var infoHeaderText:FlxStaticText;
	var infoText:FlxStaticText;
	var helpText:FlxStaticText;
	var emptyText:FlxStaticText;

	var enterButton:FlxSprite;
	var backButton:FlxSprite;
	var enterButtonBaseScale:Float = 1;
	var backButtonBaseScale:Float = 1;
	var enterButtonBaseAlpha:Float = 0.72;
	var backButtonBaseAlpha:Float = 0.72;

	var selectedSong:SongMeta;
	var goingToSong:Bool = false;
	var isClosing:Bool = false;
	var buttonsLeaving:Bool = false;

	#if TOUCH_CONTROLS
	var backButtonArmed:Bool = false;
	var enterButtonArmed:Bool = false;
	var touchStartX:Float = 0;
	var touchStartY:Float = 0;
	#end

	var curDifficulty(get, never):String;
	@:noCompletion function get_curDifficulty():String
	{
		var list = curDifficulties;
		if (list == null || list.length == 0) return null;
		return list[FlxMath.wrap(curDifficultyIndex, 0, list.length - 1)];
	}

	var curDifficulties(get, never):Array<String>;
	@:noCompletion function get_curDifficulties():Array<String>
		return selectedSong?.weekData?.data.difficulties;

	override function create()
	{
		Main.canClearMem = true;

		bgSpr = new FlxSprite(Paths.image('menuDesat'));
		bgSpr.screenCenter();
		bgSpr.color = 0xFF4A4A4A;
		bgSpr.active = false;
		bgSpr.scrollFactor.set();
		add(bgSpr);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		loadSongs();
		createChrome();
		createSongList();
		createMobileButtons();

		if (songs.length > 0)
			changeItem(0, true);
		else
			emptyText.visible = true;

		super.create();
		persistentUpdate = true;

		#if DISCORD_RPC
		DiscordClient.changePresence("In the Mobile Freeplay", null);
		#end
		if (FlxG.sound.music == null || !FlxG.sound.music.active)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}

	function createChrome()
	{
		topBar = new FlxSprite();
		topBar.makeGraphic(Std.int(FlxG.width * 1.5), 156, 0xFF000000);
		topBar.screenCenter(X);
		topBar.angle = -3;
		topBar.y = -topBar.height * 1.5;
		topBar.camera = camHUD;
		add(topBar);
		FlxTween.tween(topBar, {y: -topBar.height / 2}, 0.45, {ease: FlxEase.cubeOut});

		bottomBar = new FlxSprite();
		bottomBar.makeGraphic(Std.int(topBar.width), Std.int(topBar.height), 0xFF000000);
		bottomBar.screenCenter(X);
		bottomBar.angle = topBar.angle;
		bottomBar.y = FlxG.height + bottomBar.height;
		bottomBar.camera = camHUD;
		add(bottomBar);
		FlxTween.tween(bottomBar, {y: FlxG.height - bottomBar.height / 2}, 0.45, {ease: FlxEase.cubeOut});

		sectionText = new FlxStaticText(18, 18, 0, "GAME MENU");
		sectionText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 18, FlxColor.WHITE, FlxTextAlign.LEFT);
		sectionText.alpha = 0;
		sectionText.y -= 24;
		sectionText.camera = camHUD;
		add(sectionText);
		FlxTween.tween(sectionText, {y: 18, alpha: 1}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0.06});

		titleText = new FlxStaticText(18, 42, 0, "FREEPLAY");
		titleText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 42, FlxColor.WHITE, FlxTextAlign.LEFT);
		titleText.filters = [
			new GlowFilter(titleText.color.getLightened().to24Bit(), 0.5, 9, 9, 2, BitmapFilterQuality.HIGH, false, true)
		];
		titleText.alpha = 0;
		titleText.y -= 30;
		titleText.camera = camHUD;
		add(titleText);
		FlxTween.tween(titleText, {y: 42, alpha: 1}, 0.33, {ease: FlxEase.cubeOut, startDelay: 0.1});

		songCountText = new FlxStaticText(0, 34, 0, "TRACK 0 / 0");
		songCountText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 18, 0xFFD7D7D7, FlxTextAlign.RIGHT);
		songCountText.x = FlxG.width - songCountText.width - 22;
		songCountText.alpha = 0;
		songCountText.camera = camHUD;
		add(songCountText);
		FlxTween.tween(songCountText, {alpha: 1}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0.12});

		helpText = new FlxStaticText(0, 0, 0, "");
		helpText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 14, FlxColor.WHITE, FlxTextAlign.RIGHT);
		helpText.alpha = 0.75;
		helpText.camera = camHUD;
		add(helpText);
		updateHelpText();
	}

	function createSongList()
	{
		final listX:Int = 72;
		final listY:Int = 182;
		final listW:Int = Std.int(FlxG.width * 0.56);
		final listH:Int = Std.int(FlxG.height - 338);
		final infoX:Int = listX + listW + 36;
		final infoW:Int = FlxG.width - infoX - 72;

		listBackdrop = new FlxSprite(listX - 18, listY - 18);
		listBackdrop.makeGraphic(listW + 36, listH + 36, 0xD4000000);
		listBackdrop.alpha = 0;
		listBackdrop.x -= 42;
		listBackdrop.camera = camHUD;
		add(listBackdrop);
		FlxTween.tween(listBackdrop, {x: listX - 18, alpha: 1}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0.1});

		songList = new CustomList(listX, listY, listW, listH, null, true);
		songList.parentCamera = camHUD;
		songList.bgColor = FlxColor.TRANSPARENT;
		songList.filters = [
			new ShaderFilter(new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('engine/gradientOption'))))
		];
		songList.alpha = 0;
		songList.x -= 42;
		FlxTween.tween(songList, {x: listX, alpha: 1}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0.1});

		for (i in 0...songs.length)
		{
			var item = new SongItemSprite(songs[i], i, listW - 34);
			listItems.push(item);
			songList.add(item);
		}
		songList.updateHeightScroll();

		infoBackdrop = new FlxSprite(infoX, listY - 18);
		infoBackdrop.makeGraphic(infoW, listH + 36, 0xC6000000);
		infoBackdrop.alpha = 0;
		infoBackdrop.x += 42;
		infoBackdrop.camera = camHUD;
		add(infoBackdrop);
		FlxTween.tween(infoBackdrop, {x: infoX, alpha: 1}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0.14});

		infoAccent = new FlxSprite(infoX, listY - 18);
		infoAccent.makeGraphic(10, listH + 36, FlxColor.WHITE);
		infoAccent.alpha = 0.95;
		infoAccent.camera = camHUD;
		add(infoAccent);

		infoHeaderText = new FlxStaticText(infoX + 26, listY + 12, infoW - 52, "TRACK INFO");
		infoHeaderText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 18, 0xFFD7D7D7, FlxTextAlign.LEFT);
		infoHeaderText.alpha = 0;
		infoHeaderText.x += 24;
		infoHeaderText.camera = camHUD;
		add(infoHeaderText);
		FlxTween.tween(infoHeaderText, {x: infoX + 26, alpha: 1}, 0.28, {ease: FlxEase.cubeOut, startDelay: 0.16});

		infoText = new FlxStaticText(infoX + 26, listY + 58, infoW - 52, "");
		infoText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 22, FlxColor.WHITE, FlxTextAlign.LEFT);
		infoText.borderStyle = FlxTextBorderStyle.OUTLINE;
		infoText.borderColor = FlxColor.BLACK;
		infoText.borderSize = 1;
		infoText.fieldHeight = listH - 120;
		infoText.alpha = 0;
		infoText.x += 24;
		infoText.camera = camHUD;
		add(infoText);
		FlxTween.tween(infoText, {x: infoX + 26, alpha: 1}, 0.28, {ease: FlxEase.cubeOut, startDelay: 0.2});

		emptyText = new FlxStaticText(listX + 30, listY + listH / 2 - 18, listW - 60, "NO SONGS AVAILABLE");
		emptyText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 26, FlxColor.WHITE, FlxTextAlign.CENTER);
		emptyText.borderStyle = FlxTextBorderStyle.OUTLINE;
		emptyText.borderColor = FlxColor.BLACK;
		emptyText.borderSize = 1;
		emptyText.visible = false;
		emptyText.camera = camHUD;
		add(emptyText);
	}

	function createMobileButtons()
	{
		if (!FlxG.onMobile)
			return;

		final targetSize:Int = Std.int(Math.min(FlxG.width, FlxG.height) * 0.14);
		final margin:Float = Math.max(12, targetSize * 0.2);

		final backAtlas = Paths.getSparrowAtlas("mobileUI/back");
		if (backAtlas != null)
		{
			backButton = new FlxSprite();
			backButton.frames = backAtlas;
			backButton.animation.addByPrefix("idle", "BACK", 24, false);
			backButton.animation.play("idle");
			backButton.animation.pause();
		}
		else
		{
			backButton = new FlxSprite().makeGraphic(targetSize, targetSize, 0xFFAA0000);
		}
		backButton.antialiasing = ClientPrefs.globalAntialiasing;
		backButton.alpha = backButtonBaseAlpha;
		backButton.scrollFactor.set();
		backButton.camera = camHUD;
		backButton.setGraphicSize(0, targetSize);
		backButton.updateHitbox();
		backButton.setPosition(margin, FlxG.height - backButton.height - margin);
		backButtonBaseScale = backButton.scale.x;
		add(backButton);

		enterButton = new FlxSprite();
		if (Paths.image('mobileUI/enter') != null)
			enterButton.loadGraphic(Paths.image('mobileUI/enter'));
		else
			enterButton.makeGraphic(targetSize, targetSize, 0xFF00AA00);
		enterButton.antialiasing = ClientPrefs.globalAntialiasing;
		enterButton.alpha = enterButtonBaseAlpha;
		enterButton.scrollFactor.set();
		enterButton.camera = camHUD;
		enterButton.setGraphicSize(0, Std.int(targetSize * 0.9));
		enterButton.updateHitbox();
		enterButton.setPosition(FlxG.width - enterButton.width - margin - targetSize * 0.55, FlxG.height - enterButton.height - margin * 1.05);
		enterButtonBaseScale = enterButton.scale.x;
		add(enterButton);
	}

	function updateHelpText()
	{
		helpText.text = FlxG.onMobile
			? "SWIPE - SCROLL\nTAP ENTER - PLAY\nTAP BACK - RETURN"
			: "UP / DOWN - SELECT\nLEFT / RIGHT - DIFFICULTY\nENTER - PLAY   ESC - BACK";
		helpText.x = FlxG.width - helpText.width - 16;
		helpText.y = FlxG.height - helpText.height - 14;
	}

	override function update(elapsed:Float)
	{
		if (isClosing)
		{
			super.update(elapsed);
			return;
		}

		if (controls.BACK)
		{
			goBack();
			return;
		}

		if (songs.length > 0 && !goingToSong)
		{
			if (FlxG.mouse.wheel != 0)
				changeItem(FlxG.mouse.wheel > 0 ? -1 : 1);
			else
			{
				if (controls.UI_UP_P) changeItem(-1);
				if (controls.UI_DOWN_P) changeItem(1);
			}

			if (controls.UI_LEFT_P) changeDifficulty(-1);
			if (controls.UI_RIGHT_P) changeDifficulty(1);

			if (controls.ACCEPT)
				goToPlayState();

			#if TOUCH_CONTROLS
			handleTouchInput();
			#end
		}

		super.update(elapsed);
	}

	function goBack()
	{
		if (isClosing) return;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		beginExit(() -> MusicBeatState.switchState(new MainMenuState()));
	}

	function beginExit(action:Void->Void)
	{
		if (isClosing) return;
		isClosing = true;

		songList.canDrag = false;
		tweenOutMobileButtons();

		FlxTween.tween(topBar, {y: topBar.y - topBar.height}, 0.22, {ease: FlxEase.cubeIn});
		FlxTween.tween(bottomBar, {y: bottomBar.y + bottomBar.height}, 0.22, {ease: FlxEase.cubeIn});
		FlxTween.tween(sectionText, {y: sectionText.y - 20, alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(titleText, {y: titleText.y - 24, alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(songCountText, {alpha: 0}, 0.16, {ease: FlxEase.cubeIn});
		FlxTween.tween(listBackdrop, {x: listBackdrop.x - 36, alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(songList, {x: songList.x - 36, alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoBackdrop, {x: infoBackdrop.x + 36, alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoAccent, {alpha: 0}, 0.16, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoHeaderText, {x: infoHeaderText.x + 24, alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoText, {x: infoText.x + 24, alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(helpText, {alpha: 0}, 0.14, {ease: FlxEase.cubeIn});
		FlxTween.tween(emptyText, {alpha: 0}, 0.14, {ease: FlxEase.cubeIn});

		new FlxTimer().start(0.3, _ -> action());
	}

	function tweenOutMobileButtons(?onComplete:Void->Void)
	{
		if (!FlxG.onMobile || buttonsLeaving)
		{
			if (onComplete != null)
				onComplete();
			return;
		}

		buttonsLeaving = true;
		var pending:Int = 0;
		inline function done()
		{
			pending--;
			if (pending <= 0 && onComplete != null)
			{
				var cb = onComplete;
				onComplete = null;
				cb();
			}
		}
		function tweenButton(button:FlxSprite, targetX:Float)
		{
			if (button == null || !button.visible)
				return;
			pending++;
			FlxTween.tween(button, {x: targetX, alpha: 0}, 0.24, {ease: FlxEase.cubeInOut, onComplete: _ -> done()});
		}

		if (backButton != null)
			tweenButton(backButton, -backButton.width - 24);
		if (enterButton != null)
			tweenButton(enterButton, FlxG.width + enterButton.width + 24);

		if (pending <= 0 && onComplete != null)
			onComplete();
	}

	function changeItem(huh:Int = 0, snap:Bool = false)
	{
		if (listItems.length == 0)
			return;

		if (listItems[curSelected] != null)
			listItems[curSelected].setSelected(false);

		curSelected = FlxMath.wrap(curSelected + huh, 0, listItems.length - 1);

		if (listItems[curSelected] != null)
		{
			selectedSong = songs[curSelected];
			ModsFolder.switchMod(selectedSong.modPack);

			final newColor:Int = selectedSong.data.freeplayColor.getColorFromDynamic() ?? 0xFFABCACA;
			listItems[curSelected].setSelected(true, newColor);
			infoAccent.color = newColor;

			if (snap)
				bgSpr.color = newColor;
			else
				FlxTween.color(bgSpr, 0.5, bgSpr.color, newColor, {ease: FlxEase.cubeOut});

			scrollToItem(curSelected);
			updateInfoText();
			if (huh != 0)
				FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}

	function changeDifficulty(change:Int)
	{
		var list = curDifficulties;
		if (list == null || list.length <= 1)
			return;

		curDifficultyIndex = FlxMath.wrap(curDifficultyIndex + change, 0, list.length - 1);
		updateInfoText();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function scrollToItem(idx:Int)
	{
		if (listItems[idx] == null || songList == null) return;

		var item = listItems[idx];
		var targetY = item.y - songList.height / 2 + item.itemHeight / 2;
		songList.scrollFloat = FlxMath.bound(targetY, songList.minScrollY, songList.maxScrollY - songList.height);
	}

	function updateInfoText()
	{
		if (selectedSong == null) return;

		var name = selectedSong.data.displaySongName ?? selectedSong.data.songName;
		var category = selectedSong.modPack ?? 'Unknown';
		var diff = curDifficulty ?? '?';
		var difficulties = curDifficulties;
		var diffSuffix = difficulties != null && difficulties.length > 1 ? '  (${curDifficultyIndex + 1}/${difficulties.length})' : "";
		var hs = Highscore.getSongData(selectedSong.data.songName, diff);
		var score = hs == null ? 0 : hs.score;

		songCountText.text = 'TRACK ${curSelected + 1} / ${songs.length}';
		songCountText.x = FlxG.width - songCountText.width - 22;

		infoText.text = '$name\n\nPACK\n$category\n\nDIFFICULTY\n$diff$diffSuffix\n\nHIGHSCORE\n$score';
	}

	function goToPlayState()
	{
		if (selectedSong == null || goingToSong || isClosing) return;

		try
		{
			var song = PlayState.loadSong(selectedSong.data.songName, curDifficulty, curDifficulties, false);
			if (song != null)
			{
				goingToSong = true;
				beginExit(() -> {
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music?.stop();
				});
			}
			else
			{
				Log('Song "${selectedSong.data.songName}" failed to load', RED);
			}
		}
		catch (e)
		{
			Log(e, RED);
		}
	}

	function pulseButton(button:FlxSprite, baseScale:Float, baseAlpha:Float, restartAnimation:Bool = false)
	{
		if (button == null)
			return;

		if (restartAnimation && button.animation != null)
			button.animation.play("idle", true);

		button.alpha = 1;
		FlxTween.cancelTweensOf(button);
		FlxTween.cancelTweensOf(button.scale);
		FlxTween.tween(button.scale, {x: baseScale * 0.9, y: baseScale * 0.9}, 0.05, {
			ease: FlxEase.quadOut,
			onComplete: _ -> FlxTween.tween(button.scale, {x: baseScale, y: baseScale}, 0.1, {ease: FlxEase.quadOut})
		});
		FlxTween.tween(button, {alpha: baseAlpha}, 0.18, {ease: FlxEase.quadOut, startDelay: 0.02});
	}

	#if TOUCH_CONTROLS
	function handleTouchInput()
	{
		if (TouchUtil.justPressed)
		{
			touchStartX = TouchUtil.touch.screenX;
			touchStartY = TouchUtil.touch.screenY;

			if (TouchUtil.overlaps(backButton, camHUD))
			{
				backButtonArmed = true;
				pulseButton(backButton, backButtonBaseScale, backButtonBaseAlpha, true);
			}
			else if (TouchUtil.overlaps(enterButton, camHUD))
			{
				enterButtonArmed = true;
				pulseButton(enterButton, enterButtonBaseScale, enterButtonBaseAlpha);
			}
		}

		if (TouchUtil.justReleased)
		{
			final wasTap = Math.abs(TouchUtil.touch.screenX - touchStartX) <= 18 && Math.abs(TouchUtil.touch.screenY - touchStartY) <= 18;

			if (backButtonArmed)
			{
				backButtonArmed = false;
				if (wasTap && TouchUtil.overlaps(backButton, camHUD))
					goBack();
				return;
			}

			if (enterButtonArmed)
			{
				enterButtonArmed = false;
				if (wasTap && TouchUtil.overlaps(enterButton, camHUD))
					goToPlayState();
				return;
			}

			if (!wasTap)
				return;

			for (i => item in listItems)
			{
				if (item != null && TouchUtil.overlaps(item, songList))
				{
					if (i == curSelected)
						goToPlayState();
					else
						changeItem(i - curSelected);
					break;
				}
			}
		}
	}
	#end

	function loadSongs()
	{
		final lastMod = ModsFolder.currentModFolderPath;
		WeekData.reloadWeeksFiles(true);

		for (key in WeekData.weeksListOrder)
		{
			if (key == null) continue;
			var weekData = WeekData.weeksDatas.get(key.file);
			if (weekData == null || weekData.data.hideInFreeplay) continue;

			ModsFolder.switchMod(key.modPack, false);
			for (data in weekData.data.songs)
			{
				if (data == null || data.invisibleInFreeplay) continue;
				songs.push(new SongMeta(data, key.modPack, weekData));
			}
		}

		ModsFolder.switchMod(lastMod, false);

		songs.sort(function(a, b) {
			var nameA = (a.data.displaySongName ?? a.data.songName).toLowerCase();
			var nameB = (b.data.displaySongName ?? b.data.songName).toLowerCase();
			if (nameA < nameB) return -1;
			if (nameA > nameB) return 1;
			return 0;
		});
	}

}

class SongItemSprite extends FlxSpriteGroup
{
	public static inline var ITEM_HEIGHT:Float = 82;
	public static inline var ITEM_PADDING:Float = 12;

	public var bg:FlxSprite;
	public var accent:FlxSprite;
	public var titleText:FlxStaticText;
	public var categoryText:FlxStaticText;
	public var songMeta:SongMeta;
	public var itemHeight:Float = ITEM_HEIGHT;

	public function new(song:SongMeta, index:Int, width:Float)
	{
		super(12, ITEM_PADDING + index * (ITEM_HEIGHT + 10));
		songMeta = song;

		bg = new FlxSprite();
		bg.makeGraphic(Math.floor(width), Math.floor(ITEM_HEIGHT), 0xFF111111);
		bg.alpha = 0.78;
		add(bg);

		accent = new FlxSprite();
		accent.makeGraphic(8, Math.floor(ITEM_HEIGHT), 0xFFFFFFFF);
		accent.alpha = 0.16;
		add(accent);

		var name = song.data.displaySongName ?? song.data.songName;
		titleText = new FlxStaticText(24, 12, width - 48, name);
		titleText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 24, FlxColor.WHITE, FlxTextAlign.LEFT);
		titleText.borderStyle = FlxTextBorderStyle.OUTLINE;
		titleText.borderColor = FlxColor.BLACK;
		titleText.borderSize = 1;
		add(titleText);

		var categoryName = song.modPack;
		if (categoryName == null || categoryName.length == 0)
			categoryName = 'Freeplay';
		categoryText = new FlxStaticText(24, 46, width - 48, 'PACK: $categoryName');
		categoryText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 14, 0xFFD6D6D6, FlxTextAlign.LEFT);
		categoryText.borderStyle = FlxTextBorderStyle.OUTLINE;
		categoryText.borderColor = FlxColor.BLACK;
		categoryText.borderSize = 1;
		add(categoryText);
	}

	public function setSelected(selected:Bool, ?accentColor:Int = 0xFFFFFFFF):Void
	{
		bg.alpha = selected ? 0.96 : 0.78;
		bg.color = selected ? 0xFF262626 : 0xFF111111;
		accent.alpha = selected ? 1 : 0.16;
		accent.color = accentColor;
		titleText.scale.set(selected ? 1.03 : 1.0, selected ? 1.03 : 1.0);
		titleText.color = selected ? FlxColor.WHITE : 0xFFE7E7E7;
		categoryText.alpha = selected ? 1 : 0.82;
	}
}
