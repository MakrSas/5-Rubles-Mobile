package game.backend.system.scripts;

import flixel.system.scaleModes.RatioScaleMode;

/**
 * Compatibility scale mode for old HScript content that expects JopaScaleMode.
 * Uses fillScreen=true to avoid 16:9 letterboxing on tall Android screens.
 */
class JopaScaleModeCompat extends RatioScaleMode
{
	public function new()
	{
		super(true);
	}
}
