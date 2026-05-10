package game.states.substates;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import game.backend.data.jsons.WeekData;
import game.backend.system.song.Song;
import game.backend.system.states.MusicBeatSubstate;
import game.backend.utils.Constants;
import game.backend.utils.Difficulty;
import game.backend.utils.Highscore;
import game.objects.FlxStaticText;
import game.objects.game.Character;
import game.objects.ui.CustomList;
import game.states.LoadingState;
import game.states.playstate.PlayState;
import haxe.DynamicAccess;
import haxe.Json;
import haxe.io.Path;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import openfl.utils.Assets;
#if TOUCH_CONTROLS
import game.mobile.utils.TouchUtil;
#end

class MenuFreeplaySubstate extends MusicBeatSubstate
{
	static var curSelected:Int = 0;

	public var songs:Array<MenuFreeplayEntry> = [];

	var camFreeplay:FlxCamera;
	var bgOverlay:FlxSprite;
	var topBar:FlxSprite;
	var bottomBar:FlxSprite;
	var listBackdrop:FlxSprite;
	var infoBackdrop:FlxSprite;
	var infoAccent:FlxSprite;
	var songList:CustomList;
	var listItems:Array<MenuFreeplaySongItem> = [];

	var sectionText:FlxStaticText;
	var titleText:FlxStaticText;
	var songCountText:FlxStaticText;
	var infoHeaderText:FlxStaticText;
	var infoText:FlxStaticText;
	var helpText:FlxStaticText;
	var emptyText:FlxStaticText;

	var backButton:FlxSprite;
	var enterButton:FlxSprite;
	var backButtonBaseScaleX:Float = 1;
	var backButtonBaseScaleY:Float = 1;
	var enterButtonBaseScaleX:Float = 1;
	var enterButtonBaseScaleY:Float = 1;
	var backButtonBaseAlpha:Float = 0.82;
	var enterButtonBaseAlpha:Float = 0.78;

	var infoPanelX:Float = 0;
	var infoPanelY:Float = 0;
	var infoPanelWidth:Float = 0;

	var selectedSong:MenuFreeplayEntry;
	var initialModFolder:String;
	var lastMouseVisible:Bool;
	var isClosing:Bool = false;
	var goingToSong:Bool = false;
	var buttonsLeaving:Bool = false;
	var pendingCloseAction:Void -> Void;

	#if TOUCH_CONTROLS
	var backButtonArmed:Bool = false;
	var enterButtonArmed:Bool = false;
	var touchStartX:Float = 0;
	var touchStartY:Float = 0;
	#end

	public function new(?onOpen:Void -> Void, ?onClose:Void -> Void)
	{
		lastMouseVisible = FlxG.mouse.visible;
		super();

		openCallback = () -> {
			FlxG.mouse.visible = true;
			if (onOpen != null)
				onOpen();
		}

		closeCallback = () -> {
			FlxG.mouse.visible = lastMouseVisible;
			if (onClose != null)
				onClose();
			if (!_parentState.destroySubStates)
				destroy();
			if (pendingCloseAction != null)
			{
				var action = pendingCloseAction;
				pendingCloseAction = null;
				action();
			}
		}
	}

	override function create()
	{
		initialModFolder = ModsFolder.currentModFolderPath;

		camFreeplay = new FlxCamera();
		bgColor = camFreeplay.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camFreeplay, false);
		cameras = [camFreeplay];

		super.create();

		loadSongs();
		createChrome();
		createSongList();
		createMobileButtons();

		if (songs.length > 0)
			changeItem(0, true);
		else
			emptyText.visible = true;
	}

	function createChrome():Void
	{
		bgOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bgOverlay.scrollFactor.set();
		bgOverlay.cameras = cameras;
		bgOverlay.alpha = 0;
		add(bgOverlay);
		FlxTween.tween(bgOverlay, {alpha: 0.5}, 0.28, {ease: FlxEase.cubeOut});

		topBar = new FlxSprite().makeSolid(FlxG.width * 1.5, 156, 0xFF000000);
		topBar.screenCenter(X);
		topBar.y = -topBar.height * 1.5;
		topBar.angle = -3;
		topBar.cameras = cameras;
		add(topBar);
		FlxTween.tween(topBar, {y: -topBar.height / 2}, 0.46, {ease: FlxEase.cubeOut});

		bottomBar = new FlxSprite().makeSolid(topBar.width, topBar.height, 0xFF000000);
		bottomBar.screenCenter(X);
		bottomBar.y = FlxG.height + bottomBar.height;
		bottomBar.angle = topBar.angle;
		bottomBar.cameras = cameras;
		add(bottomBar);
		FlxTween.tween(bottomBar, {y: FlxG.height - bottomBar.height / 2}, 0.46, {ease: FlxEase.cubeOut});

		sectionText = new FlxStaticText(12, 12, 0, "GAME MENU");
		sectionText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 18, FlxColor.WHITE, FlxTextAlign.LEFT);
		sectionText.alpha = 0;
		sectionText.offset.y = -20;
		sectionText.cameras = cameras;
		add(sectionText);
		FlxTween.tween(sectionText, {alpha: 1, "offset.y": 0}, 0.26, {ease: FlxEase.cubeOut, startDelay: 0.05});

		titleText = new FlxStaticText(12, 36, 0, "FREEPLAY");
		titleText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 48, FlxColor.WHITE, FlxTextAlign.LEFT);
		titleText.filters = [
			new GlowFilter(titleText.color.getLightened().to24Bit(), 0.5, 9, 9, 2, BitmapFilterQuality.HIGH, false, true)
		];
		titleText.alpha = 0;
		titleText.offset.y = -28;
		titleText.cameras = cameras;
		add(titleText);
		FlxTween.tween(titleText, {alpha: 1, "offset.y": 0}, 0.3, {ease: FlxEase.cubeOut, startDelay: 0.08});

		songCountText = new FlxStaticText(0, 34, 0, "TRACK 0 / 0");
		songCountText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 18, 0xFFD7D7D7, FlxTextAlign.RIGHT);
		songCountText.alpha = 0;
		songCountText.cameras = cameras;
		add(songCountText);
		FlxTween.tween(songCountText, {alpha: 1}, 0.28, {ease: FlxEase.cubeOut, startDelay: 0.12});

		helpText = new FlxStaticText(0, 0, 0, "");
		helpText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 14, FlxColor.WHITE, FlxTextAlign.RIGHT);
		helpText.alpha = 0.74;
		helpText.cameras = cameras;
		add(helpText);
		updateHelpText();
	}

	function createSongList():Void
	{
		final listX:Int = 72;
		final listY:Int = 174;
		final listW:Int = 660;
		final listH:Int = 410;
		final infoX:Int = listX + listW + 24;
		final infoW:Int = FlxG.width - infoX - 72;

		infoPanelX = infoX;
		infoPanelY = listY - 10;
		infoPanelWidth = infoW;

		listBackdrop = new FlxSprite(listX - 8, listY - 10);
		listBackdrop.makeGraphic(listW + 16, listH + 20, 0xBF000000);
		listBackdrop.alpha = 0;
		listBackdrop.x -= 32;
		listBackdrop.cameras = cameras;
		add(listBackdrop);
		FlxTween.tween(listBackdrop, {x: listX - 8, alpha: 0.9}, 0.28, {ease: FlxEase.cubeOut, startDelay: 0.1});

		songList = new CustomList(listX, listY, listW, listH, null, true);
		songList.parentCamera = camFreeplay;
		songList.bgColor = FlxColor.TRANSPARENT;
		songList.alpha = 0;
		songList.x -= 32;
		FlxTween.tween(songList, {x: listX, alpha: 1}, 0.28, {ease: FlxEase.cubeOut, startDelay: 0.1});

		for (i in 0...songs.length)
		{
			var item = new MenuFreeplaySongItem(songs[i], i, listW - 34);
			listItems.push(item);
			songList.add(item);
		}
		songList.updateHeightScroll();

		infoBackdrop = new FlxSprite(infoX, listY - 10);
		infoBackdrop.makeGraphic(infoW, listH + 20, 0xB6000000);
		infoBackdrop.alpha = 0;
		infoBackdrop.x += 32;
		infoBackdrop.cameras = cameras;
		add(infoBackdrop);
		FlxTween.tween(infoBackdrop, {x: infoX, alpha: 0.92}, 0.28, {ease: FlxEase.cubeOut, startDelay: 0.12});

		infoAccent = new FlxSprite(infoX, listY - 10);
		infoAccent.makeGraphic(10, listH + 20, 0xFFFFFFFF);
		infoAccent.alpha = 0.92;
		infoAccent.cameras = cameras;
		add(infoAccent);

		infoHeaderText = new FlxStaticText(infoX + 24, listY + 12, infoW - 48, "TRACK INFO");
		infoHeaderText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 18, 0xFFD7D7D7, FlxTextAlign.LEFT);
		infoHeaderText.alpha = 0;
		infoHeaderText.x += 24;
		infoHeaderText.cameras = cameras;
		add(infoHeaderText);
		FlxTween.tween(infoHeaderText, {x: infoX + 24, alpha: 1}, 0.26, {ease: FlxEase.cubeOut, startDelay: 0.16});

		infoText = new FlxStaticText(infoX + 24, listY + 112, infoW - 48, "");
		infoText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 22, FlxColor.WHITE, FlxTextAlign.LEFT);
		infoText.borderStyle = FlxTextBorderStyle.OUTLINE;
		infoText.borderColor = FlxColor.BLACK;
		infoText.borderSize = 1;
		infoText.fieldHeight = listH - 150;
		infoText.alpha = 0;
		infoText.x += 24;
		infoText.cameras = cameras;
		add(infoText);
		FlxTween.tween(infoText, {x: infoX + 24, alpha: 1}, 0.26, {ease: FlxEase.cubeOut, startDelay: 0.2});

		emptyText = new FlxStaticText(listX + 30, listY + listH / 2 - 18, listW - 60, "NO SONGS AVAILABLE");
		emptyText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 26, FlxColor.WHITE, FlxTextAlign.CENTER);
		emptyText.borderStyle = FlxTextBorderStyle.OUTLINE;
		emptyText.borderColor = FlxColor.BLACK;
		emptyText.borderSize = 1;
		emptyText.visible = false;
		emptyText.cameras = cameras;
		add(emptyText);
	}

	function createMobileButtons():Void
	{
		if (!FlxG.onMobile)
			return;

		final targetHeight:Int = Std.int(Math.min(FlxG.width, FlxG.height) * 0.14);
		final margin:Float = Math.max(12, targetHeight * 0.18);
		final gap:Float = Math.max(12, targetHeight * 0.14);

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
			backButton = new FlxSprite().makeGraphic(targetHeight, targetHeight, 0xFFAA0000);
		}
		backButton.antialiasing = ClientPrefs.globalAntialiasing;
		backButton.scrollFactor.set();
		backButton.cameras = cameras;
		backButton.alpha = backButtonBaseAlpha;
		backButton.setGraphicSize(0, targetHeight);
		backButton.scale.x *= 1.08;
		backButton.updateHitbox();
		backButtonBaseScaleX = backButton.scale.x;
		backButtonBaseScaleY = backButton.scale.y;
		add(backButton);

		enterButton = new FlxSprite();
		if (Paths.image('mobileUI/enter') != null)
			enterButton.loadGraphic(Paths.image('mobileUI/enter'));
		else
			enterButton.makeGraphic(targetHeight, targetHeight, 0xFF00AA00);
		enterButton.antialiasing = ClientPrefs.globalAntialiasing;
		enterButton.scrollFactor.set();
		enterButton.cameras = cameras;
		enterButton.alpha = enterButtonBaseAlpha;

		final enterTargetHeight:Float = targetHeight * 1.04;
		final enterScale:Float = enterButton.frameHeight > 0 ? enterTargetHeight / enterButton.frameHeight : 1;
		enterButton.scale.set(enterScale, enterScale);
		enterButton.updateHitbox();
		enterButtonBaseScaleX = enterButton.scale.x;
		enterButtonBaseScaleY = enterButton.scale.y;
		add(enterButton);

		backButton.setPosition(FlxG.width - backButton.width - margin, FlxG.height - backButton.height - margin);
		enterButton.setPosition(backButton.x - enterButton.width - gap, backButton.y + (backButton.height - enterButton.height) / 2);
	}

	function updateHelpText():Void
	{
		helpText.text = FlxG.onMobile
			? "DRAG - SCROLL\nTAP ENTER - PLAY\nTAP BACK - RETURN"
			: "UP / DOWN - SELECT\nENTER - PLAY   ESC - BACK";
		helpText.x = FlxG.width - helpText.width - 16;
		helpText.y = FlxG.height - helpText.height - 14;
		songCountText.x = FlxG.width - songCountText.width - 22;
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

			if (controls.ACCEPT)
				goToPlayState();

			#if TOUCH_CONTROLS
			handleTouchInput();
			#end
		}

		super.update(elapsed);
	}

	function goBack():Void
	{
		if (isClosing)
			return;

		FlxG.sound.play(Paths.sound('cancelMenu'));
		beginExit(() -> close());
	}

	function beginExit(action:Void -> Void):Void
	{
		if (isClosing)
			return;

		isClosing = true;
		if (songList != null)
			songList.canDrag = false;

		tweenOutMobileButtons();

		FlxTween.tween(bgOverlay, {alpha: 0}, 0.3, {ease: FlxEase.cubeIn});
		FlxTween.tween(topBar, {y: topBar.y - topBar.height}, 0.34, {ease: FlxEase.cubeIn});
		FlxTween.tween(bottomBar, {y: bottomBar.y + bottomBar.height}, 0.34, {ease: FlxEase.cubeIn});
		FlxTween.tween(sectionText, {alpha: 0, "offset.y": -18}, 0.22, {ease: FlxEase.cubeIn});
		FlxTween.tween(titleText, {alpha: 0, "offset.y": -22}, 0.24, {ease: FlxEase.cubeIn});
		FlxTween.tween(songCountText, {alpha: 0}, 0.2, {ease: FlxEase.cubeIn});
		FlxTween.tween(listBackdrop, {x: listBackdrop.x - 28, alpha: 0}, 0.24, {ease: FlxEase.cubeIn});
		FlxTween.tween(songList, {x: songList.x - 28, alpha: 0}, 0.24, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoBackdrop, {x: infoBackdrop.x + 28, alpha: 0}, 0.24, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoAccent, {alpha: 0}, 0.2, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoHeaderText, {x: infoHeaderText.x + 20, alpha: 0}, 0.22, {ease: FlxEase.cubeIn});
		FlxTween.tween(infoText, {x: infoText.x + 20, alpha: 0}, 0.22, {ease: FlxEase.cubeIn});
		FlxTween.tween(helpText, {alpha: 0}, 0.18, {ease: FlxEase.cubeIn});
		FlxTween.tween(emptyText, {alpha: 0}, 0.18, {ease: FlxEase.cubeIn});

		new FlxTimer().start(0.38, _ -> action());
	}

	function tweenOutMobileButtons(?onComplete:Void -> Void):Void
	{
		if (!FlxG.onMobile || buttonsLeaving)
		{
			if (onComplete != null)
				onComplete();
			return;
		}

		buttonsLeaving = true;
		var pending:Int = 0;

		inline function done():Void
		{
			pending--;
			if (pending <= 0 && onComplete != null)
			{
				var cb = onComplete;
				onComplete = null;
				cb();
			}
		}

		function tweenButton(button:FlxSprite):Void
		{
			if (button == null || !button.visible)
				return;

			pending++;
			FlxTween.tween(button, {alpha: 0}, 0.26, {ease: FlxEase.quadOut, onComplete: _ -> done()});
		}

		tweenButton(backButton);
		tweenButton(enterButton);

		if (pending <= 0 && onComplete != null)
			onComplete();
	}

	function changeItem(change:Int = 0, snap:Bool = false):Void
	{
		if (listItems.length == 0)
			return;

		if (curSelected < 0 || curSelected >= listItems.length)
			curSelected = 0;

		if (listItems[curSelected] != null)
			listItems[curSelected].setSelected(false);

		curSelected = FlxMath.wrap(curSelected + change, 0, listItems.length - 1);
		selectedSong = songs[curSelected];
		if (selectedSong == null)
			return;

		ModsFolder.switchMod(selectedSong.modPack, false);
		listItems[curSelected].setSelected(true, selectedSong.freeplayColor);
		infoAccent.color = selectedSong.freeplayColor;
		scrollToItem(curSelected);
		updateInfoText();

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function scrollToItem(index:Int):Void
	{
		if (songList == null || listItems[index] == null)
			return;

		var item = listItems[index];
		var targetY = item.y - songList.height / 2 + item.itemHeight / 2;
		songList.scrollFloat = FlxMath.bound(targetY, songList.minScrollY, songList.maxScrollY - songList.height);
	}

	function updateInfoText():Void
	{
		if (selectedSong == null)
			return;

		var scoreData = Highscore.getSongData(selectedSong.songName, selectedSong.difficulty);
		var score = scoreData == null ? 0 : scoreData.score;
		songCountText.text = 'TRACK ${curSelected + 1} / ${songs.length}';
		songCountText.x = FlxG.width - songCountText.width - 22;

		infoText.text = '${selectedSong.displayName}\n\nBPM\n${formatBpm(selectedSong.bpm)}\n\nLENGTH\n${getSongLengthText(selectedSong)}\n\nHIGHSCORE\n$score';
	}

	function goToPlayState():Void
	{
		if (selectedSong == null || goingToSong || isClosing)
			return;

		try
		{
			ModsFolder.switchMod(selectedSong.modPack, false);
			var song = Song.loadFromJson(selectedSong.chartName, selectedSong.folderName);
			if (song == null)
			{
				Log('Chart "${selectedSong.folderName}/${selectedSong.chartName}.json" failed to load', RED);
				return;
			}

			song.difficulty = selectedSong.difficulty;
			Difficulty.list = [selectedSong.difficulty];
			PlayState.setSong(song);
			PlayState.isStoryMode = false;
			goingToSong = true;

			beginExit(() -> {
				pendingCloseAction = () -> {
					FlxG.sound.music?.stop();
					LoadingState.loadAndSwitchState(new PlayState());
				};
				close();
			});
		}
		catch (e)
		{
			Log(e, RED);
		}
	}

	function formatBpm(bpm:Float):String
	{
		if (Math.isNaN(bpm) || bpm <= 0)
			return "--";
		return bpm % 1 == 0 ? Std.string(Std.int(bpm)) : Std.string(FlxMath.roundDecimal(bpm, 2));
	}

	function getSongLengthText(song:MenuFreeplayEntry):String
	{
		if (song.lengthMs < 0)
		{
			var inst = Paths.inst(song.songName, song.postfix);
			song.lengthMs = inst != null ? inst.length : 0;
		}

		if (song.lengthMs <= 0)
			return "--:--";

		var totalSeconds = Std.int(Math.round(song.lengthMs / 1000));
		var minutes = Std.int(totalSeconds / 60);
		var seconds = totalSeconds % 60;
		return '$minutes:${seconds < 10 ? "0" : ""}$seconds';
	}

	function pulseButton(button:FlxSprite, baseScaleX:Float, baseScaleY:Float, baseAlpha:Float, restartAnimation:Bool = false):Void
	{
		if (button == null)
			return;

		if (restartAnimation && button.animation != null)
			button.animation.play("idle", true);

		button.alpha = 1;
		FlxTween.cancelTweensOf(button);
		FlxTween.cancelTweensOf(button.scale);
		FlxTween.tween(button.scale, {x: baseScaleX * 0.93, y: baseScaleY * 0.93}, 0.06, {
			ease: FlxEase.quadOut,
			onComplete: _ -> FlxTween.tween(button.scale, {x: baseScaleX, y: baseScaleY}, 0.14, {ease: FlxEase.quadOut})
		});
		FlxTween.tween(button, {alpha: baseAlpha}, 0.22, {ease: FlxEase.quadOut, startDelay: 0.03});
	}

	#if TOUCH_CONTROLS
	function handleTouchInput():Void
	{
		if (TouchUtil.justPressed)
		{
			touchStartX = TouchUtil.touch.screenX;
			touchStartY = TouchUtil.touch.screenY;

			if (TouchUtil.overlaps(backButton, camFreeplay))
			{
				backButtonArmed = true;
				pulseButton(backButton, backButtonBaseScaleX, backButtonBaseScaleY, backButtonBaseAlpha, true);
			}
			else if (TouchUtil.overlaps(enterButton, camFreeplay))
			{
				enterButtonArmed = true;
				pulseButton(enterButton, enterButtonBaseScaleX, enterButtonBaseScaleY, enterButtonBaseAlpha);
			}
		}

		if (TouchUtil.justReleased)
		{
			final wasTap = Math.abs(TouchUtil.touch.screenX - touchStartX) <= 18 && Math.abs(TouchUtil.touch.screenY - touchStartY) <= 18;

			if (backButtonArmed)
			{
				backButtonArmed = false;
				if (wasTap && TouchUtil.overlaps(backButton, camFreeplay))
					goBack();
				return;
			}

			if (enterButtonArmed)
			{
				enterButtonArmed = false;
				if (wasTap && TouchUtil.overlaps(enterButton, camFreeplay))
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

	function loadSongs():Void
	{
		final lastMod = ModsFolder.currentModFolderPath;
		final songMetaMap = buildSongMetaMap();
		final chartMetaMap = buildChartMetaMap();

		for (songFolder in AssetsPaths.getFolderDirectories(Constants.SONG_CHART_FILES_FOLDER, true))
		{
			var songFolderLower = songFolder.toLowerCase();
			var folderName = songFolderLower.substring(songFolderLower.lastIndexOf('/') + 1);

			for (file in AssetsPaths.getFolderContent(songFolder, true))
			{
				var fileLower = file.toLowerCase();
				if (!fileLower.endsWith('.json') || fileLower.substring(fileLower.lastIndexOf('/') + 1).indexOf(folderName) == -1)
					continue;

				var rawJson = Assets.getText(file);
				if (rawJson == null)
					continue;

				var chart = new Song(Song.parseJSONshit(rawJson));
				var chartName = Path.withoutExtension(file.substring(file.lastIndexOf('/') + 1));
				var chartKey = Paths.formatToSongPath(chartName);
				var difficulty = Difficulty.getDifficultyFromFullPath(fileLower) ?? chart.difficulty ?? Difficulty.defaultDifficulty;
				var songKey = Paths.formatToSongPath(chart.song);
				var chartMeta = chartMetaMap.get(chartKey);
				var songMeta = songMetaMap.get(songKey);
				var charData = Character.resolveCharacterData(chart.player2, false, true);

				var healthIcon = chartMeta?.healthIcon ?? songMeta?.healthIcon;
				if (healthIcon == null || healthIcon.trim().length == 0)
					healthIcon = charData?.healthicon ?? chart.player2;

				var freeplayColor:Int = chartMeta?.freeplayColor ?? songMeta?.freeplayColor ?? 0xFFABCACA;
				if (chartMeta?.freeplayColor == null && songMeta?.freeplayColor == null && charData != null && charData.healthbar_colors != null)
					freeplayColor = charData.healthbar_colors.getColorFromDynamic() ?? freeplayColor;

				var displayName = chart.display ?? chartMeta?.displayName ?? songMeta?.displayName;
				if (displayName == null || displayName.trim().length == 0)
					displayName = chart.song;

				var modPack = chartMeta?.modPack ?? songMeta?.modPack;
				if (modPack == null)
					modPack = initialModFolder;

				songs.push(new MenuFreeplayEntry(
					chart.song,
					displayName,
					chartName,
					folderName,
					file.substr(0, file.length - 5),
					difficulty,
					healthIcon,
					freeplayColor,
					modPack,
					chart.bpm,
					chart.postfix
				));
			}
		}

		ModsFolder.switchMod(lastMod, false);
	}

	function buildSongMetaMap():Map<String, MenuFreeplayMeta>
	{
		final map:Map<String, MenuFreeplayMeta> = new Map();
		final lastMod = ModsFolder.currentModFolderPath;
		WeekData.reloadWeeksFiles(true);

		for (key in WeekData.weeksListOrder)
		{
			if (key == null)
				continue;

			var weekData = WeekData.weeksDatas.get(key.file);
			if (weekData == null || weekData.data.hideInFreeplay)
				continue;

			ModsFolder.switchMod(key.modPack, false);
			for (data in weekData.data.songs)
			{
				if (data == null || data.invisibleInFreeplay)
					continue;

				var freeplayColor:Int = 0xFFABCACA;
				if (data.freeplayColor != null)
					freeplayColor = data.freeplayColor.getColorFromDynamic() ?? freeplayColor;

				map[Paths.formatToSongPath(data.songName)] = new MenuFreeplayMeta(
					data.displaySongName ?? data.songName,
					data.healthIcon,
					freeplayColor,
					key.modPack
				);
			}
		}

		ModsFolder.switchMod(lastMod, false);
		return map;
	}

	function buildChartMetaMap():Map<String, MenuFreeplayMeta>
	{
		final map:Map<String, MenuFreeplayMeta> = new Map();
		final path = AssetsPaths.getPath("data/freeplay-mixes.json");
		if (!Assets.exists(path))
			return map;

		var rawJson = Assets.getText(path);
		if (rawJson == null || rawJson.trim().length == 0)
			return map;

		var parsed:DynamicAccess<Dynamic> = cast Json.parse(rawJson);
		for (songKey in parsed.keys())
		{
			var songData = parsed.get(songKey);
			if (songData == null)
				continue;

			var color:Null<Int> = Reflect.field(songData, "color")?.getColorFromDynamic();
			var baseIcon:String = Reflect.field(songData, "unMixIcon");
			if (baseIcon == null || baseIcon.trim().length == 0)
				baseIcon = Reflect.field(songData, "icon");
			if (baseIcon != null && baseIcon.trim().length > 0)
				map[Paths.formatToSongPath(songKey)] = new MenuFreeplayMeta(null, baseIcon, color, null);

			var mixes:Array<Dynamic> = cast Reflect.field(songData, "mixes");
			if (mixes == null)
				continue;

			for (mix in mixes)
			{
				if (mix == null)
					continue;

				var mixSong:String = Reflect.field(mix, "r_song");
				var mixIcon:String = Reflect.field(mix, "r_icon");
				if (mixSong == null || mixSong.trim().length == 0 || mixIcon == null || mixIcon.trim().length == 0)
					continue;

				map[Paths.formatToSongPath(mixSong)] = new MenuFreeplayMeta(null, mixIcon, color, null);
			}
		}

		return map;
	}

	function restoreInitialModFolder():Void
	{
		ModsFolder.switchMod(initialModFolder, false);
	}

	override function destroy()
	{
		if (!goingToSong)
			restoreInitialModFolder();

		songList = FlxDestroyUtil.destroy(songList);
		listItems = null;

		if (camFreeplay != null)
		{
			if (FlxG.cameras.list.contains(camFreeplay))
				FlxG.cameras.remove(camFreeplay, false);
			camFreeplay.destroy();
			camFreeplay = null;
		}

		super.destroy();
	}
}

class MenuFreeplayMeta
{
	public var displayName:String;
	public var healthIcon:String;
	public var freeplayColor:Null<Int>;
	public var modPack:String;

	public function new(displayName:String, healthIcon:String, freeplayColor:Null<Int>, modPack:String)
	{
		this.displayName = displayName;
		this.healthIcon = healthIcon;
		this.freeplayColor = freeplayColor;
		this.modPack = modPack;
	}
}

class MenuFreeplayEntry
{
	public var songName:String;
	public var displayName:String;
	public var chartName:String;
	public var folderName:String;
	public var chartPath:String;
	public var difficulty:String;
	public var healthIcon:String;
	public var freeplayColor:Int;
	public var modPack:String;
	public var bpm:Float;
	public var postfix:String;
	public var lengthMs:Float = -1;

	public function new(songName:String, displayName:String, chartName:String, folderName:String, chartPath:String, difficulty:String, healthIcon:String,
			freeplayColor:Int, modPack:String, bpm:Float, postfix:String)
	{
		this.songName = songName;
		this.displayName = displayName;
		this.chartName = chartName;
		this.folderName = folderName;
		this.chartPath = chartPath;
		this.difficulty = difficulty ?? Difficulty.defaultDifficulty;
		this.healthIcon = healthIcon;
		this.freeplayColor = freeplayColor;
		this.modPack = modPack;
		this.bpm = bpm;
		this.postfix = postfix ?? '';
	}
}

class MenuFreeplaySongItem extends FlxSpriteGroup
{
	public static inline var ITEM_HEIGHT:Float = 82;
	public static inline var ITEM_PADDING:Float = 12;
	public static inline var TITLE_Y:Float = 24;

	public var bg:FlxSprite;
	public var accent:FlxSprite;
	public var titleText:FlxStaticText;
	public var songMeta:MenuFreeplayEntry;
	public var itemHeight:Float = ITEM_HEIGHT;

	public function new(song:MenuFreeplayEntry, index:Int, width:Float)
	{
		super(12, ITEM_PADDING + index * (ITEM_HEIGHT + 10));
		songMeta = song;

		bg = new FlxSprite();
		bg.makeGraphic(Math.floor(width), Math.floor(ITEM_HEIGHT), 0xFF111111);
		bg.alpha = 0.76;
		add(bg);

		accent = new FlxSprite();
		accent.makeGraphic(8, Math.floor(ITEM_HEIGHT), 0xFFFFFFFF);
		accent.alpha = 0.16;
		add(accent);

		titleText = new FlxStaticText(24, TITLE_Y, width - 48, normalizeTitle(song.displayName));
		titleText.setFormat(Paths.font('PhantomMuff Full Letters 1-1-5.ttf'), 22, FlxColor.WHITE, FlxTextAlign.LEFT);
		titleText.borderStyle = FlxTextBorderStyle.OUTLINE;
		titleText.borderColor = FlxColor.BLACK;
		titleText.borderSize = 1;
		titleText.fieldHeight = ITEM_HEIGHT - TITLE_Y - 8;
		add(titleText);
		setSelected(false);
	}

	public function setSelected(selected:Bool, ?accentColor:Int = 0xFFFFFFFF):Void
	{
		bg.alpha = selected ? 0.94 : 0.76;
		bg.color = selected ? 0xFF2A2A2A : 0xFF111111;
		accent.alpha = selected ? 1 : 0.16;
		accent.color = accentColor;
		titleText.alpha = selected ? 1 : 0.92;
		titleText.color = selected ? FlxColor.WHITE : 0xFFE7E7E7;
	}

	static function normalizeTitle(value:String):String
	{
		var text = value ?? '';
		text = ~/[\r\n\t]+/g.replace(text, ' ');
		text = ~/\s+/g.replace(text, ' ').trim();
		return text.length > 0 ? text : 'UNKNOWN SONG';
	}
}
