package states.stages;

import states.stages.objects.*;
import flixel.addons.display.FlxBackdrop;
import objects.Character;
import shaders.DropShadowShader;

class HexStage extends BaseStage
{
    var pitch:BGSprite;
	override function create()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var sky:BGSprite = new BGSprite('stages/hexStage/sky', -1350, -1020, 0.2, 0.2);
			add(sky);

            var clouds:FlxBackdrop = new FlxBackdrop(Paths.image('stages/hexStage/clouds'), X);
            clouds.scrollFactor.set(0.25, 0.25);
            clouds.x = -1350;
            clouds.y = -500;
            clouds.velocity.set(25, 0);
            add(clouds);
		}

		var city:BGSprite = new BGSprite('stages/hexStage/city', -1350, -1000, 0.75, 0.75);
		add(city);

        var streetBack:BGSprite = new BGSprite('stages/hexStage/streetBack', -1350, -1020 + 860, 0.99, 1);
		add(streetBack);

        pitch = new BGSprite('stages/hexStage/pitch', -1350, -640, 1, 1);
		add(pitch);
        
		if(!ClientPrefs.data.lowQuality)
		{
            var light2:BGSprite = new BGSprite('stages/hexStage/lights2', -1350, -1020, 1, 1);
			light2.blend = ADD;
            add(light2);
        }
	}

	override function createPost()
	{
        var glass:BGSprite = new BGSprite('stages/hexStage/glass', -1350, -1020 + 1453, 1, 1);
		glass.blend = ADD;
		add(glass);
        
        var street:BGSprite = new BGSprite('stages/hexStage/street', -1350, -1020 + 1433, 1, 1);
		add(street);

		if(!ClientPrefs.data.lowQuality)
		{
            var light:BGSprite = new BGSprite('stages/hexStage/light', -1360 + 40, -1020 + 368, 1.2, 1.2);
			light.blend = ADD;
            add(light);

			var front:BGSprite = new BGSprite('stages/hexStage/front', -1300 + 40, -1020 + 253, 1.2, 1.2);
			add(front);
		}

		if(ClientPrefs.data.shaders)
		{
			var rimBF = new DropShadowShader();
			rimBF.setAdjustColor(-6, -12, 6, -22);
			rimBF.color = 0x0;
			game.boyfriend.shader = rimBF;
			rimBF.attachedSprite = game.boyfriend;
			rimBF.angle = 90;

			game.boyfriend.animation.callback = function()
			{
				if (game.boyfriend != null)
				{
					rimBF.updateFrameInfo(game.boyfriend.frame);
				}
			};

			var rimGF = new DropShadowShader();
			rimGF.setAdjustColor(-6, -12, 6, -22);
			rimGF.color = 0x0;
			game.gf.shader = rimGF;
			rimGF.attachedSprite = game.gf;
			rimGF.distance = 10;
			rimGF.angle = 90;

			game.gf.animation.callback = function()
			{
				if (game.gf != null)
				{
					rimGF.updateFrameInfo(game.gf.frame);
				}
			};

			var rimDad = new DropShadowShader();
			rimDad.setAdjustColor(-6, -12, 6, -22);
			rimDad.color = 0x0;
			game.dad.shader = rimDad;
			rimDad.attachedSprite = game.dad;
			rimDad.angle = 90;

			game.dad.animation.callback = function()
			{
				if (game.dad != null)
				{
					rimDad.updateFrameInfo(game.dad.frame);
				}
			};
		}
	}
}