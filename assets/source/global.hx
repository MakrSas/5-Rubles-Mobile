import game.backend.system.states.MusicBeatState;
import game.objects.openfl.FlxGlobalTween;
import game.objects.openfl.FlxGlobalTimer;
import game.backend.utils.Controls;
// import game.states.MenuState; // TODO: перенести на сурс?

import flixel.util._FlxSignal.FlxSignal2; // flixel.util.FlxSignal
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
// import flixel.tweens.FlxTweenManager;
// import flixel.util.FlxTimerManager;

#if (DEV_BUILD && DISCORD_RPC)
import game.backend.system.net.DiscordClient;

function preChangeDSPresence(?details:String, ?state:String, ?endTimestamp:Float, ?activity)
{
	if (DiscordClient.clientID != "1237760396455055360")
		return;

	var presence = DiscordClient.presence;
	presence.state = "Разработка фанкин";
	presence.details = null;
	// activity.largeText = activity.largeText ?? DiscordClient.config.largeImageText;
	presence.largeImageKey = "https://s10.gifyu.com/images/SYcfF.png";
	presence.largeImageText = null;
	presence.button1Label = presence.button2Label = presence.button1Url = presence.button2Url = null;
	presence.startTimestamp = presence.endTimestamp = 0;
	DiscordClient.dirtyUpdate = true;
	return Function_Stop;
}
#end

public var INPUT_DEFAULT = 0; // pc
public var INPUT_XBOX = 1;
public var INPUT_PLAYSTATION = 2;
public var INPUT_MOBILE = 3;
public var inputType = INPUT_DEFAULT;
public var inputTypeChange = new FlxSignal2();

function preUpdate(elapsed:Float)
{
	// обновить Controls.instance.controllerMode
	Controls.instance.get_ANY();

	var prevInput = inputType;
	inputType = if (FlxG.onMobile)
	{
		INPUT_MOBILE;
	}
	else if (Controls.instance.controllerMode)
	{
		switch (FlxG.gamepads.firstActive.detectedModel)
		{
			case FlxGamepadModel.PS4 | FlxGamepadModel.PSVITA:
				INPUT_PLAYSTATION;
			default:
				INPUT_XBOX;
		}
	}
	else
	{
		INPUT_DEFAULT;
	}

	if (inputType != prevInput)
	{
		function inputTypeToString(input:Int)
		{
			return switch input
			{
				case INPUT_XBOX: "[XBOX]";
				case INPUT_PLAYSTATION: "[PLAYSTATION]";
				case INPUT_MOBILE: "[MOBILE]";
				default: "[PC]";
			}
		}
		Log("inputType changed from " + inputTypeToString(prevInput) + " to " + inputTypeToString(inputType));
		inputTypeChange.dispatch(prevInput, inputType);
	}
}

// store the last state class for some complicated bullshit
public var lastStateClass:Class<FlxState>;
public var openDiscordSubMenu:Bool = false;
// tween managers that doesn't clear itselves after a state switch, use with caution!
public var tweenManager = FlxGlobalTween.globalManager;
public var timerManager = FlxGlobalTimer.globalManager;

var redirectStates:Map<Class<FlxState>, EitherType<String, Class<FlxState>>> = [
	MainMenuState => "MenuState"
];

function preStateSwitch()
{
	lastStateClass = Type.getClass(FlxG.game._state);

	for (redirectState in redirectStates.keys())
		if (Std.isOfType(FlxG.game._nextState, redirectState))
		{
			FlxG.game._nextState.destroy();
			var replacement = redirectStates.get(redirectState);
			FlxG.game._nextState = (replacement is String) ? new MusicBeatState(replacement) : Type.createInstance(replacement, []);
			break;
		}
}

public var updateData:Dynamic = null;

function onFoundedUpdate(dataNewBuild) {
	updateData = dataNewBuild;
	return Function_Stop;
}

function preGameStart()
{
	// tweenManager = new FlxTweenManager();
	// timerManager = new FlxTimerManager();
	// FlxG.signals.preStateSwitch.remove(tweenManager.clear);
	// FlxG.signals.preStateSwitch.remove(timerManager.clear);
	// FlxG.plugins.addPlugin(tweenManager);
	// FlxG.plugins.addPlugin(timerManager);

	// var clown = new FlxSprite();
	// clown.scrollFactor.set();
	// clown.checkEmptyFrame();
	// clown.setGraphicSize(FlxG.width, FlxG.height);
	// clown.updateHitbox();
	// FlxG.plugins.addPlugin(clown);

	FlxG.save.data.special ??= {}; // для хранения особых одноразовых флагов
	FlxG.save.data.rubles5UnlockedSong ??= [];

	#if (FLX_MOUSE && FLX_NO_TOUCH)
	var e = Paths.image("мышка", null, false);
	if (e != null)
	{
		FlxG.bitmap.removeKey(e.key);
		FlxG.mouse.load(e.bitmap, 1, -1, -1);
	}
	#end
}

function postGameStart()
{
	FlxG.signals.preStateSwitch.addOnce(() ->
	{
		var old_checkIsUsing = Main.transition.checkIsUsing;
		Main.transition.checkIsUsing = (i, curTransition) ->
		{
			// редирект на переход рублей
			if (curTransition.indexOf(".StickersTransition") != -1)
				curTransition = "game.objects.transitions.TapeTransition";

			return old_checkIsUsing(i, curTransition);
		}
	});
}
