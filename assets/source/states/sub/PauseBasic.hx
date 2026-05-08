import game.backend.system.states.MusicBeatState;
import game.backend.utils.Highscore;
import flixel.FlxState;

static final bonusSongList = ["add-me-in-5rubles", "matematika", "under-construction",
	"jopotr4ss-d4rk", "jopotr4ss-leebert", "jopotr4ss-puk", "jopotr4ss-rofos", "jopotr4ss-simon"];

var curSong = Highscore.formatSong(PlayState.SONG.song, "");

function onCreate() FlxG.sound.play(Paths.sound("cancelMenu"));

function exit()
{
	// pauseMusic.fadeOut(0.8, 0.0);
	pauseMusic.fadeIn(0.1, pauseMusic.volume, 0.4);
	pauseMusic.pitch = 1.0;
	FlxTween.num(pauseMusic.pitch, 3.0, 0.1, {
		onComplete: _ -> FlxTween.num(pauseMusic.pitch, 0.5, 0.4, null, pauseMusic.set_pitch)
	}, pauseMusic.set_pitch);

	if (!FlxG.signals.preStateSwitch.has(goToMainMenu))
		FlxG.signals.preStateSwitch.addOnce(goToMainMenu);
}

function goToMainMenu()
{
	if (FlxG.game._nextState != null && FlxG.game._nextState is FlxState)
		FlxG.game._nextState.destroy();
	FlxG.game._nextState = new MusicBeatState("MenuState");
}
