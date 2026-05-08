using game.backend.utils.CoolUtil;
using StringTools;

importHScriptClasses("scripts/classes/CharacterTrail.hx");

var boyfriendTrail:CharacterTrail;
var dadTrail:CharacterTrail;
var gfTrail:CharacterTrail;

function onCreatePost()
{
	boyfriendGroup.insert(0, boyfriendTrail = new CharacterTrail());
	dadGroup.insert(0, dadTrail = new CharacterTrail());
	gfGroup.insert(0, gfTrail = new CharacterTrail());
	boyfriendTrail.exists = dadTrail.exists = gfTrail.exists = false;
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	// value1 ??= "";
	// value2 ??= "";
	// value3 ??= "";
	switch (name)
	{
		case "Character Trail":
			var char:Character;
			var trail:CharacterTrail;
			switch (value1.trim().toLowerCase())
			{
				case "bf" | "boyfriend":
					char = boyfriend;
					trail = boyfriendTrail;

				case "dad" | "opponent":
					char = dad;
					trail = dadTrail;

				case "gf" | "girlfriend":
					char = gf;
					trail = gfTrail;

				default: // ничего
			}

			if (trail == null)
				return;

			value2 = value2.trim().toLowerCase();
			trail.exists = true;
			trail.enabled = (value2 == "true" || value2 == "on" || value2 == "1");
			trail.setTarget(char);
			if (trail.enabled)
			{
				var options = value3.split(",");
				// if (value3[0] != "")
				// {
					trail.interval = Std.parseFloat(options[0]).getDefault(0.2);
					trail.alpha = Std.parseFloat(options[1]).getDefault(0.65);
					trail.fadeSpeed = Std.parseFloat(options[2]).getDefault(1.0);
					trail.maxSize = Std.parseInt(options[3]).getDefault(0);
					trail.velocity.x = Std.parseInt(options[4]).getDefault(0.0);
					trail.velocity.y = Std.parseInt(options[5]).getDefault(0.0);
					trail.acceleration.set(trail.velocity.x * 2.0, trail.velocity.y * 2.0);
				// }
			}

		case "Change Character":
			var char:Character;
			var trail:CharacterTrail;
			switch (value1.trim().toLowerCase())
			{
				case "gf" | "girlfriend" | "2":
					char = gf;
					trail = gfTrail;

				case "dad" | "opponent" | "1":
					char = dad;
					trail = dadTrail;

				default:
					char = boyfriend;
					trail = boyfriendTrail;
			}

			if (trail.enabled)
			{
				trail.setTarget(char);
			}
	}
}

function goodNoteHit(note:Note) onNotePress(note, boyfriendTrail, false);
function noteMiss(note:Note) onNotePress(note, boyfriendTrail, true);
function opponentNoteHit(note:Note) onNotePress(note, dadTrail, false);
function noteOpponentMiss(note:Note) onNotePress(note, dadTrail, true);

function onNotePress(note:Note, trailController:CharacterTrail, miss:Bool)
{
	if (note.isSustainNote)
		return;

	if (note.gfNote && gf != null)
		trailController = gfTrail;
	if (trailController.enabled)
	{
		var alphaFactor = miss ? 0.5 : 0.675;
		var forceAnim = null;
		if (/*trailController.target != null &&*/ (note.noAnimation || note.noSingAnimation))
		{
			// var isHold = (trailController.target.status == 0x10 && trailController.target.holdAnims);
			// var isHoldEnd = holdEndAnims;
			forceAnim = trailController.target.singAnimsPrefix + singAnimations[note.noteData] + note.animSuffix;
			// if (isHold)
			//	forceAnim += "-hold";
			// else if (isHoldEnd)
			//	forceAnim += "-holdEnd";
			alphaFactor *= 1.2;
		}
		triggerTrail(trailController, forceAnim, alphaFactor);
	}
}

function noteMissPress(direction:Int)
{
	if (boyfriendTrail.enabled)
	{
		triggerTrail(boyfriendTrail, null, 0.5);
	}
}

function triggerTrail(trailController:CharacterTrail, forceAnim:String, alphaFactor:Float)
{
	trailController.spawnTrail(forceAnim).alpha *= alphaFactor;
}

function onGameOverStart()
{
	boyfriendTrail.enabled = false;
	dadTrail.enabled = false;
	gfTrail.enabled = false;
}