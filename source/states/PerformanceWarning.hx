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
	var dot1:FlxSprite;
	var dot2:FlxSprite;
	var dot3:FlxSprite;

	override function create()
	{
		super.create();

		FlxG.sound.play(Paths.sound('performance/appear'), 0.9);

		var colorBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF130024);
		add(colorBg);

		background = new FlxSprite().loadGraphic(Paths.image('performanceMenu/image'));
		background.alpha = 0;
		background.scale.set(0.75, 0.75);
		background.antialiasing = ClientPrefs.data.antialiasing;
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

		dot1 = new FlxSprite();
		dot1.loadGraphic(Paths.image('performanceMenu/loadingDot'));
		dot1.antialiasing = ClientPrefs.data.antialiasing;
		dot1.x = 15 + bfSprite.width + 70;
		dot1.y = FlxG.height - dot1.height - 25;
		dot1.alpha = 0;
		add(dot1);

		dot2 = new FlxSprite();
		dot2.loadGraphic(Paths.image('performanceMenu/loadingDot'));
		dot2.antialiasing = ClientPrefs.data.antialiasing;
		dot2.x = dot1.x + dot1.width + 30;
		dot2.y = FlxG.height - dot1.height - 25;
		dot2.alpha = 0;
		add(dot2);

		dot3 = new FlxSprite();
		dot3.loadGraphic(Paths.image('performanceMenu/loadingDot'));
		dot3.antialiasing = ClientPrefs.data.antialiasing;
		dot3.x = dot2.x + dot2.width + 30;
		dot3.y = FlxG.height - dot1.height - 25;
		dot3.alpha = 0;
		add(dot3);

		loadingSound = new FlxSound();
		loadingSound.loadEmbedded(Paths.sound('performance/loading'));
		FlxG.sound.list.add(loadingSound);
	}

	var loadingSound:FlxSound;
	var pressedEnter:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if((controls.ACCEPT || TouchUtil.justPressed) && !pressedEnter)
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

					loadingDotsAnim(dot1);
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						loadingDotsAnim(dot2);
					});
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						loadingDotsAnim(dot3);
					});

					bfSprite.y += 10;
					FlxTween.tween(bfSprite, {y: bfSprite.y - 10, alpha: 1}, 0.95, {ease: FlxEase.quartOut});
					new FlxTimer().start(FlxG.random.float(1.85, 3.15), function(tmr:FlxTimer) // hehe random timer so it feels annoying sometimes
					{
						loadingSound.fadeOut(0.45);
						FlxTween.tween(dot1, {alpha: 0}, 0.95, {ease: FlxEase.quartOut});
						FlxTween.tween(dot2, {alpha: 0}, 0.95, {ease: FlxEase.quartOut});
						FlxTween.tween(dot3, {alpha: 0}, 0.95, {ease: FlxEase.quartOut});
						FlxTween.tween(bfSprite, {y: bfSprite.y + 10, alpha: 0}, 0.95, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
						{
							goToTitle();
						}});
					});
				});
			}}); 
		}
	}

	function loadingDotsAnim(targetDot:FlxSprite)
	{
		FlxTween.tween(targetDot, {alpha: 1, y: FlxG.height - targetDot.height - 50}, 0.37, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
		{
			FlxTween.tween(targetDot, {y: FlxG.height - targetDot.height - 25}, 0.37, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween)
			{
				loadingDotsAnim(targetDot);
			}});
		}});
	}

	function goToTitle()
	{
		leftState = true;
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());
	}
}