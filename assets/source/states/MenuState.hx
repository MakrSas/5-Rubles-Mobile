import game.backend.system.states.MusicBeatSubstate;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEvent;
import flixel.system.FlxBGSprite;
import flixel.graphics.FlxGraphic;
import haxe._Int64.Int64_Impl_ as Int64; // haxe.Int64
#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite;
#end
import flxanimate.FlxAnimate;
#if EDITORS_ALLOWED
import game.states.editors.ChartingState;
#end
import game.backend.data.jsons.WeekData;
import game.backend.system.song.Song;
import game.backend.system.states.MusicBeatState;
import game.backend.utils.Highscore;
import game.backend.utils.PathUtil;
#if VIDEOS_ALLOWED
import game.objects.VideoSprite;
#end
import game.states.FreeplayState;
import game.states.LoadingState;
import game.states.substates.GameplayChangersSubstate;
import game.states.substates.MenuFreeplaySubstate;

importHScriptClasses("scripts/classes/ExplosionSprite.hx");
using StringTools;

static var isShowingTexts = true;
static var curSelected = 1;
static var curRow = 0;
static var isTitle = true;
static var preloaded = false;

static final songsList = [
	"black2blue",
	"black2blue-picomix",
	"rubls",
	"rubls-picomix",
	"nokia",
	"nokiaredarmix",
	"rofls",
	"roflspivomix",
	"bezdari",
	"bezdarinaisonjimix",
	"bezdariamalgamatmix",
	"hernya",
	"hernyamorumix",
];

static final bonusSongList = ["add-me-in-5rubles", "matematika", "under-construction"];
static final titleScreenEasterTextsKeys = ["Окей, раз просишь -\nвот тебе по-жёсткому и без воды про 5RUBLES:"];

static final titleScreenEasterTexts = [
	"Окей, раз просишь -\nвот тебе по-жёсткому и без воды про 5RUBLES:" => [
		"Matr4Ss - батя проекта, рисует всё, делает анимацию, мутит идеи, местами чарты.",
		"juztexd - правая рука, артит, помогает рулить движухой.",
		"hopka_opka - чарты клепает, арты, да ещё и кодить может (ебашит по всем фронтам).",
		"magmansplace - тоже по артам ебашит, визуал мутит.",
		"d4rkwinged - универсал, и музыку пишет, и чарты, и арты. Такой себе швейцарский нож.",
		"Naisonji - чисто по стилю долбит арты, промки рисует.",
		"Salted_Marm - саундмастер, музло пишет, арты подливает.",
		"PukovichCat - треки делает, особо не выёбывается.",
		"rofos_hristo - музон клепает, стиль подгоняет.",
		"Alyaneshko - арты, музон, такой себе универсальный боец.",
		"redar13 - чисто кодер, движок крутит.",
		"richTrash21 - и кодит, и арты мутит.",
		"PurSnake - тоже кодер, особо не лезет в свет, но делает."
	]
];

final optionShit:Array<Array<Dynamic>> = [
	// кнопки
	[
		{
			name: "story",
			// TODO: v2 - добавить стори мод лол
			switchFunc: null,
			position: FlxPoint.get(895, 68),
			// selectedPosition: FlxPoint.get(846, 14),
			locked: true,
			// canBreak: true,
			animations: [
				// {name: "idle", loop: true},
				{name: "locked", loop: true},
				{name: "lockedClicked", offset: [0, -1]},
				// {name: "selected", loop: true, offset: [48, 54]},
				// {name: "break"} // TODO: оффсеты
			]
		},
		{
			name: "freeplay",
			switchFunc: () -> FlxG.state.openSubState(new MenuFreeplaySubstate()),
			position: FlxPoint.get(832, 247),
			// selectedPosition: FlxPoint.get(773, 178),
			canBreak: true,
			animations: [
				{name: "idle", loop: true},
				{name: "selected", loop: true, offset: [58, 69]}, // смейтесь
				{name: "break"} // TODO: оффсеты
			]
		},
		{
			name: "credits",
			switchFunc: () -> {stateClass: MusicBeatState, args: ["CreditsState"]},
			position: FlxPoint.get(743, 448),
			// selectedPosition: FlxPoint.get(663,  387),
			canBreak: true,
			animations: [
				{name: "idle", loop: true},
				{name: "selected", loop: true, offset: [80, 61]},
				{name: "break"} // TODO: оффсеты
			]
		},
		{
			name: "settings",
			switchFunc: () -> FlxG.state.openSubState(new game.states.betterOptions.OptionsSubState()),
			position: FlxPoint.get(631, 568),
			// selectedPosition: FlxPoint.get(569,  493),
			animations: [{name: "idle", loop: true}, {name: "selected", loop: true, offset: [62, 75]},]
		}
	],
	// дверь
	[
		{
			name: "exit",
			switchFunc: () -> onExists(),
			position: FlxPoint.get(1108, 495),
			animationChangedCallback: (i) -> doorCallback(i),
			animationCallback: (name:String, frameNumber:Int, frameIndex:Int) -> doorEachCallback(name, frameNumber, frameIndex),
			// selectedPosition: FlxPoint.get(1043, 497),
			canBreak: true,
			animations: [
				{name: "idle", loop: true},
				{name: "selected", loop: true, offset: [65, -2]},
				{name: "open", offset: [69, 2]},
				{name: "close", offset: [69, 2]},
				{name: "break", offset: [67, 0]} // TODO: оффсеты
			]
		}
	] // дискорда тут не будет потому что я очень хуевый программист!!!
	// - rich
];

static var crowdOut = [
	// {budName: "", "anim": "", pos: [0, 0], condition: "none", song: "song-name", framesPath: "frames/path"},
	{
		budName: "rofos",
		anim: "рофос фанк",
		pos: [135, 278],
		condition: "none",
		song: "rofls"
	},
	{
		budName: "pivozavrik",
		anim: "пиво",
		pos: [70, 315],
		condition: "none",
		song: "roflspivomix"
	},
	{
		budName: "kersive",
		anim: "керсив",
		pos: [577, 422],
		condition: "none",
		song: "matematika"
	},
	{
		budName: "g3hree",
		anim: "георг",
		pos: [548, 501],
		condition: "none",
		song: "matematika"
	},
	{
		budName: "leebert",
		anim: "либерт",
		pos: [128, 358], // 34, 375
		condition: "none",
		song: "matematika"
	},
	{
		budName: "alyaneshko",
		anim: "алянешко",
		pos: [81, 392], // 34, 375
		condition: "none"
	},
	{
		budName: "pursnake",
		anim: "снейк",
		pos: [50, 405], // 70, 412
		condition: "none",
		song: "matematika"
	},
	{
		budName: "simon",
		anim: "симон",
		pos: [2, 416], // 32, 420
		condition: "none",
		song: "matematika"
	},
	{
		budName: "hopka",
		anim: "норка фнф",
		pos: [218, 354],
		condition: "none",
		song: "bezdarinaisonjimix"
	},
	{
		budName: "m4trass",
		anim: "матрасс",
		pos: [165, 385],
		condition: "none",
		song: "bezdari"
	},
	{
		budName: "naisonji",
		anim: "найсогна",
		pos: [217, 388],
		condition: "none",
		song: "bezdarinaisonjimix"
	},
	{
		budName: "sway",
		anim: "свайстик марм солевой",
		pos: [293, 385],
		condition: "none",
		song: "black2blue"
	},
	{
		budName: "juztexd",
		anim: "джаст",
		pos: [337, 402],
		condition: "none",
		song: "hernyamorumix"
	},
	{
		budName: "richTrash",
		anim: "ричард",
		pos: [469, 415], // 64, 407
		condition: "none",
		song: "bezdariamalgamatmix"
	},
	{
		budName: "sector",
		anim: "сектор",
		pos: [516, 433], // 64, 407
		condition: "none",
		song: "matematika"
	},
	{
		budName: "amalgamat",
		anim: "шахмат анальный",
		pos: [126, 417],
		condition: "none",
		song: "bezdariamalgamatmix"
	},
	{
		budName: "lostel",
		anim: "лостель",
		pos: [93, 448],
		condition: "none",
		song: "rubls"
	},
	{
		budName: "redar13",
		anim: "редар",
		pos: [51, 470],
		condition: "none",
		song: "nokiaredarmix"
	},
	{
		budName: "xavier",
		anim: "ксави",
		pos: [2, 481],
		condition: "none"
	},
	{
		budName: "d4rkwinged",
		anim: "вингед фнф",
		pos: [399, 408],
		condition: "none",
		song: "hernya"
	},
	{
		budName: "magmanSkarler",
		anim: "магмэн папа и скарлел бро",
		pos: [432, 436],
		condition: "none",
		song: "hernyamorumix"
	},
	{
		budName: "pukohich",
		anim: "пукавич",
		pos: [499, 511],
		condition: "none",
		song: "nokia"
	},
	{
		budName: "m4trass-uc",
		anim: "матрасс uc",
		pos: [253, 452],
		condition: "uc",
		framesPath: "uc_strashilka"
	}, // {budName: "naisonji-uc", anim: "найсогна", pos: [215, 388], condition: "uc"},
];

static var spookyColorOffset = -80;
static var discordHideOffset = 160;
var distance:Float;
var allSongsIsUnloked = true;
var isBasketball = false;
var queuedNotif:Bool;

// взрывы реюзинг
var explosionsGroup:FlxGroup = new FlxGroup();

// ТИТУЛЬНИК
var offset = 60;
var bound = FlxG.width + offset;
var titleSpr:FlxSprite;
var titleTextSpr:FlxSprite;

// ГЛАВНОЕ МЕНЮ
var menuItems = [[], [], []]; // кнопки, дверь, дискорд

function forEachMenuItem(func:(spr:FlxSprite) -> Void)
{
	for (rowIndex => rowItems in menuItems)
		for (spr in rowItems)
			func(spr);
}

var buttons:FlxSpriteGroup;
var bgPosX = 491;
var crowd:FlxGroup;
var bgDoorLoadSpr:FlxSprite;
var bgDoorVoidSpr:FlxSprite;
var bgDoorSpr:FlxSprite;
var bgDoorVolume = 0.85;
var bgDoorRandomChanceDefault = 25;
var bgDoorRandomChance = bgDoorRandomChanceDefault;
var bgDoorMemeMode = false;

// томас :)
var tomatotoma:FlxSprite;
var tomasSound:FlxSound;
var tomasDeathYell:FlxSound;
var tomasVasBeaten = false;
var deleteProgressScreen:DeleteProgressSubState;
var discordScreen:DiscordSubState;
var discordIcon:DiscordIcon;
var musicVolume = 1;
var bgGroup:FlxGroup;
var randPicters = [];
var randPictersTxtPath = AssetsPaths.getPath("data/menuDoorPictures.txt");
var tomacool:FlxSprite;
var tomacoolSound:FlxSound;
var tomaRespawnTimer = new FlxTimer();

function preloadAssets()
{
	if (preloaded)
		return;

	function preloadImage(path:String)
	{
		var image = Paths.image(path);
		if (image != null)
			graphicCache.cache(image);
	}

	function preloadFolder(key:String)
	{
		var root = 'images/$key';
		for (asset in AssetsPaths.getFolderContent(root))
			if (asset.endsWith(".png"))
				graphicCache.cache(Paths.image('$key/$asset'));

		for (directory in AssetsPaths.getFolderDirectories(root))
			preloadFolder('$key/$directory');
	}

	if (FlxG.onMobile)
	{
		for (assetPath in [
			"mainmenu/sky",
			"mainmenu/sky_top",
			"mainmenu/clouds_spin",
			"mainmenu/bg",
			"mainmenu/logo_bump",
			"mainmenu/press_enter",
			"mainmenu/backbullshit",
			"mainmenu/loading_icon",
			"mainmenu/story_bt",
			"mainmenu/freeplay_bt",
			"mainmenu/credits_bt",
			"mainmenu/settings_bt",
			"mainmenu/exit_bt",
			"mainmenu/epigandokids",
			"mainmenu/irl",
			"mainmenu/rubtomsk",
			"mainmenu/rubtomsk_cooler"
		])
			preloadImage(assetPath);
	}
	else
		preloadFolder("mainmenu");

	preloaded = true;
}

static var JesusWallpaper = false;

function create()
{
	Main.canClearMem = true;
	preloadAssets();

	var jesus = false;
	FlxG.save.data.rubles5UnlockedSong ??= [];
	FlxG.save.data.seenDiscordFreeplayHelp ??= false;
	if (JesusWallpaper)
	{
		JesusWallpaper = false;
		FlxG.save.flush();
		jesus = !isBasketball;
	}

	var locked = [];
	for (song in songsList)
	{
		if (!FlxG.save.data.rubles5UnlockedSong.contains(song))
		{
			#if DEV_BUILD
			trace('"$song" непройден');
			#end
			allSongsIsUnloked = false;
			locked.push(song);
		}
	}
	for (song in bonusSongList)
	{
		if (!FlxG.save.data.rubles5UnlockedSong.contains(song))
		{
			#if DEV_BUILD
			trace('"$song" непройден');
			#end
			locked.push(song);
		}
	}

	// поигарем?
	isBasketball = (allSongsIsUnloked && locked.length == 1 && locked[0] == "under-construction");
	if (isBasketball)
	{
		// фейковый перезапуск игры хехе
		if (!FlxG.save.data.special.uc_encounter)
		{
			// ЛУЧШЕ НА ВСЯКИЙ ВЫЕБАТЬ ВСЕ ПЕРЕХОДЫ!!!
			// for (trans in Main.transition.members)
			//	trans.finish();
			// Оно их ёбет это да, до смерти - PurSk

			FlxG.save.data.special.uc_encounter = isTitle = isShowingTexts = true;
			FlxG.save.flush();
		}
		Log("поиграем? :)", TColor.RED);
	}

	FlxG.state.destroySubStates = false;
	FlxG.autoPause = ClientPrefs.autoPause;
	if (FlxG.sound.music == null || !FlxG.sound.music.active)
	{
		FlxG.sound.playMusic(Paths.music("freakyMenu"), 0);
	}
	Conductor.bpm = 146;

	add(bgGroup = new FlxGroup());

	var gradientBG = bgGroup.add(new FlxSprite(0, 0, Paths.image("mainmenu/sky")));
	bgGroup.add(new FlxSprite(0, 0, Paths.image("mainmenu/sky_top")));
	var clouds = bgGroup.add(new FlxSprite(2, -286, Paths.image("mainmenu/clouds_spin")));
	var bg = bgGroup.add(new FlxSprite(-49, -16, Paths.image("mainmenu/bg")));

	distance = (gradientBG.height - FlxG.height - 100);
	bg.y += distance;

	gradientBG.scale.x = FlxG.width;
	gradientBG.updateHitbox();

	clouds.origin.set(600 - clouds.x, 100 - clouds.y);
	clouds.angularVelocity = 1.5;
	clouds.angle = FlxG.random.float(0, 360);

	if (!isBasketball)
	{
		tomacool = new FlxSprite();
		tomacool.frames = Paths.getSparrowAtlas("mainmenu/rubtomsk_cooler");
		tomacool.animation.addByPrefix("Ў", "атака бпла");
		tomacool.animation.play("Ў");
		tomacool.kill();
		add(tomacool);

		tomacoolSound = FlxG.sound.load(Paths.sound("vertoletReal"), 0, true);
		tomacoolSound.play();
	}

	if (isBasketball)
	{
		randPicters = ["mainmenu/bgDoor_uc"];
	}
	else
	{
		for (i in CoolUtil.coolTextFile(randPictersTxtPath))
		{
			if (i.length == 0)
				return;

			if (i.endsWith("*"))
			{
				for (i in AssetsPaths.getFolderContent(i.substring(0, i.length - 2), true, false))
					randPicters.push(i);
			}
			else
			{
				randPicters.push(i);
			}
		}
		if (FlxG.save.data.rubles5UnlockedSong.contains("under-construction"))
		{
			#if VIDEOS_ALLOWED
			randPicters.push("videos/WE_ARE_5RUBLES.mp4");
			randPicters.push("videos/better_than_mario_madness.mp4");
			randPicters.push("videos/uc concept.mp4");
			#end
		}
	}
	// trace(randPicters);

	// title menu
	titleSpr = new FlxSprite();
	titleSpr.frames = Paths.getSparrowAtlas("mainmenu/logo_bump");
	titleSpr.animation.addByPrefix("beat", "logo_bump", 24, false);
	titleSpr.animation.play("beat", true);
	add(titleSpr).screenCenter().y -= 100;

	titleTextSpr = new FlxSprite();
	titleTextSpr.frames = Paths.getSparrowAtlas("mainmenu/press_enter");
	titleTextSpr.animation.addByPrefix("idle", "press_enter0", 24, false);
	titleTextSpr.animation.addByPrefix("press", "press_enter-confirm0", 24, false);
	titleTextSpr.animation.play("idle", true);
	titleTextSpr.centerOffsets();
	add(titleTextSpr).screenCenter().y += 240;

	crowd = new FlxGroup();
	final crowdFrames = Paths.getSparrowAtlas("mainmenu/epigandokids"); // огобля
	for (dude in crowdOut)
	{
		// чекем кондиции
		var allowed = switch (dude.condition)
		{
			// показываются только когда были пройдены все песни кроме подконструкции
			case "uc": isBasketball;
			// none или похуй вхатевер
			default: !isBasketball && (dude.song == null ? allSongsIsUnloked : FlxG.save.data.rubles5UnlockedSong.contains(dude.song));
		}
		if (!allowed)
			continue;

		final aoaBashbash = new FlxSprite(dude.pos[0], dude.pos[1] + distance);
		aoaBashbash.frames = (dude.framesPath == null) ? crowdFrames : Paths.getSparrowAtlas("mainmenu/" + dude.framesPath);
		aoaBashbash.animation.addByPrefix("y", dude.anim, 24, true);
		// aoaBashbash.animation.addByPrefix("y", "шахмат анальный образец 1", 24, true); // интересно
		aoaBashbash.animation.play("y", true);
		aoaBashbash.origin.set(aoaBashbash.width / 2, aoaBashbash.height - 5);
		// if (FlxG.random.bool(25)) FlxTween.tween(aoaBashbash, {"scale.x": 1.15, "scale.y": 0.75}, Conductor.crochet / 1000, {ease: FlxEase.elasticInOut, type: 4});
		crowd.add(aoaBashbash);
		if (jesus)
		{
			aoaBashbash.colorTransform.redOffset = aoaBashbash.colorTransform.greenOffset = aoaBashbash.colorTransform.blueOffset = 255;
			aoaBashbash.colorTransform.alphaMultiplier = 0;
			var offsetStart = FlxG.random.float(0.5, 2.5);
			FlxTween.num(aoaBashbash.y - FlxG.random.int(50, 100), aoaBashbash.y, 2.5, {
				ease: FlxEase.expoOut,
				startDelay: offsetStart
			}, aoaBashbash.set_y);
			FlxTween.num(aoaBashbash.colorTransform.redOffset * 1.5, 0, 3.5, {
				ease: FlxEase.cubeOut,
				startDelay: offsetStart
			}, i ->
			{
				aoaBashbash.colorTransform.redOffset = aoaBashbash.colorTransform.greenOffset = aoaBashbash.colorTransform.blueOffset = i;
			});
			FlxTween.num(aoaBashbash.colorTransform.alphaMultiplier, 1, 1.5, {
				ease: FlxEase.cubeInOut,
				startDelay: offsetStart
			}, i ->
			{
				aoaBashbash.colorTransform.alphaMultiplier = i;
			});
		}
		// ?TODO: приколы с мышкой и чуваками
	}
	add(crowd);

	// ну привет максим
	tomatotoma = new FlxSprite(0 + 100500, distance + 50);
	tomatotoma.frames = Paths.getSparrowAtlas("mainmenu/rubtomsk");
	tomatotoma.animation.addByPrefix("y", "было", 24, true);
	tomatotoma.animation.play("y", true);
	add(tomatotoma);
	tomatotoma.origin.x -= 60;
	tomaRespawnTimer.start(1, _ -> tomasGichaStart());
	tomaRespawnTimer.active = !isTitle;

	// add(new TomskPlane(150, 1200, distance - 50, distance + 50));

	tomasSound = FlxG.sound.load(Paths.sound("vertoletReal"), 0, true);
	tomasSound.play();
	tomasDeathYell = FlxG.sound.load(Paths.sound("vertoletdead"), 0);

	FlxMouseEvent.add(tomatotoma, _ ->
	{
		if (!tomasVasBeaten && subState == null /*&& !forMouseClick*/)
		{
			tomasVasBeaten = true;
			tomatotoma.acceleration.y = FlxG.random.float(90, 110);
			tomatotoma.velocity.y = -FlxG.random.float(30, 40);
			tomatotoma.angularVelocity = -(tomatotoma.velocity.y / 10);
			tomatotoma.angularAcceleration = -(tomatotoma.acceleration.y / 10);

			tomatotoma.scale.set(FlxG.random.float(0.95, 0.975), FlxG.random.float(1.025, 1.05));
			FlxTween.tween(tomatotoma, {"scale.x": 1, "scale.y": 1}, FlxG.random.float(0.15, 0.25), {ease: FlxEase.quadOut});

			tomasDeathYell.play(true);
			var time = (tomasDeathYell.length / 1000 - 0.01) * FlxG.random.float(0.95, 0.98);
			FlxTween.shake(tomatotoma, FlxG.random.float(0.004, 0.006), time, XY, {onUpdate: t -> t.intensity -= FlxG.elapsed * 0.005});
			new FlxTimer().start(time, _ ->
			{
				explodeTomsk();
				FlxG.camera.shake(0.008, 0.11);
				// timer to revive
				tomaRespawnTimer.start(FlxG.random.float(1.5, 3.5), _ ->
				{
					tomasVasBeaten = false;
					tomatotoma.revive();
					tomatotoma.angularVelocity = tomatotoma.angularAcceleration = tomatotoma.angle = 0;
					tomasGichaStart();
				});
			});
		}
	}, null, null, null, false, true, false);

	add(buttons = new FlxSpriteGroup());
	var backBullshit = new FlxSprite(0, 0, Paths.image("mainmenu/backbullshit"));
	backBullshit.y = (FlxG.height - backBullshit.height) / 2;
	backBullshit.ID = -1;
	buttons.add(backBullshit);
	buttons.add(bgDoorVoidSpr = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK));
	bgDoorVoidSpr.active = false;
	bgDoorVoidSpr.scrollFactor.set();
	#if VIDEOS_ALLOWED
	buttons.add(bgDoorSpr = new FlxVideoSprite());
	#else
	buttons.add(bgDoorSpr = new FlxSprite());
	#end
	bgDoorSpr.scrollFactor.set();
	#if VIDEOS_ALLOWED
	bgDoorSpr.bitmap.volumeAdjust = bgDoorVolume;
	#end
	bgDoorSpr.clipRect ??= FlxRect.get();
	#if VIDEOS_ALLOWED
	bgDoorSpr.bitmap.onFormatSetup.add(() ->
	{
		setupBgDoorSpr();
		bgDoorLoadSpr.exists = false;
	}, false, -1);
	#end
	// bgDoorSpr.bitmap.onEndReached.add(() -> {
	// 	// stopDoorVideo();
	// 	changeItemByIndex(0, curRow, true);
	// }, false, -1);
	bgDoorSpr.kill();
	buttons.add(bgDoorLoadSpr = new FlxSprite(672, 598.35, Paths.image("mainmenu/loading_icon")));
	bgDoorLoadSpr.scrollFactor.set();
	bgDoorLoadSpr.origin.set(27 / 2, 23.85 - 10);
	bgDoorLoadSpr.exists = false;
	bgDoorLoadSpr.angularVelocity = -360;
	persistentUpdate = persistentDraw = true;
	setupBgDoorSpr();

	var onPressButt = spr -> if (subState == null && !isTitle && !selectedSomethin)
	{
		var row = Std.int(spr.ID / 10);
		var id = spr.ID % 10;
		// if (optionShit[row][id].locked)
		// 	return;

		if (id != curSelected || row != curRow)
			changeItemByIndex(id, row, false, true);
		else
			onAccept();
	}
	var onOverButt = spr -> if (subState == null && !isTitle && !selectedSomethin)
	{
		var row = Std.int(spr.ID / 10);
		var id = spr.ID % 10;
		if (id != curSelected || row != curRow) // && !optionShit[row][id].locked
			changeItemByIndex(id, row, true, true);
	}
	for (row in 0...optionShit.length)
		for (i => data in optionShit[row])
		{
			final menuItem = new TwistSprite(data.position.x - bgPosX, data.position.y);
			menuItem.frames = Paths.getSparrowAtlas("mainmenu/" + data.name + "_bt");

			// menuItem.addAnimation('idle', data.name + "_idle0", null, null, 0, 0, false);
			// var offset = (data.selectedPosition == null) ? null : [data.position.x - data.selectedPosition.x, data.position.y - data.selectedPosition.y];
			// menuItem.addAnimation('selected', data.name + "_selected0", null, offset, 0, 0, true);
			// TODO: анимки ломания
			// if (data.canBreak)
			//	menuItem.addAnimation('break', data.name + "_break0");
			// menuItem.playAnim('idle');

			for (anim in data.animations)
			{
				menuItem.addAnimation(anim.name, data.name + "_" + anim.name + "0", null, anim.offset, 24, anim.loopPoint, anim.loop);
			}
			if (data.animationChangedCallback != null || data.animationCallback != null)
			{
				var _lastAnim;
				menuItem.animation.callback = (name:String, frameNumber:Int, frameIndex:Int) ->
				{
					if (_lastAnim != name && data.animationChangedCallback != null)
						data.animationChangedCallback(_lastAnim = name);
					if (data.animationCallback != null)
						data.animationCallback(name, frameNumber, frameIndex);
				}
			}
			menuItem.animation.finishCallback = anim -> switch anim
			{
				case "lockedClicked":
					menuItem.playAnim("locked");
				case "open":
					menuItem.playAnim("selected");
				case "close":
					menuItem.playAnim("idle");
			}
			// if (!menuItem.playAnim("idle"))
			menuItem.playAnim(data.animations[0].name);
			// data.canBreak = menuItem.animation.exists("break");

			menuItem.ID = row * 10 + i;
			menuItems[row].push(menuItem);
			buttons.add(menuItem);
			FlxMouseEvent.add(menuItem, onPressButt, null, onOverButt, null, false, true, false);
		}

	buttons.scrollFactor.set();
	buttons.forEach(spr -> spr.scrollFactor.set());
	buttons.x = FlxG.width;

	discordIcon = new DiscordIcon(1190, 335);
	discordIcon.addMouseEvent(() ->
	{
		if (selectedSomethin)
			return;

		switch (subState)
		{
			case discordScreen:
				if (!discordScreen.blocked) discordScreen.exit();

			case null: // default:
				changeItem(0, 2, false);
				openSubState(discordScreen);
		}
	}, () ->
		{
			if (selectedSomethin)
				return;

			// discordIcon.border.exists = true;
			switch (subState)
			{
				case discordScreen:
					if (discordScreen.phone.anim.curAnimName != "exit") // !discordScreen.blocked
						FlxG.sound.play(Paths.sound("scrollMenu"));

				case null: // default:
					changeItem(0, 2, true);
					discordIcon.setSelected(true);
			}
		}, () ->
		{
			if (selectedSomethin)
				return;

			// discordIcon.border.exists = false;
			switch (subState)
			{
				case null: // default:
					// changeItem(0, 2, false);
					discordIcon.setSelected(false);
			}
		});
	queuedNotif = (allSongsIsUnloked && locked.length != 0);
	add(discordIcon);
	menuItems[2].push(discordIcon);

	FlxG.mouse.visible = true;
	// Updating Discord Rich Presence
	#if DISCORD_RPC
	DiscordClient.changePresence("In the Menus", null);
	#end
	changeItem(0, curRow, false);

	if (isTitle)
	{
		FlxG.camera.scroll.y = 0;
		discordIcon.x -= discordHideOffset;
		discordIcon.alive = false;
	}
	else
	{
		if (jesus)
		{
			FlxG.camera.scroll.y = distance;
			discordIcon.setNotif(queuedNotif);
			selectedSomethin = false;
			buttons.x = bgPosX;
		}
		else
		{
			FlxG.camera.scroll.y = distance;
			selectedSomethin = true;
			FlxTween.num(buttons.x, bgPosX, 0.6, {ease: FlxEase.sineOut, onComplete: _ -> selectedSomethin = false}, buttons.set_x);
			FlxG.camera.scroll.x -= 300;
			FlxG.camera.zoom += 1.55;
			FlxTween.tween(FlxG.camera, {"scroll.x": FlxG.camera.scroll.x + 300, zoom: FlxG.camera.zoom - 1.55}, 0.7,
				{ease: FlxEase.smootherStepOut, onComplete: _ -> new FlxTimer().start(0.1, _ -> discordIcon.setNotif(queuedNotif))});
		}
		if (isBasketball)
		{
			FlxTween.num(0, spookyColorOffset, 2.6, null, o -> for (spr in bgGroup.members)
				spr.colorTransform.redOffset = spr.colorTransform.greenOffset = spr.colorTransform.blueOffset = o // 💘
			);
		}

		if (__globalScript__.getVar("lastStateClass") == PlayState)
		{
			FlxG.signals.preUpdate.addOnce(() ->
			{
				FlxG.sound.music.pitch = 0.5;
				var pitch = 1;
				var time = 0.4;
				if (isBasketball)
				{
					pitch = 0.4;
					time = 2;
					FlxG.sound.music.pitch *= pitch;
				}
				pitchMusic(pitch, time);
				if (__globalScript__.getVar("openDiscordSubMenu"))
				{
					openSubState(discordScreen);
					discordIcon.setSelected(true);
				}
				__globalScript__.setVar("openDiscordSubMenu", false);
			});
		}
		else if (isBasketball)
			pitchMusic(0.4, 2);
	}

	if (isShowingTexts)
	{
		FlxG.camera.zoom -= 0.75;
		var introSound = FlxG.sound.load(Paths.music("freakyMenuIntro"));
		introSound.onComplete = () -> FlxG.sound.music.play(true);
		FlxG.sound.music.pause();

		var blacky = new FlxBGSprite();
		blacky.color = FlxColor.BLACK;
		add(blacky);

		var maintext = new FlxText(0, 0, FlxG.width * 0.7, "", 16);
		maintext.setFormat(Paths.font("VCR OSD Mono Cyr.ttf"), 28, FlxColor.WHITE, "center"); // TODO: Заменить шрифт
		maintext.scrollFactor.set();
		maintext.alpha = 0;
		maintext.antialiasing = false; // a
		add(maintext);

		Main.fpsVar.alpha = 0;
		new FlxTimer().start(1, _ ->
		{
			var titleTexts:Array<String> = CoolUtil.coolTextFile(Paths.txt("titleTexts"));
			introSound.play();

			var key = null;
			var chan = FlxG.random.bool(20);
			var titleTextsArr = titleTexts;
			if (chan)
			{
				key = titleScreenEasterTextsKeys[FlxG.random.int(0, titleScreenEasterTextsKeys.length - 1)];
				titleTextsArr = titleScreenEasterTexts.get(key);
				maintext.alpha = 0.2;
			}
			var timers = [
				{time: 0.01},
				{time: 0.15},
				{time: 0.3},
				{time: 0.45},
				{time: 0.6},
				{time: 0.75},
				{time: 0.9},
				{time: 1.05},
				{time: 1.2},
				{time: 1.35},
				{time: 1.5},
				{time: 1.65},
				{time: 1.8},
				{time: 1.95},
				{time: 2.1},
				{time: 2.25},
				{time: 2.4, zoom: -0.45, text: "5"},
				{time: 2.75, zoom: 0.25, text: " 5РУ"},
				{time: 3, zoom: 0.35, text: "5РУБЛЕЙ"},
				{time: 3.15, zoom: -0.25, kill: true}
			];
			var prevTextId = -1;
			var onTimer = (_, timer) ->
			{
				FlxG.camera.zoom += (timer.zoom ?? 0.07);
				maintext.alpha += 0.07;
				if (timer.kill)
				{
					Main.fpsVar.alpha = 1;
					maintext.kill();
					blacky.kill();
					isShowingTexts = false;
					FlxG.camera.flash(FlxColor.WHITE, 0.8, null, true);
					updateMusicVolumeState();

				}
				else
				{
					if (timer.text == null)
					{
						var curTextId = FlxG.random.int(0, titleTextsArr.length - 1, prevTextId);
						if (chan)
						{
							if (timer.time <= 0.3 && key != null)
							{
								timer.text = key;
							}
							else
							{
								timer.text = titleTextsArr[curTextId].replace("\\n", "\n");
							}
						}
						else
						{
							timer.text = titleTextsArr[curTextId].replace("\\n", "\n");
						}
						prevTextId = curTextId;
					}
					else
						Main.fpsVar.alpha += 0.2;

					maintext.text = timer.text.toUpperCase();
					maintext.screenCenter();
				}
			}
			for (timer in timers)
				new FlxTimer().start(timer.time, onTimer.bind(_, timer));
		});
	}
	else if (jesus)
	{
		var flash = new game.objects.improvedFlixel.FlxBGSprite();
		FlxTween.num(1.5, 0, 3, {
			onCompleted: i -> remove(flash, true)
		}, flash.set_alpha);
		add(flash);
		var jesusSpr = new game.objects.improvedFlixel.FlxBGSprite();
		jesusSpr.loadGraphic(Paths.image("JesusWallpaper.jpg"));
		FlxTween.num(1.5, 0, 1.5, {
			onCompleted: i -> remove(jesusSpr, true)
		}, jesusSpr.set_alpha);
		add(jesusSpr);
		var flash = new game.objects.improvedFlixel.FlxBGSprite();
		FlxTween.num(0.25, 0, 1, {
			onCompleted: i -> remove(flash, true)
		}, flash.set_alpha);
		add(flash);
		flash.blend = ADD;
		FlxG.sound.play(Paths.sound("bell"), 1);
	}

	FlxG.signals.postUpdate.addOnce(() ->
	{
		if (!isShowingTexts && FlxG.sound.music.volume == 0)
			FlxG.sound.music.play(true);
		FlxG.sound.music.volume = musicVolume;
	});

	FlxG.signals.focusGained.add(focusOn);

	function onExitDeleteProgress()
	{
		discordIcon.alive = true;
		// discordIcon.alive = false;
		// discordIcon.x -= discordHideOffset;
		// FlxTween.num(discordIcon.x, discordIcon.x + discordHideOffset, 1.4,
		//	{ease: FlxEase.smootherStepInOut, onComplete: _ -> discordIcon.alive = true}, discordIcon.set_x);

		if (tomatotoma.alive)
			return;

		tomaRespawnTimer.start(FlxG.random.float(1.5, 3.5), _ ->
		{
			tomasVasBeaten = false;
			tomasSound.play();
			tomatotoma.revive();
			tomasGichaStart();
		});
	}

	deleteProgressScreen = new DeleteProgressSubState(() ->
	{
		discordIcon.alive = false;
		discordIcon.selected = false;
		// discordIcon.x -= discordHideOffset;

		if (tomasVasBeaten)
			return;

		tomasVasBeaten = true;
		trace("EXPLODE");
		var tomabombom = explodeTomsk(0.1).explSpr;
		tomasSound.pause();
		FlxG.camera.shake(0.003, 0.11);
		tomabombom.setPosition(tomatotoma.x, tomatotoma.y);
		tomabombom.setGraphicSize(tomatotoma.frameWidth, tomatotoma.frameHeight);
		tomabombom.updateHitbox();
		tomabombom.scale.x *= FlxG.random.float(1.8, 2.2);
		tomabombom.scale.y *= FlxG.random.float(4.6, 5.2);
	}, () -> // imaginary technique: EPIGANDO EXPLOSION!!!!
		{
			if (!crowd.alive)
				return;

			// фильтруем гандонов (так надо)
			var dudes = [];
			crowd.forEachAlive(dude -> dudes.push(dude));

			// FlxG.random.shuffle(dudes);
			var maxValidIndex = dudes.length - 1;
			for (i in 0...maxValidIndex)
			{
				var j = FlxG.random.int(i, maxValidIndex);
				var tmp = dudes[i];
				dudes[i] = dudes[j];
				dudes[j] = tmp;
			}

			// ВЗРЫВАЕМ ИХ НАХУЙ
			for (i => dude in dudes)
			{
				final boom = makeExplosion(dude.x, dude.y);
				boom.setGraphicSize(dude.frameWidth, dude.frameHeight);
				boom.updateHitbox();
				boom.scale.x *= FlxG.random.float(2.2, 2.6);
				boom.scale.y *= FlxG.random.float(2.2, 2.6);
				boom.animation.callback = (_, f, _) -> if (f >= 2 && dude.alive) dude.kill();
				// boom.onEndAnim.add(() ->
				boom.animation.finishCallback = _ ->
				{
					crowd.remove(boom, true);
					boom.animation.callback = null;
				} // );
				crowd.insert(crowd.members.indexOf(dude) + 1, boom);
				boom.active = boom.visible = false;

				new FlxTimer().start(0.2 * i + FlxG.random.float(-0.075, 0.075), _ ->
				{
					boom.active = boom.visible = true;
					FlxG.sound.play(Paths.sound("explosion"), 0.5);
					FlxG.camera.shake(0.003, FlxG.random.float(0.125, 0.2));
				});
			}

			allSongsIsUnloked = false;
			discordScreen.unlocked = false;
			discordIcon.setNotif(false);

			for (song in FlxG.save.data.rubles5UnlockedSong)
				Highscore.resetSong(song);

			FlxG.save.data.special.uc_encounter = null;
			FlxG.save.data.rubles5UnlockedSong = [];
			FlxG.save.data.seenDiscordFreeplayHelp = false;
			FlxG.save.flush();
			Main.saveIcon.show();
			crowd.alive = false;
			onExitDeleteProgress();
		}, onExitDeleteProgress);

	discordScreen = new DiscordSubState(allSongsIsUnloked, isBasketball, discordIcon, () ->
	{
		remove(discordIcon);
		discordScreen.add(discordIcon);
		discordIcon.camera = discordScreen.camera;
	}, () ->
		{
			discordScreen.remove(discordIcon);
			add(discordIcon);
			discordIcon.camera = FlxG.camera;
			selectedSomethin = false;
			changeItem(0, curRow, false);
		});

	/*
		var myVideoPlayer = new FlxVideoSprite();
		// var myVideoPlayer = new VideoSprite();
		myVideoPlayer.load(Paths.video("liryc sigma"));
		myVideoPlayer.bitmap.onFormatSetup.add(() -> {
			// trace("fuck");
			// FlxG.signals.preDraw.addOnce(() -> {
				// trace("fuck");
				// myVideoPlayer.setGraphicSize(myVideoPlayer.frameWidth / 2);
				// myVideoPlayer.clipRect = FlxRect.get(myVideoPlayer.frameWidth, myVideoPlayer.frameHeight);
			// });
		});
		add(myVideoPlayer);
		myVideoPlayer.play();
		myVideoPlayer.scrollFactor.set();
	 */
	/*for (i => row in menuItems)
		for (j => item in row)
			trace('\n\nrow: $i, index: $j, item: $item\n\n'); */
}

function launchCoolTomas()
{
	if (tomacool == null || tomaRespawnTimer.finished /*|| tomacool.alive*/)
		return;

	var time = 3, delay = 1;
	tomacool.setPosition(1600, 630);
	tomacool.scale.x = tomacool.scale.y = 0.8;
	tomacool.angle = -7.5;
	tomacool.revive();
	FlxTween.tween(tomacool, {
		x: -950,
		y: 1100,
		angle: 16,
		"scale.x": 1.2,
		"scale.y": 1.2
	}, time, {
		startDelay: delay,
		ease: FlxEase.quartInOut,
		onComplete: _ -> tomacool.kill(),
		onUpdate: t ->
		{
			var p = 0.5 - Math.abs(t.percent - 0.5);
			tomacoolSound.pan = p * 4 - 1;
			tomacoolSound.volume = p * 2;
		}
	});
	tomaRespawnTimer.time += time + delay;
}

function setupBgDoorSpr()
{
	var clipWidth = 112;
	var clipHeight = 162;
	bgDoorSpr.setPosition(buttons.x + 1123 - bgPosX, buttons.y + 532);

	bgDoorVoidSpr.setPosition(bgDoorSpr.x, bgDoorSpr.y);
	bgDoorVoidSpr.setGraphicSize(clipWidth, clipHeight);
	bgDoorVoidSpr.updateHitbox();

	bgDoorSpr.setGraphicSize(0, clipHeight);
	bgDoorSpr.updateHitbox();

	bgDoorSpr.clipRect.set(0, 0, Math.min(clipWidth, bgDoorSpr.width) / bgDoorSpr.scale.x, bgDoorSpr.frameHeight);
	bgDoorSpr.clipRect.x = (bgDoorSpr.frameWidth - bgDoorSpr.clipRect.width) / 2;
	bgDoorSpr.x -= bgDoorSpr.clipRect.x * bgDoorSpr.scale.x;
	bgDoorSpr.x += FlxMath.bound(clipWidth - bgDoorSpr.width, 0, clipWidth) / 2 / 1.25;
	// bgDoorSpr.screenCenter();

	updateMusicVolumeState();
}

function updateMusicVolumeState()
{
	var videoVolume = bgDoorVolume * (_doorVolumeTween?.value ?? (isTitle ? 0 : 1));
	if (isShowingTexts)
	{
		musicVolume = 0;
		videoVolume = 0;
	}
	#if VIDEOS_ALLOWED
	else if (!selectedSomethin && bgDoorSpr.exists && bgDoorSpr?.bitmap.isPlaying)
		musicVolume = 1 - videoVolume;
	#end
	else
		musicVolume = 1;
	#if VIDEOS_ALLOWED
	if (bgDoorSpr?.bitmap != null)
		bgDoorSpr.bitmap.volumeAdjust = videoVolume;
	#end
	FlxG.sound.music.volume = musicVolume;
}

var bgDoorSprSourcePath;

function doorEachCallback(name:String, frameNumber:Int, frameIndex:Int)
{
	switch name
	{
		case "break":
			if (frameNumber >= 3 && bgDoorSpr.exists)
			{
				stopDoorVideo();
				bgDoorVoidSpr.kill();
			}
	}
}

var cactusPath = "images/mainmenu/prikoli/brEkLc1gv1MnFYSd.mp4";
var cactusChanceDefault = 10;
var cactusChance = cactusChanceDefault;
function doorCallback(anim)
{
	switch anim
	{
		case "open":
			if ((isBasketball || bgDoorMemeMode || FlxG.random.bool(bgDoorRandomChance)) && randPicters.length > 0)
			{
				bgDoorRandomChance = bgDoorRandomChanceDefault;
				var randomThing;
				while (!bgDoorSpr.exists)
				{
					// if (FlxG.save.data.rubles5UnlockedSong.contains("under-construction") && !FlxG.save.data.rubles5UnlockedSong.contains("beatbox"))
					// {
						#if VIDEOS_ALLOWED
						randomThing = FlxG.random.bool(cactusChance) ? cactusPath : randPicters[FlxG.random.int(0, randPicters.length - 1)];
						#else
						randomThing = randPicters[FlxG.random.int(0, randPicters.length - 1)];
						#end
						cactusChance = randomThing == cactusPath ? cactusChanceDefault : cactusChance + 2;
					// }
					// else
					// 	randomThing = randPicters[FlxG.random.int(0, randPicters.length - 1)];

					if (bgDoorSprSourcePath == randomThing && randPicters.length != 1)
						continue;
					bgDoorSprSourcePath = randomThing;

					// bgDoorSpr.revive();
					bgDoorSpr.exists = true;
					// trace(randomThing, AssetsPaths.VIDEO_REGEX.match(randomThing));
					if (AssetsPaths.VIDEO_REGEX.match(randomThing)) // try to find video
					{
						#if VIDEOS_ALLOWED
						bgDoorSpr.makeGraphic(1, 1, FlxColor.TRANSPARENT);
						// trace(bgDoorSpr.bitmap.length);
						// if (Int64.gteInt(bgDoorSpr.bitmap.length, Math.floor(10 * 1000)))
						bgDoorSpr.load(AssetsPaths.getPath(randomThing), [VideoSprite.looping]);
						// bgDoorSpr.load(AssetsPaths.getPath(randomThing));
						bgDoorSpr.play();
						bgDoorLoadSpr.angle = FlxG.random.int(0, 360);
						bgDoorLoadSpr.exists = true;
						break;
						#else
						bgDoorSpr.exists = false;
						continue;
						#end
					}

					if (randomThing.startsWith("images/"))
						randomThing = randomThing.substring("images/".length, randomThing.length);
					if (Assets.exists(AssetsPaths.getPath('images/${PathUtil.withoutExtension(randomThing)}.xml'))) // try find sparrow atlas
					{
						try
						{
							bgDoorSpr.frames = Paths.getSparrowAtlas(PathUtil.withoutExtension(randomThing));
							CoolUtil.tryExportAllAnimsFromXmlFlxSprite(bgDoorSpr, null);
						}
						catch (e)
						{
							trace(e);
						}
						if (bgDoorSpr.animation.curAnim != null)
						{
							bgDoorSpr.animation.curAnim.looped = true;
							setupBgDoorSpr();
						}
						else
						{
							Log('Неправильно загружен Sparrow Atlas images/$randomThing.xml', TColor.RED);
							bgDoorSpr.exists = false;
							// bgDoorSpr.kill();
						}
					}
					else // try find image
					{
						var image = Paths.image(randomThing);
						if (image != null)
						{
							bgDoorSpr.loadGraphic(image);
							setupBgDoorSpr();
						}
						else
						{
							Log('Ненайдено изображение images/$randomThing', TColor.RED);
							bgDoorSpr.exists = false;
							// bgDoorSpr.kill();
						}
					}
				}
				bgDoorVoidSpr.revive();
			}
			else
			{
				bgDoorRandomChance += 2;
				bgDoorSpr.revive();
				bgDoorSpr.frames = Paths.getSparrowAtlas("mainmenu/irl");
				CoolUtil.tryExportAllAnimsFromXmlFlxSprite(bgDoorSpr, null);
				// if (bgDoorSpr.animation.curAnim != null)
				// {
					bgDoorSpr.animation.curAnim.looped = true;
					setupBgDoorSpr();
				// }
				// else
				// {
				// 	Log('Неправильно загружен Sparrow Atlas images/mainmenu/irl.xml', TColor.RED);
				// 	bgDoorSpr.kill();
				// }
			}
		case "idle":
			stopDoorVideo();
			bgDoorVoidSpr.kill();
	}
}

function stopDoorVideo()
{
	bgDoorSpr.exists = false;
	bgDoorLoadSpr.exists = false;
	#if VIDEOS_ALLOWED
	bgDoorSpr.parseStop();
	bgDoorSpr.stop();
	#end
	updateMusicVolumeState();

	// bgDoorVoidSpr.kill();
}

function onExists()
{
	selectedSomethin = true;
	if (bgDoorSprSourcePath == cactusPath && FlxG.save.data.rubles5UnlockedSong.contains("under-construction")) // избейние прикол
	{
		curSelected = 1;
		var levelName = "beatbox";
		var level = Song.loadFromJson(Highscore.formatSong(levelName, ""), levelName);
		if (level != null)
		{
			PlayState.SONG = level;
			PlayState.isStoryMode = false;

			FlxG.sound.music.stop();
			// if (ambient != null)
			// 	ambient.stop();

			LoadingState.loadAndSwitchState(#if EDITORS_ALLOWED FlxG.keys.pressed.SHIFT ? new ChartingState() : #end new PlayState());
			return;
		}
	}

	FlxG.sound.keysAllowed = false;
	var initVolume = FlxG.sound.volume;
	var music = FlxG.sound.music;
	music.setEffect('REVERB').setEffectVar('DECAY_TIME', 0, 0);
	music.setFilter("LOWPASS").setFilterVar("GAINHF", 1, 0);
	FlxTween.num(1, 0, 3.8, {}, i ->
	{
		music.setFilterVar("GAINHF", FlxMath.remapToRange(i, 0, 1, 0.2, 1), 0);
		music.setEffectVar('DECAY_TIME', (1 - i) * 6.5, 0);
		FlxG.sound.volume = initVolume * i;
	});
	camera.fade(FlxColor.BLACK, 3.5, false, () -> new FlxTimer().start(1.2, i ->
	{
		#if ios
		selectedSomethin = false;
		FlxG.sound.keysAllowed = true;
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
		#else
		Sys.exit();
		#end
	}));
}

var forMouseClick = false;

function focusOn()
{
	forMouseClick = true;
}

function destroy()
{
	updateMusicVolumeState();
	FlxG.mouse.visible = false;
	FlxG.signals.focusGained.remove(focusOn);
	deleteProgressScreen.destroy();
	discordScreen.destroy();
	explosionsGroup.destroy();
	tomasSound.destroy();
	tomasDeathYell.destroy();
	tomacoolSound?.destroy();
	if (isBasketball)
		FlxG.sound.music.pitch = 1; // pitchMusic(1, 0.8);
}

function pitchMusic(target:Float, time:Float, ?options:TweenOptions)
{
	if (FlxG.sound.music.pitch == target)
		return;

	var percent = 0;
	var tweenManager = FlxTween.globalManager; // __globalScript__.getVar("tweenManager");
	tweenManager.forEachTweensOf(FlxG.sound.music, ["pitch"], tween ->
	{
		percent = 1 - tween.percent;
		tween.cancel();
	});
	tweenManager.tween(FlxG.sound.music, {pitch: target}, time, options).percent = percent;
}

function tomasGichaStart()
{
	if (isBasketball)
		return;

	tomatotoma.acceleration.set();
	tomatotoma.x = 1200;
	tomatotoma.velocity.set(-FlxG.random.float(40, 80), 0);
	tomatotoma.y = distance + FlxG.random.float(5, 75);
}

function beatHit(beat:Int)
{
	if (isShowingTexts)
		return;

	titleSpr.animation.play("beat", true);
	if (subState == null)
	{
		if (isTitle)
			FlxG.camera.zoom += 0.02;
		else if (!isBasketball)
			FlxG.camera.zoom += 0.005;
	}

	/*crowd.forEachAlive(bud -> {
			if (FlxG.random.bool(2)) {
				bud.scale.x *= 1.1;
				bud.scale.y *= .95;
				FlxTween.tween(bud.scale, {y: 1, x: 1}, Conductor.stepCrochet / 500, {ease: FlxEase.elasticInOut});
			}
		}); // добейте мёртвых
	 */
}

var _tween:FlxTween;
var _doorVolumeTween:FlxTween;
var _buttonsTween:FlxTween;
var selectedSomethin:Bool = false;
var _tick:Float;

function vsynsLipAnimSpr(spr:FlxSprite)
{
	var curAnim = spr.animation?.curAnim;
	if (curAnim != null && curAnim.looped)
		curAnim.curFrame = Std.int(_tick % curAnim.numFrames);
}

function preUpdate(elapsed:Float)
{
	if (isShowingTexts)
		return;

	Conductor.songPosition = FlxG.sound.music?.time ?? 0;
	FlxG.camera.zoom = CoolUtil.fpsLerp(FlxG.camera.zoom, 1, 0.0475);

	// var camera = FlxG.camera;
	// camera.targetOffset.set(FlxG.mouse.x - camera.width / 2, FlxG.mouse.y - camera.height / 2);

	// if (FlxG.keys.justPressed.F5)
	// 	FlxG.switchState(new MusicBeatState("MenuState"));
	// FlxG.camera.followLerp = elapsed * 9 * (FlxG.updateFramerate / 60);
	if (subState == null)
	{
		if (!selectedSomethin)
		{
			if (!isBasketball && controls.RESET_R && FlxG.save.data.rubles5UnlockedSong.length != 0)
				FlxG.state.openSubState(deleteProgressScreen);

			if (isTitle)
				titleUpdate(elapsed);
			else
				mainUpdate(elapsed);
		}
		#if DEV_BUILD
		/*if (FlxG.keys.justPressed.TAB)
			{
				selectedSomethin = true;
				FlxG.state.openSubState(new FreeplayState(() -> selectedSomethin = false));
		}*/
		if (controls.DEBUG_1)
		{
			selectedSomethin = true;
			MusicBeatState.switchState(new game.states.editors.MasterEditorMenu());
		}
		/**
		 * K - Открывает все песни с фриплея
		 * ALT + K - Открывает обсолютно все песни
		 * ALT + U + K - Открывает все песни, за исключением под кострукции и переносит в специальное меню
		 */
		if (FlxG.keys.justPressed.K)
		{
			var newSongsList = songsList.copy();
			var alt = FlxG.keys.pressed.ALT;
			if (alt)
				newSongsList = newSongsList.concat(bonusSongList);
			var u = FlxG.keys.pressed.U;
			if (u)
				newSongsList.remove("under-construction");
			// trace(newSongsList);
			if (!alt || !u)
			{
				JesusWallpaper = true;
				FlxTransitionableState.skipNextTransIn = true;
			}
			FlxG.save.data.rubles5UnlockedSong = newSongsList;
			FlxG.save.data.seenDiscordFreeplayHelp = true;
			FlxG.save.flush();
			selectedSomethin = true;
			MusicBeatState.switchState(new MusicBeatState("MenuState"));
		}

		if (FlxG.keys.justPressed.M)
		{
			bgDoorMemeMode = !bgDoorMemeMode;
			FlxG.sound.play(Paths.sound(bgDoorMemeMode ? "buawawawawa" : "cancelMenu"), 0.6);
		}
		#end
	}
	tomaRespawnTimer.active = !isTitle;
}

function postUpdate(elapsed:Float)
{
	// if (bgDoorSpr.bitmap.isPlaying)
	// 	bgDoorSpr.setPosition(FlxG.mouse.x, FlxG.mouse.y);
	// а может похер?
	// - richTrash21
	// нет
	// - redar13
	_tick = FlxG.game.ticks * (1 / 24) * (6 / 10);
	forEachMenuItem(vsynsLipAnimSpr);

	if (!tomasVasBeaten && tomatotoma.x <= -350)
	{
		tomasVasBeaten = true;
		tomaRespawnTimer.start(FlxG.random.int(3, 12), _ ->
		{
			tomasVasBeaten = false;
			tomasGichaStart();
		});
	}

	var pan = (tomatotoma.x - FlxG.width / 3.5) / FlxG.width * 2;
	var vol = subState != null ? 0 : (1 - pan * pan) * 0.8 + (FlxG.camera.scroll.y - distance) / distance * 1.2;
	if (tomasVasBeaten)
	{
		tomasSound.pan = tomasSound.volume = 0;
		tomasDeathYell.pan = pan;
		tomasDeathYell.volume = vol;
	}
	else
	{
		tomasDeathYell.pan = tomasDeathYell.volume = 0;
		tomasSound.pan = pan;
		tomasSound.volume = vol;
	}
}

function titleUpdate(elapsed:Float)
{
	if (controls.ACCEPT || (!forMouseClick && FlxG.mouse.justPressed))
	{
		if (FlxG.sound.music == null || !FlxG.sound.music.active)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
		titleTextSpr.animation.play("press", true);
		titleTextSpr.centerOffsets();
		titleTextSpr.offset.y += 8;
		// if (ClientPrefs.flashing) FlxFlicker.flicker(titleTextSpr, 3, 0.075, true, true);

		FlxG.camera.zoom += 0.05;

		selectedSomethin = true;
		new FlxTimer().start(2, _ ->
		{
			isTitle = false;
			selectedSomethin = false;
			if (isBasketball)
			{
				pitchMusic(0.4, 2);
				FlxTween.num(0, spookyColorOffset, 2.4, {startDelay: 0.2}, o -> for (spr in bgGroup.members)
					spr.colorTransform.redOffset = spr.colorTransform.greenOffset = spr.colorTransform.blueOffset = o // 💘
				);
			}
		});
		_buttonsTween = doTween(_buttonsTween, FlxTween.num(buttons.x, bgPosX, 1, {
			startDelay: 2.5,
			ease: FlxEase.cubeInOut,
			onComplete: _ -> _buttonsTween = null
		}, buttons.set_x));
		_tween = doTween(_tween,
			FlxTween.num(0, distance, 3, {startDelay: 1, ease: FlxEase.cubeInOut, onComplete: _ -> _tween = null}, FlxG.camera.scroll.set_y));
		_doorVolumeTween = doTween(_doorVolumeTween,
			FlxTween.num(0, 1, 2.5, {startDelay: 2.5, ease: FlxEase.cubeInOut, onComplete: _ -> _doorVolumeTween = null}, i -> updateMusicVolumeState()));
		launchCoolTomas();

		discordIcon.tween(discordIcon.x, discordIcon.x + discordHideOffset, 1.6, {
			startDelay: 2,
			ease: FlxEase.smootherStepInOut,
			onComplete: _ ->
			{
				discordIcon.alive = true;
				discordIcon.setNotif(queuedNotif);
			}
		});
	}
	if (forMouseClick)
		forMouseClick = false;
}

function mainUpdate(elapsed:Float)
{
	if ((optionShit[curRow]?.length ?? 0) > 1)
	{
		if (!FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel != 0)
			changeItem(FlxMath.signOf(-FlxG.mouse.wheel), curRow, true);
		else if (controls.UI_UP_P)
			changeItem(-1, curRow, true);
		else if (controls.UI_DOWN_P)
			changeItem(1, curRow, true);
	}

	if (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel != 0)
		changeItem(0, curRow + FlxMath.signOf(-FlxG.mouse.wheel), true);
	else if (controls.UI_LEFT_P)
		changeItem(0, curRow - 1, true);
	else if (controls.UI_RIGHT_P)
		changeItem(0, curRow + 1, true);

	if (controls.BACK)
	{
		if (isBasketball)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			// nuh uh!!
			return;
		}

		selectedSomethin = true;
		titleTextSpr.animation.play("idle", true);
		titleTextSpr.centerOffsets();
		new FlxTimer().start(2.5, _ ->
		{
			isTitle = true;
			selectedSomethin = false;
		});

		_buttonsTween = doTween(_buttonsTween,
			FlxTween.num(buttons.x, FlxG.width, 2, {ease: FlxEase.cubeInOut, onComplete: _ -> _buttonsTween = null}, buttons.set_x));
		_tween = doTween(_tween, FlxTween.num(distance, 0, 3, {ease: FlxEase.cubeInOut, onComplete: _ -> _tween = null}, FlxG.camera.scroll.set_y));

		_doorVolumeTween = doTween(_doorVolumeTween,
			FlxTween.num(1, 0, 2, {ease: FlxEase.cubeInOut, onComplete: _ -> _doorVolumeTween = null}, i -> updateMusicVolumeState()));

		discordIcon.alive = false;
		discordIcon.tween(discordIcon.x, discordIcon.x - discordHideOffset, 1.6, {ease: FlxEase.smootherStepInOut});
	}

	if (controls.ACCEPT /*|| (!forMouseClick && FlxG.mouse.justPressed)*/)
	{
		onAccept();
	}
}

function onAccept()
{
	switch curRow
	{
		case 2:
			discordIcon.setSelected(true);
			openSubState(discordScreen);

		default:
			var selection = optionShit[curRow][curSelected];
			if (selection.canBreak
				&& (isBasketball
					|| selection.name == "exit"
					&& bgDoorSprSourcePath == PathUtil.withoutExtension("images/mainmenu/bgDoor_uc")) // прикол
			)
			{
				// убить кнопку
				var spr = menuItems[curRow][curSelected];
				if (spr.alive)
				{
					spr.alive = false;
					spr.playAnim("break");
					FlxTween.shake(spr, 0.015, 0.1);
					FlxG.camera.shake(0.001, 0.1, null, true, X);
					FlxG.sound.play(Paths.sound("buttonBreak"));
				}
				return;
			}

			if (selection.locked)
			{
				var spr = menuItems[curRow][curSelected];
				if (spr != null && spr.animation.name != "lockedClicked" && spr.playAnim("lockedClicked"))
					FlxG.sound.play(Paths.sound("cancelMenu"));

				return;
			}

			var toState = (selection.switchFunc == null ? null : selection.switchFunc());
			if (toState != null && toState.stateClass != null)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
				selectedSomethin = true;

				new FlxTimer().start(1, _ -> FlxG.switchState(Type.createInstance(toState.stateClass, toState.args ?? [])));

				var selected = menuItems[curRow][curSelected];
				if (ClientPrefs.flashing)
					FlxFlicker.flicker(selected, 1, 0.075, false, true);

				forEachMenuItem(spr -> if (spr != selected) FlxTween.num(spr.alpha, 0, 0.4, {ease: FlxEase.quadOut}, spr.set_alpha));
			}
	}
}

function changeItemByIndex(index = 0, row = 0, doSound = true, ignoreLocked = false)
{
	var spr = menuItems[curRow][curSelected];
	if (spr != discordIcon)
		playAnimOnCurFrame(spr, "idle");

	var originalRow = row;
	var maxIndexRow = menuItems.length - 1;
	var moveLeftRow = (index < curRow);
	if (row == 0 && curRow == maxIndexRow)
		moveLeftRow = false;
	else if (row == maxIndexRow && curRow == 0)
		moveLeftRow = true;

	var originalIndex = index;
	var maxIndex = menuItems[row].length - 1;
	var moveUp = (index < curSelected);
	if (index == 0 && curSelected == maxIndex)
		moveUp = false;
	else if (index == maxIndex && curSelected == 0)
		moveUp = true;

	spr = menuItems[row][index];
	while (!spr.alive || (!ignoreLocked && (optionShit[row] != null && optionShit[row][index].locked)))
	{
		index = FlxMath.wrap(moveUp ? --index : ++index, 0, menuItems[row].length - 1);
		if (index == originalIndex)
		{
			// trace(row + " недоступен");
			row = FlxMath.wrap(moveLeftRow ? --row : ++row, 0, menuItems.length - 1);
			originalIndex = index = FlxMath.wrap(index, 0, menuItems[row].length - 1);
			if (row == originalRow)
			{
				trace("ого бесконечный луп, рич (это я) еще больший гандон!");
				return;
			}
		}
		spr = menuItems[row][index];
	}

	if (curSelected == index && curRow == row)
		doSound = false;

	if (spr != null && spr != discordIcon)
	{
		var oldAnim = spr.animation.curAnim;
		playAnimOnCurFrame(spr, "selected");
		if (oldAnim == spr.animation.curAnim)
			doSound = false;
	}
	buttons.members.sort((a, b) -> a.ID == (row * 10 + index) ? 1 : 0);

	var onIcon = row == 2;
	discordIcon.border.exists = onIcon;
	discordIcon.setSelected(onIcon);

	curRow = row;
	curSelected = index;
	if (doSound)
		FlxG.sound.play(Paths.sound("scrollMenu"));
}

function playAnimOnCurFrame(spr:TwistSprite, anim:String)
{
	if (!spr.alive)
		return;
	var transAnim = switch anim
	{
		case "selected": "open";
		case "idle": "close";
		default: null;
	}
	if (transAnim == null || !spr.playAnim(transAnim, false, false))
		spr.playAnim(anim, false, false);
}

function changeItem(huh = 0, row = 0, doSound:Bool = true)
{
	row = FlxMath.wrap(row, 0, menuItems.length - 1);
	var index = FlxMath.wrap(curSelected + huh, 0, menuItems[row].length - 1);
	changeItemByIndex(index, row, doSound);
}

function doTween(oldTween:FlxTween, newTween:FlxTween):FlxTween
{
	if (oldTween != null)
	{
		// newTween.percent = (1 - oldTween.percent);
		oldTween.cancel();
	}
	return newTween;
}

function explodeTomsk(?volume:Float = 0.5)
{
	var boom = makeExplosion(tomatotoma.x - 100 - tomatotoma.origin.x, tomatotoma.y - 100 - tomatotoma.origin.y);
	boom.scale.set(5.5, 3.5);
	boom.updateHitbox();
	boom.centerOffsets();
	boom.animation.callback = (_, f, _) -> if (f >= 2 && tomatotoma.alive) tomatotoma.kill();
	// boom.onEndAnim.add(() ->
	boom.animation.finishCallback = _ ->
	{
		remove(boom, true);
		boom.animation.callback = null;
		boom.scale.set(1, 1);
		boom.updateHitbox();
		// boom.offset.set();
	} // );
	addAheadObject(boom, tomatotoma);
	var sound = FlxG.sound.play(Paths.sound("explosion"), volume);
	sound.pan = (tomatotoma.x - FlxG.width / 3.5) / FlxG.width * 2;
	return {
		explSpr: boom,
		explsound: sound
	};
}

// https://cdn.discordapp.com/attachments/1292841644990926920/1299704849365073941/intro_lol_we_rushed_the_fuck_out_of_this_mod_sry.mp4?ex=672ab237&is=672960b7&hm=bd80dc96bb4dc50e933549bc67de37a55978aace5d77099cde2100961df2cb04&
function recycleExplosion()
	return new ExplosionSprite();

function makeExplosion(x = 0, y = 0):ExplosionSprite
{
	var s = explosionsGroup.recycle(null, recycleExplosion);
	s.setPosition(x, y);
	s.animation.play("boom");
	return s;
}

class DeleteProgressSubState extends FlxSubState
{
	var tomsk:TwistSprite;
	var window:TwistSprite;
	var windowText:FlxSprite;

	var buttonNo:TwistSprite;
	var buttonYes:TwistSprite;
	var buttonNoText:FlxSprite;
	var buttonYesText:FlxSprite;

	var delete:Bool = true;
	var blocked = true;
	var selected = false;

	var onOpen:() -> Void;
	var onConfirm:() -> Void;
	var onCancel:() -> Void;

	public function new(onOpen:() -> Void, onConfirm:() -> Void, onCancel:() -> Void)
	{
		super(FlxColor.BLACK);
		this.onOpen = onOpen;
		this.onConfirm = onConfirm;
		this.onCancel = onCancel;
	}

	override public function create()
	{
		super.create();

		window = new TwistSprite(58.55, 27.8);
		window.scrollFactor.set();
		window.frames = Paths.getSparrowAtlas("clean_progress/window");
		window.addAnimation("intro", "окно появление", null, [177, 88]);
		window.addAnimation("idle", "окно статичное", null, null, 24, 0, true);
		window.animation.finishCallback = n -> if (n == "intro") window.playAnim("idle", false, false, 2);

		windowText = new FlxSprite(129.45, 118.4);
		windowText.scrollFactor.set();
		windowText.frames = Paths.getSparrowAtlas("clean_progress/delete");
		windowText.animation.addByPrefix("idle", "русская сделка с чертом текст", 24);
		windowText.animation.play("idle");

		buttonNo = new TwistSprite(442.65, 548.35);
		buttonNo.scrollFactor.set();
		buttonNo.frames = Paths.getSparrowAtlas("clean_progress/buttons");
		buttonNo.addAnimation("intro", "кнопка появление право", null, [11, 83]);
		buttonNo.addAnimation("idle", "кнопка статичность", null, null, 24, 0, true, true);
		// buttonNo.addAnimation("idle", "кнопка статичность АНИМЕЙТ ХУЙНЯ ЕБАНАЯ БЛЯТЬ", null, null, 24, 0, true); // правду говорбю вам, правду
		buttonNo.addAnimation("selected", "кнопка выбирание", null, [7, 5], 24, 0, true, true);
		buttonNo.animation.finishCallback = n -> if (n == "intro")
		{
			buttonNoText.color = toggleButton(buttonNo, !delete).color;
			FlxTween.num(0, 1, 2 / 24, null, buttonNoText.set_alpha);
		}

		buttonYes = new TwistSprite(105.25, 548.35);
		buttonYes.scrollFactor.set();
		buttonYes.frames = Paths.getSparrowAtlas("clean_progress/buttons");
		buttonYes.addAnimation("intro", "кнопка появление лево", null, [16, 100]);
		buttonYes.addAnimation("idle", "кнопка статичность", null, null, 24, 0, true);
		buttonYes.addAnimation("selected", "кнопка выбирание", null, [2, 5], 24, 0, true);
		buttonYes.animation.finishCallback = n -> if (n == "intro")
		{
			buttonYesText.color = toggleButton(buttonYes, delete).color;
			FlxTween.num(0, 1, 2 / 24, {onComplete: _ -> blocked = false}, buttonYesText.set_alpha);
		}

		buttonNoText = new FlxSprite(507.45, 590.65);
		buttonNoText.scrollFactor.set();
		buttonNoText.frames = Paths.getSparrowAtlas("clean_progress/selection");
		buttonNoText.animation.addByPrefix("idle", "нет русский0", 24);
		buttonNoText.animation.addByPrefix("selected", "нет русский выбор", 24);
		buttonNoText.animation.play("idle");

		buttonYesText = new FlxSprite(159.95, 581.85);
		buttonYesText.scrollFactor.set();
		buttonYesText.frames = Paths.getSparrowAtlas("clean_progress/selection");
		buttonYesText.animation.addByPrefix("idle", "да русский0", 24);
		buttonYesText.animation.addByPrefix("selected", "да русский выбор", 24);
		buttonYesText.animation.play("idle");

		tomsk = new TwistSprite(736.05, -21.75);
		tomsk.scrollFactor.set();
		tomsk.frames = Paths.getSparrowAtlas("clean_progress/tom");
		tomsk.addAnimation("intro", "Том появление", null, [63, 43]);
		tomsk.addAnimation("idle", "том статичность", null, null, 24, 0, true); // девственность? она самая
		tomsk.addAnimation("yes", "том да", null, [30, 56], 24, 6, true);
		tomsk.addAnimation("no", "том нет", null, [-40, -8], 24, 6, true);
		tomsk.animation.finishCallback = n -> if (n == "intro") tomsk.playAnim("idle", false, false, 4);

		add(buttonNo);
		add(buttonNoText);
		add(buttonYes);
		add(buttonYesText);
		add(window);
		add(windowText);
		add(tomsk);

		FlxMouseEvent.add(buttonNo, _ -> if (!blocked) accept(), null, _ -> if (!blocked) switchButtons(false), null, false, true, false);
		FlxMouseEvent.add(buttonYes, _ -> if (!blocked) accept(), null, _ -> if (!blocked) switchButtons(true), null, false, true, false);

		openCallback = () ->
		{
			// перезапускаем значения
			delete = true;
			blocked = true;

			// еще немного
			window.offset.set();
			windowText.offset.set();
			buttonNo.offset.set();
			buttonYes.offset.set();
			buttonNoText.offset.set();
			buttonYesText.offset.set();
			tomsk.offset.set();
			buttonNoText.animation.play("idle", true);
			buttonYesText.animation.play("idle", true);
			buttonNo.color = buttonNoText.color = !delete ? FlxColor.WHITE : FlxColor.GRAY;
			buttonYes.color = buttonYesText.color = delete ? FlxColor.WHITE : FlxColor.GRAY;

			// и начинаем интро
			buttonNo.playAnim("intro", true);
			buttonYes.playAnim("intro", true);
			window.playAnim("intro", true);
			tomsk.playAnim("intro", true);
			buttonNoText.alpha = 0;
			buttonYesText.alpha = 0;
			windowText.alpha = 0;
			windowText.offset.y = -16;
			FlxTween.tween(windowText, {"offset.y": 0, alpha: 1}, 6 / 24, {startDelay: 2 / 24});
			FlxTween.color(null, 7 / 24, FlxColor.BLACK, 0xAB000000, {startDelay: 1 / 24, onUpdate: t -> bgColor = t.color});
			FlxG.sound.play(Paths.sound("Lights_Turn_On")).pitch = FlxG.random.float(1.2, 1.8);
			onOpen();
		}
	}

	override function tryUpdate(elapsed:Float)
	{
		super.tryUpdate(elapsed);

		if (blocked)
			return;

		if (controls.BACK)
		{
			blocked = true;
			selected = false;
			delete = false;
			FlxG.sound.play(Paths.sound("cancelMenu"));
			exit();
			return;
		}

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			switchButtons(!delete);
		else if (controls.ACCEPT)
			accept();
	}

	function accept()
	{
		blocked = true;
		selected = true;
		if (delete)
		{
			FlxG.sound.play(Paths.sound("confirmMenu"), 0.6);
			buttonYesText.animation.play("selected");
			buttonYesText.centerOffsets();
			buttonNoText.offset.x += 6;
			tomsk.playAnim("yes");
		}
		else
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			buttonNoText.animation.play("selected");
			buttonNoText.centerOffsets();
			buttonNoText.offset.x += 6;
			tomsk.playAnim("no");
		}
		new FlxTimer().start(tomsk.animation.curAnim.numFrames * tomsk.animation.curAnim.frameDuration * 1.8, t -> exit());
	}

	function switchButtons(isDelete:Bool)
	{
		if (delete != isDelete)
			FlxG.sound.play(Paths.sound("scrollMenu"));

		delete = isDelete;
		buttonNoText.color = toggleButton(buttonNo, !delete).color;
		buttonYesText.color = toggleButton(buttonYes, delete).color;
	}

	function toggleButton(butt:TwistSprite, toggle:Bool)
	{
		butt.playAnim(toggle ? "selected" : "idle", false, false, butt.animation.curAnim.curFrame);
		butt.color = toggle ? FlxColor.WHITE : FlxColor.GRAY;
		return butt;
	}

	function exit()
	{
		final time = (8 / 24);
		final offset = 710;
		FlxTween.tween(buttonNo.offset, {y: offset}, time, {ease: FlxEase.cubeIn});
		FlxTween.tween(buttonNoText.offset, {y: offset}, time, {ease: FlxEase.cubeIn});
		FlxTween.tween(buttonYes.offset, {y: offset}, time, {ease: FlxEase.cubeIn});
		FlxTween.tween(buttonYesText.offset, {y: offset}, time, {ease: FlxEase.cubeIn});
		FlxTween.tween(window.offset, {y: offset}, time, {ease: FlxEase.cubeIn});
		FlxTween.tween(windowText.offset, {y: offset}, time, {ease: FlxEase.cubeIn});
		FlxTween.tween(tomsk.offset, {x: -560}, time, {ease: FlxEase.cubeIn});
		FlxTween.color(null, time, bgColor, FlxColor.TRANSPARENT, {
			onUpdate: t -> bgColor = t.color,
			onComplete: _ ->
			{
				if (selected && delete)
					onConfirm();
				else
					onCancel();

				close();
			}
		});
	}
}

class DiscordSubState extends FlxSubState
{
	static final SCALE = 1280 / 1920;
	static final MAX_BLUR_SIZE = 10;

	var isBasketball:Bool;
	var unlocked:Bool;
	var curSelected = 0;
	var curSelectedValid = 0;

	var bg:FlxSprite;
	var phone:FlxAnimate;
	var container:FlxGroup;
	var icon:DiscordIcon;
	var timeArray:Array<FlxSprite>;
	var stream:FlxSprite;

	var week:WeekData;
	var weekAss:WeekData;
	var selectionBg:FlxSprite;
	var selectionText:FlxSprite;
	var selectionList:Array<SongSelection>;

	var blocked = true;
	var blockedAss = false;
	var dateTimer = 0;
	var bgTween:FlxTween;
	var ambient:FlxSound;

	var onOpen:() -> Void;
	var onClose:() -> Void;

	var _lastBlurSize = 0;
	var _blurScrTween:FlxTween;
	var _blurScrShader:FlxRuntimeShader;
	var _blurScrFilter:ShaderFilter;
	var _lastToogleBlurScr = false;
	var _lastSelectedSpr:FlxSprite = null;

	public function new(unlocked:Bool, isBasketball:Bool, icon:DiscordIcon, onOpen:() -> Void, onClose:() -> Void)
	{
		super();
		this.unlocked = unlocked;
		this.isBasketball = isBasketball;
		this.icon = icon;
		this.onOpen = onOpen;
		this.onClose = onClose;

		WeekData.reloadWeeksFiles(true);
		week = WeekData.weeksDatas.get("weeks/5rublesBONUS.json");
		weekAss = WeekData.weeksDatas.get("weeks/ass.json");

		// отдельная камера нужна для блюра основной
		camera = FlxG.cameras.add(new FlxCamera(), false);
		camera.bgColor = FlxColor.TRANSPARENT;
		persistentUpdate = true;

		ambient = this.isBasketball ? FlxG.sound.load(Paths.sound("discord/ambientUC"), 0, true) : null;

		_blurScrShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("BlurCamera")));
		_blurScrFilter = new ShaderFilter(_blurScrShader);
	}

	override public function create()
	{
		super.create();

		var path = "mainmenu/discord";
		bg = new FlxSprite(0, 0, Paths.image('$path/vignette${isBasketball ? "_uc" : ""}'));
		bg.alpha = 0;
		bg.camera = camera;

		phone = new FlxAnimate(1188.95, 331.15, AssetsPaths.getPath('images/$path/phone'));
		var prefix = isBasketball ? "uc_" : "";
		phone.anim.addByFrameLabel("intro", prefix + "on", 0, null, false);
		phone.anim.addByFrameLabel("idle", prefix + "loop");
		phone.anim.addByFrameLabel("exit", prefix + "off", 0, null, false);
		phone.anim.onFrame.add((n, _, f) ->
		{
			switch (n)
			{
				case "intro":
					if (f > 19) container.exists = true;
			}
		});
		phone.anim.onComplete.add((n, _) ->
		{
			switch (n)
			{
				case "intro":
					toggleMouseInput(unlocked);
					phone.anim.play("idle");
					container.exists = true;
					selectionBg.exists = true;

				case "exit":
					onClose();
					close();
			}
		});
		scaleAtlas(phone);

		// анимейт хуйня кста
		var scaleFix = 1 - (0.7 - SCALE) * 1.4;
		function fixSpriteScale(spr:FlxSprite)
		{
			spr.scale.set(scaleFix, scaleFix);
			spr.updateHitbox();
		}

		container = new FlxGroup();
		container.exists = false;

		// if (unlocked)
		// TODO: суппорт скролла????

		selectionBg = new FlxSprite(0, 0, Paths.image('$path/friend_bg'));
		fixSpriteScale(selectionBg);
		container.add(selectionBg);
		selectionBg.exists = false;
		selectionBg.visible = false;

		selectionList = [];
		var frames = Paths.getSparrowAtlas('$path/friends');
		var x = 774.45 * SCALE;
		var y = 383.95 * SCALE;
		var unlockedSongs = FlxG.save.data.rubles5UnlockedSong;
		for (i => song in week.data.songs)
		{
			var name = Highscore.formatSong(song.songName, "");
			var beaten = unlockedSongs.contains(name);
			var allowed = switch (song.extraFields?.condition)
			{
				case "uc": isBasketball || beaten;
				default: !isBasketball;
			}
			if (!allowed)
				continue;

			var frameID = i * 2;
			var selection = new SongSelection(x, y, frames, song, selectionList.length);
			setSpriteFrame(selection, unlockedSongs.contains(name) ? frameID + 1 : frameID);
			fixSpriteScale(selection);
			selection.y += (selection.height + 5) * selection.ID;
			selection.alpha = 0;
			selection.camera = camera;
			selectionList.push(container.add(selection));
			FlxMouseEvent.add(selection, _ -> loadLevel(_), null, _ -> changeAt(_.ID), _ -> changeAt(-1), false, true, false);
		}

		var last = selectionList[selectionList.length - 1];
		var selectionEnd = new FlxSprite(795.95 * SCALE, last == null ? y : last.y + last.height + 20 * SCALE, Paths.image('$path/no_friends'));
		fixSpriteScale(selectionEnd);

		stream = new FlxSprite(786.9 * SCALE, 244.1 * SCALE);
		stream.frames = Paths.getSparrowAtlas('$path/streams');
		fixSpriteScale(stream);
		stream.camera = camera;
		FlxMouseEvent.add(stream, _ -> randomStream(true), null, null, null, false, true, false);

		selectionText = new FlxSprite(771.45 * SCALE, 830 * SCALE);
		selectionText.frames = Paths.getSparrowAtlas('$path/selection');
		fixSpriteScale(selectionText);

		container.add(selectionEnd);
		container.add(stream);
		container.add(selectionText);
		selectionEnd.alpha = stream.alpha = selectionText.alpha = 0;

		phone.anim.onComplete.add((n, _) ->
		{
			if (!unlocked)
				return;

			switch (n)
			{
				case "intro":
					randomStream(false);
					setSpriteFrame(selectionText, 0);

					var time = 7 / 24;
					FlxTween.num(selectionEnd.alpha, 1, time, {ease: FlxEase.sineOut}, selectionEnd.set_alpha);
					FlxTween.num(stream.alpha, 1, time, {ease: FlxEase.sineOut}, stream.set_alpha);
					FlxTween.num(selectionText.alpha, 1, time, {ease: FlxEase.sineOut}, selectionText.set_alpha);

					var delay = 3 / 24;
					var offset = 7.5 * SCALE;
					var maxIndex = selectionList.length - 1;
					for (selection in selectionList)
					{
						var options = {startDelay: delay * selection.ID, ease: FlxEase.sineOut};
						if (selection.ID == maxIndex)
							options.onComplete = _ ->
							{
								blocked = false;
								changeAt(curSelected);
							}

						selection.y -= offset;
						FlxTween.tween(selection, {alpha: 1, y: selection.y + offset}, time, options);
					}

				case "exit":
					selectionEnd.alpha = stream.alpha = selectionText.alpha = 0;
					for (selection in selectionList)
						selection.alpha = 0;
					selectionBg.visible = false;
			}
		});

		// if (!unlocked)
		var loading = new FlxAnimate(922.8, 421.05, AssetsPaths.getPath('images/$path/loading'));
		loading.anim.addBySymbol("idle", "loading");
		loading.anim.play("idle");
		scaleAtlas(loading);
		loading.alpha = 0;

		phone.anim.onComplete.add((n, _) ->
		{
			if (unlocked)
				return;

			switch (n)
			{
				case "intro":
					var offset = 14 * SCALE;
					loading.y -= offset;
					FlxTween.tween(loading, {y: loading.y + offset, alpha: 1}, 4 / 24, {
						ease: FlxEase.sineOut,
						onComplete: _ -> blocked = false
					});

				case "exit":
					loading.alpha = 0;
			}
		});
		container.add(loading);

		timeArray = new Array();
		var frames = Paths.getSparrowAtlas('$path/time');
		var x = 794.05 * SCALE;
		var y = 98.45 * SCALE;
		for (i in [0, 0, 10, 0, 0, 11])
		{
			var spr = new FlxSprite(x, y);
			spr.frames = frames;
			setSpriteFrame(spr, i);
			fixSpriteScale(spr);
			timeArray.push(container.add(spr));
			x += spr.width / 2 + 1.5;
		}

		add(bg);
		add(phone);
		add(container);

		openCallback = () ->
		{
			toggleMouseInput(false);
			blocked = true;
			updateTime();

			var time = (isBasketball ? 51 : 8) / 24;
			bgTween = FlxTween.num(bg.alpha, 1, time, {startDelay: 5 / 24, onComplete: _ -> bgTween = null}, bg.set_alpha);
			phone.anim.play("intro");
			if (ambient != null)
				ambient.fadeIn(time);
			FlxG.sound.music.fadeOut(time * 3, isBasketball ? 0.2 : 0.6);
			FlxG.sound.play(Paths.sound("discord/openSfx"));

			FlxG.camera.setFilters([_blurScrFilter]);
			FlxG.camera.filtersEnabled = ClientPrefs.shaders;
			toggleBlurScreen(true, time);
			onOpen();
		}
	}

	function toggleMouseInput(status:Bool)
	{
		for (selection in selectionList)
			selection.alive = status;
		stream.alive = status;
	}

	override function tryUpdate(elapsed:Float)
	{
		super.tryUpdate(elapsed);

		dateTimer += elapsed;
		if (dateTimer >= 60)
			updateTime();

		camera.zoom = FlxG.camera.zoom;
		camera.alive = subState == null;
		if (blocked || !camera.alive)
			return;

		if (controls.BACK)
		{
			exit();
			return;
		}

		if (!unlocked)
			return;

		if (_lastSelectedSpr != null)
		{
			changeAt(_lastSelectedSpr.ID);
			_lastSelectedSpr = null;
		}

		if (FlxG.keys.justPressed.SPACE)
			randomStream(true);

		#if DEV_BUILD
		if (FlxG.keys.pressed.ALT)
		{
			var key = FlxG.keys.firstJustPressed();
			if (key >= FlxKey.ONE && key <= (FlxKey.ONE + weekAss.data.songs.length - 1))
				loadJopotr4ss(key - FlxKey.ONE);
		}
		#end

		if (!isBasketball && FlxG.keys.justPressed.CONTROL)
			openSubState(new GameplayChangersSubstate());

		if (curSelected != -1 && controls.ACCEPT && !FlxG.keys.justPressed.SPACE)
			loadLevel(selectionList[curSelected]);
		else if (controls.UI_UP_P)
			change(-1);
		else if (controls.UI_DOWN_P)
			change(1);
	}

	override public function openSubState(subState:FlxSubState)
	{
		super.openSubState(subState);
		subState.camera = camera;
	}

	function loadLevel(selection:SongSelection)
	{
		if (blocked)
			return;

		try
		{
			blocked = true;
			loadLevelFromData(selection.data);
		}
		catch (e)
		{
			blocked = false;
			Log(e, TColor.RED);
		}

		if (blocked)
		{
			FlxG.camera.zoom += 0.03;
			camera.zoom = FlxG.camera.zoom;
			FlxG.sound.music.stop();
			if (ambient != null)
				ambient.stop();

			var frameID = selection.frames.frames.indexOf(selection.frame);
			if (frameID % 2 == 0)
			{
				icon.setNotif(false);
				selection.frame = selection.frames.frames[frameID + 1];
			}

			var sound = FlxG.sound.play(Paths.sound("discord/pressFunky"));
			sound.pitch = isBasketball ? 0.5 : 1;
			var time = sound.length / 1000 / sound.pitch * 0.85;
			new FlxTimer().start(time,
				_ -> LoadingState.loadAndSwitchState(#if EDITORS_ALLOWED FlxG.keys.pressed.SHIFT ? new ChartingState() : #end new PlayState()));

			if (ClientPrefs.flashing)
				FlxFlicker.flicker(selection, time + 0.4, 0.075, false, true);

			for (spr in selectionList)
			{
				if (spr != selection)
					FlxTween.num(spr.alpha, 0, 0.4, {ease: FlxEase.quadOut}, spr.set_alpha);
			}
		}
	}

	function loadLevelFromData(data:SongMetaData)
	{
		if (data == null)
			throw 'Null level data';

		var levelName = Highscore.formatSong(data.songName, "");
		#if DEV_BUILD
		trace(levelName);
		#end
		var level = Song.loadFromJson(levelName, data.songName);
		if (level == null)
			throw 'Song "$levelName" failed to load';

		PlayState.SONG = level;
		PlayState.isStoryMode = false;
	}

	function exit()
	{
		if (_requestedSubState != null)
			_requestedSubState.destroy();
		_requestedSubState = null;

		toggleMouseInput(false);
		blocked = true;
		container.exists = false;

		// var percent = 0;
		if (bgTween != null)
		{
			// percent = 1 - bgTween.percent;
			bgTween.cancel();
		}

		var time = (isBasketball ? 11 : 7) / 24;
		bgTween = FlxTween.num(bg.alpha, 0, time, {onComplete: _ -> bgTween = null}, bg.set_alpha);
		// bgTween.percent = percent;
		phone.anim.play("exit"); // так же триггерит закрытие меню по завершении анимации
		FlxG.sound.play(Paths.sound("discord/closeSfx"));
		if (ambient != null)
			ambient.fadeOut(time, 0, _ -> ambient.pause());
		FlxG.sound.music.fadeIn(time, FlxG.sound.music.volume * 0.6);

		icon.alive = false;
		new FlxTimer().start(2 / 24, _ ->
		{
			icon.alive = true;
			icon.playAnim("exit");
		});
		toggleBlurScreen(false, time);
	}

	function change(add:Int)
	{
		changeAt(FlxMath.wrap(curSelectedValid + add, 0, selectionList.length - 1));
	}

	function changeAt(index:Int)
	{
		if (blocked)
		{
			_lastSelectedSpr = selectionList[index];
			return;
		}

		curSelected = index;

		if (curSelected == -1)
		{
			setSpriteFrame(selectionText, 0);
			selectionBg.visible = false;
		}
		else
		{
			FlxG.sound.play(Paths.sound("discord/selectSfx"));
			var selection = selectionList[curSelected];
			selectionBg.setPosition(selection.x + (selection.width - selectionBg.width) / 2, selection.y + (selection.height - selectionBg.height) / 2 + 2.5);
			selectionBg.visible = true;
			setSpriteFrame(selectionText, week.data.songs.indexOf(selection.data) + 1); // никакого баскетболла 😭
			curSelectedValid = curSelected;
		}
	}

	function updateTime()
	{
		var date = Date.now();
		var hours = date.getHours();
		var minutes = date.getMinutes();
		dateTimer = date.getSeconds();
		// trace(date);

		// часы
		var hoursTwelve = hours % 12;
		setSpriteFrame(timeArray[0], Math.floor(hoursTwelve / 10) % 10);
		setSpriteFrame(timeArray[1], hoursTwelve % 10);

		// минуты
		setSpriteFrame(timeArray[3], Math.floor(minutes / 10) % 10);
		setSpriteFrame(timeArray[4], minutes % 10);

		// до/после полудня?
		setSpriteFrame(timeArray[5], (hours > 11) ? 12 : 11);
	}

	function setSpriteFrame(spr:FlxSprite, f:Int)
	{
		spr.frame = spr.frames.frames[f];
	}

	function randomStream(easteregg:Bool)
	{
		if (blockedAss)
			return;

		if (easteregg && stream.frames.frames.indexOf(stream.frame) == 3)
			loadJopotr4ss();
		else
			setSpriteFrame(stream, isBasketball ? 4 : FlxG.random.int(0, stream.frames.numFrames - 1, [4, stream.frames.frames.indexOf(stream.frame)]));
	}

	function loadJopotr4ss(?id:Int)
	{
		try
		{
			blockedAss = blocked = true;

			if (id == null)
			{
				// не даем заходить заново в пройденные миксы
				var exclude = [];
				for (i => data in weekAss.data.songs)
				{
					var name = Highscore.formatSong(data.songName, "");
					if (FlxG.save.data.rubles5UnlockedSong.contains(name))
					{
						exclude.push(i);
						// trace(i, name);
					}
				}
				// все миксы пройдены - да будет полный рандом!
				if (exclude.length == weekAss.data.songs.length)
				{
					exclude = null;
					trace("абсолют жопотряс!");
				}
				id = FlxG.random.int(0, weekAss.data.songs.length - 1, exclude);
			}

			loadLevelFromData(weekAss.data.songs[id]);

			FlxG.sound.music.stop();
			if (ambient != null)
				ambient.stop();

			LoadingState.loadAndSwitchState(#if EDITORS_ALLOWED FlxG.keys.pressed.SHIFT ? new ChartingState() : #end new PlayState());
		}
		catch (e)
		{
			blockedAss = blocked = false;
			Log('error: $e, id: $id', TColor.RED);
		}
	}

	function scaleAtlas(spr:FlxAnimate)
	{
		spr.scale.set(SCALE, SCALE);
		spr.x *= spr.scale.x;
		spr.y *= spr.scale.y;
		spr.updateHitbox();
	}

	function onUpdateScreenBlur(i:Float)
	{
		_lastBlurSize = i;
		_blurScrShader.setFloatArray("blurSize", [i, i]);
	}

	function toggleBlurScreen(toggle:Bool, time:Float)
	{
		if (_lastToogleBlurScr == toggle)
			return;

		_lastToogleBlurScr = toggle;
		_blurScrTween?.cancel();
		_blurScrTween = FlxTween.num(_lastBlurSize, toggle ? MAX_BLUR_SIZE : 0, time, {onComplete: _ -> _blurScrTween = null}, onUpdateScreenBlur);
	}
}

class DiscordIcon extends FlxAnimate
{
	static var SCALE = 1280 / 1920;

	var notif = false;
	var selected = false;
	var border:FlxSprite;
	var _tween:FlxTween;

	public function new(x = 0, y = 0)
	{
		border = new FlxSprite(1180.95, -92.35);
		border.frames = Paths.getSparrowAtlas("mainmenu/discord/icon/border");
		border.animation.addByPrefix("idle", "border anal", 24);
		border.animation.play("idle");
		border.scale.x = border.scale.y = 1 - (0.7 - SCALE) * 1.4;
		border.x *= border.scale.x;
		border.y *= border.scale.y;
		border.updateHitbox();
		border.exists = false;
		border.scrollFactor.set();

		super(x, y, AssetsPaths.getPath("images/mainmenu/discord/icon"));
		// anim.addByFrameLabel("idle", "не наведен без уведомлений", 0, null, false);
		anim.addBySymbolIndices("idle", "_ATLAS_discord_button", [0], 0, false);
		// anim.addByFrameLabel("selected", "наведен без уведомлений", 0, null, false);
		anim.addBySymbolIndices("selected", "_ATLAS_discord_button", [1], 0, false);
		anim.addByFrameLabel("exit", "выход с меню без уведомления", 0, null, false);
		// anim.addByFrameLabel("idle_notif", "не наведен с уведомлением", 0, null, false);
		anim.addBySymbolIndices("idle_notif", "_ATLAS_discord_button", [27], 0, false);
		// anim.addByFrameLabel("selected_notif", "наведен с уведомлением", 0, null, false);
		anim.addBySymbolIndices("selected_notif", "_ATLAS_discord_button", [28], 0, false);
		anim.addByFrameLabel("exit_notif", "выход с уведомлением", 0, null, false);
		// анюзед контент ЛМАОООО
		// anim.addByFrameLabel("locked", "=ЗАБЛОКИРОВАНО=", 0, null, false);
		// anim.addBySymbolIndices("locked", "_ATLAS_discord_button", [2], 0, false);
		anim.addByFrameLabel("notif", "анимация уведомления", 0, null, false);
		// скорее всего тоже не будет использоваться лол
		anim.addByFrameLabel("idle_notif_gone", "НЕ НАВЕДЕН пропажа уведомления", 0, null, false);
		anim.addByFrameLabel("selected_notif_gone", "НАВЕДЕН пропажа уведомления", 0, null, false);
		anim.play("idle");
		scale.x = scale.y = SCALE;
		this.x *= scale.x;
		this.y *= scale.y;
		updateHitbox();
		scrollFactor.set();

		anim.onComplete.add((n, _) ->
		{
			switch (n)
			{
				case "notif":
					playAnim(selected ? "selected" : "idle");

				case "exit_notif":
					playAnim("idle");
					selected = false;
				// border.exists = selected;

				case "idle_notif_gone" | "exit":
					anim.play("idle");
					selected = false;
				// border.exists = selected;

				case "selected_notif_gone":
					anim.play("selected");
					selected = true;
					// border.exists = selected;
			}
		});
	}

	public function addMouseEvent(onMouseDown:() -> Void, onMouseOver:() -> Void, onMouseOut:() -> Void)
	{
		var onMouseDown = onMouseDown;
		var onMouseOver = onMouseOver;
		var onMouseOut = onMouseOut;
		FlxMouseEvent.add(this, _ -> onMouseDown(), null, _ -> onMouseOver(), _ -> onMouseOut(), false, true, false);
	}

	public function tween(from:Float, to:Float, time:Float, options:TweenOptions)
	{
		if (_tween != null)
			_tween.cancel();

		if (options == null)
			options = {onComplete: _ -> _tween = null};
		else
		{
			var old_onComplete = options.onComplete;
			options.onComplete = _ ->
			{
				_tween = null;
				if (old_onComplete != null)
					old_onComplete(_);
			}
		}

		_tween = FlxTween.num(from, to, time, options, set_x);
	}

	public function setNotif(value:Bool)
	{
		if (notif != value)
		{
			// border.exists = value ? false : selected;
			anim.play(value ? "notif" : ((selected ? "selected" : "idle") + "_notif_gone"));
			notif = value;
		}
	}

	public function setSelected(value:Bool)
	{
		// приоритезация анимаций получения/пропажи уведомления
		if (!anim.finished && (anim.curAnimName.startsWith("exit") || anim.curAnimName.contains("notif")))
		{
			selected = value;
			return;
		}

		if (selected != value)
		{
			playAnim(value ? "selected" : "idle");
			selected = value;
			// border.exists = selected;
		}
	}

	public function playAnim(name:String)
	{
		anim.play(notif ? name + "_notif" : name);
	}

	override public function update(elapsed:Float)
	{
		if (border.exists)
			border.update(elapsed);
		super.update(elapsed);
	}

	override public function draw()
	{
		if (border.exists)
		{
			border.draw();
			border.setPosition(x - 1180.95 * SCALE, y - 92.35 * SCALE);
		}
		super.draw();
	}

	override public function destroy()
	{
		if (border != null)
		{
			border.destroy();
			border = null;
		}
		super.destroy();
	}

	override function set_alpha(value:Float):Float
		return border.alpha = super.set_alpha(value);
}

class SongSelection extends FlxSprite
{
	public var data:SongMetaData;

	public function new(x = 0, y = 0, frames:FlxFramesCollection, data:SongMetaData, ID:Int)
	{
		super(x, y);
		this.frames = frames;
		this.data = data;
		this.ID = ID;
	}
}
