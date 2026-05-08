package game.states.editors;

import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import game.backend.data.jsons.WeekData;
import game.backend.system.song.Conductor.mainInstance as Conductor;
import game.backend.system.song.Song;
import game.backend.system.states.MusicBeatState;
import game.backend.utils.Difficulty;
import game.backend.utils.Highscore;
import game.objects.FlxStaticText;
import game.objects.ui.FlxInputText;
import game.mobile.utils.SwipeUtil;
import game.mobile.utils.TouchUtil;
import game.states.playstate.PlayState;
import game.states.substates.GameplayChangersSubstate;
import game.states.substates.ResetScoreSubState;
import haxe.Json;
import haxe.io.Path;

// -РўРРњРћРҐРђ Р§РЃ РўР« РўР’РћР РРЁР¬ РќРђРҐРЈР™?!
// -Р­РўРћ ROFLS!
class SongsState extends MusicBeatState
{
	public var textGroup:FlxTypedGroup<FlxStaticText>;

	var songs:Array<Array<String>> = []; // <'PATH', 'SONG NAME', 'MODFOLDER', 'NAME SONG FOR SAVE'> or <'MODNAME', 'BYTES'>

	static var curSelected:Int = 0;

	var scoreText:FlxStaticText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedMisses:Int = 0;
	var intendedRating:Float = 0;

	public static var inDebugFreeplay:Bool = false;

	#if TOUCH_CONTROLS
	var mobileBackButton:FlxSprite;
	var mobileTouchPoint:FlxPoint = FlxPoint.get();
	var mobileButtons:FlxSpriteGroup;
	var mobileButtonUp:FlxSprite;
	var mobileButtonDown:FlxSprite;
	var mobileButtonEnter:FlxSprite;
	var mobileButtonsLeaving:Bool = false;
	#end

	public function loadSongs()
	{
		// Mods.pushGlobalMods();
		final files:Array<Array<String>> = [];

		var songName:String;
		var diff:String;
		for (songFolder in AssetsPaths.getFolderDirectories(Constants.SONG_CHART_FILES_FOLDER, true))
		{
			songFolder = songFolder.toLowerCase();
			songName = songFolder.substring(songFolder.lastIndexOf('/') + 1);
			for (file in AssetsPaths.getFolderContent(songFolder, true))
			{
				if (!file.endsWith('.json') || file.toLowerCase().substring(file.lastIndexOf('/') + 1).indexOf(songName) == -1)
					continue;
				diff = Difficulty.getDifficultyFromFullPath(file);
				if (diff != null && diff.trim().length == 0)
					diff = null;
				files.push([
					file.substring(songFolder.length + 1, file.length - 5),
					file.substring(0, file.length - 5),
					diff
				]);
			}
		}
		// files.reverse();
		return files;
	}

	var searchInput:FlxInputText;

	override function create()
	{
		inDebugFreeplay = true;
		FlxG.camera.bgColor = 0xFF000000;
		songs = loadSongs();

		curSelected = Std.int(Math.min(curSelected, songs.length - 1)); // safe

		FlxG.camera.antialiasing = true;

		textGroup = new FlxTypedGroup<FlxStaticText>();
		add(textGroup);

		if (songs.length > 0)
		{
			final max:Int = songs.length;
			var i:Array<String>;
			var text:FlxStaticText;
			for (index in 0...max)
			{
				i = songs[index];
				text = new FlxStaticText(120, 50 + 68 * index, 0, '', 30);
				text.ID = index;
				// if(i.length > 2){
				text.text = i[0] + ".json";
				text.alpha = 0.5;
				// var deSang:String = 'ERROR_DATA';
				// var rawJson = File.getContent(i[0]).trim();
				// final data = Song.parseJSONshit(rawJson);
				// try {
				// 	deSang = data.song; // aaaaauuuuuuuuhhhhhhhhhhhhhhh
				// }
				// i.push(i[1]);
				// }else{
				// 	text.size = 22;
				// 	text.screenCenter(X);
				// 	// text.text += ' ( ' + CoolUtil.getSizeString(Std.parseInt(i[1])) + ' )';
				// 	if ((BULLSHIT + BULLSHITOFFSET) % 2 == 1){
				// 		BULLSHITOFFSETY++;
				// 		text.y += 68;
				// 	}else{
				// 		BULLSHITOFFSET++;
				// 	}
				// }
				textGroup.add(text);
			}

			scoreText = new FlxStaticText(FlxG.width * 0.7, 5, 0, "", 32);
			scoreText.setFormat(null, 32, FlxColor.WHITE, RIGHT); // idk how type default font
			scoreText.scrollFactor.set();
			add(scoreText);

			if (ModsFolder.currentModFolderPath != null && ModsFolder.currentModFolderPath.length > 0)
			{
				var warnTxt = new FlxStaticText(8, 5, 0, 'Warning, the engine is starting to be remaded and is scheduled to be detuned from Psych,
				so mods from Psych may break!
				Р’РЅРёРјР°РЅРёРµ, РґРІРёР¶РѕРє РЅР°С‡РёРЅР°РµС‚ РїРµСЂРµРґРµР»С‹РІР°С‚СЊСЃСЏ Рё РїР»Р°РЅРёСЂСѓРµС‚СЃСЏ РѕС‚СЃС‚СЂР°РЅРёС‚СЊСЃСЏ РѕС‚ Psych,
				РїРѕСЌС‚РѕРјСѓ РјРѕРґС‹ СЃ Psych РјРѕРіСѓС‚ СЃР»РѕРјР°С‚СЊСЃСЏ!', 10);
				warnTxt.alpha = 0;
				warnTxt.alignment = LEFT;
				warnTxt.y = FlxG.height - warnTxt.height - 10;
				warnTxt.scrollFactor.set();
				flixel.tweens.FlxTween.tween(warnTxt, {alpha: 0.6}, 4);
				add(warnTxt);
			}

			/*
			searchInput = new FlxInputText(0, 0, 300);
			searchInput.allowUndo = false;
			searchInput.setFormat(null, 8, FlxColor.WHITE, RIGHT);
			searchInput.onChangeText.add(text -> {
				final index = textGroup.any((obj) -> return obj.text.substr(0, obj.text.indexOf('.json')) == text) ?
					textGroup.getFirstIndex((obj) -> return obj.text.substr(0, obj.text.indexOf('.json')) == text)
				:
					-1;
				trace(index);
				if (index == -1) return;
			});
			add(searchInput);
			FlxG.mouse.visible = true;
			*/

			changeSelection();
		}
		else
		{
			final text:FlxStaticText = new FlxStaticText(120, 100 + 68, 0, 'Songs not found', 60);
			text.screenCenter();
			textGroup.add(text);
		}
		#if DISCORD_RPC
		// Updating Discord Rich Presence
		// DiscordClient.changePresence(".. --. .-. .- . - / .-- / -. . / -.-. --- .-.. --- .-. ... / .- -.. ...- . -. - ..- .-. .", null);
		DiscordClient.changePresence();
		#end

		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);

		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(0.45);

		super.create();

		#if TOUCH_CONTROLS
		createMobileBackButton();
		createMobileMenuButtons();
		#end

		FlxG.camera.followLerp = 0;
	}

	#if TOUCH_CONTROLS
	inline function useMobileMenuButtons():Bool
	{
		return FlxG.onMobile && ClientPrefs.mobileMenuButtons;
	}

	inline function getMobileButtonGraphic(name:String, ?fallbackName:String)
	{
		var graphic = Paths.image('mobileUI/$name');
		if (graphic == null && fallbackName != null)
			graphic = Paths.image('mobileUI/$fallbackName');
		return graphic;
	}

	function createMobileMenuButtons()
	{
		if (!useMobileMenuButtons())
			return;

		if (mobileButtons != null)
			return;

		final targetSize:Int = Std.int(Math.min(FlxG.width, FlxG.height) * 0.12);
		if (targetSize <= 0)
			return;

		final margin:Float = Math.max(12, targetSize * 0.2);
		final dpadX:Float = margin;
		final dpadY:Float = FlxG.height - margin - targetSize * 2;

		mobileButtons = new FlxSpriteGroup();
		mobileButtons.scrollFactor.set();
		add(mobileButtons);

		function makeButton(name:String, x:Float, y:Float, ?fallbackName:String):FlxSprite
		{
			final graphic = getMobileButtonGraphic(name, fallbackName);
			if (graphic == null)
				return null;

			final button = new FlxSprite(x, y);
			button.loadGraphic(graphic);
			button.antialiasing = ClientPrefs.globalAntialiasing;
			button.scrollFactor.set();
			button.alpha = 0.85;
			button.setGraphicSize(targetSize, targetSize);
			button.updateHitbox();
			mobileButtons.add(button);
			return button;
		}

		mobileButtonUp = makeButton("up", dpadX + targetSize * 0.5, dpadY, "up (2)");
		mobileButtonDown = makeButton("down", dpadX + targetSize * 0.5, dpadY + targetSize, "down (2)");
		mobileButtonEnter = makeButton("enter", FlxG.width - margin - targetSize * 1.25, FlxG.height - margin - targetSize * 1.25);
	}

	function mobileButtonJustPressed(button:FlxSprite):Bool
	{
		if (!useMobileMenuButtons() || button == null || !button.visible)
			return false;

		for (touch in FlxG.touches.list)
		{
			if (!touch.justPressed)
				continue;
			if (button.overlapsPoint(touch.getWorldPosition(FlxG.camera, mobileTouchPoint), true, FlxG.camera))
				return true;
		}

		return false;
	}

	function createMobileBackButton()
	{
		if (!FlxG.onMobile)
			return;

		final graphic = Paths.image("mobileUI/back");
		if (graphic == null)
			return;

		mobileBackButton = new FlxSprite();
		mobileBackButton.loadGraphic(graphic);
		mobileBackButton.antialiasing = ClientPrefs.globalAntialiasing;
		mobileBackButton.scrollFactor.set();
		mobileBackButton.alpha = 0.85;

		final targetSize:Int = Std.int(Math.min(FlxG.width, FlxG.height) * 0.115);
		if (targetSize > 0)
			mobileBackButton.setGraphicSize(targetSize, targetSize);
		mobileBackButton.updateHitbox();

		final margin:Float = Math.max(12, targetSize * 0.2);
		mobileBackButton.setPosition(margin, margin);
		add(mobileBackButton);
	}

	function mobileBackPressed():Bool
	{
		if (!FlxG.onMobile || mobileBackButton == null || !mobileBackButton.visible)
			return false;

		for (touch in FlxG.touches.list)
		{
			if (!touch.justPressed)
				continue;
			if (mobileBackButton.overlapsPoint(touch.getWorldPosition(FlxG.camera, mobileTouchPoint), true, FlxG.camera))
				return true;
		}

		return false;
	}

	function getTouchedSongIndex():Int
	{
		if (!FlxG.onMobile || textGroup == null)
			return -1;

		for (touch in FlxG.touches.list)
		{
			if (!touch.justPressed)
				continue;

			for (songText in textGroup.members)
			{
				if (songText == null)
					continue;
				if (touch.overlaps(songText, FlxG.camera))
					return songText.ID;
			}
		}

		return -1;
	}
	function tweenOutMobileButtons(?onComplete:Void->Void):Void
	{
		#if TOUCH_CONTROLS
		mobileButtonsLeaving = true;
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
		function tweenButton(button:FlxSprite, targetX:Float):Void
		{
			if (button == null || !button.visible)
				return;
			pending++;
			FlxTween.tween(button, {x: targetX, alpha: 0}, 0.14, {onComplete: _ -> done()});
		}
		if (mobileBackButton != null)
			tweenButton(mobileBackButton, -mobileBackButton.width - 24);
		if (mobileButtonUp != null)
			tweenButton(mobileButtonUp, -mobileButtonUp.width - 24);
		if (mobileButtonDown != null)
			tweenButton(mobileButtonDown, -mobileButtonDown.width - 24);
		if (mobileButtonEnter != null)
			tweenButton(mobileButtonEnter, FlxG.width + mobileButtonEnter.width + 24);
		if (pending <= 0 && onComplete != null)
		{
			var cb = onComplete;
			onComplete = null;
			cb();
		}
		#else
		if (onComplete != null)
			onComplete();
		#end
	}
	#end

	function runWithMobileButtonsExit(action:Void->Void):Void
	{
		#if TOUCH_CONTROLS
		if (FlxG.onMobile)
		{
			if (mobileButtonsLeaving)
				return;
			tweenOutMobileButtons(action);
			return;
		}
		#end
		action();
	}

	override function closeSubState()
	{
		super.closeSubState();
		if (songs.length > 1)
			changeSelection(0, false);
	}

	var isGoBack:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (subState == null && !isGoBack)
		{
			#if TOUCH_CONTROLS
			final usingMobileButtons:Bool = useMobileMenuButtons();
			#else
			final usingMobileButtons:Bool = false;
			#end

			#if TOUCH_CONTROLS
			if (mobileBackPressed())
			{
				runWithMobileButtonsExit(() ->
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					inDebugFreeplay = false;
					MusicBeatState.switchState(new MusicBeatState("MenuState"));
					isGoBack = true;
				});
				return;
			}

			if (!usingMobileButtons)
			{
				var touchedSongIndex = getTouchedSongIndex();
				if (touchedSongIndex != -1)
				{
					changeSelection(touchedSongIndex - curSelected, false);
					tryGoToCurrentSong();
					return;
				}

				if (TouchUtil.justPressed && TouchUtil.touch.getWorldPosition(FlxG.camera, mobileTouchPoint).x < FlxG.width * 0.75)
				{
					tryGoToCurrentSong();
					return;
				}
			}
			else if (songs.length > 0 && mobileButtonJustPressed(mobileButtonEnter))
			{
				tryGoToCurrentSong();
				return;
			}
			#end

			if (songs.length > 1)
			{
				final shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;
				#if TOUCH_CONTROLS
				final mobileUp:Bool = usingMobileButtons && mobileButtonJustPressed(mobileButtonUp);
				final mobileDown:Bool = usingMobileButtons && mobileButtonJustPressed(mobileButtonDown);
				#end

				if (controls.UI_UP_P
					|| (!usingMobileButtons && SwipeUtil.swipeUp)
					#if TOUCH_CONTROLS
					|| mobileUp
					#end
				)
				{
					FlxG.camera.shake(0.001, 0.08);
					changeSelection(-shiftMult);
				}
				else if (controls.UI_DOWN_P
					|| (!usingMobileButtons && SwipeUtil.swipeDown)
					#if TOUCH_CONTROLS
					|| mobileDown
					#end
				)
				{
					FlxG.camera.shake(0.001, 0.08);
					changeSelection(shiftMult);
				}

				if (controls.UI_LEFT_P
				)
				{
					FlxG.camera.shake(0.001, 0.08);
					changeSelection(-shiftMult);
				}
				else if (controls.UI_RIGHT_P
				)
				{
					FlxG.camera.shake(0.001, 0.08);
					changeSelection(shiftMult);
				}
			}
			if (songs.length > 0)
				if (controls.ACCEPT)
				{
					tryGoToCurrentSong();
				}
				// else if (controls.RESET)
				// {
				// 	openSubState(new ResetScoreSubState(songs[curSelected], '', -2));
				// 	FlxG.sound.play(Paths.sound('scrollMenuDown'));
				// }
			if (FlxG.keys.justPressed.CONTROL)
				openSubState(new GameplayChangersSubstate());
			if (controls.BACK)
			{
				runWithMobileButtonsExit(() ->
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					inDebugFreeplay = false;
					MusicBeatState.switchState(new MusicBeatState("MenuState"));
					isGoBack = true;
				});
			}
		}
		// super.update(elapsed);
	}

	inline function tryGoToCurrentSong()
	{
		if (songs.length <= 0)
			return;

		if (Assets.exists(songs[curSelected][1] + '.json'))
		{
			goToPlayState();
		}
		else
		{
			trace('Couldnt find file for play');
			FlxG.sound.play(Paths.sound('whyNotLol/Voice (' + FlxG.random.int(1, 20) + ')'));
		}
	}

	public function goToPlayState()
	{
		runWithMobileButtonsExit(() ->
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			if (ClientPrefs.flashing)
				FlxFlicker.flicker(textGroup.members[curSelected], 10, 0.15, false);
			isGoBack = true;
			new FlxTimer().start(1.1, _ ->
			{
				var e = new Song(Song.parseJSONshit(Assets.getText(songs[curSelected][1] + '.json')));
				e.difficulty = Difficulty.getDifficultyFromFullPath(songs[curSelected][1]) ?? e.difficulty;
				Difficulty.list = [e.difficulty]; // woo vomp
				PlayState.setSong(e);
				PlayState.isStoryMode = false;
				#if EDITORS_ALLOWED
				if (FlxG.keys.pressed.SHIFT)
				{
					MusicBeatState.switchState(new ChartingState());
				}
				else
				#end
				{
					LoadingState.loadAndSwitchState(new PlayState());
				}
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.volume = 0;
					FlxG.sound.music.stop();
				}
				Conductor.songPosition = -5000;
			});
		});
	}
	private inline function unselectableCheck(num:Int):Bool
		return songs[num].length > 1;

	public function changeSelection(change:Int = 0, ?playSound:Bool = true)
	{
		var obj = textGroup.members[curSelected];
		if (obj != null)
			obj.alpha = 0.5;

		if (songs.length > 1)
		{
			do
			{
				curSelected = flixel.math.FlxMath.wrap(curSelected + change, 0, songs.length - 1);
			}
			while (!unselectableCheck(curSelected));
		}
		else
		{
			curSelected = 0;
		}
		obj = textGroup.members[curSelected];
		// trace(songs[curSelected]);
		obj.alpha = 1;
		var point = obj.getMidpoint();
		FlxG.camera.scroll.y = point.y - FlxG.camera.height / 2;
		point.put();
		final data = Highscore.getSongData(songs[curSelected][0]);
		trace(songs[curSelected]);
		if (data == null)
		{
			intendedScore = 0;
			intendedRating = 0;
			intendedMisses = 0;
		}
		else
		{
			intendedScore = data.score;
			intendedRating = Math.floor(100 * data.rating);
			intendedMisses = data.misses;
		}

		scoreText.text = 'PERSONAL BEST: $intendedScore ($intendedRating%)\nMisses: $intendedMisses';
		// ModsFolder.currentModFolder = songs[curSelected][2];
		scoreText.x = FlxG.width - scoreText.width - 26;
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	override function destroy()
	{
		#if TOUCH_CONTROLS
		mobileBackButton = null;
		mobileButtons = null;
		mobileButtonUp = null;
		mobileButtonDown = null;
		mobileButtonEnter = null;
		mobileTouchPoint.put();
		#end
		super.destroy();
	}
}
