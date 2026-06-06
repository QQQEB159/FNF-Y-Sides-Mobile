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

	override function create()
	{
		super.create();

		var background = new FlxSprite().loadGraphic(Paths.image('performanceMenu/image'));
		add(background);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(controls.ACCEPT)
		{
			leftState = true;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new TitleState());
		}
	}
}