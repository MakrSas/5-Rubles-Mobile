import flixel.util.helpers.FlxRange;

import game.backend.utils.Highscore;
import game.backend.utils.Difficulty;

var decrease = 0.01;
function onCreatePost()
{
	boyfriend.origin.set(276);
	// привет fitin из 17 бакс!
	songLoops = true;
	loopSongBounds = new FlxRange(Math.ffloor(Conductor.crochet * 15.99), Math.ffloor(songLength) + 1000);

	var curSong = Highscore.formatSong(PlayState.SONG.song, "");
	onSongGenerated = () ->
	{
		// health = (healthBounds.min + healthBounds.max) / 2.0;
		boyfriend.scale.x -= decrease;
		// decrease *= 2;
		decrease += 0.01;
		if (boyfriend.scale.x - decrease <= 0.01)
		{
			// songLoops = false;
			finishSong();
			return;
		}

		FlxG.save.data.rubles5UnlockedSong ??= [];
		// луп пройден - засчитать песню как пройденную
		if (!FlxG.save.data.rubles5UnlockedSong.contains(curSong))
		{
			FlxG.save.data.rubles5UnlockedSong.push(curSong);
			FlxG.save.flush();
		}

		if (botplaySine == 0)
		{
			// Null Object Reference (почему-то)
			// Highscore.save(PlayState.SONG.song, {score: songScore, misses: songMisses, rating: CoolUtil.getDefault(ratingPercent, 0)}, Difficulty.getString());

			var daSong = PlayState.SONG.song;
			var data = {score: songScore, misses: songMisses, rating: CoolUtil.getDefault(ratingPercent, 0)};
			var diff = Difficulty.getString();

			daSong = Highscore.formatSong(daSong, diff);
			final olddata = Highscore.songsData.get(daSong);
			// if (Highscore.songsData.exists(daSong))
			if (olddata != null)
			{
				if (olddata.score < data.score)
				{
					Highscore.songsData.set(daSong, data);
					// data.score = data.score;
					// data.misses = data.misses;
					// data.rating = data.rating;
				}
			}
			else
			{
				Highscore.songsData.set(daSong, data);
			}
			trace(daSong + " => " + [for( i in Reflect.fields(data)) '$i = ' + Reflect.field(data, i)].join(', '));

			FlxG.save.data.songsData = Highscore.songsData;
			FlxG.save.flush();
		}
	}
}

function onUpdate(e)
{
	iconP1.scale.x /= boyfriend.scale.x;
}

function onUpdatePost(e)
{
	iconP1.scale.x *= boyfriend.scale.x;
	iconP1.offset.x += (iconP1.frameWidth - 150) / 2 * (1 - boyfriend.scale.x);
}

// ДА, СИДИ 5 ЧАСОВ РАДИ ЭТОЙ ТИПА СЦЕНКИ
// UPD: теперь уже пол часа :(
var fiveHoursScene = true;
function onEndSong()
{
	if (fiveHoursScene)
	{
		trace("тайлер исчез...");
		fiveHoursScene = false;
		boyfriend.visible = iconP1.visible = false;
		inCutscene = transitioning = true;
		camZooming = false;
		updateCameraPosition = false;
		cameraZooming = _ -> {};
		eventNotes = [];
		clearNotesBefore(inst.length);
		var time = 2;
		for (cam in [camHUD, camControls])
			FlxTween.num(1, 0, time, null, cam.set_alpha);
		new FlxTimer().start(time + FlxG.random.int(4, 16), _ ->
		{
			dad.skipDance = true;
			dad.playAnim("burp");
			moveCameraOnChar("dad", true);
			camFollowPos.setPosition(camFollow.x, camFollow.y);
			FlxG.camera.snapToTarget();
			FlxG.camera.zoom = 1.3;
			// dad.animation.curAnim.frameDuration * dad.animation.curAnim.numFrames
			new FlxTimer().start(12 / 24, _ -> endSong());
			FlxG.sound.play(Paths.sound("sonic-exe-scream")); // "matr4ss_burp", 1.5
		});
		return;
	}
	transitioning = fiveHoursScene = false;
}