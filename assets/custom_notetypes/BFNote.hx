final scriptName = "BFNote";
function onSpawnNote(note:Note)
{
	if (note.noteType == scriptName && !note.mustPress)
		note.noAnimation = true;
}
function opponentNoteHit(note:Note)
{
	if (note.noteType == scriptName)
	{
		boyfriend.holdTimer = 0.0;
		boyfriend.sing(singAnimations[note.noteData] + note.animSuffix, !note.isSustainNote, note.nextNote != null);
	}
}