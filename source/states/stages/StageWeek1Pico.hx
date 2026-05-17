package states.stages;

import states.stages.objects.*;
import objects.Character;
import shaders.DropShadowShader;

class StageWeek1Pico extends BaseStage
{
	override function create()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var sky:BGSprite = new BGSprite('stages/stagePico/sky', -1350, -1020, 0.2, 0.2);
			add(sky);
		}

		var city:BGSprite = new BGSprite('stages/stagePico/city', -1350, -640, 0.8, 0.8);
		add(city);

		if(!ClientPrefs.data.lowQuality)
		{
			var lights:BGSprite = new BGSprite('stages/stagePico/lights', -1350, -1000, 1, 1);
			lights.blend = ADD;
			add(lights);
		}

		var gym:BGSprite = new BGSprite('stages/stagePico/gym', -1350, -1000, 1, 1);
		add(gym);

        var bigLight:BGSprite = new BGSprite('stages/stagePico/bigLight', -1350, -1000, 1, 1);
        bigLight.blend = ADD;
		bigLight.alpha = 0.39;
        add(bigLight);
	}

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var front:BGSprite = new BGSprite('stages/stagePico/front', -1350, 300, 1.2, 1.2);
			add(front);
		}
        
		// lights on characters
		var rimBF = new DropShadowShader();
		rimBF.setAdjustColor(-46, -38, -25, -20);
		rimBF.color = 0xFFFEF9AA;
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
		rimGF.color = 0xFFFEF9AA;
		game.gf.shader = rimGF;
		rimGF.attachedSprite = game.gf;
		rimGF.distance = 10;
        rimGF.angle = 180;
        
		game.gf.animation.callback = function()
		{
			if (game.gf != null)
			{
				rimGF.updateFrameInfo(game.gf.frame);
			}
		};

        var rimDad = new DropShadowShader();
        rimDad.setAdjustColor(-46, -38, -25, -20);
        rimDad.color = 0xFFFEF9AA;
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
	}
}