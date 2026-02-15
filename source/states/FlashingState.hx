package states;

import states.gallery.GalleryPreload;
import flixel.FlxSubState;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import objects.ParticleGroup;
import objects.CheckOptionObject;

import openfl.filters.ShaderFilter;
import shaders.DeflectiveLens;
import shaders.BloomShader;
import shaders.ChromaticAberration;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxSprite;
	var icons:FlxBackdrop;
	var particles:ParticleGroup;
	var gradient:FlxSprite;
	var gradient2:FlxSprite;
	var warningText:Alphabet;
	var infoText:Alphabet;
	var infoText2:Alphabet;
	var infoText3:Alphabet;

	var flashingLightsOpt:CheckOptionObject;
	var shadersOpt:CheckOptionObject;

	var pressEnterToContinueText:Alphabet;

	var deflectiveLensShader:DeflectiveLens;
	var deflectiveLensFilter:ShaderFilter;
	var bloomShader:BloomShader;
	var bloomFilter:ShaderFilter;
	var rgbShader:ChromaticAberration;
	var rgbFilter:ShaderFilter;

	override function create()
	{
		super.create();

		var startTweenDuration:Float = 0.6;

		FlxG.mouse.visible = true;

		GalleryPreload.preloadMusic();
		GalleryPreload.preloadImages('outdated_concepts');
		GalleryPreload.preloadImages('bored');

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF030007);
		add(bg);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(10, 10);
		icons.alpha = 1;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		icons.blend = MULTIPLY;
		add(icons);

		particles = new ParticleGroup(0, 0, FlxG.width, 400, 'particle');
		//particles.y = FlxG.height - particles.height;
		particles.startY = FlxG.height;
		particles.endY = FlxG.height - 450;
		particles.initialScale = 0.25;
		particles.fadeSpeed = 0.8;
		particles.randomX = 90;
		particles.randomY = 90;
		add(particles);

		gradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, ([0xFF030007, 0xFF4B2E71]));
		//gradient.alpha = 0.45;
		gradient.alpha = 0;
		add(gradient);

		FlxTween.tween(gradient, {alpha: 0.45}, startTweenDuration);

		gradient2 = FlxGradient.createGradientFlxSprite(FlxG.width, Std.int(FlxG.height * 0.5), ([0xFF030007, 0xFFFFFFFF]));
		//gradient2.alpha = 0.15;
		gradient2.alpha = 0;
		gradient2.blend = ADD;
		gradient2.y = FlxG.height - gradient2.height;
		add(gradient2);

		FlxTween.tween(gradient2, {alpha: 0.15}, startTweenDuration);

		warningText = new Alphabet(0, 80, 'WARNING!', true);
		warningText.screenCenter(X);
		warningText.color = 0xFFFF877E;
		warningText.y += 10;
		warningText.alpha = 0;
		add(warningText);
		
		FlxTween.tween(warningText, {y: warningText.y - 10, alpha: 1}, startTweenDuration);

		var text:String = 'This mod contains shaders and flashing lights.';
		var text2:String = 'Before you start playing, we would like to know';
		var text3:String = 'if you wish to disable them!';
		infoText = new Alphabet(0, warningText.y + warningText.height + 10, text, true);
		infoText.setScale(0.4, 0.4);
		infoText.screenCenter(X);
		infoText.y += 10;
		infoText.alpha = 0;
		//infoText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		add(infoText);

		FlxTween.tween(infoText, {y: infoText.y - 10, alpha: 1}, startTweenDuration);

		infoText2 = new Alphabet(0, infoText.y + infoText.height + 10, text2, true);
		infoText2.setScale(0.4, 0.4);
		infoText2.screenCenter(X);
		infoText2.y += 10;
		infoText2.alpha = 0;
		//infoText2.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		add(infoText2);

		FlxTween.tween(infoText2, {y: infoText2.y - 10, alpha: 1}, startTweenDuration);

		infoText3 = new Alphabet(0, infoText2.y + infoText2.height + 10, text3, true);
		infoText3.setScale(0.4, 0.4);
		infoText3.screenCenter(X);
		infoText3.y += 10;
		infoText3.alpha = 0;
		//infoText3.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		add(infoText3);

		FlxTween.tween(infoText3, {y: infoText3.y - 10, alpha: 1}, startTweenDuration);

		flashingLightsOpt = new CheckOptionObject(0, 0, 'Flashing Lights', ClientPrefs.data.flashing);
		flashingLightsOpt.screenCenter(X);
		flashingLightsOpt.x += 110;
		flashingLightsOpt.y = infoText3.y + infoText3.height + 80;
		flashingLightsOpt.y += 10;
		flashingLightsOpt.checkbox.alpha = 0;
		flashingLightsOpt.optionText.alpha = 0;
		add(flashingLightsOpt);

		FlxTween.tween(flashingLightsOpt, {y: flashingLightsOpt.y - 10}, startTweenDuration);
		FlxTween.tween(flashingLightsOpt.checkbox, {alpha: 1}, startTweenDuration);
		FlxTween.tween(flashingLightsOpt.optionText, {alpha: 1}, startTweenDuration);

		shadersOpt = new CheckOptionObject(0, 0, 'Shaders', ClientPrefs.data.shaders);
		shadersOpt.screenCenter(X);
		shadersOpt.x += 110;
		shadersOpt.y = flashingLightsOpt.y + flashingLightsOpt.height - 10;
		shadersOpt.y += 10;
		shadersOpt.checkbox.alpha = 0;
		shadersOpt.optionText.alpha = 0;
		add(shadersOpt);

		FlxTween.tween(shadersOpt, {y: shadersOpt.y - 10}, startTweenDuration);
		FlxTween.tween(shadersOpt.checkbox, {alpha: 1}, startTweenDuration);
		FlxTween.tween(shadersOpt.optionText, {alpha: 1}, startTweenDuration);

		pressEnterToContinueText = new Alphabet(0, 0, 'Press ENTER to continue!', false);
		pressEnterToContinueText.setScale(0.8, 0.8);
		pressEnterToContinueText.y = FlxG.height - pressEnterToContinueText.height - 100;
		//pressEnterToContinueText.x += (128 * i) - 80;
        pressEnterToContinueText.screenCenter(X);
		pressEnterToContinueText.y += 10;
		pressEnterToContinueText.alpha = 0;
		pressEnterToContinueText.antialiasing = ClientPrefs.data.antialiasing;
		add(pressEnterToContinueText);

		FlxTween.tween(pressEnterToContinueText, {alpha: 1, y: pressEnterToContinueText.y - 10}, 0.2);

		deflectiveLensShader = new DeflectiveLens();
		deflectiveLensShader.distortionScale.value = [0.0];
		//deflectiveLensShader.fringeScale.value = [0.02];
		deflectiveLensFilter = new ShaderFilter(deflectiveLensShader);

		bloomShader = new BloomShader();
		bloomShader.dim.value = [2.0]; // 1.8
		bloomShader.Directions.value = [10.0]; // 2.0, 100.0 to remove
		bloomShader.Quality.value = [8.0]; // 8.0
		bloomShader.Size.value = [0.0]; // 8.0, 1.0

		bloomFilter = new ShaderFilter(bloomShader);

		rgbShader = new ChromaticAberration();
		rgbShader.rOffset.value = [0.0];
		rgbShader.gOffset.value = [0.0];
		rgbShader.bOffset.value = [0.0];
		rgbFilter = new ShaderFilter(rgbShader);
	}

	override function update(elapsed:Float)
	{
		if(leftState) {
			super.update(elapsed);
			return;
		}

		if(FlxG.mouse.overlaps(flashingLightsOpt))
		{
			FlxTween.cancelTweensOf(flashingLightsOpt.background);
			FlxTween.tween(flashingLightsOpt.background, {alpha: 0.3}, 0.05);
			if(FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				trace('Changing from ${flashingLightsOpt.value} to ${!flashingLightsOpt.value}');
				flashingLightsOpt.value = !flashingLightsOpt.value;
			}
		}
		else
		{
			FlxTween.cancelTweensOf(flashingLightsOpt.background);
			FlxTween.tween(flashingLightsOpt.background, {alpha: 0}, 0.05);
		}

		if(FlxG.mouse.overlaps(shadersOpt))
		{
			FlxTween.cancelTweensOf(shadersOpt.background);
			FlxTween.tween(shadersOpt.background, {alpha: 0.3}, 0.05);
			if(FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				trace('Changing from ${shadersOpt.value} to ${!shadersOpt.value}');
				shadersOpt.value = !shadersOpt.value;
			}
		}
		else
		{
			FlxTween.cancelTweensOf(shadersOpt.background);
			FlxTween.tween(shadersOpt.background, {alpha: 0}, 0.05);
		}

		if (controls.ACCEPT) {
			leftState = true;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			var tweenDuration:Float = 1.2;

			FlxG.camera.zoom = 1.15;
			FlxTween.tween(FlxG.camera, {zoom: 1}, tweenDuration, {ease: FlxEase.cubeOut});

			ClientPrefs.data.shaders = shadersOpt.value;
			ClientPrefs.data.flashing = flashingLightsOpt.value;
			ClientPrefs.saveSettings();

			if(ClientPrefs.data.flashing && ClientPrefs.data.shaders) FlxG.camera.filters = [bloomFilter, rgbFilter];

			FlxTween.num(0, 1.8, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
            {
				deflectiveLensShader.distortionScale.value[0] = v;
            });

			FlxTween.num(0.001, 0, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
            {
				rgbShader.rOffset.value[0] = v;
				rgbShader.gOffset.value[0] = 0;
				rgbShader.bOffset.value[0] = -v;
            });

			FlxTween.num(1.35, 10, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
            {
				bloomShader.Directions.value[0] = v;
            });

			FlxTween.num(1.45, 2, tweenDuration, {ease: FlxEase.cubeOut}, function(v:Float)
            {
				bloomShader.dim.value[0] = v;
            });

			FlxTween.cancelTweensOf(gradient);
			FlxTween.cancelTweensOf(gradient2);
			FlxTween.cancelTweensOf(particles);
			FlxTween.cancelTweensOf(infoText);
			FlxTween.cancelTweensOf(infoText2);
			FlxTween.cancelTweensOf(infoText3);
			FlxTween.cancelTweensOf(flashingLightsOpt.checkbox);
			FlxTween.cancelTweensOf(flashingLightsOpt.optionText);
			FlxTween.cancelTweensOf(flashingLightsOpt.background);
			FlxTween.cancelTweensOf(shadersOpt.checkbox);
			FlxTween.cancelTweensOf(shadersOpt.optionText);
			FlxTween.cancelTweensOf(shadersOpt.background);
			FlxTween.cancelTweensOf(pressEnterToContinueText);

			FlxTween.tween(gradient, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(gradient2, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(particles, {alpha: 0}, tweenDuration, {ease: FlxEase.cubeOut});

			FlxTween.tween(warningText, {alpha: 0, y: warningText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(infoText, {alpha: 0, y: infoText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(infoText2, {alpha: 0, y: infoText2.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(infoText3, {alpha: 0, y: infoText3.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(flashingLightsOpt.checkbox, {alpha: 0, y: flashingLightsOpt.checkbox.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(flashingLightsOpt.optionText, {alpha: 0, y: flashingLightsOpt.optionText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(flashingLightsOpt.background, {alpha: 0, y: flashingLightsOpt.background.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(shadersOpt.checkbox, {alpha: 0, y: shadersOpt.checkbox.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(shadersOpt.optionText, {alpha: 0, y: shadersOpt.optionText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(shadersOpt.background, {alpha: 0, y: shadersOpt.background.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});
			FlxTween.tween(pressEnterToContinueText, {alpha: 0, y: pressEnterToContinueText.y - 10}, tweenDuration, {ease: FlxEase.cubeOut});

			new FlxTimer().start(1.5, function(t:FlxTimer)
			{
				MusicBeatState.switchState(new TitleState());
			});
		}
		super.update(elapsed);
	}
}