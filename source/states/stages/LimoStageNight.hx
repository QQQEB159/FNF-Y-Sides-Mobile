package states.stages;

import shaders.DropShadowShader;
import shaders.WaterShader;
import flixel.addons.display.FlxBackdrop;
import states.stages.objects.*;
import objects.Character;

class LimoStageNight extends BaseStage
{
    var waterShader:WaterShader;

    var skyNight:FlxSprite;
    var clouds:FlxBackdrop;
    var buildingsBack2:FlxBackdrop;
    var buildingsBack:FlxBackdrop;
    var buildingsFront:FlxBackdrop;
    var water:FlxSprite;
    var road:FlxBackdrop;
    var roadLights:FlxBackdrop;
    var truck:FlxSprite;

	override function create()
	{
        skyNight = new FlxSprite();
        skyNight.loadGraphic(Paths.image('stages/limoStage/night/skyNight'));
        skyNight.scrollFactor.set(0.1, 0.1);
        skyNight.x += -1200;
        skyNight.y += -650;
        skyNight.antialiasing = ClientPrefs.data.antialiasing;
        add(skyNight);

        clouds = new FlxBackdrop(Paths.image('stages/limoStage/night/clouds'), X, 20, 0);
        clouds.scrollFactor.set(0.25, 0.25);
        clouds.y += -1000;
        clouds.x = LimoStage.cloudsXPos;
        clouds.antialiasing = ClientPrefs.data.antialiasing;
        add(clouds);

        buildingsBack2 = new FlxBackdrop(Paths.image('stages/limoStage/night/buildingBack2'), X, 0, 0);
        buildingsBack2.scrollFactor.set(0.4, 0.4);
        buildingsBack2.x = LimoStage.buildingsBack2XPos;
        //buildingsBack2.y = 80;
        buildingsBack2.antialiasing = ClientPrefs.data.antialiasing;
        add(buildingsBack2);

        buildingsBack = new FlxBackdrop(Paths.image('stages/limoStage/night/buildingBack'), X, 0, 0);
        buildingsBack.scrollFactor.set(0.4, 0.4);
        buildingsBack.x = LimoStage.buildingsBackXPos;
        //buildingsBack.y = 80;
        buildingsBack.antialiasing = ClientPrefs.data.antialiasing;
        add(buildingsBack);

        buildingsFront = new FlxBackdrop(Paths.image('stages/limoStage/night/building'), X, 0, 0);
        buildingsFront.scrollFactor.set(0.6, 0.6);
        buildingsFront.x = LimoStage.buildingsFrontXPos;
        //buildingsFront.y = 80;
        buildingsFront.antialiasing = ClientPrefs.data.antialiasing;
        add(buildingsFront);

        water = new FlxBackdrop(Paths.image('stages/limoStage/night/water'), X, 0, 0);
        water.y = 560;
        water.x = -600;
        water.scrollFactor.set(0.65, 0.65);
        water.antialiasing = ClientPrefs.data.antialiasing;
        add(water);

        if(ClientPrefs.data.shaders)
        {
            waterShader = new WaterShader();
            waterShader.iTime.value = [0];
            water.shader = waterShader;
        }

        road = new FlxBackdrop(Paths.image('stages/limoStage/night/road'), X, 0, 0);
        road.antialiasing = ClientPrefs.data.antialiasing;
        add(road);

        roadLights = new FlxBackdrop(Paths.image('stages/limoStage/night/roadLights'), X, 0, 0);
        roadLights.antialiasing = ClientPrefs.data.antialiasing;
        add(roadLights);

        truck = new FlxSprite();
        truck.antialiasing = ClientPrefs.data.antialiasing;
        truck.loadGraphic(Paths.image('stages/limoStage/night/truck'));
        add(truck);

        applyVelocites(true);
	}

    var speedMult:Float = 2.33;
    //var speedMult:Float = 10;
    function applyVelocites(isMaximumSpeed:Bool = false)
    {
        clouds.velocity.set(20, 0);
        buildingsBack2.velocity.set(40, 0);
        buildingsBack.velocity.set(50, 0);
        buildingsFront.velocity.set(75, 0);
        road.velocity.set(3000, 0);
        roadLights.velocity.set(3000, 0);

        if(isMaximumSpeed)
        {
            clouds.velocity.set(20 * speedMult, 0);
            buildingsBack2.velocity.set(40 * speedMult, 0);
            buildingsBack.velocity.set(50 * speedMult, 0);
            buildingsFront.velocity.set(75 * speedMult, 0);
            road.velocity.set(3000 * speedMult, 0);
            roadLights.velocity.set(3000 * speedMult, 0);
        }
    }

    override function update(elapsed:Float)
    {
        if(ClientPrefs.data.shaders) waterShader.iTime.value[0] += elapsed;
    }

    override function stepHit()
    {
        switch(curStep)
        {
            case 1312:
                FlxTween.tween(windLmao, {alpha: 1}, 1.2, {ease: FlxEase.quartOut});
                FlxTween.num(speedMult, 7, 1.2, {ease: FlxEase.quartOut}, function(v:Float)
                {
                    speedMult = v;
                    clouds.velocity.set(20 * v, 0);
                    buildingsBack2.velocity.set(40 * v, 0);
                    buildingsBack.velocity.set(50 * v, 0);
                    buildingsFront.velocity.set(75 * v, 0);
                    road.velocity.set(3000 * v, 0);
                    roadLights.velocity.set(3000 * v, 0);
                    windLmao.velocity.set(5000 * v, 0);
                });
            case 1440:
                FlxTween.tween(windLmao, {alpha: 0}, 1.2, {ease: FlxEase.quartOut});
                FlxTween.num(speedMult, 2.33, 1.2, {ease: FlxEase.quartOut}, function(v:Float)
                {
                    clouds.velocity.set(20 * v, 0);
                    buildingsBack2.velocity.set(40 * v, 0);
                    buildingsBack.velocity.set(50 * v, 0);
                    buildingsFront.velocity.set(75 * v, 0);
                    road.velocity.set(3000 * v, 0);
                    roadLights.velocity.set(3000 * v, 0);
                    windLmao.velocity.set(5000 * v, 0);
                });
        }
    }

    var windLmao:FlxBackdrop;
    override function createPost() 
    {
        var light:FlxSprite = new FlxSprite();
        light.loadGraphic(Paths.image('stages/limoStage/night/lights'));
        light.blend = ADD;
        light.scrollFactor.set(0.1, 0.1);
        light.x += -1200;
        light.y += -650;
        add(light);

        windLmao = new FlxBackdrop(Paths.image('stages/limoStage/night/windlmao'), XY, 0, 0);
        windLmao.alpha = 0;
        windLmao.velocity.set(5000 * speedMult, 0);
        windLmao.scrollFactor.set(0, 0);
        add(windLmao);

		if(ClientPrefs.data.shaders)
		{
			// lights on characters
			var rimBF = new DropShadowShader();
			rimBF.setAdjustColor(-33, -15, -23, 0);
			rimBF.color = 0xFFCEE7FF;
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
			rimGF.setAdjustColor(-33, -15, -23, 0);
			rimGF.color = 0xFFCEE7FF;
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
			rimDad.setAdjustColor(-33, -15, -23, 0);
			rimDad.color = 0xFFCEE7FF;
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