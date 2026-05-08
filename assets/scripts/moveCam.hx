var lastNote:Note;
var module:MoveCameraModule;

function onCreate()
{
	insert(0, module = new MoveCameraModule([FlxG.camera]));
}

function curSectionIsValid(note:Note)
{
	final curSection = PlayState.SONG.notes[curSection];
	return curSection != null && (note.gfNote ? curSection.gfSection : note.mustPress == curSection.mustHitSection) || note.noteType.indexOf("BFNote") != -1;
}

function moveCamOnBack()
{
	if (curSectionIsValid(lastNote))
	{
		module.finish();
		// moveCamera(!lastNote.mustPress);
	}
}

function moveCam(note:Note)
{
	if (/*!note.isSustainNote &&*/ curSectionIsValid(note))
	{
		// moveCamera(!note.mustPress);
		//var factor = 10 / defaultCamZoom;
		module.notePress(note, moveCamOnBack);
		lastNote = note;
	}
}

function opponentNoteHit(note:Note)	moveCam(note);
function goodNoteHit(note:Note)		moveCam(note);

// function onSectionHit() {
//     module.speed = 1.0;
// }

class MoveCameraModule extends FlxBasic
{
	static var TARGET_FACTOR = 30.0;
	static var NOTE_HIT_SPEED = 2.0;

	public var offset:{x:Float, y:Float};
	public var timer:Float;
	public var speed:Float;

	var finishCallback:()->Void;

	public function new(?cameras:FlxCamera)
	{
		super();
		offset = {x: 0.0, y: 0.0};
		timer = 0.0;
		speed = 1.0;
		this.cameras = cameras;
		visible = false;
	}

	public function notePress(note:Note, ?finishCallback:()->Void)
	{
		speed = NOTE_HIT_SPEED;
		this.finishCallback = finishCallback ?? finish;
		timer = Conductor.crochet * 0.0011;
		if (note.isLastSustain || note.tail.length == 0)
			timer /= 2.0;

		var factor = TARGET_FACTOR;
		if (note.isLastSustain)
			factor /= 2.0;
		offset.x = offset.y = 0.0;
		switch (note.noteData % 4)
		{
			case 0: offset.x -= factor;
			case 1: offset.y += factor;
			case 2: offset.y -= factor;
			case 3: offset.x += factor;
		}
	}

	public function finish()
	{
		offset.x = offset.y = 0.0;
		speed = 1.0;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (timer > 0.0)
		{
			timer -= elapsed;
			if (timer <= 0.0)
				finishCallback();
		}
		var lerpFactor = 0.04 * speed;
		for (camera in cameras)
			camera.targetOffset.set(
				CoolUtil.fpsLerp(camera.targetOffset.x, offset.x, lerpFactor),
				CoolUtil.fpsLerp(camera.targetOffset.y, offset.y, lerpFactor)
			);
	}
}