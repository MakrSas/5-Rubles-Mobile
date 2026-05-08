package game.backend.utils;

import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import haxe.Timer;

#if ALLOW_HAPTICS
import extension.haptics.Haptic;
#end

class GamepadUtil
{
	static inline final SUSTAIN_COOLDOWN_MS:Float = 70;
	static var _lastSustainPulseAt:Float = -100000.0;

	public static function init()
	{
		FlxG.gamepads.deviceConnected.add(connetedGamepad ->		Log('Connected: ${Std.string(connetedGamepad)}', GREEN));
		FlxG.gamepads.deviceDisconnected.add(disconnetedGamepad ->	Log('Disconnected: ${Std.string(disconnetedGamepad)}', RED));
	}

	static inline function clamp01(value:Float):Float
	{
		return FlxMath.bound(value, 0, 1);
	}

	static inline function canUseMobileHaptics():Bool
	{
		#if ALLOW_HAPTICS
		return FlxG.onMobile;
		#else
		return false;
		#end
	}

	static inline function pulse(duration:Float, amplitude:Float, sharpness:Float):Void
	{
		#if ALLOW_HAPTICS
		if (!canUseMobileHaptics())
			return;
		Haptic.vibrateOneShot(duration, clamp01(amplitude), clamp01(sharpness));
		#end
	}

	static inline function pulsePattern(durations:Array<Float>, amplitudes:Array<Float>, sharpnesses:Array<Float>):Void
	{
		#if ALLOW_HAPTICS
		if (!canUseMobileHaptics())
			return;
		Haptic.vibratePattern(durations, amplitudes, sharpnesses);
		#end
	}

	public static function doVibrate(milliseconds:Float = 250, intensity:Int = 100)
	{
		final amp:Float = clamp01(intensity / 100);
		pulse(Math.max(0.01, milliseconds / 1000), amp, 0.6);
	}

	public static function vibrateGameplayTap():Void
	{
		if (!canUseMobileHaptics())
			return;

		final strength:Float = clamp01(ClientPrefs.mobileGameplayVibration);
		if (strength <= 0)
			return;

		final soft:Float = clamp01(Math.max(0.05, strength * 0.38));
		pulsePattern([0.010, 0.019], [soft, strength], [0.35, 0.8]);
	}

	public static function vibrateSustainTap():Void
	{
		if (!canUseMobileHaptics())
			return;

		final baseStrength:Float = clamp01(ClientPrefs.mobileGameplayVibration);
		if (baseStrength <= 0)
			return;

		final nowMs:Float = Timer.stamp() * 1000;
		if (nowMs - _lastSustainPulseAt < SUSTAIN_COOLDOWN_MS)
			return;
		_lastSustainPulseAt = nowMs;

		final sustainStrength:Float = clamp01(Math.max(0.03, baseStrength * 0.5));
		pulse(0.010, sustainStrength, 0.35);
	}

	public static function vibrateMiss():Void
	{
		if (!canUseMobileHaptics())
			return;

		final strength:Float = clamp01(ClientPrefs.mobileMissVibration);
		if (strength <= 0)
			return;

		pulse(0.032, Math.max(0.05, strength), 0.45);
	}

	public static function vibrateButton():Void
	{
		if (!canUseMobileHaptics())
			return;

		final strength:Float = clamp01(ClientPrefs.mobileButtonVibration);
		if (strength <= 0)
			return;

		final soft:Float = clamp01(Math.max(0.03, strength * 0.5));
		pulsePattern([0.007, 0.012], [soft, strength], [0.25, 0.55]);
	}
}
