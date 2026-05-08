import spine.Physics;
import spine.PhysicsConstraint;
import spine.PhysicsConstraintData;
import spine.SkeletonData;
import spine.animation.AnimationStateData;
import spine.atlas.TextureAtlas;
import spine.flixel.FlixelTextureLoader;
import spine.flixel.SkeletonSprite;

import flixel.system.scaleModes.RatioScaleMode;

import game.backend.data.StructureOptionsData;

#if TOUCH_CONTROLS
import game.mobile.objects.MobileHitbox.MobileHint;
import flixel.input.touch.FlxTouch;
#end

import game.backend.utils.GamepadUtil;

#if ALLOW_EIGHTSINES
import extension.eightsines.EsOrientation;
#end

loadHScript("data/smert_vikluchit.hx");

static final KEY_UP = "keyUp";
static final skin = "ass_matr4ss/notes";

var reaction:FlxAnimate;
var jopotr4ssSpine:SkeletonSprite;
var cheekLConstraint:PhysicsConstraint;
var cheekRConstraint:PhysicsConstraint;
var point = FlxPoint.get();
var prevScaleMode:Dynamic = null;

function onCreate()
{
	#if ALLOW_EIGHTSINES
	EsOrientation.setScreenOrientation(1);
	prevScaleMode = FlxG.scaleMode;
	FlxG.scaleMode = new RatioScaleMode(true);
	#end

	// May G0DS forgive me for what I did. PLAYER! STEP BACK! - Redar13
	// /*
	var spinesFilesPath = "assets/images/ass_matr4ss/skeleton";
	var spineScale = 1.0;

	var atlas = new TextureAtlas(
		Assets.getText(spinesFilesPath + ".atlas"),
		new FlixelTextureLoader(spinesFilesPath + ".atlas")
	);
	var skeletondata = SkeletonData.from(Assets.getText(spinesFilesPath + ".json"), atlas, spineScale);
	var animationStateData = new AnimationStateData(skeletondata);
	// animationStateData.defaultMix = 0.25;
	var skeletonSprite = new SkeletonSprite(skeletondata, animationStateData);
	// skeletonSprite.screenCenter();
	// skeletonSprite.alpha = 0;
	var controlBoneNames = [
		"assL",
		"assR",
	];
	// var controlBones = [];
	// var bonesDefaultPositions = [];
	var steps = 1 / (ClientPrefs.lowQuality ? 24 : 24 * 2);
	var skeleton = skeletonSprite.skeleton;
	for (i => boneName in controlBoneNames) {
		var bone = skeleton.findBone(boneName);
		var physicsData:PhysicsConstraintData = new PhysicsConstraintData(boneName + "-physic");
		physicsData.bone = bone._data;
		physicsData.order = i;
		// physicsData.x = bone._data.x;
		// physicsData.y = bone._data.y;
		physicsData.x = 10;
		physicsData.y = 10;
		physicsData.limit = 500;
		physicsData.step = steps;
		physicsData.inertia = 0.5;
		physicsData.strength = 100;
		physicsData.damping = 0.89;
		// physicsData.scaleX = bone._data.scaleX;
		// physicsData.shearX = bone._data.shearX;
		physicsData.massInverse = 1 / 1;
		physicsData.mix = 1;
		// physicsData.inertiaGlobal = true;
		// physicsData.strengthGlobal = true;
		// physicsData.dampingGlobal = true;
		// physicsData.massGlobal = true;
		// physicsData.windGlobal = true;
		// physicsData.gravityGlobal = true;
		// physicsData.mixGlobal = true;
		var constraint = new PhysicsConstraint(physicsData, skeleton);
		skeleton.physicsConstraints.push(constraint);
		switch boneName
		{
			case "assL":
				cheekLConstraint = constraint;
			case "assR":
				cheekRConstraint = constraint;
		}
	}
	skeleton.updateCache();
	skeleton.updateWorldTransform(Physics.update);
	jopotr4ssSpine = skeletonSprite;
	updatePhysContaints();
	// add(skeletonSprite);
	// */


	// loading spineboy
	// var atlas = new TextureAtlas(Assets.getText("assets/images/spineboy/spineboy.atlas"), new FlixelTextureLoader("assets/images/spineboy/spineboy.atlas"));
	// var skeletondata = SkeletonData.from(Assets.getText("assets/images/spineboy/spineboy-pro.json"), atlas, 1);
	// var animationStateData = new AnimationStateData(skeletondata);
	// spineSprite = new SkeletonSprite(skeletondata, animationStateData);
	// add(spineSprite);

	// loading random spine
	// var atlas = new TextureAtlas(Assets.getText("assets/images/spinetest/celestial-circus.atlas"), new FlixelTextureLoader("assets/images/spinetest/celestial-circus.atlas"));
	// var skeletondata = SkeletonData.from(Assets.getText("assets/images/spinetest/celestial-circus-pro.json"), atlas, 0.2);
	// var animationStateData = new AnimationStateData(skeletondata);
	// spineSprite = new SkeletonSprite(skeletondata, animationStateData);
	// add(spineSprite);
	// spineSprite.screenCenter();

	// spineTest = spineSprite;

	middleScrollMode = true;
	// ClientPrefs.downScroll = true;
	strumLine.y = FlxG.height - 150;
	camZooming = true;
	camZoomingFreq = 0;
	camZoomingMult = 2.2;
	addZoomOnSection = false;

	// var old_setCharCamOffset = setCharCamOffset;
	setCharCamOffset = (char:String, moveCamera:Bool) ->
	{
		point.set(jopotr4ssSpine.x + jopotr4ssSpine.width / 2, jopotr4ssSpine.y + jopotr4ssSpine.height / 2 - 200);
		if (moveCamera)
			camFollow?.set(point.x, point.y);
		// return old_setCharCamOffset(char, moveCamera);
		return point;
	}

	var moveCamScript = scriptPack.getHScript("scripts/moveCam");
	if (moveCamScript != null)
	{
		// moveCamScript.dispose();
		moveCamScript.call("onDestroy");
		moveCamScript.destroy();
		scriptPack.hscriptArray.remove(moveCamScript);
	}

	StructureOptionsData.onChangePost.add(onChangeOptionPost);
}

function onChangeOptionPost(data)
{
	switch (data.variableName) {
		case "framerate":
			updatePhysContaints();
	}
}

function updatePhysContaints()
{
	updatePhysContaint(cheekLConstraint);
	updatePhysContaint(cheekRConstraint);
}

function updatePhysContaint(constraint)
{
	if (constraint == null) return;
	var framerateFactor = FlxG.updateFramerate / 360 / FlxG.timeScale;
	framerateFactor = Math.pow(framerateFactor, 0.5);
	// constraint._data.step =  1 / (ClientPrefs.lowQuality ? 24 : 24 * 2);
	constraint._data.x = 15 * framerateFactor;
	constraint._data.y = 15 * framerateFactor;
}

function resetPhysContaint(constraint)
{
	constraint.reset();
	constraint._reset = false;
	constraint.ux = constraint._bone.wordX;
	constraint.uy = constraint._bone.wordY;
}

function onCreatePost()
{
	#if TOUCH_CONTROLS
	PlayState.instance.removeHitbox(true);
	#end

	if (FlxG.onMobile)
	{
		camPAUSE.x += FlxG.width * 0.3;
		camPAUSE.zoom = 0.85;

		var old_createCountSprite = createCountSprite;
		createCountSprite = (name, sound) ->
		{
			var spr = old_createCountSprite(name, sound);
			if (spr != null)
			{
			var scaleMult = 0.5;
			spr.scale.x *= scaleMult;
			spr.scale.y *= scaleMult;
			}
			return spr;
		}
	}
	else
	{
		var shader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("tiktok")));
		var blurSize = 6;
		shader.setFloatArray("blurSize", [blurSize, blurSize]);
		shader.setBool("enabled", ClientPrefs.shaders);
		FlxG.camera.setFilters([new ShaderFilter(shader)]);
	}
	FlxG.camera.zoom = defaultCamZoom = 0.5;

	var scale = 1280 / 1920 / defaultCamZoom * 0.9;
	reaction = new FlxAnimate(-270 * scale + 440, -200 * scale, AssetsPaths.getPath("images/ass_matr4ss/reaction"));
	reaction.antialiasing = ClientPrefs.globalAntialiasing;
	reaction.scale.x = reaction.scale.y = scale;
	reaction.anim.addBySymbol("anim", "cumbo_anim", 0, false);
	reaction.anim.play("anim");
	reaction.anim.finish();
	reaction.scrollFactor.set();
	add(reaction);

	var old_popUpCombo = popUpCombo;
	popUpCombo = (daRating:Rating) ->
	{
		old_popUpCombo(daRating);
		if (combo > 0 && combo % 50 == 0)
		{
			FlxG.sound.play(Paths.sound("buawawawawa"));
			reaction.anim.play("anim");
		}
	}

	// TODO: Р С—Р ВµРЎР‚Р ВµР Р…Р ВµРЎРѓРЎвЂљР С‘ Р Р…Р В° РЎРѓРЎвЂљР ВµР в„–Р Т‘Р В¶
	var scoreGroup = getVar("scoreGroup");
	// scoreGroup.camera = camHUD;
	scoreGroup.x += 560;
	scoreGroup.y += 360;
	remove(scoreGroup);
	addAheadObject(scoreGroup, boyfriendGroup);

	FlxG.stage.addEventListener(KEY_UP, onKeyRelease);
	addAheadObject(jopotr4ssSpine, boyfriendGroup);
	jopotr4ssSpine.x = boyfriend.x;
	jopotr4ssSpine.y = boyfriend.y;
	boyfriend.visible = false;

	moveCameraSection();
	snapCamFollowToPos(camFollow.x, camFollow.y);
	FlxG.camera.snapToTarget();
}

function onDestroy()
{	#if ALLOW_EIGHTSINES
	EsOrientation.setScreenOrientation(2);
	FlxG.scaleMode = prevScaleMode != null ? prevScaleMode : new RatioScaleMode();
	#end

	StructureOptionsData.onChangePost.remove(onChangeOptionPost);
	FlxG.stage.removeEventListener(KEY_UP, onKeyRelease);
	point.put();
}

function onUpdate(elapsed)
{
	#if FLX_NO_TOUCH
	return;
	#end

	for (touch in FlxG.touches.list)
	{
		checkStrumNoteTouch(0, touch);
		checkStrumNoteTouch(3, touch);
	}
}

function checkStrumNoteTouch(noteIndex:Int, touch:FlxTouch)
{
	var strumNote = playerStrumLine.strumNotes.members[noteIndex];
	if (strumNote.overlapsPoint(touch.getWorldPosition(camHUD, strumNote._point), true, camHUD))
	{
		if (touch.justPressed)
			MobileHint.handleInput(noteIndex);

		if (touch.justReleased)
			MobileHint.handleInput(noteIndex, true);
	}
}

var _lastTimeScale;
function onUpdatePost(elapsed)
{
	_lastTimeScale ??= FlxG.timeScale;
	if (_lastTimeScale != FlxG.timeScale)
		updatePhysContaints();
	_lastTimeScale = FlxG.timeScale;
}

function onCountdownStarted()
{
	// ClientPrefs.downScroll = FlxG.save.data.downScroll;
	// strumLineNotes.members[0].visible = false;
	// strumLineNotes.members[1].visible = false;
	// strumLineNotes.members[2].visible = false;
	// strumLineNotes.members[3].visible = false;
	for (i in strumLines)
	{
		i.visible = i.isPlayer;
		i.downScroll = true;
	}
	enterStrum(playerStrumLine.strumNotes.members[0], 0);
	playerStrumLine.strumNotes.members[1].visible = false;
	playerStrumLine.strumNotes.members[2].visible = false;
	enterStrum(playerStrumLine.strumNotes.members[3], 1);
}

function enterStrum(strum:StrumNote, i:Int)
{
	var even = FlxMath.isEven(i);
	strum.texture = skin;
	strum.flipX = !even;
	strum.x += 65 * (even ? 1 : -1);
	strum.y += 10;
	FlxTween.cancelTweensOf(strum);
	FlxTween.tween(strum, {y: (strum.y -= 15) + 15, alpha: 1}, 0.8, {ease: FlxEase.circOut, startDelay: 0.3 * i * playerStrums.scaleNoteFactor});
}

function onSpawnNote(note:Note)
{
	note.texture = skin;
}

function getSlapPower() return FlxG.random.float(0.95, 1.25);

var lastNote:Note;
function goodNoteHit(note:Note)
{
	var daPower = getSlapPower();

	GamepadUtil.vibrateGameplayTap();

	FlxG.sound.play(Paths.sound("cool-minigame/slap-hit"), 0.85).pitch = FlxG.random.float(0.87, 1.13);
	if (lastNote != null && FlxMath.equal(note.strumTime, lastNote.strumTime, 1)) // || FlxG.random.bool(10)
	{
		FlxG.sound.play(Paths.soundRandom("cool-minigame/reaction", 1, 11), 5).pitch = FlxG.random.float(0.93, 1.07);
		FlxG.camera.zoom += 0.015 * camZoomingMult;
		camHUD.zoom += 0.03 * camZoomingMult;
		tweenStrum(strumLineNotes.members[4]);
		tweenStrum(strumLineNotes.members[7]);
		// jopotr4ssSpine?.skeleton.physicsTranslate(
		// 	FlxG.random.float(0.85, 1.5) * FlxG.random.sign(50) * 240,
		// 	FlxG.random.sign(50) * 10
		// );
		if (cheekLConstraint != null)
		{
			var daPower = getSlapPower() / FlxG.timeScale;
			resetPhysContaint(cheekLConstraint);
			cheekLConstraint.translate(
				-1000 * daPower,
				528 * daPower
			);
		}
		if (cheekRConstraint != null)
		{
			var daPower = getSlapPower() / FlxG.timeScale;
			resetPhysContaint(cheekRConstraint);
			cheekRConstraint.translate(
				1000 * daPower,
				528 * daPower
			);
		}
	}
	else
	{
		// jopotr4ssSpine?.skeleton.physicsTranslate(
		// 	FlxG.random.float(0.85, 1.5) * slapLeftSideFactor * 120,
		// 	FlxG.random.sign(50) * 2
		// );
		if (cheekLConstraint != null)
		{
			var daPower = getSlapPower() / FlxG.timeScale;
			var slapLeftSideFactor = note.noteData == 0 ? -1 : 0.1;
			slapLeftSideFactor *= daPower;
			cheekLConstraint.translate(
				slapLeftSideFactor * 700,
				332 * -slapLeftSideFactor
			);
		}
		if (cheekRConstraint != null)
		{
			var daPower = getSlapPower() / FlxG.timeScale;
			var slapRightSideFactor = note.noteData == 3 ? 1 : -0.1;
			slapRightSideFactor *= daPower;
			cheekRConstraint.translate(
				slapRightSideFactor * 700,
				332 * slapRightSideFactor
			);
		}
	}
	lastNote = note;
}

function tweenStrum(strum:StrumNote)
{
	FlxTween.cancelTweensOf(strum);
	strum.color = 0xFFF9D96A;
	FlxTween.color(strum, 0.6, strum.color, FlxColor.WHITE);
}

var pressedKeys = [];
var blockPressedKeys = false;

function preKeyPress(key:Int)
{
	// РЎвЂљРЎС“РЎвЂљ Р В±РЎвЂ№Р В»Р В° Р С•РЎвЂљРЎРѓР В°Р В»Р С”Р В° Р Р…Р В° Р С”Р ВµР С—Р С•РЎвЂЎР С”РЎС“ Р СР С‘РЎРѓР В°Р в„–Р Т‘, РЎРѓР ВµР в„–РЎвЂЎР В°РЎРѓ Р С•Р Р…Р В° Р С—РЎР‚Р С•Р С—Р В°Р В»Р В°
	// https://media.istockphoto.com/photos/insane-person-in-straitjacket-picture-id180810522?k=6&m=180810522&s=612x612&w=0&h=Bd60Iok1tjd-bOvpNIs9FnCd2gGp69w16D0qIv73ek8=
	if (!blockPressedKeys && !pressedKeys.contains(key))
		pressedKeys.push(key);

	var redirect = redirectKey(key);
	if (redirect != null)
	{
		blockPressedKeys = true;
		keyPressed(redirect);
		blockPressedKeys = false;
		return Function_Stop;
	}

	if (pressedKeysCheck(key, 0, 1) || pressedKeysCheck(key, 2, 3))
		return Function_Stop;
}

function pressedKeysCheck(key:Int, a:Int, b:Int)
{
	if (key == a || key == b)
	{
		var hasA = pressedKeys.contains(a);
		var hasB = pressedKeys.contains(b);
		return (hasA || hasB) && hasA == hasB;
	}
	return false;
}

function onResume()
{
	pressedKeys.resize(0);
}

function onKeyRelease(event:KeyboardEvent)
{
	// Р В° Р СР С•Р В¶Р ВµРЎвЂљ Р С—Р С•РЎвЂ¦РЎС“Р в„–?
	// if (controls.controllerMode)
	//	 return;

	var key = PlayState.getKeyFromEvent(keysArray, event.keyCode);
	var redirect = redirectKey(key);
	if (redirect != null /*&& !pressedKeysCheck(key, 0, 1) && !pressedKeysCheck(key, 2, 3)*/)
		keyReleased(redirect);

	pressedKeys.remove(key);
}

function redirectKey(key:Int):Null<Int>
{
	return switch (key)
	{
		case 1: 0;
		case 2: 3;
		default: null;
	}
}


