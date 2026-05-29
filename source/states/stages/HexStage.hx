package states.stages;

import states.stages.objects.*;
import flixel.addons.display.FlxBackdrop;
import objects.Character;

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
            clouds.scrollFactor.set();
            clouds.x = -1350;
            clouds.y = -880;
            clouds.velocity.set(10, 0);
            add(clouds);
		}

		var city:BGSprite = new BGSprite('stages/hexStage/city', -1350, -1000, 0.8, 0.8);
		add(city);

        var streetBack:BGSprite = new BGSprite('stages/hexStage/streetBack', -1350, -1020 + 860, 1, 1);
		add(streetBack);

        pitch = new BGSprite('stages/hexStage/pitch', -1350, -640, 1, 1);
		add(pitch);
        
		if(!ClientPrefs.data.lowQuality)
		{
            var light2:BGSprite = new BGSprite('stages/hexStage/lights2', -1350, -1020, 1.2, 1.2);
			light2.blend = ADD;
            add(light2);
        }
	}

	override function createPost()
	{
        var glass:BGSprite = new BGSprite('stages/hexStage/glass', -1350, -1020 + 1453, 1, 1);
		add(glass);
        
        var street:BGSprite = new BGSprite('stages/hexStage/street', -1350, -1020 + 1433, 1, 1);
		add(street);

		if(!ClientPrefs.data.lowQuality)
		{
            var light:BGSprite = new BGSprite('stages/hexStage/light', -1350, -1020 + 368, 1.2, 1.2);
			light.blend = ADD;
            add(light);

			var front:BGSprite = new BGSprite('stages/hexStage/front', -1350, -1020 + 253, 1.2, 1.2);
			add(front);
		}
	}
}