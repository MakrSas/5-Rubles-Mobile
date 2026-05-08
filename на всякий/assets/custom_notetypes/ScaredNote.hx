function onSpawnNote(note:Note)
{
	if (note.noteType == "ScaredNote")
		note.animSuffix = "-scared";
}