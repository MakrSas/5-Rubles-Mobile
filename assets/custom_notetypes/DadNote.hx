final scriptName = "DadNote";
function onSpawnNote(note:Note)
{
	if (note.noteType == scriptName && !note.mustPress)
		note.noAnimation = true;
}
function opponentNoteHit(note:Note)
{
	if (note.noteType == scriptName)
	{
		dad.holdTimer = 0.0;
		dad.sing(singAnimations[note.noteData] + note.animSuffix, !note.isSustainNote, note.nextNote != null);
	}
}