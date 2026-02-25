package states.stages;

import states.stages.objects.*;
import objects.Character;

class PicoStage extends BaseStage
{
    var bg:BGSprite;
    var guards:BGSprite;
    var signs:BGSprite;
    var car:FlxSprite;

	override function create()
	{
		bg = new BGSprite('stages/picoStage/bg_pico', -1009, -728, 1, 1);
        bg.scale.set(0.9, 0.9);
        bg.updateHitbox();
        bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		guards = new BGSprite('stages/picoStage/guards', -470, -70, 1, 1, ['idle1', 'idle2']);
        guards.scale.set(1.3, 1.3);
        guards.animOffsets = [ [3, -8], [0, 5] ];
        guards.antialiasing = ClientPrefs.data.antialiasing;
        guards.updateHitbox();
        guards.animation.play('idle1');
        guards.offset.set(guards.animOffsets[0][0], guards.animOffsets[0][1]);
		add(guards);

		var lights:BGSprite = new BGSprite('stages/picoStage/lightslol', -1016 + 1120, -737 + 540, 1, 1);
        lights.scale.set(0.9, 0.9);
        lights.updateHitbox();
        lights.antialiasing = ClientPrefs.data.antialiasing;
		add(lights);
	}

    override function createPost() 
    {
		if(!ClientPrefs.data.lowQuality)
		{
            car = new FlxSprite();
            //car.makeGraphic(350, 350);
            car.antialiasing = ClientPrefs.data.antialiasing;
            car.x = 2000;
            car.y = bg.y + 1000;
            add(car);

		    var lights2:BGSprite = new BGSprite('stages/picoStage/lightsfr', -1079, -808, 1, 1);
            lights2.antialiasing = ClientPrefs.data.antialiasing;
            lights2.updateHitbox();
            lights2.blend = ADD;
            lights2.alpha = 0.5;
		    add(lights2);

		    signs = new BGSprite('stages/picoStage/signs', -1168, -959, 1.5, 1.5);
            signs.alpha = 0.95;
            signs.updateHitbox();
            signs.antialiasing = ClientPrefs.data.antialiasing;
		    add(signs);
        }
    }

    var signsVisible:Bool = true;
    override function update(elapsed:Float)
    {
        if(game.camGame.zoom > 0.65 && signsVisible) {
            signsVisible = false;

            if(signs == null) return;

            FlxTween.cancelTweensOf(signs);
            FlxTween.tween(signs, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        }
        else if(game.camGame.zoom <= 0.65 && !signsVisible) {
            signsVisible = true;
            
            if(signs == null) return;

            FlxTween.cancelTweensOf(signs);
            FlxTween.tween(signs, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
        }
    }

    override function beatHit()
    {
        if(curBeat % 2 == 0) 
        {
            guards.animation.play('idle1');
            guards.offset.set(guards.animOffsets[0][0], guards.animOffsets[0][1]);
        }
        else
        {
            guards.animation.play('idle2');
            guards.offset.set(guards.animOffsets[1][0], guards.animOffsets[1][1]);
        }

        if(FlxG.random.bool(10) && canSpawnCar)
        {
            spawnCar();
        }
    }

    var canSpawnCar:Bool = true;
    function spawnCar()
    {
        if(ClientPrefs.data.lowQuality) return;

        canSpawnCar = false;
        var random:Int = FlxG.random.int(1, 2);
        car.frames = Paths.getSparrowAtlas('stages/picoStage/car$random');
        car.animation.addByPrefix('idle', 'car anim', 24, true);
        car.animation.play('idle');

        if(random == 2) car.y += -190;

        FlxG.sound.play(Paths.sound('car_passing'));
        
        new FlxTimer().start(3.5, function(tmr:FlxTimer)
        {
            FlxTween.tween(car, {x: -2500}, 0.2, {ease: FlxEase.linear});
        });
        new FlxTimer().start(7, function(tmr:FlxTimer)
        {
            // reset
            car.x = 2000;
            car.y = bg.y + 1000;
            canSpawnCar = true;
        });
    }
}