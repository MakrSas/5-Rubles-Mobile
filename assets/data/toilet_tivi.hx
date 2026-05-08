#if !DEV_BUILD static #end var GF_OFFSET = 120;
#if !DEV_BUILD static #end var ROPE_OFFSET = 777; // НЕВЕР СТОП ГЭМБЛИНГ!!!! 🎰🎰🎰
#if !DEV_BUILD static #end var SWAY_SPEED = 17; // привет свау

var tv:Character;
var rope:FlxSprite;
var acceleration = 0;
var direction = 0;

function onCreatePost()
{
	tv = getVar("gf_tv");

	rope = new FlxSprite(gf.x - gfGroup.x, gf.y - gfGroup.y, Paths.image("KrasnBeloe/toilettv"));
	rope.x += (gf.width + rope.width) / 2 - 110;
	rope.y -= rope.height - 300;
	rope.scale.set(0.9, 0.9);
	rope.updateHitbox();
	rope.shader = tv.shader;

	gfGroup.insert(0, rope);
	gfGroup.y += GF_OFFSET;

	for (spr in gfGroup.members)
	{
		// хз как но оно работает - rich
		spr.updateHitbox();
		// МАГИЧЕСКОЕ ДЕРЬМО ТРАСТ МИ - rich
		spr.origin.set(723.45 - spr.x + spr.offset.x * spr.scale.x, -1041 - spr.y + spr.offset.y * spr.scale.y);
	}

	gfGroup.x += gf.offset.x;
	gfGroup.y += gf.offset.y;
	rope.y -= ROPE_OFFSET;
}

var beatLen = 4;
function onBeatHit(beat:Int)
{
	if (direction == 0)
		return;

	if (beat % beatLen == 0)
		direction *= -1;
}

function onUpdatePost(elapsed:Float)
{
	if (direction == 0)
		return;

	var target = acceleration * direction;
	var angle = CoolUtil.fpsLerp(rope.angle, FlxMath.lerp(target * -1, target, FlxEase.quadInOut((curDecBeat % beatLen) / beatLen)), 0.5);
	for (spr in gfGroup.members)
		spr.angle = angle;
}

function onEvent(name:String, value1:String, value2:String, value3:String)
{
	if (name != "")
		return;

	switch (value1)
	{
		case "тоилет_тиви":
			var crochet = Conductor.crochet / 1000;
			// 8 битов на опускание веревки
			FlxTween.num(rope.y, rope.y + ROPE_OFFSET, crochet * 8, {
				ease: FlxEase.backOut,
				onComplete: _ ->
				{
					if (tv != null)
					{
						@:bypassAccessor tv.idleSuffix = "-alt";
						tv.recalculateDanceIdle();
						tv.animation.timeScale = 1.5;
						tv.playAnim("imgay");
						tv.skipDance = true;
					}

					// 2-х битовая тряска тряски
					var offset = FlxG.random.int(8, 12);
					FlxTween.num(gfGroup.y, gfGroup.y - offset, crochet * 2,
					{
						ease: FlxEase.backOut,
						onComplete: _ ->
						{
							// 6 битов на поднятие тоилет тиви
							FlxTween.num(gfGroup.y, gfGroup.y - GF_OFFSET + offset, crochet * 6, {
								ease: FlxEase.backInOut,
								onComplete: _ ->
								{
									if (tv != null)
									{
										tv.skipDance = false;
										tv.dance();
									}

									// начинаем перекрут
									direction = FlxG.random.int(-1, 1, [0]);
									// ждем 1 бит и 7 битов на увеличение силы раскачки
									FlxTween.num(0, SWAY_SPEED, crochet * 7, {startDelay: crochet}, a -> acceleration = a);
								}
							}, gfGroup.set_y);
						}
					}, gfGroup.set_y);
				}}, rope.set_y);

		case "холд_ап":
			if (tv != null)
			{
				tv.animation.timeScale = 1;
				tv.danceEveryNumBeats = 2;
			}

		case "спид_ап":
			if (tv != null)
			{
				tv.animation.timeScale = 1.5;
				tv.danceEveryNumBeats = 1;
			}
	}
}

function onGameOverStart()
{
	if (tv != null)
		tv.animation.timeScale = 1;
}