package states.stages;

import flixel.addons.display.FlxBackdrop;
import states.stages.objects.*;
import objects.Character;
import objects.SnowParticles;

class SkiStage extends BaseStage
{
	override function create()
	{
		var sky:BGSprite = new BGSprite('stages/skiStage/sky', -1000, -700, 0, 0);
		add(sky);

		if(!ClientPrefs.data.lowQuality)
		{
			var sun:BGSprite = new BGSprite('stages/skiStage/sun', -1000, -700, 0, 0);
			add(sun);

			var clouds:FlxBackdrop = new FlxBackdrop(Paths.image('stages/skiStage/clouds'));
			clouds.scrollFactor.set(0.1, 0.1);
			clouds.setPosition(-1000, -1200);
			clouds.velocity.set(10, 0);
			add(clouds);

			var sunLight:BGSprite = new BGSprite('stages/skiStage/sun_light', -1000, -700, 0, 0);
			add(sunLight);
		}

		var mountains:BGSprite = new BGSprite('stages/skiStage/mountains', -600, -200, 0.3, 0.3);
		add(mountains);

		var snowBack2:BGSprite = new BGSprite('stages/skiStage/snowBack2', -400, -200, 0.6, 0.6);
		add(snowBack2);

		var snowBack:BGSprite = new BGSprite('stages/skiStage/snowBack', -300, -100, 0.75, 0.75);
		add(snowBack);

		var fence:BGSprite = new BGSprite('stages/skiStage/fence', 0, 0, 1, 1);
		add(fence);

		var snow:BGSprite = new BGSprite('stages/skiStage/snow', 0, 0, 1, 1);
		add(snow);

		var buildings:BGSprite = new BGSprite('stages/skiStage/buildings', 0, 0, 1, 1);
		add(buildings);
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var snow:SnowParticles = new SnowParticles(0, 0, 3840, 400, 'stages/skiStage/snowParticle');
			snow.startY = 300;
			snow.endY = 1500;
			snow.intensity = 6; // snow intensity = 9 is like too much (eggnog.. ) for cocoa i would like less snow and sunnier weather
			snow.xIntensity = -500;
			snow.endScale = 1;
			snow.randomX = 150;
			snow.randomY = 150;
			snow.spawnDelay = 0.15;
			snow.initialScale = 0.75;
			snow.endScale = 0.55;
			snow.fadeSpeed = 1.5;
			add(snow);

			var snowboards:BGSprite = new BGSprite('stages/skiStage/snowboards', 0, 0, 1, 1);
			add(snowboards);

			var lights:BGSprite = new BGSprite('stages/skiStage/lights', 0, 0, 1, 1);
			lights.blend = ADD;
			add(lights);
			
			var shadow:BGSprite = new BGSprite('stages/skiStage/shadow', 0, 0, 1, 1);
			add(shadow);
		}
	}
}