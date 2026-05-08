var chars:Map<String, Character> = [];

var x_offset = -1516;
var y_offset = -1013;

var allowErectBg = true;
var isMoruMix = game.SONG.song.toLowerCase() == "hernyamorumix";
var isErectBg = (allowErectBg && isMoruMix && ClientPrefs.shaders);
var hsvShader;
var kompShader;

if (isErectBg)
{
	hsvShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("adjustColor")));
	hsvShader.setFloat("saturation", -30);
	hsvShader.setFloat("hue", -16);

	kompShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("adjustColor")));
	kompShader.setFloat("saturation", -30 * 2.3);
	kompShader.setFloat("hue", -16 * 3);
}


function addWithShader(obj:FlxBasic, front:Bool = false)
{
	if (isErectBg)
	{
		obj.setColorTransform(0.5, 0.5, 0.5, 1, 0, 0, 0, 0);
		obj.shader ??= hsvShader;
	}
	return addHxObject(obj, front);
}


function pushChar(char:Character) {
	setVar(char.curCharacter + '_char', char);
	startCharacterLua(char);
	chars.set(char.curCharacter, char);
}

var bg = new FlxSprite(-2139 + 428.7 - 23.15, -1532 + 448.7, Paths.image('hernya_market/bg'));
addWithShader(bg);

if (isMoruMix)
	addWithShader(new FlxSprite(1852 + x_offset, 314 + y_offset, Paths.image('hernya_market/moruMix/hole')));
else
	bg.color = 0xfff0f0f0;


var komp = new Character(-482, -76, 'komp', true);
pushChar(komp);
if (isMoruMix)
{
	addAheadObject(komp, dadGroup);
	if (isErectBg)
	{
		komp.shader = kompShader;
		komp.setColorTransform(0.5,0.5,0.5,1,0,0,0,0);
	}
}
else
	add(komp);


// new FlxTimer().start(2, (_) -> komp.playAnim('upal'));
// 1181.76
var juztPosX = -181.76;
var juzt = new Character(-1200, -200, isMoruMix ? '5juztexds-flipped' : '5juztexds');
pushChar(juzt);
juzt.alpha = FlxPoint.EPSILON;
// juzt.visible = false;

var lamp = new FlxSprite(-360, -701);
var graphic = Paths.image('hernya_market/lamp left');
lamp.loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
lamp.animation.add('', [0, 1], 0);
lamp.animation.play('');
addHxObject(lamp);

var lamp2 = new FlxSprite(2972 + x_offset, 307 + y_offset);
// var graphic = Paths.image('hernya_market/lamp left');
lamp2.loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
lamp2.flipX = true;
lamp2.animation.add('', [0, 1], 0);
lamp2.animation.play('');
addHxObject(lamp2);
if (isMoruMix)
{
	addWithShader(new FlxSprite(366 + x_offset, 1458 + y_offset, Paths.image('hernya_market/moruMix/boxes_erect_left')), true);
	addWithShader(new FlxSprite(3673 + x_offset, 1219 + y_offset, Paths.image('hernya_market/moruMix/boxes_erect_right')), true);
}
var lightFine = new FlxSprite(960, -690, Paths.image('hernya_market/light'));
lightFine.flipX = true;
addWithShader(lightFine, true);
lightFine.alpha = (isErectBg ? 0.4 : 0.1);
var lightGlitcher = new FlxSprite(-947, -703, Paths.image('hernya_market/light'));
addWithShader(lightGlitcher, true);
var boxes = new TwistSprite(-2239, 360, Paths.image('hernya_market/' + (isMoruMix ? "moruMix/boxses front erect" : "boxes front")));
boxes.scrollFactor.set(1.38, 1.5);
boxes.zoomFactor = 0.85;
boxes.drawAlways = true;
addWithShader(boxes, true);

if (ClientPrefs.lowQuality)
{
	lightFine.alpha *= 2;
}
else
{
	lightFine.blend = BlendMode.ADD;
	// lightGlitcher.blend = BlendMode.SHADER;
	lightGlitcher.blend = BlendMode.ADD;
}

function onCreatePost()
{
	var scoreGroup = getVar('scoreGroup');
	scoreGroup.scrollFactor.set(1, 1);
	if (isMoruMix)
	{
		scoreGroup.x += 150;
		scoreGroup.y -= 125;
		addBehindObject(juzt, lightGlitcher);
		if (isErectBg)
		{
			if (juzt.shader != null)
			{
				juzt.shader.setFloat("brightness", hsvShader.getFloat("brightness"));
				juzt.shader.setFloat("contrast", hsvShader.getFloat("contrast"));
				juzt.shader.setFloat("hue", hsvShader.getFloat("hue"));
				juzt.shader.setFloat("saturation", hsvShader.getFloat("saturation"));
			}
			else
			{
				juzt.shader = hsvShader;
			}
			dad.shader = hsvShader;
			gf.shader = hsvShader;
			boyfriend.shader = hsvShader;
		}
	}
	else
	{
		scoreGroup.y -= 225;
		addBehindDad(juzt);
		remove(boyfriendGroup, true);
		addBehindObject(boyfriendGroup, juzt);
	}

	// фейд передних спрайтов на геймовере
	var applyFade = getVar("gameOverApplyFade");
	if (!isMoruMix)
	{
		applyFade(dad);
		applyFade(juzt);
	}
	applyFade(boxes);
	// applyFade(isMoruMix ? komp : dad);
}

// camHUD.visible = false;
var ___time:Float = 0;
var _alphaTarget:Float = 1;
var _alphaTarget2:Float = 1;
var _lerpAlphaFactor:Float = ClientPrefs.flashing ? 0.5 : 0.9;

function onGameOverStart()
{
	if (isMoruMix)
	{
		FlxTween.tween(boxes, {alpha: 0}, 0.6);
	}
	else
	{
		moveToGameOverSubstate(juzt, FlxG.state);
		moveToGameOverSubstate(dad, dadGroup);
		dad.x += dadGroup.x;
		dad.y += dadGroup.y;
		getVar("gameOverApplyFade")(komp);
		moveToGameOverSubstate(komp, FlxG.state);
	}
	moveToGameOverSubstate(lightFine, FlxG.state);
	moveToGameOverSubstate(lightGlitcher, FlxG.state);
	moveToGameOverSubstate(boxes, FlxG.state);
}

function moveToGameOverSubstate(obj:FlxBasic, group:FlxGroup)
{
	group.remove(obj);
	GameOverSubstate.instance.add(obj);
}
var alphaFuckt = lightFine.alpha;
// var alphaFuckt = 1.0;
function onUpdate(elapsed:Float)
{
	//camera.zoom = 0.2;
	___time += elapsed;
	if (___time > 0.05)
	{
		_alphaTarget = FlxG.random.float(-0.75, 1.2) * alphaFuckt;
		do
		{
			___time -= 0.05;
		}
		while (___time > 0.05);
	}
	if (FlxG.game.ticks % 100 > 50)
	{
		lightGlitcher.colorTransform.alphaMultiplier = CoolUtil.fpsLerp(lightGlitcher.colorTransform.alphaMultiplier, _alphaTarget, _lerpAlphaFactor);
		lamp.animation.curAnim.curFrame = lightGlitcher.colorTransform.alphaMultiplier > 0.35 ? 1 : 0;
		// if (isErectBg)
		// {
		// 	var brigh = Math.max(lightGlitcher.colorTransform.alphaMultiplier, 0) / 4 + 0.75;
		// 	dad.setColorTransform(brigh, brigh, brigh, 1, 0, 0, 0, 0);
		// 	juzt.setColorTransform(brigh, brigh, brigh, juzt.colorTransform.alphaMultiplier, 0, 0, 0, 0);
		// }
	}
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	switch (name)
	{
		case "":
			switch (value1)
			{
				case "juzt_slide":
					var time = Conductor.crochet / 1000.0;
					juzt.alpha = 1.0;
					// juzt.visible = true;
					juzt.setPosition(juztPosX + 1700.0, 176.58);
					var cum = t -> moveCameraOnChar("juzt", true);
					FlxTween.num(juzt.x, juztPosX, time, {ease: FlxEase.backOut, onComplete: cum, onUpdate: cum}, juzt.set_x);

					var offset = 220.0;
					FlxTween.num(gf.x, gf.x + offset, time * 1.1, {ease: FlxEase.backOut}, gf.set_x);
					FlxTween.num(dad.x, dad.x + offset, time * 1.3, {ease: FlxEase.backOut}, dad.set_x);

				case "drop_juzt":
					juzt.alpha = 1.0;
					// juzt.visible = true;
					juzt.setPosition(-820.0, -200.0);
					juzt.playAnim("jump");
					juzt.specialAnim = true;
					komp.playAnim("upal", false);
					komp.danceIdle = true;
			}
	}
}

function onSpawnNote(note:Note)
{
	switch (note.noteType)
	{
		case "KompNote":
			note.noAnimation = note.noMissAnimation = true;
			note.extraData.set("char", komp);
		case "JuztNote":
			note.noAnimation = note.noMissAnimation = true;
			note.extraData.set("char", juzt);
	}
}

var oldDanceCharacters = danceCharacters;
danceCharacters = beat -> {
	oldDanceCharacters(beat);
	danceCharacter(juzt, beat, juzt.danceEveryNumBeats);
}

function goodNoteHit(note:Note) checkNoteOnHit(note);
function opponentNoteHit(note:Note) checkNoteOnHit(note);

function checkNoteOnHit(note:Note)
{
	var overridechar = note.extraData.get("char");
	playerCharacters[0] = boyfriend;
	if (overridechar == null)
		return;

	if (note.mustPress)
		playerCharacters[0] = overridechar;
	overridechar.holdTimer = 0.0;
	overridechar.sing(singAnimations[note.noteData] + note.animSuffix, !note.isSustainNote, note.nextNote != null);
}

function noteMiss(note:Note)
{
	var overridechar = note.extraData.get("char");
	if (overridechar == null)
		return;

	var anim = singAnimations[note.noteData] + "miss";
	if (!overridechar.playAnim(anim + note.animSuffix, !note.isSustainNote || overridechar.forceSing))
		overridechar.playAnim(anim, !note.isSustainNote || overridechar.forceSing);
	if (overridechar != gf && combo > 5 && gf != null && gf.playAnim("sad", true))
		gf.specialAnim = true; // play ":("
	if (overridechar.status != 0x011)
		overridechar.status = 0x011;
}

var oldSetCharCamOffset = setCharCamOffset;
setCharCamOffset = (char:String, moveCamera:Bool) ->
{
	var charMidpoint:FlxPoint = oldSetCharCamOffset(char, moveCamera);
	switch (char)
	{
		case "komp" | "комп":
			var point = komp.getCameraPosition();
			charMidpoint.set(point.x, point.y);
			charMidpoint.x -= 100 - bfCamOffset.x;
			charMidpoint.y -= 100 - bfCamOffset.y;

		case "juzt" | "джаст":
			var point = juzt.getCameraPosition();
			charMidpoint.set(point.x, point.y);
			charMidpoint.x += 150 + dadCamOffset.x;
			charMidpoint.y += -100 + dadCamOffset.y;
	}
	if (moveCamera)
		camFollow?.set(charMidpoint.x, charMidpoint.y);

	return charMidpoint;
}

var oldCreateCountSprite = createCountSprite;
createCountSprite = (name, sound) ->
{
	var countdown = oldCreateCountSprite(name, 'hernya/$sound');
	if (countdown != null)
		countdown.camera = camOther;

	return countdown;
}