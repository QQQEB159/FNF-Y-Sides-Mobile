package states.stages;

import flixel.addons.display.FlxBackdrop;
import shaders.Dubswitcher;
import shaders.ColorSwap.ColorSwapShader;
import openfl.filters.ShaderFilter;
import states.stages.objects.*;
import objects.Character;
import objects.SnowParticles;

class SkiCreepyStage extends BaseStage
{
	var dubswitcherShader:Dubswitcher;
	var dubswitcherFilter:ShaderFilter;
	var colorSwapShader:ColorSwapShader;
	var colorSwapFilter:ShaderFilter;

	override function create()
	{
		var sky:BGSprite = new BGSprite('stages/skiStage/sky', -1000, -1000, 0, 0);
		add(sky);

		if(!ClientPrefs.data.lowQuality)
		{
			var sun:BGSprite = new BGSprite('stages/skiStage/sun', -1000, -1000, 0, 0);
			add(sun);

			var clouds:FlxBackdrop = new FlxBackdrop(Paths.image('stages/skiStage/clouds'));
			clouds.scrollFactor.set(0.1, 0.1);
			clouds.setPosition(-1000, -1000);
			clouds.velocity.set(10, 0);
			add(clouds);

			var sunLight:BGSprite = new BGSprite('stages/skiStage/sun_light', -1000, -1000, 0, 0);
			add(sunLight);
		}

		var mountains:BGSprite = new BGSprite('stages/skiStage/mountains', -600, -500, 0.3, 0.3);
		add(mountains);

		if(!ClientPrefs.data.lowQuality)
		{
			var mountainsFront:BGSprite = new BGSprite('stages/skiStage/mountainsFront', -550, -450, 0.4, 0.4);
			add(mountainsFront);
		}

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

		dubswitcherShader = new Dubswitcher();
		dubswitcherShader.intensity.value = [0.03];

		dubswitcherFilter = new ShaderFilter(dubswitcherShader);

		colorSwapShader = new ColorSwapShader();
		colorSwapShader.uTime.value = [0, -0.3, 0];

		colorSwapFilter = new ShaderFilter(colorSwapShader);
		if(ClientPrefs.data.shaders) FlxG.camera.filters = [dubswitcherFilter, colorSwapFilter];
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var snow:SnowParticles = new SnowParticles(0, 0, 3840, 400, 'stages/skiStage/snowParticle');
			snow.startY = -2000;
			snow.endY = 1500;
			snow.intensity = 14;
			snow.xIntensity = -700;
			snow.endScale = 1;
			snow.randomX = 150;
			snow.randomY = 150;
			snow.spawnDelay = 0.1;
			snow.initialScale = 0.8;
			snow.endScale = 0.6;
			snow.fadeSpeed = 1.3;
			add(snow);

			var snowboards:BGSprite = new BGSprite('stages/skiStage/snowboards', 0, 0, 1, 1);
			add(snowboards);

			var lights:BGSprite = new BGSprite('stages/skiStage/lights', 0, 0, 0, 0);
			lights.blend = ADD;
			//add(lights);
			
			var shadow:BGSprite = new BGSprite('stages/skiStage/shadow', 0, 0, 0, 0);
			//add(shadow);
		}
	}

	override function update(elapsed:Float)
	{
		if(dubswitcherShader != null)
			dubswitcherShader.iTime.value[0] += elapsed;
	}

	override function stepHit()
	{
		switch(curStep)
		{
			case 1:
				FlxTween.num(0.03, 0.01, 15, {ease: FlxEase.cubeOut}, function(v:Float)
				{
					dubswitcherShader.intensity.value[0] = v;
				});
			case 240:
				FlxTween.num(-0.3, 0, 10, {ease: FlxEase.cubeOut}, function(v:Float)
				{
					colorSwapShader.uTime.value[1] = v;
				});
		}
	}
}