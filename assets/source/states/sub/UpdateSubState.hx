#if UPDATE_FEATURE
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEvent;
import flixel.system.FlxBGSprite;
import flxanimate.FlxAnimate;
import hxvlc.flixel.FlxVideoSprite;
#if EDITORS_ALLOWED
import game.states.editors.ChartingState;
#end
import game.backend.data.jsons.WeekData;
import game.backend.system.net.Downloader;
import game.backend.system.song.Song;
import game.backend.system.states.MusicBeatState;
import game.backend.utils.FileUtil;
import game.backend.utils.Highscore;
import game.backend.utils.HttpUtil;
import game.backend.utils.PathUtil;
import game.objects.VideoSprite;
import game.objects.openfl.UpdaterPopup;
import game.states.LoadingState;
import game.states.substates.GameplayChangersSubstate;

var addButn;
var removeButn;
var ui;

static final MAX_BLUR_SIZE = 10;
var _lastBlurSize = 0;
var _blurScrTween:FlxTween;
var _blurScrShader:FlxRuntimeShader;
var _lastToogleBlurScr = false;
var _enableButtons:Bool = false;

function create() {
	camera = FlxG.cameras.add(new FlxCamera(), false);
	camera.bgColor = FlxColor.TRANSPARENT;
	persistentUpdate = true;

	ui = new FlxSprite(0, 0, Paths.image("updateWindow/window"));
	add(ui);
	ui.screenCenter();

	bgSprite.color = FlxColor.BLACK;
	bgSprite.alpha = 0;

	_blurScrShader = new FlxRuntimeShader(Assets.getText(AssetsPaths.fragShader("BlurCamera")));
	FlxG.camera.setFilters([new ShaderFilter(_blurScrShader)]);
	FlxG.camera.filtersEnabled = ClientPrefs.shaders;

	var buttonsFrames = Paths.getSparrowAtlas("updateWindow/buttons");
	addButn = new FlxSprite(465.35, 443.2);
	removeButn = new FlxSprite(691.45, 443.2);
	addButn.frames = removeButn.frames = buttonsFrames;
	addButn.animation.addByIndices("", "BUTTON_YESORNO", [0, 1], "", 0);
	removeButn.animation.addByIndices("", "BUTTON_YESORNO", [2, 3], "", 0);
	addButn.animation.play("");
	removeButn.animation.play("");
	add(addButn);
	add(removeButn);

	var buildAsset = __globalScript__.getVar("updateData");
	var url = buildAsset.browser_download_url;
	var eregFile = ~/\/([^\s\/]*.\w*)$/;
	var filePath = "./" + (eregFile.match(url) ? eregFile.matched(1) : UpdaterPopup.gitHubRepBuildFile);
	FlxMouseEvent.add(addButn, _ -> {
		if (_enableButtons)
		{
			trace("Accept");
			_enableButtons = false;

			var oldAutoPause = FlxG.autoPause;
			FlxG.autoPause = true; // trying to stop game

			FileUtil.browseForSaveFile([FileUtil.FILE_FILTER_ZIP],
				path -> {
					exit();
					Main.fpsVar.addDowloaderUI(Downloader.downloadFileFromUrl(url, path));
					FlxG.autoPause = oldAutoPause;
				},
				() -> {
					_enableButtons = true;
					FlxG.autoPause = oldAutoPause;
				},
				filePath,
				'Install New Build'
			);
		}
	}, null, _ -> addButn.animation.curAnim.curFrame = 1, _ -> addButn.animation.curAnim.curFrame = 0, false, true, false);

	FlxMouseEvent.add(removeButn, _ -> {
		if (_enableButtons)
		{
			trace("no");
			exit();
		}
	}, null, _ -> removeButn.animation.curAnim.curFrame = 1, _ -> removeButn.animation.curAnim.curFrame = 0, false, true, false);

	camera.visible = false;
	var time = 10 / 24;
	FlxTween.num(bgSprite.alpha = 0, 0.2, 5 / 24, null, bgSprite.set_alpha);
	FlxTween.num(camera.zoom = 0, 1.0, time, {ease: FlxEase.backOut, onStart: _ -> camera.visible = true}, camera.set_zoom);
	toggleBlurScreen(true, time);
	new FlxTimer().start(time - 0.1, _ -> _enableButtons = true);

	FlxG.mouse.visible = true;
}
function createPost() {
	closeCallback = () -> {
		if (!_parentState.destroySubStates)
			destroy(); // he's going to die anyway
	}
}

function onUpdateScreenBlur(i:Float)
{
	_lastBlurSize = i;
	_blurScrShader.setFloatArray("blurSize", [i, i]);
}
function toggleBlurScreen(toggle:Bool, time:Float)
{
	if (_lastToogleBlurScr == toggle)
		return;
	_lastToogleBlurScr = toggle;
	_blurScrTween?.cancel();
	_blurScrTween = FlxTween.num(_lastBlurSize, toggle ? MAX_BLUR_SIZE : 0, time, {onComplete: _ -> _blurScrTween = null}, onUpdateScreenBlur);
}

function exit() {
	_enableButtons = false;
	__globalScript__.setVar("updateData", null);
	var time = 0.5;
	toggleBlurScreen(false, time);
	FlxTween.num(camera.zoom, 0.0, time, {ease: FlxEase.backIn, onComplete: _ -> camera.visible = false}, camera.set_zoom);
	new FlxTimer().start(time + 0.1, _ -> close());
}

function destroy() {
	FlxG.cameras.remove(camera, true);
	FlxG.camera.setFilters([]);
}
#end
