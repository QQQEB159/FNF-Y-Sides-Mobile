package states;

import states.gallery.GalleryPreload;
import flixel.FlxSubState;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import objects.ParticleGroup;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class PerformanceWarning extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxSprite;
	var icons:FlxBackdrop;
	var particles:ParticleGroup;
	var gradient:FlxSprite;
	var gradient2:FlxSprite;
	var warningText:Alphabet;
	var infoText:FlxText;
	var pressEnterToContinueText:Alphabet;

	override function create()
	{
		super.create();

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
		//blackScreenGradient.alpha = 0.45;
		gradient.alpha = 0.45;
		add(gradient);

		gradient2 = FlxGradient.createGradientFlxSprite(FlxG.width, Std.int(FlxG.height * 0.5), ([0xFF030007, 0xFFFFFFFF]));
		//gradient2.alpha = 0.15;
		gradient2.alpha = 0.15;
		gradient2.blend = ADD;
		gradient2.y = FlxG.height - gradient2.height;
		add(gradient2);

		warningText = new Alphabet(0, 80, 'WARNING!', true);
		warningText.screenCenter(X);
		warningText.color = 0xFFFF877E;
		add(warningText);

		var text:String = 'This mod contains shaders and flashing lights.';
		infoText = new FlxText(0, warningText.y + warningText.height + 10, FlxG.width, text);
		infoText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 30, 0xFFF1E7FF, CENTER);
		add(infoText);

		pressEnterToContinueText = new Alphabet(0, 0, 'Press ENTER to continue!', false);
		pressEnterToContinueText.setScale(0.8, 0.8);
		pressEnterToContinueText.y = FlxG.height - pressEnterToContinueText.height - 50;
		//pressEnterToContinueText.x += (128 * i) - 80;
        pressEnterToContinueText.screenCenter(X);
		pressEnterToContinueText.y += 10;
		pressEnterToContinueText.alpha = 0;
		pressEnterToContinueText.antialiasing = ClientPrefs.data.antialiasing;
		add(pressEnterToContinueText);

		FlxTween.tween(pressEnterToContinueText, {alpha: 1, y: pressEnterToContinueText.y - 10}, 0.2);
	}

	override function update(elapsed:Float)
	{
		if(leftState) {
			super.update(elapsed);
			return;
		}

		if (controls.ACCEPT) {
			leftState = true;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			//FlxTween.tween(warnText, {alpha: 0, y: warnText.y - 10}, 0.2);
			FlxTween.tween(pressEnterToContinueText, {alpha: 0, y: pressEnterToContinueText.y - 10}, 0.2);

			new FlxTimer().start(1, function(t:FlxTimer)
			{
				MusicBeatState.switchState(new TitleState());
			});
		}
		super.update(elapsed);
	}
}
