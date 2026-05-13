package states.stages;

import shaders.DropShadowShader;
import shaders.WaterShader;
import flixel.addons.display.FlxBackdrop;
import states.stages.objects.*;
import objects.Character;

class LimoStageNightPico extends BaseStage
{
    var waterShader:WaterShader;

    var skyNight:FlxSprite;
    var clouds:FlxBackdrop;
    public var airplaneLeft:FlxSprite;
    public var airplaneRight:FlxSprite;
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

        if(!ClientPrefs.data.lowQuality)
        {
            clouds = new FlxBackdrop(Paths.image('stages/limoStage/night/clouds'), X, 20, 0);
            clouds.scrollFactor.set(0.25, 0.25);
            clouds.y += -1000;
            clouds.x = LimoStage.cloudsXPos;
            clouds.antialiasing = ClientPrefs.data.antialiasing;
            add(clouds);

            airplaneLeft = new FlxSprite(skyNight.x + skyNight.width + 700, skyNight.y + 500 + FlxG.random.float(-5, 105));
            airplaneLeft.scrollFactor.set(0.25, 0.25);
            //airplaneLeft.loadGraphic(Paths.image('stages/limoStage/airplane'));
            airplaneLeft.frames = Paths.getSparrowAtlas('stages/limoStage/airplane');
            airplaneLeft.animation.addByPrefix('idle', 'idle', 2, true);
            airplaneLeft.animation.play('idle', true);
            airplaneLeft.antialiasing = ClientPrefs.data.antialiasing;
            airplaneLeft.scale.set(0.67, 0.67);
            airplaneLeft.flipX = true;
            add(airplaneLeft);

            airplaneRight = new FlxSprite(skyNight.x, skyNight.y + 520 + FlxG.random.float(-5, 105));
            airplaneRight.scrollFactor.set(0.25, 0.25);
            //airplaneRight.loadGraphic(Paths.image('stages/limoStage/airplane'));
            airplaneRight.frames = Paths.getSparrowAtlas('stages/limoStage/airplane');
            airplaneRight.animation.addByPrefix('idle', 'idle', 2, true);
            airplaneRight.animation.play('idle', true);
            airplaneRight.antialiasing = ClientPrefs.data.antialiasing;
            airplaneRight.scale.set(0.75, 0.75);
            add(airplaneRight);

            FlxTween.tween(airplaneLeft, {y: airplaneLeft.y + 10}, 3.5, {ease: FlxEase.sineInOut, type: PINGPONG});
            FlxTween.tween(airplaneRight, {y: airplaneRight.y + 10}, 3.5, {ease: FlxEase.sineInOut, type: PINGPONG});
        }

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
        water.y = 990;
        water.x = -600;
        water.scrollFactor.set(0.65, 0.65);
        water.antialiasing = ClientPrefs.data.antialiasing;
        add(water);

        if(ClientPrefs.data.shaders)
        {
            waterShader = new WaterShader();
            waterShader.iTime.value = [0];
            if(!ClientPrefs.data.lowQuality) water.shader = waterShader;
        }

        road = new FlxBackdrop(Paths.image('stages/limoStage/night/road'), X, 0, 0);
        road.antialiasing = ClientPrefs.data.antialiasing;
        add(road);

        if(!ClientPrefs.data.lowQuality)
        {
            roadLights = new FlxBackdrop(Paths.image('stages/limoStage/night/roadLights'), X, 0, 0);
            roadLights.antialiasing = ClientPrefs.data.antialiasing;
            add(roadLights);
        }

        truck = new FlxSprite();
        truck.antialiasing = ClientPrefs.data.antialiasing;
        truck.loadGraphic(Paths.image('stages/limoStage/night/truck'));
        add(truck);

        applyVelocites(true);
	}

    var speedMult:Float = 2.33;
    var targetSpeed:Float = 20;

    //var speedMult:Float = 10;
    function applyVelocites(isMaximumSpeed:Bool = false)
    {
        if(!ClientPrefs.data.lowQuality) clouds.velocity.set(targetSpeed, 0);
        if(!ClientPrefs.data.lowQuality) airplaneRight.velocity.set(130, 0);
        if(!ClientPrefs.data.lowQuality) airplaneLeft.velocity.set(-115, 0);
        buildingsBack2.velocity.set(targetSpeed * 2, 0); // 2x faster
        buildingsBack.velocity.set(targetSpeed * 2.5, 0); // 2.5 faster
        buildingsFront.velocity.set(targetSpeed * 3.75, 0); // 3.75 faster
        water.velocity.set(targetSpeed * 3.75, 0); // 3.75 faster
        road.velocity.set(targetSpeed * 150, 0); // 150x faster
        if(!ClientPrefs.data.lowQuality) roadLights.velocity.set(targetSpeed * 150, 0); // 150x faster
        // wind is 250x faster lmao

        if(isMaximumSpeed)
        {
            if(!ClientPrefs.data.lowQuality) clouds.velocity.set(targetSpeed * speedMult, 0);
            if(!ClientPrefs.data.lowQuality) airplaneRight.velocity.set(130 * speedMult, 0);
            if(!ClientPrefs.data.lowQuality) airplaneLeft.velocity.set(-115 * speedMult, 0);
            buildingsBack2.velocity.set(targetSpeed * 2 * speedMult, 0);
            buildingsBack.velocity.set(targetSpeed * 2.5 * speedMult, 0);
            buildingsFront.velocity.set(targetSpeed * 3.75 * speedMult, 0);
            water.velocity.set(targetSpeed * 3.75 * speedMult, 0);
            road.velocity.set(targetSpeed * 150 * speedMult, 0);
            if(!ClientPrefs.data.lowQuality) roadLights.velocity.set(targetSpeed * 150 * speedMult, 0);
        }
    }

    override function update(elapsed:Float)
    {
        if(ClientPrefs.data.shaders) waterShader.iTime.value[0] += elapsed;
        if(!ClientPrefs.data.lowQuality) 
        {
            if(airplaneRight.x > skyNight.x + 3660) 
            {
                airplaneRight.y = skyNight.y + 520 + FlxG.random.float(-5, 105);
                airplaneRight.x = skyNight.x - 3600;

                FlxTween.cancelTweensOf(airplaneRight);
                FlxTween.tween(airplaneRight, {y: airplaneRight.y + 10}, 3.5, {ease: FlxEase.sineInOut, type: PINGPONG});
            }

            if(airplaneLeft.x < skyNight.x - 3660) 
            {
                airplaneLeft.y = skyNight.y + 500 + FlxG.random.float(-5, 105);
                airplaneLeft.x = skyNight.x + skyNight.width + 300;

                FlxTween.cancelTweensOf(airplaneLeft);
                FlxTween.tween(airplaneLeft, {y: airplaneLeft.y + 10}, 3.5, {ease: FlxEase.sineInOut, type: PINGPONG});
            }
        }
    }

    override function stepHit()
    {
        switch(curStep)
        {
            case 1312:
                if(windLmao != null) FlxTween.tween(windLmao, {alpha: 1}, 1.2, {ease: FlxEase.quartOut});
                FlxTween.num(speedMult, 7, 1.2, {ease: FlxEase.quartOut}, function(v:Float)
                {
                    speedMult = v;
                    if(clouds != null) clouds.velocity.set(targetSpeed * v, 0);
                    buildingsBack2.velocity.set(targetSpeed * 2 * v, 0);
                    buildingsBack.velocity.set(targetSpeed * 2.5 * v, 0);
                    buildingsFront.velocity.set(targetSpeed * 3.75 * v, 0);
                    road.velocity.set(targetSpeed * 150 * v, 0);
                    if(roadLights != null) roadLights.velocity.set(targetSpeed * 150 * v, 0);
                    if(windLmao != null) windLmao.velocity.set(targetSpeed * 250 * v, 0);
                });
            case 1440:
                if(windLmao != null) FlxTween.tween(windLmao, {alpha: 0}, 1.2, {ease: FlxEase.quartOut});
                FlxTween.num(speedMult, 2.33, 1.2, {ease: FlxEase.quartOut}, function(v:Float)
                {
                    if(clouds != null) clouds.velocity.set(targetSpeed * v, 0);
                    buildingsBack2.velocity.set(targetSpeed * 2 * v, 0);
                    buildingsBack.velocity.set(targetSpeed * 2.5 * v, 0);
                    buildingsFront.velocity.set(targetSpeed * 3.75 * v, 0);
                    road.velocity.set(targetSpeed * 150 * v, 0);
                    if(roadLights != null) roadLights.velocity.set(targetSpeed * 150 * v, 0);
                    if(windLmao != null) windLmao.velocity.set(targetSpeed * 250 * v, 0);
                });
        }
    }

    var windLmao:FlxBackdrop;
    override function createPost() 
    {
        if(!ClientPrefs.data.lowQuality)
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
        }

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