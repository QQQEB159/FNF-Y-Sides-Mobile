package states.stages;

import states.stages.objects.*;
import objects.Character;

class LimoStage extends BaseStage
{
	override function create()
	{
        var sky:FlxSprite = new FlxSprite();
        sky.loadGraphic(Paths.image('sky'));
        add(sky);

        var clouds:FlxSprite = new FlxSprite();
        clouds.loadGraphic(Paths.image('clouds'));
        add(clouds);

        var buildingsBack:FlxSprite = new FlxSprite(0, 200);
        buildingsBack.loadGraphic(Paths.image('buildingBack'));
        add(buildingsBack);

        var buildingsFront:FlxSprite = new FlxSprite(0, 200);
        buildingsFront.loadGraphic(Paths.image('building'));
        add(buildingsFront);

        var water:FlxSprite = new FlxSprite();
        water.loadGraphic(Paths.image('water'));
        add(water);

        var road:FlxSprite = new FlxSprite();
        road.loadGraphic(Paths.image('road'));
        add(road);

        var truck:FlxSprite = new FlxSprite();
        truck.loadGraphic(Paths.image('truck'));
        add(truck);
	}

    override function createPost() 
    {
        var light:FlxSprite = new FlxSprite();
        light.loadGraphic(Paths.image('light'));
        light.blend = ADD;
        add(light);
    }
}