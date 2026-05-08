final scriptName = "BFNote-Alt";
function onSpawnNote(note:Note)
{
	if (note.noteType == scriptName)
	{
		note.animSuffix = "-alt";
		if (!note.mustPress)
			note.noAnimation = true;
	}
}
function opponentNoteHit(note:Note)
{
	if (note.noteType == scriptName)
	{
		boyfriend.holdTimer = 0.0;
		boyfriend.sing(singAnimations[note.noteData] + note.animSuffix, !note.isSustainNote, note.nextNote != null);
	}
}