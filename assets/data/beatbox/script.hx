import game.backend.utils.WindowUtil;

loadHScript("data/psychHUD.hx");
importHScriptClasses("scripts/classes/ExplosionSprite.hx");

var boom:ExplosionSprite;
function onCreatePost()
{
	boom = new ExplosionSprite();
	boom.animation.callback = (n, f, i) -> if (f >= 2) dadGroup.visible = false;
	boom.animation.play("boom");
	boom.kill();
	boom.setPosition(dad.x, dad.y);
	boom.setGraphicSize(dad.width, dad.height);
	boom.updateHitbox();
	boom.scale.set(boom.scale.x * dad.scale.x * 2.6, boom.scale.y * dad.scale.y * 2.6);
	addAheadObject(boom, dadGroup);

	// if (boyfriend.curCharacter == "bf")
	// {
		boyfriend.jsonScale *= 1.25;
		boyfriend.scale.set(boyfriend.jsonScale, boyfriend.jsonScale);
		boyfriend.y -= 50.0;
	// }
	// if (gf.curCharacter == "gf")
	// {
		gf.jsonScale *= 1.25;
		gf.scale.set(gf.jsonScale, gf.jsonScale);
	// }
	moveCameraSection();
	WindowUtil.prefix = "Коротко про весь ";
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name == "" && value1 == "взорвись")
	{
		trace("взрыв нахуй");
		boom.revive();
		FlxG.sound.play(Paths.sound("system/explode1"));
		FlxG.sound.play(Paths.sound("explosion"));
	}
}