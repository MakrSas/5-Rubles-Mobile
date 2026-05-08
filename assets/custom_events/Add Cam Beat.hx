using game.backend.utils.CoolUtil;
using StringTools;

static final ADC_PRESET_STOP = "stop"; // ✋✋
static final ADC_PRESET_BEAT = "beat"; // "beat2" или просто "2" => каждый 2-й бит
static final ADC_PRESET_STEP = "step"; // "step2" => только на 2-ом степе
static final ADC_PRESET_JERSEY = "jersey"; // ну думаю понятно
static final ADC_PRESET_DOUBLE = "double"; // 0-ый и 2-ой степ каждые 6 степов
static final ADC_PRESET_SNARE = "snare"; // 4-й и вписанный степ ("snare12" => второй зум будет на 12-ом степе)

var preset = ADC_PRESET_STOP;
var mainZoom = 0.0;
var hudZoom = 0.0;
var trigger = 0;

function onStepHit(step:Int)
{
	if (!ClientPrefs.camZooms || !camZooming || isDead || preset == ADC_PRESET_STOP)
		return;

	// более точный подсчет степов с учетом длины секции
	var sectionSteps = getBeatsOnSection() * 4;
	step = ((sectionSteps - (stepsToDo - step)) % sectionSteps);
	switch (preset)
	{
		case ADC_PRESET_BEAT:
			if (step % trigger == 0)
				addZoom();

		case ADC_PRESET_STEP:
			if (step == trigger)
				addZoom();

		// бум бум бум бумбум 🤙🤙
		case ADC_PRESET_JERSEY:
			if (step == 0 || step == 4 || step == 8 || step == 11 || step == 14)
				addZoom();

		// держи норкинг эф эн эф
		case ADC_PRESET_DOUBLE:
			step %= 6;
			if (step == 0 || step == 2)
				addZoom();

		case ADC_PRESET_SNARE:
			if (step == 4 || step == trigger)
				addZoom();
	}
}

static final __BEAT_REGEX = ~/^\d$/;
function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "Add Cam Beat")
	{
		final presetValue = (value1 == null ? ADC_PRESET_STOP : value1.toLowerCase().trim());
		preset = ((presetValue.length == 0 || presetValue == "0") ? ADC_PRESET_STOP : presetValue);
		if (preset != ADC_PRESET_STOP)
		{
			mainZoom = Std.parseFloat(value2).getDefault(0.015);
			hudZoom = Std.parseFloat(value3).getDefault(mainZoom * 2.0);

			var isNumber = __BEAT_REGEX.match(preset);
			if (isNumber || preset.startsWith(ADC_PRESET_BEAT))
			{
				trigger = Math.fround(Std.parseFloat(isNumber ? preset : preset.substr(ADC_PRESET_BEAT.length)).getDefault(0) * 4);
				preset = ADC_PRESET_BEAT;
			}
			else if (preset.startsWith(ADC_PRESET_STEP))
			{
				trigger = Std.parseFloat(preset.substr(ADC_PRESET_STEP.length)).getDefault(0);
				preset = ADC_PRESET_STEP;
			}
			else if (preset.startsWith(ADC_PRESET_SNARE))
			{
				trigger = Std.parseFloat(preset.substr(ADC_PRESET_SNARE.length)).getDefault(0);
				preset = ADC_PRESET_SNARE;
			}
		}
		// trace(preset, mainZoom, hudZoom, trigger);
	}
}

function addZoom()
{
	for (camera in FlxCamera._defaultCameras)
		camera.zoom += mainZoom;
	camHUD.zoom += hudZoom;
	// trace('zoom: {preset: $preset, step: $curStep, beat: $curBeat}');
}