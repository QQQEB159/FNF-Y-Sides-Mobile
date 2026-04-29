package states.stages;

import states.stages.objects.*;
import objects.Character;
import flixel.addons.display.FlxBackdrop;
import shaders.WaterShader;

class TrickyStage extends BaseStage
{
	var sky:BGSprite;
	var mountains:BGSprite;
	var verticalVoid:FlxBackdrop;
	var horizontalVoid:FlxBackdrop;
	var floatingIslandLeft:BGSprite;
	var floatingIslandRight:BGSprite;
	var islandBehind:BGSprite;
	var bg:BGSprite;
	var smoke:FlxBackdrop;
	var light:BGSprite;
	var front:BGSprite;
	var sign:BGSprite;

	var voidShader:WaterShader;

	override function create()
	{
		sky = new BGSprite('stages/trickyStage/sky', -1350, -1020, 0, 0);
        sky.updateHitbox();
		add(sky);

		mountains = new BGSprite('stages/trickyStage/mountains', -1350, -1020, 0.15, 0.15);
        mountains.updateHitbox();
		mountains.x += 120;
		mountains.y = sky.y + sky.height - mountains.height + 150;
		add(mountains);

		verticalVoid = new FlxBackdrop(Paths.image('stages/trickyStage/voidVertical'), Y);
        verticalVoid.updateHitbox();
		verticalVoid.x = sky.x + sky.width / 2 - verticalVoid.width / 2;
		verticalVoid.y = sky.y;
		verticalVoid.scrollFactor.set(0.3, 0.3);
		verticalVoid.velocity.set(0, -35);
		verticalVoid.antialiasing = ClientPrefs.data.antialiasing;
		add(verticalVoid);

		horizontalVoid = new FlxBackdrop(Paths.image('stages/trickyStage/void'), X);
        horizontalVoid.updateHitbox();
		horizontalVoid.x = sky.x;
		horizontalVoid.y = sky.y + sky.height - horizontalVoid.height + 15;
		horizontalVoid.scrollFactor.set(0.3, 0.3);
		horizontalVoid.velocity.set(35, 0);
		horizontalVoid.antialiasing = ClientPrefs.data.antialiasing;
		add(horizontalVoid);

		floatingIslandLeft = new BGSprite('stages/trickyStage/floatingIslandLeft', -1350, -1020, 0.4, 0.4);
        floatingIslandLeft.updateHitbox();
		floatingIslandLeft.x = sky.x + 100;
		floatingIslandLeft.y = sky.y + 410;
		add(floatingIslandLeft);

		floatingIslandRight = new BGSprite('stages/trickyStage/floatingIslandRight', -1350, -1020, 0.4, 0.4);
        floatingIslandRight.updateHitbox();
		floatingIslandRight.x = sky.x + sky.width - floatingIslandRight.width - 120;
		floatingIslandRight.y = sky.y + 825;
		add(floatingIslandRight);

		islandBehind = new BGSprite('stages/trickyStage/islandBehind', -1350, -1020, 0.8, 0.8);
        islandBehind.updateHitbox();
		islandBehind.x = sky.x + sky.width / 2 - islandBehind.width / 2;
		islandBehind.y = sky.y + 250;
		add(islandBehind);

		bg = new BGSprite('stages/trickyStage/bg', -1350, -1020, 1, 1);
        bg.updateHitbox();
		bg.y = sky.y + 355; 
		add(bg);

		if(ClientPrefs.data.shaders)
		{
			voidShader = new WaterShader();
			verticalVoid.shader = voidShader;
			horizontalVoid.shader = voidShader;
		}
	}

	override function createPost()
	{
		smoke = new FlxBackdrop(Paths.image('stages/trickyStage/smoke'), X);
        smoke.updateHitbox();
		smoke.blend = ADD;
		smoke.y = sky.y + 1160;
		smoke.x =  -1350;
		smoke.velocity.set(15, 0);
		add(smoke);

		light = new BGSprite('stages/trickyStage/light', -1350, -1020, 1, 1);
        light.updateHitbox();
		light.blend = ADD;
		add(light);

		front = new BGSprite('stages/trickyStage/front', -1350, -1020, 1.25, 1.25);
        front.updateHitbox();
		front.y = sky.y + 1245;
		add(front);

		sign = new BGSprite('stages/trickyStage/sign', -1350, -1020, 1.3, 1.3);
        sign.updateHitbox();
		sign.x = sky.x + sky.width - sign.width - 55;
		sign.y = sky.y + 1220;
		add(sign);
	}

	override function update(elapsed:Float)
	{
        if(voidShader != null) voidShader.iTime.value[0] += (elapsed / 1.25);
	}
}