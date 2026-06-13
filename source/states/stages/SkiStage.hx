package states.stages;

import shaders.DropShadowShader;
import flixel.addons.display.FlxBackdrop;
import states.stages.objects.*;
import objects.Character;
import objects.SnowParticles;

class SkiStage extends BaseStage
{
	var fence:BGSprite;
	var fenceChar1:FlxSprite;
	var fenceChar2:FlxSprite;

	var cocoaCloudySky:BGSprite;
	var sun:BGSprite;
	var sunLight:BGSprite;
	var clouds:FlxBackdrop;

	override function create()
	{
		var sky:BGSprite = new BGSprite('stages/skiStage/sky', -1000, -700, 0, 0);
		if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') sky.loadGraphic(Paths.image('stages/skiStage/skyCloudy'));
		add(sky);

		cocoaCloudySky = new BGSprite('stages/skiStage/skyCloudy', -1000, -700, 0, 0);
		cocoaCloudySky.alpha = 0;
		if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') cocoaCloudySky.visible = false;

		if(!ClientPrefs.data.lowQuality)
		{
			sun = new BGSprite('stages/skiStage/sun', -1000, -700, 0, 0);
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') sun.visible = false;
			add(sun);

			var cloudImg = (PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') ? Paths.image('stages/skiStage/cloudsCloudy') : Paths.image('stages/skiStage/clouds');
			clouds = new FlxBackdrop(cloudImg);
			clouds.scrollFactor.set(0.1, 0.1);
			clouds.setPosition(-1000, -1200);
			clouds.velocity.set(20, 0);
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') clouds.velocity.set(50, 0);
			add(clouds);

			add(cocoaCloudySky);

			sunLight = new BGSprite('stages/skiStage/sun_light', -1000, -700, 0, 0);
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') sunLight.visible = false;
			add(sunLight);
		}

		var mountains:BGSprite = new BGSprite('stages/skiStage/mountains', -600, -200, 0.3, 0.3);
		add(mountains);

		var snowBack2:BGSprite = new BGSprite('stages/skiStage/snowBack2', -400, -200, 0.6, 0.6);
		add(snowBack2);

		var snowBack:BGSprite = new BGSprite('stages/skiStage/snowBack', -300, -100, 0.75, 0.75);
		add(snowBack);

		var elevatorLines:BGSprite = new BGSprite('stages/skiStage/elevatorLines', -300, -100, 0.75, 0.75);
		add(elevatorLines);

		fenceChar1 = new FlxSprite();
		fenceChar1.frames = Paths.getSparrowAtlas('stages/skiStage/fenceChar1');
		fenceChar1.animation.addByPrefix('idle', 'idle', 4, true);
		fenceChar1.animation.addByPrefix('run', 'run', 4, true);
		fenceChar1.animation.play('idle');
		fenceChar1.scrollFactor.set(0.75, 0.75);
		fenceChar1.antialiasing = ClientPrefs.data.antialiasing;
		add(fenceChar1);

		fenceChar2 = new FlxSprite();
		fenceChar2.frames = Paths.getSparrowAtlas('stages/skiStage/fenceChar2');
		fenceChar2.animation.addByPrefix('run', 'run', 4, true);
		fenceChar2.animation.play('run');
		fenceChar2.scrollFactor.set(0.75, 0.75);
		fenceChar2.antialiasing = ClientPrefs.data.antialiasing;
		add(fenceChar2);

		fence = new BGSprite('stages/skiStage/fence', 0, 0, 1, 1);
		add(fence);

		fenceChar1.x = fence.x + fence.width - 885;
		fenceChar1.y = fence.y + 962 - 115;

		fenceChar2.x = fence.x + fence.width - 885;
		fenceChar2.y = fence.y + 962 - 115;

		if(PlayState.SONG.song == 'Eggnog') {
			fenceChar1.x = fence.x + fence.width - 1440;
			fenceChar2.x = fence.x + fence.width - 1440;
			startFenceCharStuff(true);
		}

		var snow:BGSprite = new BGSprite('stages/skiStage/snow', 0, 0, 1, 1);
		add(snow);

		var buildings:BGSprite = new BGSprite('stages/skiStage/buildings', 0, 0, 1, 1);
		add(buildings);

		var charactersLeft:FlxSprite = new FlxSprite();
		charactersLeft.frames = Paths.getSparrowAtlas('stages/skiStage/leftcharacters');
		charactersLeft.animation.addByPrefix('idle', 'idle', 4, true);
		charactersLeft.animation.play('idle');
		charactersLeft.antialiasing = ClientPrefs.data.antialiasing;
		//charactersLeft.x += charactersLeft.width;
		charactersLeft.x += -568;
		charactersLeft.y += 48 + 5;
		add(charactersLeft);

		var charactersRight:FlxSprite = new FlxSprite();
		charactersRight.frames = Paths.getSparrowAtlas('stages/skiStage/rightcharacters');
		charactersRight.animation.addByPrefix('idle', 'idle', 4, true);
		charactersRight.animation.play('idle');
		charactersRight.antialiasing = ClientPrefs.data.antialiasing;
		//charactersRight.x += charactersLeft.width - 400;
		charactersRight.x += -568 + 2230 + 40;
		charactersRight.y += 48 + 115;
		add(charactersRight);
	}

	var snow:SnowParticles;
	var lights:BGSprite;
	var shadow:BGSprite;
	var cocoaLightsCloudy:BGSprite;
	var cocoaShadowCloudy:BGSprite;

	var rimBF:DropShadowShader;
	var rimGF:DropShadowShader;
	var rimDad:DropShadowShader;
	var rimPlayer3:DropShadowShader;

	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			snow = new SnowParticles(0, 0, 3840, 400, 'stages/skiStage/snowParticle');
			snow.startY = 300;
			snow.endY = 1500;
			snow.intensity = 2; // snow intensity = 9 is like too much (eggnog.. ) for cocoa i would like less snow and sunnier weather
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') snow.intensity = 7;
			snow.xIntensity = -500;
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') snow.xIntensity = -600;
			snow.endScale = 1;
			snow.randomX = 1000;
			snow.randomY = 300;

			// final ones
			//snow.randomX = 300;
			//snow.randomY = 200;
			snow.spawnDelay = 0.15;
			snow.initialScale = 0.75;
			snow.endScale = 0.55;
			snow.fadeSpeed = 1.5;
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') snow.fadeSpeed = 1.3;
			add(snow);

			var snowboards:BGSprite = new BGSprite('stages/skiStage/snowboards', 0, 0, 1, 1);
			add(snowboards);

			var charactersLeftFront:FlxSprite = new FlxSprite();
			charactersLeftFront.frames = Paths.getSparrowAtlas('stages/skiStage/leftFrontChar');
			charactersLeftFront.animation.addByPrefix('idle', 'idle', 4, true);
			charactersLeftFront.animation.play('idle');
			charactersLeftFront.antialiasing = ClientPrefs.data.antialiasing;
			//charactersLeftFront.x += charactersLeftFront.width;
			charactersLeftFront.scrollFactor.set(1.1, 1.1);
			charactersLeftFront.x += -568 + 70 + 500 + 400 - 50;
			charactersLeftFront.y += 48 + 5 + 620 + 200 + 190;
			add(charactersLeftFront);

			var charactersRightFront:FlxSprite = new FlxSprite();
			charactersRightFront.frames = Paths.getSparrowAtlas('stages/skiStage/rightFrontChar');
			charactersRightFront.animation.addByPrefix('idle', 'idle', 4, true);
			charactersRightFront.animation.play('idle');
			charactersRightFront.antialiasing = ClientPrefs.data.antialiasing;
			//charactersRightFront.x += charactersLeft.width - 400;
			charactersRightFront.scrollFactor.set(1.05, 1.05);
			charactersRightFront.x += -568 + 2230 + 40 + 40 + 950;
			charactersRightFront.y += 48 + 115 + 600 + 200 + 175;
			add(charactersRightFront);

			lights = new BGSprite('stages/skiStage/lights', 0, 0, 1, 1);
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') lights.loadGraphic(Paths.image('stages/skiStage/lightsCloudy'));
			lights.blend = ADD;
			add(lights);

			cocoaLightsCloudy = new BGSprite('stages/skiStage/lightsCloudy', 0, 0, 1, 1);
			cocoaLightsCloudy.alpha = 0;
			cocoaLightsCloudy.blend = ADD;
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') cocoaLightsCloudy.visible = false;
			add(cocoaLightsCloudy);
			
			shadow = new BGSprite('stages/skiStage/shadow', 0, 0, 1, 1);
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') shadow.loadGraphic(Paths.image('stages/skiStage/shadowCloudy'));
			add(shadow);

			cocoaShadowCloudy = new BGSprite('stages/skiStage/shadowCloudy', 0, 0, 1, 1);
			cocoaShadowCloudy.alpha = 0;
			//cocoaShadowCloudy.blend = ADD;
			if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') cocoaShadowCloudy.visible = false;
			add(cocoaShadowCloudy);

			if(ClientPrefs.data.shaders)
			{
				rimBF = new DropShadowShader();
				rimBF.setAdjustColor(0, 0, 0, 0);
				if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') rimBF.setAdjustColor(-6, -12, 6, -22);
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

				rimGF = new DropShadowShader();
				rimGF.setAdjustColor(0, 0, 0, 0);
				if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') rimGF.setAdjustColor(-6, -12, 6, -22);
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

				rimDad = new DropShadowShader();
				rimDad.setAdjustColor(0, 0, 0, 0);
				if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') rimDad.setAdjustColor(-6, -12, 6, -22);
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

				if(game.player3 != null)
				{
					rimPlayer3 = new DropShadowShader();
					rimPlayer3.setAdjustColor(0, 0, 0, 0);
					if(PlayState.SONG != null && PlayState.SONG.song == 'Eggnog') rimPlayer3.setAdjustColor(-6, -12, 6, -22);
					rimPlayer3.color = 0x0;
					game.player3.shader = rimPlayer3;
					rimPlayer3.attachedSprite = game.player3;
					rimPlayer3.angle = 90;

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
	}

	override function stepHit()
	{
		switch(curStep)
		{
			case 512:
				if(PlayState.SONG.song == 'Cocoa')
				{
					if(!ClientPrefs.data.lowQuality)
					{
						FlxTween.tween(cocoaCloudySky, {alpha: 1}, 35);
						FlxTween.tween(sun, {alpha: 0}, 35);
						FlxTween.tween(sunLight, {alpha: 0}, 35);
						FlxTween.tween(cocoaLightsCloudy, {alpha: 1}, 35);
						FlxTween.tween(cocoaShadowCloudy, {alpha: 1}, 35);
						FlxTween.tween(lights, {alpha: 0}, 35);
						FlxTween.tween(shadow, {alpha: 0}, 35);
						FlxTween.num(2, 5, 35, null, function(v:Float)
						{
							snow.intensity = Std.int(v);
						});
						FlxTween.num(20, 50, 35, null, function(v:Float)
						{
							snow.velocity.x = v;
						});
						
						FlxTween.num(1000, 300, 35, null, function(v:Float)
						{
							snow.randomX = Std.int(v);
						});

						handleCharacterShaders(rimBF);
						handleCharacterShaders(rimGF);
						handleCharacterShaders(rimDad);
						handleCharacterShaders(rimPlayer3);
					}
				}
		}
	}

	override function update(elapsed:Float)
	{
		if(PlayState.SONG != null)
		{

		}
	}

	var goneBack:Bool = false;
	function startFenceCharStuff(left:Bool)
	{
		if(left)
		{
			fenceChar2.flipX = false;
			fenceChar1.animation.play('run', true);
			FlxTween.tween(fenceChar1, {x: fenceChar1.x - 985}, 7, {onComplete: function(twn:FlxTween)
			{
				fenceChar1.flipX = true;
				fenceChar1.animation.play('idle', true);
			}});

			FlxTween.tween(fenceChar2, {x: fenceChar2.x - 985}, 10, {onComplete: function(twn:FlxTween) 
			{
				startFenceCharStuff(false);
			}});
		}
		else
		{
			fenceChar2.flipX = true;
			fenceChar1.animation.play('run', true);
			FlxTween.tween(fenceChar1, {x: fence.x + fence.width - 1440}, 7, {onComplete: function(twn:FlxTween)
			{
				fenceChar1.flipX = false;
				fenceChar1.animation.play('idle', true);
			}});

			FlxTween.tween(fenceChar2, {x: fence.x + fence.width - 1440}, 10, {onComplete: function(twn:FlxTween) 
			{
				startFenceCharStuff(true);
			}});
		}
	}

	function handleCharacterShaders(targetRim:Dynamic) {

		FlxTween.num(0, -6, 35, null, function(v:Float)
		{
			targetRim.setAdjustColor(v, targetRim.baseHue, targetRim.baseContrast, targetRim.baseSaturation);
		});

		FlxTween.num(0, -12, 35, null, function(v:Float)
		{
			targetRim.setAdjustColor(targetRim.baseBrightness, v, targetRim.baseContrast, targetRim.baseSaturation);
		});

		FlxTween.num(0, 6, 35, null, function(v:Float)
		{
			targetRim.setAdjustColor(targetRim.baseBrightness, targetRim.baseHue, v, targetRim.baseSaturation);
		});

		FlxTween.num(0, -22, 35, null, function(v:Float)
		{
			targetRim.setAdjustColor(targetRim.baseBrightness, targetRim.baseHue, targetRim.baseContrast, v);
		});
	}
}