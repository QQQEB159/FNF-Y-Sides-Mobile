package states.stages;

import openfl.filters.ShaderFilter;
import shaders.BloomShader;
import shaders.ChromaticAberration;
import shaders.DropShadowShader;

class HalloweenCreepyStage extends BaseStage
{
	override function create()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var sky:BGSprite = new BGSprite('stages/halloweenStage/monster/sky', -1248 + 250, -1041, 1, 1);
			add(sky);

			var moon:BGSprite = new BGSprite('stages/halloweenStage/monster/moon', 485, -805, 0.1, 0.1);
			add(moon);

			var clouds:BGSprite = new BGSprite('stages/halloweenStage/monster/clouds', -1286, -1146, 0.2, 0.2);
			add(clouds);
		}

		var buildings:BGSprite = new BGSprite('stages/halloweenStage/monster/buildings', -1038, -885, 0.6, 0.6);
		add(buildings);

		var bgmain:BGSprite = new BGSprite('stages/halloweenStage/monster/bgmain', -730, -878, 1, 1);
		add(bgmain);

	}

	var chromaticAberration:ChromaticAberration;
	var chromaticAberrationFilter:ShaderFilter;
	var superBloomHUD:BloomShader;
	var superBloomHUDFilter:ShaderFilter;
	override function createPost()
	{

		if(!ClientPrefs.data.lowQuality)
		{
			var gradient:BGSprite = new BGSprite('stages/halloweenStage/monster/gradient', -230, -628, 1, 1);
			gradient.blend = ADD;
			add(gradient);
		}

		if(ClientPrefs.data.shaders)
		{
			var bloom = new BloomShader();

			bloom.dim.value = [1.8]; // 1.8
			bloom.Directions.value = [4.0]; // 2.0, 100.0 to remove
			bloom.Quality.value = [8.0]; // 8.0
			bloom.Size.value = [4.0]; // 8.0, 1.0

			superBloomHUD = new BloomShader();

			superBloomHUD.dim.value = [1.8]; // 1.8
			superBloomHUD.Directions.value = [4.0]; // 2.0, 100.0 to remove
			superBloomHUD.Quality.value = [8.0]; // 8.0
			superBloomHUD.Size.value = [4.0]; // 8.0, 1.0

			superBloomHUDFilter = new ShaderFilter(superBloomHUD);
			game.camHUD.filters = [superBloomHUDFilter];

			var shaderFilter = new ShaderFilter(bloom);
			FlxG.camera.filters = [shaderFilter];

			chromaticAberration = new ChromaticAberration();
			chromaticAberration.rOffset.value = [0.0];
			chromaticAberration.gOffset.value = [0.0];
			chromaticAberration.bOffset.value = [0.0];

			var chromaticAberrationFilter = new ShaderFilter(chromaticAberration);
			FlxG.camera.filters.push(chromaticAberrationFilter);
			game.camHUD.filters.push(chromaticAberrationFilter);

			// lights on characters
			var rimBF = new DropShadowShader();
			rimBF.setAdjustColor(-46, -38, -25, -20);
			rimBF.color = 0xFFE9001F;
			game.boyfriend.shader = rimBF;
			rimBF.attachedSprite = game.boyfriend;

			game.boyfriend.animation.callback = function()
			{
				if (game.boyfriend != null)
				{
					rimBF.updateFrameInfo(game.boyfriend.frame);
				}
			};

			var rimGF = new DropShadowShader();
			rimGF.setAdjustColor(-46, -38, -25, -20);
			rimGF.color = 0xFFE9001F;
			game.gf.shader = rimGF;
			rimGF.attachedSprite = game.gf;
			rimGF.distance = 10;

			game.gf.animation.callback = function()
			{
				if (game.gf != null)
				{
					rimGF.updateFrameInfo(game.gf.frame);
				}
			};

			var rimDad = new DropShadowShader();
			rimDad.setAdjustColor(-46, -38, -25, -20);
			rimDad.color = 0xFFE9001F;
			game.dad.shader = rimDad;
			rimDad.attachedSprite = game.dad;
			rimDad.angle = 180;

			game.dad.animation.callback = function()
			{
				if (game.dad != null)
				{
					rimDad.updateFrameInfo(game.dad.frame);
				}
			};

			if (game.player3 != null)
			{
				var rimPlayer3 = new DropShadowShader();
				rimPlayer3.setAdjustColor(-46, -38, -25, -20);
				rimPlayer3.color = 0xFFE9001F;
				game.player3.shader = rimPlayer3;
				rimPlayer3.attachedSprite = game.player3;
				rimPlayer3.angle = 180;
				game.player3.animation.callback = function()
				{
					if (game.player3 != null)
					{
						rimPlayer3.updateFrameInfo(game.player3.frame);
					}
				};
			}
		}
	}

	override function stepHit()
	{
		switch(curStep)
		{
			case 580:
				if(ClientPrefs.data.shaders)
				{
					FlxTween.num(2, 1.75, 1.8, {ease: FlxEase.sineOut}, function(v:Float)
					{
						superBloomHUD.dim.value[0] = v; // 1.8
					});

					FlxTween.num(4, 1.95, 1.8, {ease: FlxEase.sineOut}, function(v:Float)
					{
						superBloomHUD.Directions.value[0] = v; // 1.8
					});

					FlxTween.num(0, 0.003, 1.8, {ease: FlxEase.sineOut}, function(v:Float)
					{
						chromaticAberration.rOffset.value[0] = v;
						chromaticAberration.gOffset.value[0] = 0;
						chromaticAberration.bOffset.value[0] = -v;
					});
				}
			case 608:
				if(ClientPrefs.data.shaders)
				{
					superBloomHUD.dim.value[0] = 2.0;
					superBloomHUD.Directions.value[0] = 100; // 1.8
					
					game.camHUD.filters.remove(superBloomHUDFilter);
					game.camHUD.filters.remove(chromaticAberrationFilter);

					chromaticAberration.rOffset.value = [0.001];
					chromaticAberration.gOffset.value = [0.0];
					chromaticAberration.bOffset.value = [-0.001];
				}
			case 1088:
				if(ClientPrefs.data.shaders)
				{

					chromaticAberration.rOffset.value = [0.002];
					chromaticAberration.gOffset.value = [0.0];
					chromaticAberration.bOffset.value = [-0.002];
				}

		}
	}
}