function onSpawnNote(note:Note)
{
	if (note.noteType == "GFNote-Alt")
	{
		note.animSuffix = "-alt";
		note.gfNote = true;
	}
}