loadHScript(AssetsPaths.getPath("data/smert_vikluchit.hx"));

var ama:FlxSprite;
var nai:FlxSprite;
var amaBG:FlxSprite;
var naiBG:FlxSprite;

function onCreatePost()
{
	var thisScript = game.scriptPack.getHScript("moveCam");
	game.scriptPack.hscriptArray.remove(thisScript);
	thisScript.call("onDestroy", []);
	thisScript.destroy();

	final amaFrames = Paths.getSparrowAtlas("characters/ama");
	final naiFrames = Paths.getSparrowAtlas("characters/nai");

	ama = makeSprite(31.1, 84.5, amaFrames, "ama_body", true);
	nai = makeSprite(691, 110.6, naiFrames, "nai_body", true);
	amaBG = makeSprite(14.8, 186.8, amaFrames, "ama_idle", false);
	naiBG = makeSprite(924.9, 210.7, naiFrames, "nai_idle", false);

	boyfriend.visible = false;
	dad.visible = false;

	isCameraOnForcedPos = true;
	camFollow.set(FlxG.width / 2, FlxG.height / 2);
	FlxG.camera.scroll.set();
	getVar("scoreGroup").visible = false;
}

function onSongStart()
{
	ama.visible = true;
	dad.visible = true;
}

function onBeatHit()
{
	amaBG.animation.play("idle", true);
	naiBG.animation.play("idle", true);
}

function onEvent(name, value1, value2)
{
	switch (name)
	{
		case "":
			final sing = (value1 == "1");

			boyfriend.visible = sing;
			amaBG.visible = sing;
			naiBG.visible = sing;

			dad.visible = !sing;
			ama.visible = (dad.visible ? dad.curCharacter == "ama" : false);
			nai.visible = (dad.visible ? dad.curCharacter == "nai" : false);

		case "Change Character":
			ama.visible = (value2 == "ama");
			nai.visible = (value2 == "nai");
			// втффф????
			dad.visible = true;
	}
}

function makeSprite(x, y, frames, prefix, loop)
{
	final s = new FlxSprite(x, y);
	s.frames = frames;
	s.animation.addByPrefix("idle", prefix, 24, loop);
	s.animation.play("idle");
	s.moves = false;
	s.visible = false;
	addBehindGF(s);
	return s;
}
