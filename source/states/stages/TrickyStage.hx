package states.stages;

import states.stages.objects.*;
import objects.Character;
import flixel.addons.display.FlxBackdrop;
import shaders.ChromaticAberration;
import shaders.WaterShader;
import shaders.Dubswitcher;
import openfl.filters.ShaderFilter;

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
	var blackFullThingie:FlxSprite;

	var voidShader:WaterShader;
	var chromaticAberration:ChromaticAberration;
	var chromaticAberrationFilter:ShaderFilter;
	var dubswitcherShader:Dubswitcher;
	var dubswitcherFilter:ShaderFilter;

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
		verticalVoid.velocity.set(0, -45);
		verticalVoid.antialiasing = ClientPrefs.data.antialiasing;
		add(verticalVoid);

		horizontalVoid = new FlxBackdrop(Paths.image('stages/trickyStage/void'), X);
        horizontalVoid.updateHitbox();
		horizontalVoid.x = sky.x;
		horizontalVoid.y = sky.y + sky.height - horizontalVoid.height + 15;
		horizontalVoid.scrollFactor.set(0.3, 0.3);
		horizontalVoid.velocity.set(45, 0);
		horizontalVoid.antialiasing = ClientPrefs.data.antialiasing;
		add(horizontalVoid);

		floatingIslandLeft = new BGSprite('stages/trickyStage/floatingIslandLeft', -1350, -1020, 0.4, 0.4);
        floatingIslandLeft.updateHitbox();
		floatingIslandLeft.x = sky.x + 300;
		floatingIslandLeft.y = sky.y + 410;
		add(floatingIslandLeft);

		FlxTween.tween(floatingIslandLeft, {y: floatingIslandLeft.y + 40}, 4.4, {ease: FlxEase.quartInOut, type: PINGPONG});

		floatingIslandRight = new BGSprite('stages/trickyStage/floatingIslandRight', -1350, -1020, 0.4, 0.4);
        floatingIslandRight.updateHitbox();
		floatingIslandRight.x = sky.x + sky.width - floatingIslandRight.width - 340;
		floatingIslandRight.y = sky.y + 845;
		add(floatingIslandRight);

		FlxTween.tween(floatingIslandRight, {y: floatingIslandRight.y + 40}, 4.4, {ease: FlxEase.quartInOut, type: PINGPONG});

		islandBehind = new BGSprite('stages/trickyStage/islandBehind', -1350, -1020, 0.8, 0.8);
        islandBehind.updateHitbox();
		islandBehind.x = sky.x + sky.width / 2 - islandBehind.width / 2;
		islandBehind.y = sky.y + 250;
		add(islandBehind);

		bg = new BGSprite('stages/trickyStage/bg', -1350, -1020, 1, 1);
        bg.updateHitbox();
		bg.y = sky.y + 355; 
		add(bg);

		blackFullThingie = new FlxSprite(-1000, -1000);
		blackFullThingie.makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
		blackFullThingie.scrollFactor.set(0, 0);
		blackFullThingie.antialiasing = ClientPrefs.data.antialiasing;
		blackFullThingie.alpha = 0;
		add(blackFullThingie);

		if(ClientPrefs.data.shaders)
		{
			voidShader = new WaterShader();
			verticalVoid.shader = voidShader;
			horizontalVoid.shader = voidShader;

            dubswitcherShader = new Dubswitcher();
            dubswitcherShader.intensity.value = [0.004];

			chromaticAberration = new ChromaticAberration();
			chromaticAberration.rOffset.value = [0.0];
			chromaticAberration.gOffset.value = [0.0];
			chromaticAberration.bOffset.value = [0.0];

			chromaticAberrationFilter = new ShaderFilter(chromaticAberration);

            dubswitcherFilter = new ShaderFilter(dubswitcherShader);
            if(ClientPrefs.data.shaders) FlxG.camera.filters = [dubswitcherFilter, chromaticAberrationFilter];
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
        if(voidShader != null) voidShader.iTime.value[0] += (elapsed / 1.15);
		if(dubswitcherShader != null) dubswitcherShader.iTime.value[0] += elapsed;

		if(curStep >= 768 && curStep < 1024 && !game.endingSong)
		{
			FlxG.camera.shake(0.004, 0.15);
		}
	}

	override function stepHit()
	{
        switch(game.curSong)
        {
            case 'Madness':
                switch(curStep)
                {
					case 768:
						blackFullThingie.alpha = 0.05;
						smoke.alpha = 0;
						light.alpha = 0;

            			dubswitcherShader.intensity.value = [0.0045];
						chromaticAberration.rOffset.value = [0.0007];
						chromaticAberration.gOffset.value = [0.0];
						chromaticAberration.bOffset.value = [-0.0007];
					case 1024:
						blackFullThingie.alpha = 0;
						smoke.alpha = 1;
						light.alpha = 1;

            			dubswitcherShader.intensity.value = [0.004];
						chromaticAberration.rOffset.value = [0.0];
						chromaticAberration.gOffset.value = [0.0];
						chromaticAberration.bOffset.value = [0.0];
				}
		}
	}
}