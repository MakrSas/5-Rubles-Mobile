using game.backend.utils.CoolUtil;

var drainBound = 69;
var drainTypes = ["JuztNote"];
var drainMarkilpier = 0.8; //я посчитал что стоит немного увеличить дрейн. ух ух как же джаст дрейнит холи щииит йоооу
// Hello everybody my name is Markiplier and welcome to Five Rubles
/*
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣮⣝⡯⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⢼⣧⣿⣿⣿⡿⠻⠿⢿⣯⣿⣮⣀⡁⢑⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⡟⠁⠀⠙⠧⠞⠈⢓⣿⣿⣿⣿⢿⣾⣷⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣫⠟⠀⠀⠀⠀⠀⠀⠀⠀⡙⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠢⢈⢻⣿⣿⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣿⠁⠚⣛⣒⠀⠀⠀⡀⠐⢒⡒⠳⠤⢺⣟⣿⣿⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠋⠀⠋⠚⠛⠃⢈⣩⣓⢮⠿⠯⠷⠀⠀⢽⣿⠏⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡜⠄⠀⠀⠀⠀⠀⠀⢸⠩⠀⠀⠀⠀⠀⠀⠀⢻⡤⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠔⡸⡎⠀⠀⠀⠀⠀⠀⠀⠀⠠⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠂⠀⠀⠀⠀⠈⠀⡳⣿⠆⠄⠀⠀⠁⠀⠠⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠘⠤⡔⢎⣵⣸⢯⠜⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⠀⣠⣆⣿⣿⣾⣹⣏⢳⣄⡀⠀⠀⠀⠃⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣸⠤⠋⠙⠓⠶⠖⣾⠾⠟⠋⢣⣲⣦⡾⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣤⣶⣶⣾⣽⣿⢷⠀⢈⠃⢙⠃⠀⠀⠀⢐⡾⣾⡿⠃⠀⠀⠠⣄⠀⠀⠀⠀
⠀⢀⣤⣾⣿⣿⣿⣿⣿⣿⣯⣆⢣⣑⣄⠴⡇⣽⣦⣢⣾⣾⠋⡀⠐⠀⠁⢀⣿⣷⣄⠀⠀
⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣗⣉⣛⣿⣶⣟⣿⣿⣛⣁⣐⣀⣀⣀⣠⣶⣿⣡⣨⣟⣑⣢
*/
var isWorking = false;

function onCreatePost()
{
	drainBound = healthBounds.max * 0.1;
}

function opponentNoteHit(note:Note)
{
	if (isWorking && (drainTypes.length == 0 || drainTypes.contains(note.noteType)) && health > drainBound)
		health = Math.max(health - note.hitHealth * healthLoss * drainMarkilpier, drainBound);
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "Note Drain")
	{
		if (value1 == null)
			isWorking = false;
		else
		{
			value1 = StringTools.trim(value1.toLowerCase());
			isWorking = (value1 == "true" || value1 == "on");
		}

		var split = value2.split(",");
		drainBound = healthBounds.max / Std.parseFloat(split[0]).getDefault(10);
		drainMarkilpier = Std.parseFloat(split[1]).getDefault(0.75);

		if (value3 == null)
		{
			drainTypes = [];
		}
		else
		{
			drainTypes = [for(i in value3.split(",")) StringTools.trim(i)].filter(i -> return i.length != 0);
		}
	}
}