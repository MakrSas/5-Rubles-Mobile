// ничего сверхестественного, просто фиксы для геймовера чтобы сурс лишний раз не трогать
// UPD: ой а тут уже много чего появилось упси

import game.backend.system.states.MusicBeatState;
import game.backend.utils.Highscore;
import flixel.FlxState;

static final bonusSongList = ["add-me-in-5rubles", "matematika", "under-construction"];

var curSong = Highscore.formatSong(PlayState.SONG.song, "");

// на всякий случай
function preUpdate(elapsed:Float)
{
	PlayState.instance.curDecStep = curDecStep;
	PlayState.instance.curDecBeat = curDecBeat;
}

function postUpdate(elapsed:Float)
{
	PlayState.instance.curDecStep = curDecStep;
	PlayState.instance.curDecBeat = curDecBeat;

	if (FlxG.state.controls.BACK)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			// FlxG.sound.music.stop();
			// FlxG.sound.music.fadeOut(0.8, 0.0, _ -> FlxG.sound.music.stop());
			FlxG.sound.music.pitch = 1.0;
			FlxTween.num(FlxG.sound.music.pitch, 3.0, 0.1, {
				onComplete: _ -> FlxTween.num(FlxG.sound.music.pitch, 0.5, 0.4, null, FlxG.sound.music.set_pitch)
			}, FlxG.sound.music.set_pitch);
		}

		if (bonusSongList.contains(curSong) && !FlxG.signals.preStateSwitch.has(goToMainMenu))
			FlxG.signals.preStateSwitch.addOnce(goToMainMenu);
	}
}

function goToMainMenu()
{
	if (FlxG.game._nextState != null && FlxG.game._nextState is FlxState)
		FlxG.game._nextState.destroy();
	FlxG.game._nextState = new MusicBeatState("MenuState");
}

function stepHit(step:Int)
{
	PlayState.instance.curStep = step;
	PlayState.instance.callOnScripts("onStepHit", [step]);
}

function beatHit(beat:Int)
{
	PlayState.instance.curBeat = beat;
	PlayState.instance.callOnScripts("onBeatHit", [beat]);
}

function sectionHit(section:Int)
{
	PlayState.instance.curSection = section;
	PlayState.instance.callOnScripts("onSectionHit", [section]);
}