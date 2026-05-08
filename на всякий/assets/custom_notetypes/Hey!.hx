static final _eventHeyName = "Hey!";
function onSpawnNote(note:Note)
{
	if (note.noteType == _eventHeyName)
		note.noSingAnimation = true;
}
function goodNoteHit(note:Note) noteHit(note, boyfriend);
function opponentNoteHit(note:Note) noteHit(note, dad);
function noteHit(note:Note, defaultChar:Character)
{
	if (note.noAnimation || note.noteType != _eventHeyName)
		return;

	final char = (note.gfNote && gf != null) ? gf : defaultChar;
	final animCheck = (char == gf) ? "cheer" : "hey";
	if (char.hasAnimation(animCheck))
	{
		char.playAnim(animCheck, true);
		char.specialAnim = true;
		char.heyTimer = 0.6;
	}
}