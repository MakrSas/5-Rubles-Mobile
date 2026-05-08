static final TWERK_SUFFIX = "-twerk";
static final FUCK_PSYCH_ENGINE_EVENT_SYSTEM = ["boyfriend", "bf", "1", "gf", "girlfriend", "2"];

function onStepHit(step:Int)
{
	if (idleSuffix != TWERK_SUFFIX)
		return;

	// более точный подсчет степов с учетом длины секции
	var sectionSteps = game.getBeatsOnSection() * 4;
	step = ((sectionSteps - (game.stepsToDo - step)) % sectionSteps);

	if (step == 0 || step == 4 || step == 8 || step == 11 || step == 14)
		dance(true);
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "Alt Idle Animation":
			value1 = StringTools.trim(value1.toLowerCase());
			if (!FUCK_PSYCH_ENGINE_EVENT_SYSTEM.contains(value1))
				stunned = value2 == TWERK_SUFFIX;
	}
}