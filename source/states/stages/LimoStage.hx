package states.stages;

import shaders.DropShadowShader;
import shaders.WaterShader;
import flixel.addons.display.FlxBackdrop;
import states.stages.objects.*;
import objects.Character;

class LimoStage extends BaseStage
{
    var waterShader:WaterShader;

    var skySunset:FlxSprite;
    public static var clouds:FlxBackdrop;
    public var airplaneLeft:FlxSprite;
    public var airplaneRight:FlxSprite;
    public static var buildingsBack2:FlxBackdrop;
    public static var buildingsBack:FlxBackdrop;
    public static var buildingsFront:FlxBackdrop;
    var water:FlxSprite;
    var road:FlxBackdrop;
    var truck:FlxSprite;

    public static var buildingsBack2XPos:Float = 0;
    public static var buildingsBackXPos:Float = 0;
    public static var buildingsFrontXPos:Float = 0;
    public static var cloudsXPos:Float = 0;

	override function create()
	{
        skySunset = new FlxSprite();
        skySunset.loadGraphic(Paths.image('stages/limoStage/skySunset'));
        skySunset.scrollFactor.set(0.1, 0.1);
        skySunset.x += -1200;
        skySunset.y += -650;
        skySunset.antialiasing = ClientPrefs.data.antialiasing;
        add(skySunset);

        if(!ClientPrefs.data.lowQuality)
        {
            clouds = new FlxBackdrop(Paths.image('stages/limoStage/clouds'), X, 20, 0);
            clouds.scrollFactor.set(0.25, 0.25);
            clouds.y += -1000;
            clouds.x = cloudsXPos;
            clouds.antialiasing = ClientPrefs.data.antialiasing;
            add(clouds);

            airplaneLeft = new FlxSprite(skySunset.x + skySunset.width + 700, skySunset.y + 500 + FlxG.random.float(-5, 105));
            airplaneLeft.scrollFactor.set(0.25, 0.25);
            //airplaneLeft.loadGraphic(Paths.image('stages/limoStage/airplane'));
            airplaneLeft.frames = Paths.getSparrowAtlas('stages/limoStage/airplane');
            airplaneLeft.animation.addByPrefix('idle', 'idle', 2, true);
            airplaneLeft.animation.play('idle', true);
            airplaneLeft.antialiasing = ClientPrefs.data.antialiasing;
            airplaneLeft.scale.set(0.67, 0.67);
            airplaneLeft.flipX = true;
            add(airplaneLeft);

            airplaneRight = new FlxSprite(skySunset.x, skySunset.y + 520 + FlxG.random.float(-5, 105));
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

        buildingsBack2 = new FlxBackdrop(Paths.image('stages/limoStage/buildingBack2'), X, 0, 0);
        buildingsBack2.scrollFactor.set(0.4, 0.4);
        buildingsBack2.x = buildingsBack2XPos;
        //buildingsBack2.y = 80;
        buildingsBack2.antialiasing = ClientPrefs.data.antialiasing;
        add(buildingsBack2);

        buildingsBack = new FlxBackdrop(Paths.image('stages/limoStage/buildingBack'), X, 0, 0);
        buildingsBack.scrollFactor.set(0.4, 0.4);
        buildingsBack.x = buildingsBackXPos;
        //buildingsBack.y = 80;
        buildingsBack.antialiasing = ClientPrefs.data.antialiasing;
        add(buildingsBack);

        buildingsFront = new FlxBackdrop(Paths.image('stages/limoStage/building'), X, 0, 0);
        buildingsFront.scrollFactor.set(0.6, 0.6);
        buildingsFront.x = buildingsFrontXPos;
        //buildingsFront.y = 80;
        buildingsFront.antialiasing = ClientPrefs.data.antialiasing;
        add(buildingsFront);

        water = new FlxBackdrop(Paths.image('stages/limoStage/water'), X, 0, 0);
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

        road = new FlxBackdrop(Paths.image('stages/limoStage/road'), X, 0, 0);
        road.antialiasing = ClientPrefs.data.antialiasing;
        add(road);

        truck = new FlxSprite();
        truck.antialiasing = ClientPrefs.data.antialiasing;
        truck.loadGraphic(Paths.image('stages/limoStage/truck'));
        add(truck);

        applyVelocites();
	}

    var speedMult:Float = 2.33;
    //var speedMult:Float = 10;
    function applyVelocites(isMaximumSpeed:Bool = false)
    {
        if(!ClientPrefs.data.lowQuality) clouds.velocity.set(20, 0);
        if(!ClientPrefs.data.lowQuality) airplaneRight.velocity.set(130, 0);
        if(!ClientPrefs.data.lowQuality) airplaneLeft.velocity.set(-115, 0);
        buildingsBack2.velocity.set(40, 0);
        buildingsBack.velocity.set(50, 0);
        buildingsFront.velocity.set(75, 0);
        water.velocity.set(75, 0);
        road.velocity.set(3000, 0);

        if(isMaximumSpeed)
        {
            if(!ClientPrefs.data.lowQuality) clouds.velocity.set(20 * speedMult, 0);
            if(!ClientPrefs.data.lowQuality) airplaneRight.velocity.set(130 * speedMult, 0);
            if(!ClientPrefs.data.lowQuality) airplaneLeft.velocity.set(-115 * speedMult, 0);
            buildingsBack2.velocity.set(40 * speedMult, 0);
            buildingsBack.velocity.set(50 * speedMult, 0);
            buildingsFront.velocity.set(75 * speedMult, 0);
            water.velocity.set(75 * speedMult, 0);
            road.velocity.set(3000 * speedMult, 0);
        }
    }

    override function update(elapsed:Float)
    {
        if(ClientPrefs.data.shaders) waterShader.iTime.value[0] += elapsed;
        if(!ClientPrefs.data.lowQuality) 
        {
            if(airplaneRight.x > skySunset.x + 3660) 
            {
                airplaneRight.y = skySunset.y + 520 + FlxG.random.float(-5, 105);
                airplaneRight.x = skySunset.x - 3600;

                FlxTween.cancelTweensOf(airplaneRight);
                FlxTween.tween(airplaneRight, {y: airplaneRight.y + 10}, 3.5, {ease: FlxEase.sineInOut, type: PINGPONG});
            }

            if(airplaneLeft.x < skySunset.x - 3660) 
            {
                airplaneLeft.y = skySunset.y + 500 + FlxG.random.float(-5, 105);
                airplaneLeft.x = skySunset.x + skySunset.width + 300;

                FlxTween.cancelTweensOf(airplaneLeft);
                FlxTween.tween(airplaneLeft, {y: airplaneLeft.y + 10}, 3.5, {ease: FlxEase.sineInOut, type: PINGPONG});
            }
        }
    }

    override function createPost() 
    {
        if(!ClientPrefs.data.lowQuality)
        {
            var light:FlxSprite = new FlxSprite();
            light.loadGraphic(Paths.image('stages/limoStage/light'));
            light.blend = ADD;
            light.scrollFactor.set(0.1, 0.1);
            light.x += -1200;
            light.y += -650;
            add(light);
        }

		if(ClientPrefs.data.shaders)
		{
			// lights on characters
			var rimBF = new DropShadowShader();
			rimBF.setAdjustColor(0, 0, 0, 0);
			rimBF.color = 0xFFFEF9AA;
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
			rimGF.setAdjustColor(0, 0, 0, 0);
			rimGF.color = 0xFFFEF9AA;
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
			rimDad.setAdjustColor(0, 0, 0, 0);
			rimDad.color = 0xFFFEF9AA;
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