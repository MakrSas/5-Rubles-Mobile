import game.objects.improvedFlixel.FlxFixedText;
import game.backend.system.audio.EffectSound;
import game.backend.utils.Highscore;
import game.backend.utils.HttpUtil;
import game.mobile.utils.TouchUtil;
#if DISCORD_RPC
import game.backend.system.net.DiscordClient;
#end

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.tweens.FlxTweenType;

import flxanimate.data.Loop;
import flxanimate.FlxAnimate;

import haxe.xml.Access;

var isUC = Highscore.formatSong(PlayState.SONG.song, "") == "under-construction";
var showArtist = StringTools.startsWith(Highscore.formatSong(PlayState.SONG.song, ""), "jopotr4ss") && FlxG.save.data.completedOneOfJopotr4ss == true;
// trace(showArtist, Highscore.formatSong(PlayState.SONG.song, ""), FlxG.save.data.completedOneOfJopotr4ss);
static var ucSymbol = "ЭКСПОРТ/сиськи/баскетболл";

/*
	{
		text: "Hello world",
		onCreate: (origText) -> {
			return null; // при нулле совет меняется на другой
		}
		onUpdate: (origText, elapsed) -> {
			return null; // при нулле используется обычный текст из совета
		}
	}
 */

/**
 * Внимание!
 * Данные ники не будут видны всем желающим, так как в релиз билде все скрипты будут встроенны в игру и небудут в файлах.
 */
static var familiarPeople = [
	// Ник в дискорде => Обычный ник

	"kalail"		=> "Калайл",
	"mopspler"		=> "Максплеер",
	"rocky888"		=> "Рокки.\nКак этот мод может быть лучше марио маднесса?",
	"cleancosmos"	=> "Cosmos! when direct",
	"phantomarcade3k"=> "PHANTOM ARCADE???!!! ШТООООО ЕБАААТАЬЬЬ",
	"ninja_muffin99"	=> "NinjaMuffin. FIX YOUR GAME!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
	"penkaru"		=> "Penkaru. поиграй в рубле",
	"humst_star"	=> "HUMST HUMST HUMST HUMST HUMST HUMST HUMST",
	"dumer."		=> "Думер",
	"dastgum"		=> "Дастер",
	"mmotyaa_"		=> "Мотя, пошли варить мет",
	"thesnowgrave"	=> "Ерка",
	"stardanae"	=> "Danae. no construction * is for faggots",
	"winterghfasc"	=> "Винтер зимний зима",
	"ssktrockbug"	=> "Funkin news make post about meee MAKE ME POPLULAR",
	"o_mathew_o."	=> "Матвейм ур мур",
	"huhqrio"		=> "Глеб Триугольник",
	"aironus"		=> "Айрон",
	"dinebon_ "	=> "Динебон",
	"funniguy342"	=> "Funni. я фанат я фана",
	"jengdezant"	=> "Jeng",
	"peacock6k"	=> "Peacock6k",
	"2ape0"		=> "Peacock6k",
	"sisins2004"=> "Сиквенс",
	"distixing" => "Дисктикс",
	"poelkefirom"=> "Кефир Вася",
	"psenkoks"  => "Псенкокс",
	"cleancosmos"=>"Сосмоs",
	"scorpion105951"=>"тупой аниме дрочер",
	"meffzo"		=>"матрасс -135 градусов хуе шифт",
	"voidee_gane"	=>"войд моя козочка",
	"nickngcarchive"=>"ник нгс ушедший из фнф комьюинити",
	"literallyfys"	=>"фус файс фис",

	// Девы
	"amalgamat"		=> "Аналшахмат",
	"bruh_leebert"	=> "Либерт",
	"d4rkwinged"	=> "темные крылошки кфс", // ТёмноКрылый
	"g3hree"		=> "Георга",
	"hopka_opka"	=> "пи-до-рок)",
	"juztexd"		=> "Эругису Буратофу",
	"kersive."		=> "Керсив",
	"lostel"		=> "мы не заслужили тебя, Лостель...",
	"magmansplace"	=> "папочка магмен",
	"matr4ss"		=> "Матр4эсэс",
	"mistikaltacc"	=> "Свей", // алт акк
	"naisonji"		=> "пац",
	"pivozavrik69"	=> "Сайааныч",
	"pukovich1"		=> "Алекслей Нокиевич",
	"pursnake"	=> "Змеинный", // Змеинный
	"redar13"		=> "Редан13",
	"richtrash21"	=> "БогатыйМусор21",
	"rofos_hristo"	=> "Рофос", // Руфус
	"salted_marm"	=> "Свей", // Солевой
	"simnsnd"		=> "Симон, а что это за игра?",
	"skarler.yeah"	=> "Скайлер",
	"xiavier_"		=> "ксавье",
	"sector_5"		=> "Сектор. Ello gentlemen",
];
static var peopleMessages = [
	"Привет, <user>",
];

var rubleExchangeRate = null;
var searchRubleExchangeRate = false;
var tips = [
	{
		text: "",
		onCreate: (origText) -> {
			#if DISCORD_RPC
			var key = DiscordClient.user?.username;
			if (key != null && familiarPeople.exists(key))
				return StringTools.replace(peopleMessages[FlxG.random.int(0, peopleMessages.length - 1)], "<user>", familiarPeople.get(key));
			#end
			return null;
		}
	},
	{
		text: "1 Доллар США = ",
		onCreate: (origText) -> {
			if (rubleExchangeRate == null && !searchRubleExchangeRate)
			{
				searchRubleExchangeRate = true;
				HttpUtil.aSyncRequestText("https://www.cbr-xml-daily.ru/daily_utf8.xml").onComplete(rawResult -> {
					try
					{
						var xmlResult = Xml.parse(rawResult).firstElement();

						for (child in xmlResult.children)
						{
							if (child.nodeType == 0 && child.nodeName == "Valute" && child.attributeMap.get("ID") == "R01235") // находит по курсу доллара
							{
								for (child in child.children)
								{
									if (child.nodeType == 0 && child.nodeName == "Value")
									{
										rubleExchangeRate = StringTools.replace(child.firstChild().nodeValue, ",", ".") + " рубля";
										break;
									}
								}
								break;
							}
						}
						if (rubleExchangeRate == null)
							throw "Ненайдено";
					}
					catch (e)
					{
						Log(e, TColor.RED);
						searchRubleExchangeRate = false;
						rubleExchangeRate = "хз";
					}
				});
			}
			return origText;
		},
		onUpdate: (origText, elapsed) -> {
			return origText + (rubleExchangeRate ?? "хз");
		}
	},
	/*
	{
		text: "Привет",
		onCreate: (origText) -> {
			#if DISCORD_RPC
			if (DiscordClient.user?.globalName != null)
				return '$origText, ${DiscordClient.user.globalName}';
			#end
			return origText;
		}
	},
	*/
	{
		text: "ВХОД ВОРОНЕЖ",
		onUpdate: (origText, elapsed) -> return StringTools.rpad(origText, ".", Std.int(origText.length + (FlxG.game.ticks / 300) % 4))
	},
	{
		text: "Для получения .lua скриптов нажмите {X}.",
		onUpdate: (origText, elapsed) ->
		{
			if (FlxG.onMobile)
				return "Здесь были .lua скрипты, они кончились...";

			if (FlxG.keys.justPressed.P || FlxG.gamepads.anyJustPressed(FlxGamepadInputID.B))
				CoolUtil.browserLoad("https://www.youtube.com/watch?v=YAgJ9XugGBo");

			return StringTools.replace(origText, "{X}", switch __globalScript__.getVar("inputType")
			{
				case __globalScript__.getVar("INPUT_XBOX"):
					"(B)";
				case __globalScript__.getVar("INPUT_PLAYSTATION"):
					"(O)";
				default:
					"[P]";
			});
		}
	},
	{
		text: "Совет: у вас есть {X}, чтобы играть в FNF",
		// onCreate: (origText) -> FlxG.random.bool(10) ? StringTools.replace(origText, "{X}", "руки") : origText,
		onUpdate: (origText, elapsed) ->
		{
			return StringTools.replace(origText, "{X}", switch __globalScript__.getVar("inputType")
			{
				case __globalScript__.getVar("INPUT_XBOX") | __globalScript__.getVar("INPUT_PLAYSTATION"):
					"контроллер";
				case __globalScript__.getVar("INPUT_MOBILE"):
					"экран";
				default:
					"клавиатура";
			});
		}
	},
	{
		text: "Совет: нажми на {X}. ПРЯМО СЕЙЧАС",
		onUpdate: (origText, elapsed) ->
		{
			return StringTools.replace(origText, "{X}", switch __globalScript__.getVar("inputType")
			{
				case __globalScript__.getVar("INPUT_XBOX"):
					"(Y)";
				case __globalScript__.getVar("INPUT_PLAYSTATION"):
					"(ТРЕУГОЛЬНИК)";
				case __globalScript__.getVar("INPUT_MOBILE"):
					"> МЕНЯ <"; // "текст"
				default:
					"[ПРОБЕЛ]";
			});
		}
	},
];

var txtTipsPath = AssetsPaths.getPath("data/loadingTips.txt");
if (true && Assets.exists(txtTipsPath))
{
	for (i in CoolUtil.unixNewLine(Assets.getText(txtTipsPath)).split("\n"))
	{
		i = StringTools.trim(i);
		if (i.length > 0)
			tips.push({
				text: StringTools.replace(i, "\\n", "\n")
			});
	}
}

/*static*/ var tipsUC = [
	{
		text: "Пойдём поиграем в баскетболл?",
		onCreate: origText -> return FlxG.random.bool(10) ? origText + "\nСосал?" : origText
	}
];

var currentTips = isUC ? tipsUC : tips;
var curTip:Dynamic;
var malishi:FlxAnimate;
var loading:FlxSprite;
var pressEnter:FlxAnimate;
var musicShit:EffectSound;
var advice:FlxFixedText;
var confirm = false;
var loadingFont:String = null;

function resolveLoadingFont():String
{
	for (fontPath in [
		Paths.font('comicbd.ttf'),
		Paths.font('defaultPsych/vcr.ttf')
	])
	{
		try
		{
			if (Assets.exists(fontPath))
				return fontPath;
		}
		catch (e) {}
	}
	return "_sans";
}

function applyLoadingFont(text:FlxFixedText, size:Int, alignment:String):Void
{
	if (loadingFont == "_sans")
		text.setFormat("_sans", size, 0xffffffff, alignment, null, FlxColor.TRANSPARENT, false);
	else
		text.setFormat(loadingFont, size, 0xffffffff, alignment);
}

function create()
{
	// Simon - у меня загрузка не черная а серая
	// Matr4Ss - каждый билд пяти рублей персонализирован
	FlxG.camera.bgColor = FlxColor.BLACK;
	loadingFont = resolveLoadingFont();

	defaultStatsText = new FlxFixedText(0, 20, 0, "huh?");
	applyLoadingFont(defaultStatsText, 20, "right");
	add(defaultStatsText);

	advice = new FlxFixedText(0, 0, 0, "huh?");
	applyLoadingFont(advice, 23, "center");
	add(advice);
	reloadAdvice();
	updateAdvicePosition();

	musicShit = EffectSound.load(Paths.music(isUC ? "ucambience" : "loadinshit"), 0, true);
	musicShit.play(musicShit.length / 2);
	musicShit.fadeIn(isUC ? 2.5 : 1.5, 0, 0.8);

	loading = new FlxSprite(52.35, 649);
	loading.frames = Paths.getSparrowAtlas("loadingscreen/loading");
	loading.animation.addByPrefix("idle", "лоадинг", 24, true);
	loading.animation.play("idle");
	add(loading);

	pressEnter = new FlxAnimate(47.35, 578.7, AssetsPaths.getPath("images/loadingscreen/press"));
	var confirmFrames = [for (i in 16...38) i];
	for (i => platform in ["", "xbox ", "playstation ", "mobile "])
	{
		var symbol = "EXPORT/" + platform + "continue";
		pressEnter.anim.addBySymbol('idle$i', symbol);
		pressEnter.anim.addBySymbolIndices('confirm$i', symbol, confirmFrames, 0, false);
	}
	pressEnter.anim.play("idle" + __globalScript__.getVar("inputType"));
	pressEnter.alpha = 0;
	add(pressEnter);
	__globalScript__.getVar("inputTypeChange").add(pressChangeType);

	malishi = new FlxAnimate(1039.05, 538.7, AssetsPaths.getPath("images/loadingscreen/siski"));
	reloadPidor(isUC ? ucSymbol : null);
	add(malishi);
}

function pressChangeType(prevType:Int, newType:Int)
{
	pressEnter.anim.play(pressEnter.anim.curAnimName.substr(0, pressEnter.anim.curAnimName.length - 1) + newType, false, false, pressEnter.anim.curFrame);
}

function destroy()
{
	__globalScript__.getVar("inputTypeChange").remove(pressChangeType);
}

function reloadAdvice()
{
	curTip = currentTips[FlxG.random.int(0, currentTips.length - 1, currentTips.length > 1 ? [currentTips.indexOf(curTip)] : null)];
	if (curTip.onCreate != null)
	{
		var fromFuncText = curTip.onCreate(curTip.text);
		if (fromFuncText != null)
			advice.text = fromFuncText;
		else
			reloadAdvice();
	}
	else
	{
		advice.text = curTip.text;
	}
	if (advice.text.length > 0)
		advice.scale.x = Math.min((FlxG.width - 500) / advice.width, 1.0);
}

function updateAdvicePosition()
{
	advice.screenCenter(X);
	advice.y = 648.35 - Math.max(advice.height - advice.size, 0) / 1.7;
}

var listSymbols:Array<String>;
function reloadPidor(?anim:String)
{
	if (listSymbols == null)
	{
		listSymbols = [];
		var layer = malishi.anim.symbolDictionary.get("EXPORT ATLAS");
		// layer.getElement(0, FlxG.random.int(0, layer.length - 1));
		var layer = layer.timeline.getList()[0];
		for (j in 0...layer.length)
		{
			for (i in layer.get(j).getList())
			{
				var name = i.symbol?.name;
				if (name != null && name.length > 0)
				{
					malishi.anim.addAnimation(name, name, 0, true, null, i.matrix.tx, i.matrix.ty);
					listSymbols.push(name);
				}
			}
		}
		// var pisa:FlxElement = layer.get(rand).get(0);
		// trace(layer.get(rand).getList());
		// trace([for (i in layer.get(rand).getList()) i.symbol.name]);
		// trace(layer.timeline.getListNames());
		// trace(layer.timeline.getList()[0]);
		// trace(pisa);
		// trace(pisa.matrix, pisa.symbol.name);
	}

	if (anim == null)
	{
		var exclude = [listSymbols.indexOf(malishi.anim.curAnimName)];
		if (!isUC)
			exclude.push(listSymbols.indexOf(ucSymbol));
		anim = listSymbols[FlxG.random.int(0, listSymbols.length - 1, exclude)];
	}
	malishi.anim.play(anim, true);
	malishi.anim.curFrame = FlxG.random.int(0, malishi.anim.length - 1);
	// malishi.setPosition(1039.05 + pisa.matrix.tx, 538.7 + pisa.matrix.ty);
}

function preUpdate(elapsed:Float)
{
	#if DEV_BUILD
	if (FlxG.keys.justPressed.R || (TouchUtil.justPressed && TouchUtil.overlapsComplex(malishi)) || FlxG.gamepads.anyJustPressed(FlxGamepadInputID.X))
	{
		reloadPidor();
	}
	#end
	if (FlxG.keys.justPressed.SPACE || (TouchUtil.justPressed && TouchUtil.overlapsComplex(advice)) || FlxG.gamepads.anyJustPressed(FlxGamepadInputID.Y))
	{
		reloadAdvice();
	}
	if (curTip.onUpdate != null)
	{
		advice.text = curTip.onUpdate(curTip.text, elapsed) ?? curTip.text;
	}
	updateAdvicePosition();
	if (defaultStatsText != null)
	{
		var loaded = callbacks.length - callbacks.numRemaining;
		var maxLoad = callbacks.length;
		var percent = maxLoad == 0 ? "0" : Std.string(Math.round(loaded / maxLoad * 100.0)); // FlxMath.roundDecimal(loaded / maxLoad * 100.0, 2)

		/*var dotIndex = percent.indexOf(".");
		if (dotIndex == -1)
			percent += ".00";
		else if (percent.length - dotIndex - 1 < 2)
			percent += "0";*/

		var daText = 'Song: ${PlayState.SONG.display}';
		if (showArtist)
			daText += ' (${PlayState.SONG.artist})';
		daText += '\n$percent%';
		#if DEV_BUILD
		daText += ' ($loaded / $maxLoad)';
		#end
		if (confirm)
		{
			daText += '\nDone!';
		}
		#if DEV_BUILD
		else
		{
			daText += '\nCurrent Asset Load:\n' + (callbacks?.curID ?? "|X|");
		}
		#end
		if (daText != defaultStatsText.text)
		{
			defaultStatsText.text = daText;
			// defaultStatsText.screenCenter(X);
			defaultStatsText.x = Math.max(20, FlxG.width - defaultStatsText.width - 20);
			// defaultStatsText.y = FlxG.height - defaultStatsText.height - 20;
		}
	}
}

function onCompleted()
{
	musicShit.stop();
	funcsPrepare.clearArray();

	ClientPrefs.cacheOnGPU = oldGPUCacheAllowed;
	onComplete(this);
	transitioning = true;
}

function onLoaded()
{
	if (!transitioning && canLeave)
	{
		if (!confirm)
		{
			loading.animation.pause();

			FlxTween.tween(loading, {y: loading.y + 200}, 0.5, {ease:FlxEase.cubeInOut});
			FlxTween.tween(pressEnter, {alpha: 1}, 0.5, {ease:FlxEase.cubeInOut});
			FlxTween.tween(pressEnter, {y: pressEnter.y + 200}, 0.5, {ease:FlxEase.cubeInOut, type: BACKWARD});
			confirm = true;
		}
		if (FlxG.keys.justPressed.ENTER || (controls.ACCEPT && !FlxG.keys.justPressed.SPACE) || (TouchUtil.justPressed && !TouchUtil.overlapsComplex(advice)))
		{
			pressEnter.anim.play("confirm" + __globalScript__.getVar("inputType"));
			if (isUC)
			{
				musicShit.fadeOut(3.5, 0, _ -> new FlxTimer().start(1.5, _ -> onCompleted()));
				FlxTween.tween(musicShit, {pitch: 0.1}, 3.5, {ease: FlxEase.cubeInOut});
				camera.fade(FlxColor.BLACK, 2.5, false, onCompleted);

				// FlxTween.num(Main.fpsVar.alpha, 0, 2.4, null, Main.fpsVar.set_alpha);
				// FlxG.signals.preStateCreate.addOnce(i -> {
				// 	Main.fpsVar.alpha = 1.0;
				// 	trace("a");
				// });
			}
			else
			{
				musicShit.setFilter("LOWPASS");
				musicShit.setFilterVar("GAINHF", 1.0, 0);
				FlxTween.num(1, 0, 0.7, null, musicShit.setFilterVar.bind("GAINHF", _, 0));
				camera.fade(FlxColor.BLACK, 1., false, onCompleted);
				musicShit.fadeOut(0.9, 0);
			}
		}
	}
}
