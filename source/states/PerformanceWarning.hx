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

class PerformanceWarning extends MusicBeatState
{
	public static var leftState:Bool = false;

	public function new()
	{
		super();
		
		// preload gallery stuff
		// GalleryPreload.preloadMusic();
		// GalleryPreload.preloadImages('outdated_concepts');
		// GalleryPreload.preloadImages('bored');
	}

	var background:FlxSprite;
	var bfSprite:FlxSprite;

	override function create()
	{
		super.create();

		FlxG.sound.play(Paths.sound('performance/appear'), 0.9);

		var colorBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF130024);
		add(colorBg);

		background = new FlxSprite().loadGraphic(Paths.image('performanceMenu/image'));
		background.alpha = 0;
		background.scale.set(0.75, 0.75);
		add(background);

		bfSprite = new FlxSprite();
		bfSprite.frames = Paths.getSparrowAtlas('performanceMenu/bfWalkin');
		bfSprite.animation.addByPrefix('idle', 'bfwalk', 4, true);
		bfSprite.animation.play('idle');
		bfSprite.alpha = 0;
		bfSprite.antialiasing = ClientPrefs.data.antialiasing;
		bfSprite.scale.set(0.55, 0.55);
		bfSprite.updateHitbox();
		bfSprite.x = 15;
		bfSprite.y = FlxG.height - bfSprite.height - 15;
		add(bfSprite);

		FlxTween.tween(background, {alpha: 1}, 0.3);
		FlxTween.tween(background, {"scale.x": 1, "scale.y": 1}, 0.3, {ease: FlxEase.elasticOut, onComplete: function(twn:FlxTween) 
		{
			colorBg.alpha = 0;	
		}});

		loadingSound = new FlxSound();
		loadingSound.loadEmbedded(Paths.sound('performance/loading'));
		FlxG.sound.list.add(loadingSound);
	}

	var loadingSound:FlxSound;
	var pressedEnter:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(controls.ACCEPT && !pressedEnter)
		{
			pressedEnter = true;
			FlxG.sound.play(Paths.sound('performance/enter'), 0.9);

			FlxTween.tween(background, {alpha: 0}, 0.3, {ease: FlxEase.quartOut});
			FlxTween.tween(background, {"scale.x": 0.75, "scale.y": 0.75}, 0.3, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(0.9, function(tmr:FlxTimer)
				{
					//FlxG.sound.play(Paths.sound('performance/loading'), 0.9);
					loadingSound.play();

					// precache stuff into premanent assets so they NEVER lag the game never gbvevers
					var fnflosssfx = new FlxSound();
					fnflosssfx.loadEmbedded(Paths.sound('fnf_loss_sfx'));

					Paths.permanentTrackedAssets.set('gameover', fnflosssfx);

					bfSprite.y += 10;
					FlxTween.tween(bfSprite, {y: bfSprite.y - 10, alpha: 1}, 0.95, {ease: FlxEase.quartOut});
					new FlxTimer().start(FlxG.random.float(1.85, 3.15), function(tmr:FlxTimer) // hehe random timer so it feels annoying sometimes
					{
						loadingSound.fadeOut(0.45);
						FlxTween.tween(bfSprite, {y: bfSprite.y + 10, alpha: 0}, 0.95, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
						{
							goToTitle();
						}});
					});
				});
			}}); 
		}
	}

	function goToTitle()
	{
		leftState = true;
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());
	}
}