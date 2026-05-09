package game.states;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import game.backend.data.jsons.WeekData;
import game.backend.utils.Highscore;
import game.objects.FlxStaticText;
import game.objects.ui.CustomList;
import game.states.FreeplayState.SongMeta;
import game.states.playstate.PlayState;
#if TOUCH_CONTROLS
import game.mobile.utils.TouchUtil;
#end

/**
 * Mobile-friendly Freeplay state.
 * Vertical scrollable list of songs, alphabetically sorted, showing category.
 */
class MobileFreeplayState extends MusicBeatState
{
	static var curSelected:Int = 0;
	static var curDifficultyIndex:Int = 0;

	public var songs:Array<SongMeta> = [];

	var bgSpr:FlxSprite;
	var camHUD:FlxCamera;
	var songList:CustomList;
	var listItems:Array<SongItemSprite> = [];

	var titleText:FlxStaticText;
	var infoText:FlxStaticText;

	var enterButton:FlxSprite;
	var actionButton:FlxSprite;

	var selectedSong:SongMeta;
	var selectedSaveScore:ScoreData;
	var goingToSong:Bool = false;

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

		// Background
		bgSpr = new FlxSprite(Paths.image('menuDesat'));
		bgSpr.screenCenter();
		bgSpr.color = 0xFF444444;
		bgSpr.active = false;
		bgSpr.scrollFactor.set();
		add(bgSpr);

		// Camera HUD for buttons
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		// Header title
		titleText = new FlxStaticText(20, 20, FlxG.width - 40, 'FREEPLAY', 32);
		titleText.alignment = CENTER;
		titleText.borderStyle = OUTLINE;
		titleText.borderColor = FlxColor.BLACK;
		titleText.borderSize = 2;
		titleText.scrollFactor.set();
		titleText.camera = camHUD;
		add(titleText);

		// Info text (selected song details)
		infoText = new FlxStaticText(20, FlxG.height - 150, FlxG.width - 40, '', 16);
		infoText.alignment = CENTER;
		infoText.borderStyle = OUTLINE;
		infoText.borderColor = FlxColor.BLACK;
		infoText.borderSize = 1;
		infoText.scrollFactor.set();
		infoText.camera = camHUD;
		add(infoText);

		// Load songs
		loadSongs();

		// Create scrollable list
		var listX:Int = 50;
		var listY:Int = 80;
		var listW:Int = FlxG.width - 100;
		var listH:Int = FlxG.height - 250;
		songList = new CustomList(listX, listY, listW, listH, true);

		// Build list items
		for (i in 0...songs.length)
		{
			var item = new SongItemSprite(songs[i], i, listW - 40);
			listItems.push(item);
			songList.add(item);
		}
		songList.updateHeightScroll();

		// Mobile buttons
		createMobileButtons();

		if (songs.length > 0)
			changeItem(0, true);

		super.create();
		persistentUpdate = true;

		#if DISCORD_RPC
		DiscordClient.changePresence("In the Mobile Freeplay", null);
		#end
		if (FlxG.sound.music == null || !FlxG.sound.music.active)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}

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

		// Sort alphabetically
		songs.sort(function(a, b) {
			var nameA = (a.data.displaySongName ?? a.data.songName).toLowerCase();
			var nameB = (b.data.displaySongName ?? b.data.songName).toLowerCase();
			if (nameA < nameB) return -1;
			if (nameA > nameB) return 1;
			return 0;
		});
	}

	function createMobileButtons()
	{
		// Action button (back) - right side
		actionButton = new FlxSprite();
		try {
			actionButton.frames = Paths.getSparrowAtlas('mobileUI/back');
			actionButton.animation.addByPrefix("idle", "BACK", 24, false);
			actionButton.animation.play("idle");
			actionButton.animation.pause();
		} catch (e:Dynamic) {
			actionButton.makeGraphic(80, 80, 0xFFAA0000);
		}
		actionButton.alpha = 0.75;
		actionButton.scale.set(0.7, 0.7);
		actionButton.updateHitbox();
		actionButton.setPosition(FlxG.width - actionButton.width - 20, FlxG.height - actionButton.height - 20);
		actionButton.scrollFactor.set();
		actionButton.camera = camHUD;
		add(actionButton);

		// Enter button - left of back button
		enterButton = new FlxSprite();
		try {
			enterButton.loadGraphic(Paths.image('mobileUI/enter'));
		} catch (e:Dynamic) {
			enterButton.makeGraphic(80, 80, 0xFF00AA00);
		}
		enterButton.alpha = 0.75;
		enterButton.scale.set(0.7, 0.7);
		enterButton.updateHitbox();
		enterButton.setPosition(actionButton.x - enterButton.width - 10, FlxG.height - enterButton.height - 20);
		enterButton.scrollFactor.set();
		enterButton.camera = camHUD;
		add(enterButton);
	}

	override function update(elapsed:Float)
	{
		if (goingToSong)
		{
			super.update(elapsed);
			return;
		}

		// Keyboard navigation
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			return;
		}

		if (songs.length > 0)
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

	#if TOUCH_CONTROLS
	function handleTouchInput()
	{
		if (TouchUtil.justReleased)
		{
			if (TouchUtil.overlaps(enterButton, camHUD))
			{
				goToPlayState();
			}
			else if (TouchUtil.overlaps(actionButton, camHUD))
			{
				actionButton.animation.play("idle", true);
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			else
			{
				// Check if user tapped on a list item
				for (i => item in listItems)
				{
					if (item != null && TouchUtil.overlaps(item, songList))
					{
						if (i == curSelected)
						{
							goToPlayState();
						}
						else
						{
							changeItem(i - curSelected);
						}
						break;
					}
				}
			}
		}
	}
	#end

	function changeItem(huh:Int = 0, snap:Bool = false)
	{
		// Deselect old item
		if (listItems[curSelected] != null)
			listItems[curSelected].setSelected(false);

		curSelected = FlxMath.wrap(curSelected + huh, 0, listItems.length - 1);

		// Select new item
		if (listItems[curSelected] != null)
		{
			listItems[curSelected].setSelected(true);
			selectedSong = songs[curSelected];
			ModsFolder.switchMod(selectedSong.modPack);

			// Color tween
			final newColor:Int = selectedSong.data.freeplayColor.getColorFromDynamic() ?? 0xFFABCACA;
			if (snap)
				bgSpr.color = newColor;
			else
				FlxTween.color(bgSpr, 0.5, bgSpr.color, newColor, {ease: FlxEase.cubeOut});

			// Scroll list to selected
			scrollToItem(curSelected);

			updateInfoText();
			if (huh != 0)
				FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}

	function scrollToItem(idx:Int)
	{
		if (listItems[idx] == null || songList == null) return;
		var item = listItems[idx];
		var targetY = item.y - songList.height / 2 + item.itemHeight / 2;
		songList.scrollFloat = targetY;
	}

	function updateInfoText()
	{
		if (selectedSong == null) return;
		var name = selectedSong.data.displaySongName ?? selectedSong.data.songName;
		var category = selectedSong.modPack ?? 'Unknown';
		var diff = curDifficulty ?? '?';
		var hs = Highscore.getSongData(selectedSong.data.songName, diff);
		var score = hs == null ? 0 : hs.score;
		infoText.text = '$name\nFrom: $category | Difficulty: $diff | Highscore: $score';
	}

	function goToPlayState()
	{
		if (selectedSong == null || goingToSong) return;
		goingToSong = true;
		try
		{
			var song = PlayState.loadSong(selectedSong.data.songName, curDifficulty, curDifficulties, false);
			if (song != null)
			{
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music?.stop();
			}
			else
			{
				goingToSong = false;
				Log('Song "${selectedSong.data.songName}" failed to load', RED);
			}
		}
		catch (e)
		{
			goingToSong = false;
			Log(e, RED);
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}

/**
 * UI element representing a single song in the list.
 */
class SongItemSprite extends FlxSpriteGroup
{
	public static inline var ITEM_HEIGHT:Float = 70;
	public static inline var ITEM_PADDING:Float = 10;

	public var bg:FlxSprite;
	public var titleText:FlxStaticText;
	public var categoryText:FlxStaticText;
	public var songMeta:SongMeta;
	public var itemHeight:Float = ITEM_HEIGHT;

	public function new(song:SongMeta, index:Int, width:Float)
	{
		super(20, ITEM_PADDING + index * (ITEM_HEIGHT + 8));
		songMeta = song;

		bg = new FlxSprite();
		bg.makeGraphic(Math.floor(width), Math.floor(ITEM_HEIGHT), 0xFF1A1A1A);
		bg.alpha = 0.6;
		add(bg);

		var name = song.data.displaySongName ?? song.data.songName;
		titleText = new FlxStaticText(15, 8, width - 30, name, 22);
		titleText.borderStyle = OUTLINE;
		titleText.borderColor = FlxColor.BLACK;
		titleText.borderSize = 1;
		add(titleText);

		var categoryName = song.modPack;
		if (categoryName == null || categoryName.length == 0)
			categoryName = 'Freeplay';
		categoryText = new FlxStaticText(15, 38, width - 30, 'From: $categoryName', 14);
		categoryText.alpha = 0.7;
		categoryText.borderStyle = OUTLINE;
		categoryText.borderColor = FlxColor.BLACK;
		categoryText.borderSize = 1;
		add(categoryText);
	}

	public function setSelected(selected:Bool):Void
	{
		bg.alpha = selected ? 0.85 : 0.6;
		bg.color = selected ? 0xFF3A3A3A : 0xFF1A1A1A;
		titleText.scale.set(selected ? 1.05 : 1.0, selected ? 1.05 : 1.0);
	}
}
