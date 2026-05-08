// just for placeholder lol

var isNotHernya = game.SONG.song.toLowerCase().indexOf('hernya') == -1;
var bounce = 0.;
var de_flipX = 1;
var de_flipY = 1;
var de_flipX_isPlayer = isPlayer ? -1 : 1;

frameOffsetAngle = 0;

if (isPlayer) {
	function goodNoteHit(e)
		if (isNotHernya || e.noteType == "JuztNote")
			goDoACrime(e);
} else {
	function opponentNoteHit(e)
		if (isNotHernya || e.noteType == "JuztNote")
			goDoACrime(e);
}
function goDoACrime(note) {
	if (isNotHernya || note.extraData.get('char') == this.interp.scriptObject) {
		de_flipY = 1;
		switch (note.noteData % 4) {
			case 0:
				bounce = 1 - Math.abs(bounce) * 0.35;
				de_flipX = 1;
				angle -= 30 / bounce * 1.2;
				x -= 24 / bounce;
			case 1:
				bounce = bounce * 0.7 + 0.25;
				if (angle > 0)
					angle -= bounce * 10;
				else
					angle += bounce * 10;
				de_flipY = -1;
				y += 9 / bounce;
			case 2:
				bounce = bounce * 0.8 + 0.25;
				if (angle > 0)
					angle -= bounce * 10;
				else
					angle += bounce * 10;
				y -= 12 / bounce;
			case 3:
				de_flipX = -1;
				bounce = 1 - Math.abs(bounce) * 0.35;
				angle += 30 / bounce * 1.2;
				x += 20 / bounce;
		}
	}
}

function onUpdatePost(elapsed) {
	bounce = CoolUtil.fpsLerp(bounce, 1, 0.13);
	x += de_flipX * de_flipX_isPlayer * (1 - bounce) * 750 * elapsed;
	scale.set(de_flipX_isPlayer * de_flipX / bounce, bounce * de_flipY);
	angle = CoolUtil.fpsLerp(angle, 0, 0.01);
}
