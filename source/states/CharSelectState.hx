package states;

import backend.Conductor;
import flixel.addons.display.FlxBackdrop;
import shaders.WaterShader;

class CharSelectState extends MusicBeatState
{
    var avaibleCharactersGrp:FlxTypedGroup<CharSelectObject>;
    var avaibleCharactersArr:Array<Dynamic> = [
        ['bf', 0xFFFFFD9C],
        ['pico', 0xFF8C1249]
    ];

    static var curSelected:Int = 0;

    var bg:FlxSprite;
    var blackBg:FlxSprite;
    var checkerWhite:FlxBackdrop;
    var checker:FlxBackdrop;
    var waterShader:WaterShader;
    var gradient:FlxSprite;
    var graphicColor:FlxSprite;
    var line:FlxSprite;
    var blackThing:FlxSprite;
    var selectorLeft:FlxSprite;
    var selectorRight:FlxSprite;
    var light:FlxSprite;
    var poloUp:FlxSprite;
    var poloDown:FlxSprite;
    var nametag:FlxSprite;

    var checkerSpeed:Float = 14;
    override function create()
    {
        super.create();

        Conductor.bpm = 85;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Character Selector", null);
		#end

		if(FlxG.sound.music != null)
		{
            trace('music not null');
            /*
			if(!FlxG.sound.music.playing)
			{
                trace('music not playing');
				FlxG.sound.playMusic(Paths.music('charSelect/stayFunky'), 0);
				FlxG.sound.music.fadeIn(1);
			}
            */

			FlxG.sound.playMusic(Paths.music('charSelect/stayFunky'), 0);
			FlxG.sound.music.fadeIn(1);
		}

        waterShader = new WaterShader();
        waterShader.iTime.value = [0];

        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('charSelect/bglol'));
        bg.screenCenter();
        bg.x += 10;
        bg.y += 60;
        bg.shader = waterShader;
        bg.antialiasing = ClientPrefs.data.antialiasing;
        //add(bg);

        blackBg = new FlxSprite();
        blackBg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        blackBg.screenCenter();
        blackBg.alpha = 0.4;
        acceptOptions.set(blackBg, 0.7);
        backOptions.set(blackBg, 0.4);
        add(blackBg);

        checker = new FlxBackdrop(Paths.image('charSelect/checker'), XY);
        checker.antialiasing = ClientPrefs.data.antialiasing;
        checker.velocity.set(-checkerSpeed, checkerSpeed);
        add(checker);

        checkerWhite = new FlxBackdrop(Paths.image('charSelect/checkerwhite'), XY);
        checkerWhite.antialiasing = ClientPrefs.data.antialiasing;
        checkerWhite.velocity.set(checkerSpeed, checkerSpeed);
        add(checkerWhite);

        graphicColor = new FlxSprite();
        graphicColor.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
        graphicColor.blend = MULTIPLY;
        graphicColor.antialiasing = ClientPrefs.data.antialiasing;
        add(graphicColor);

        gradient = new FlxSprite();
        gradient.loadGraphic(Paths.image('charSelect/gradient'));
        gradient.antialiasing = ClientPrefs.data.antialiasing;
        gradient.blend = ADD;
        gradient.y = FlxG.height -gradient.height;
        add(gradient);

        line = new FlxSprite();
        line.loadGraphic(Paths.image('charSelect/line'));
        line.screenCenter();
        line.antialiasing = ClientPrefs.data.antialiasing;
        add(line);

        blackThing = new FlxSprite();
        blackThing.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        blackThing.alpha = 0;
        acceptOptions.set(blackThing, 0.35);
        backOptions.set(blackThing, 0);
        add(blackThing);

        avaibleCharactersGrp = new FlxTypedGroup<CharSelectObject>();
        add(avaibleCharactersGrp);

        nametag = new FlxSprite();
        nametag.loadGraphic(Paths.image('charSelect/characters/${avaibleCharactersArr[curSelected][0]}Name'));
        nametag.antialiasing = ClientPrefs.data.antialiasing;
        nametag.screenCenter(X);
        nametag.y = 70;
        nametag.shader = waterShader;
        add(nametag);

        light = new FlxSprite();
        light.loadGraphic(Paths.image('charSelect/light'));
        light.blend = ADD;
        light.alpha = 0.55;
        light.antialiasing = ClientPrefs.data.antialiasing;
        acceptOptions.set(light, 0.65);
        backOptions.set(light, 0.55);
        //add(light);

        selectorLeft = new FlxSprite(300, 0);
        selectorLeft.loadGraphic(Paths.image('charSelect/arrow'));
        selectorLeft.flipX = true;
        selectorLeft.antialiasing = ClientPrefs.data.antialiasing;
        selectorLeft.screenCenter(Y);
        add(selectorLeft);

        selectorRight = new FlxSprite(0, 0);
        selectorRight.loadGraphic(Paths.image('charSelect/arrow'));
        selectorRight.x = FlxG.width - selectorRight.width - 300;
        selectorRight.screenCenter(Y);
        add(selectorRight);

        for(i in 0...avaibleCharactersArr.length)
        {
            var char = new CharSelectObject(0, 0, avaibleCharactersArr[i][0], avaibleCharactersArr[i][1]);
            char.useTargets = true;
            char.screenCenter();
            char.y += 55;
            switch(avaibleCharactersArr[i][0])
            {
                case 'bf': char.offset.set(30, 0);
                case 'pico': char.offset.set(-30, 0);
            }
            char.startPosition = new FlxPoint(char.x, char.y);
            trace('startposition.x is ${char.startPosition.x}');
            char.targetX = i;
            char.targetY = i;
            char.ID = i;
            char.snap();
            avaibleCharactersGrp.add(char);
        }

        poloUp = new FlxSprite();
        poloUp.loadGraphic(Paths.image('charSelect/poloUp'));
        poloUp.antialiasing = ClientPrefs.data.antialiasing;
        add(poloUp);

        poloDown = new FlxSprite();
        poloDown.loadGraphic(Paths.image('charSelect/poloDown'));
        poloDown.antialiasing = ClientPrefs.data.antialiasing;
        poloDown.y = FlxG.height - poloDown.height;
        add(poloDown);

        changeSelect();
    }

    public static var currentFreeplaySelectedName:String = 'bf';
    var selectedCharacter:Bool = false;
    var currentCharacter:CharSelectObject; // reference of the selected char
    var acceptTimer:FlxTimer;
    var idleTimer:FlxTimer;
    var canInteract:Bool = true;
    final acceptOptions:Map<FlxSprite, Float> = new Map<FlxSprite, Float>();
    final backOptions:Map<FlxSprite, Float> = new Map<FlxSprite, Float>();
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var multRight:Float = FlxMath.lerp(selectorRight.scale.x, 1, elapsed * 21);
        selectorRight.scale.set(multRight, multRight);
        
        var multLeft:Float = FlxMath.lerp(selectorLeft.scale.x, 1, elapsed * 21);
        selectorLeft.scale.set(multLeft, multLeft);

        if(FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

        if(waterShader != null) waterShader.iTime.value[0] += elapsed;

        if(!selectedCharacter && canInteract)
        {
            if(controls.UI_LEFT_P)
            {
                selectorLeft.scale.set(1.1, 1.1);
                changeSelect(-1);
            }

            if(controls.UI_RIGHT_P)
            {
                selectorRight.scale.set(1.1, 1.1);
                changeSelect(1);
            }

            if(controls.ACCEPT)
            {
                selectedCharacter = true;

                FlxG.sound.music.fadeOut(0.5);
                FlxG.sound.play(Paths.sound('charSelect/CS_confirm'));

                FlxTween.cancelTweensOf(FlxG.camera);
                FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.4, {ease: FlxEase.quartOut});

                for(object in acceptOptions.keys())
                {
                    FlxTween.cancelTweensOf(object);
                    final alphaValue:Float = acceptOptions.get(object);
                    FlxTween.tween(object, {alpha: alphaValue}, 0.4, {ease: FlxEase.quartOut});
                }

                avaibleCharactersGrp.forEach(function(obj:CharSelectObject)
                {
                    if(obj.ID == curSelected)
                    {
                        if(currentCharacter != null) currentCharacter.animation.finishCallback = null;
                        currentCharacter = obj;

                        obj.animation.finishCallback = null;
                        obj.animation.play('accept', true);
                    }
                });

                if(currentCharacter.idleTimer != null && !currentCharacter.idleTimer.finished)
                    currentCharacter.idleTimer.cancel();

                acceptTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
                {
                    currentFreeplaySelectedName = avaibleCharactersArr[curSelected][0];

                    FlxG.sound.music.stop();
                    MusicBeatState.switchStateIcon(new NewFreeplayState(currentFreeplaySelectedName == 'pico'), currentFreeplaySelectedName, 0.8);
                });
            }
        }

        if(controls.BACK)
        {
            if(selectedCharacter)
            {
                if(!FlxG.sound.music.playing) return; // this means we are in the middle of the transition and we don't want lofi music in the freeplay menu (already experienced this and not funny.) -madera

                trace('SELECTED CHAR TRUE! Reverse anim...');
                selectedCharacter = false;
                acceptTimer.cancel();

                FlxTween.cancelTweensOf(FlxG.sound.music);
                FlxG.sound.music.fadeIn(0.6, FlxG.sound.music.volume);
                FlxG.sound.music.pitch = 0.4;
                FlxTween.tween(FlxG.sound.music, {pitch: 1}, 0.6);

                FlxTween.cancelTweensOf(FlxG.camera);
                FlxTween.tween(FlxG.camera, {zoom: 1}, 0.25, {ease: FlxEase.quartOut});

                for(object in backOptions.keys())
                {
                    FlxTween.cancelTweensOf(object);
                    final alphaValue:Float = backOptions.get(object);
                    FlxTween.tween(object, {alpha: alphaValue}, 0.4, {ease: FlxEase.quartOut});
                }

                // cancel anim
                if(currentCharacter == null) throw "Ermm, what the hell? currentCharacter seems to be null.";

                currentCharacter.goneBack = true;
                currentCharacter.animation.play('deny', true);
                currentCharacter.animation.finishCallback = function(name)
                {
                    if(name == 'deny') 
                    {
                        if(currentCharacter.idleTimer != null && !currentCharacter.idleTimer.finished)
                            currentCharacter.idleTimer.cancel();
                        currentCharacter.idleTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
                        {
                            avaibleCharactersGrp.forEach(function(obj:CharSelectObject)
                            {
                                if(obj.goneBack)
                                {
                                    obj.goneBack = false;
                                    obj.animation.play('idle');
                                }
                            });
                        });
                    }
                }
            }
            else goBack();
        }
    }

    override function beatHit()
    {
        super.beatHit();

        for(obj in avaibleCharactersGrp)
        {
            if(obj.animation.curAnim.name == 'idle') obj.animation.play('idle', true);
        }
    }

    function goBack()
    {
        if(MusicBeatState.timePassedOnState < 0.8) return;

        if(!canInteract) return;
        canInteract = false;
        FlxG.sound.play(Paths.sound('cancelMenu'));
        
        FlxG.sound.music.fadeOut(0.5);
        new FlxTimer().start(0.5, function(tmr:FlxTimer)
        {
            FlxG.sound.music.pause();
        });

        MusicBeatState.switchStateIcon(new NewFreeplayState(currentFreeplaySelectedName == 'pico'), currentFreeplaySelectedName, 0.8);
    }

    function changeSelect(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, avaibleCharactersArr.length - 1);

        if(change != 0) FlxG.sound.play(Paths.sound('charSelect/CS_select'));

        FlxTween.cancelTweensOf(graphicColor);
        //FlxTween.cancelTweensOf(gradient);

        FlxTween.color(graphicColor, 0.2, graphicColor.color, avaibleCharactersGrp.members[curSelected].charColor);
        //FlxTween.color(gradient, 0.2, gradient.color, avaibleCharactersGrp.members[curSelected].charColor);
        
        nametag.loadGraphic(Paths.image('charSelect/characters/${avaibleCharactersArr[curSelected][0]}Name'));
        nametag.screenCenter(X);

        avaibleCharactersGrp.forEach(function(obj:CharSelectObject)
        {
            obj.targetX = obj.ID - curSelected;
            obj.targetY = obj.ID - curSelected;

            FlxTween.cancelTweensOf(obj);
            FlxTween.color(obj, 0.1, obj.color, obj.ID == curSelected ? 0xFFFFFFFF : 0xFF666666);
        });
    }
}

class CharSelectObject extends FlxSprite
{
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    public var targetX:Float = 0;
    public var targetY:Float = 0;
    public var elapsedSpeed:Float = 8;
    public var useTargets:Bool = true;
    public var charColor:FlxColor = 0xFFFFFFFF;
    public var goneBack:Bool = false;
    public var idleTimer:FlxTimer;

    public function new(x:Float = 0, y:Float = 0, name:String = '', _charColor:FlxColor = 0xFFFFFFFF)
    {
        super(x, y);

        frames = Paths.getSparrowAtlas('charSelect/characters/$name');
        animation.addByPrefix('idle', 'bf', 12, false);
        animation.addByPrefix('accept', 'accept', 12, false);
        animation.addByPrefix('deny', 'deny', 12, false);
        animation.play('idle');

        charColor = _charColor;

        antialiasing = ClientPrefs.data.antialiasing;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(useTargets) 
        {
            x = FlxMath.lerp(x, startPosition.x + (targetX * (FlxG.width * 0.4)), elapsed * elapsedSpeed);

            var distance:Float = 60;
            var yDifference = targetY > 0 ? (targetY * distance) : -(targetY * distance);
            y = FlxMath.lerp(y, startPosition.y + yDifference, elapsed * elapsedSpeed);
            
            var mult = FlxMath.lerp(scale.x, targetX == 0 ? 1 : 0.75, elapsed * elapsedSpeed);
            scale.set(mult, mult);
            // trace('${startPosition.x} + ($targetX * ${FlxG.width}) = ${startPosition.x + (targetX * FlxG.width)}');
        }
    }

    public function snap()
    {
        x = startPosition.x + (targetX * (FlxG.width * 0.4));
        
        var distance:Float = 60;
        var yDifference = targetY > 0 ? (targetY * distance) : -(targetY * distance);
        y = startPosition.y + yDifference;

        var mult = targetX == 0 ? 1 : 0.75;
        scale.set(mult, mult);
    }
}