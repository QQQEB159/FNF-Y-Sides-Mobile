package states;

import shaders.WaterShader;

class CharSelectState extends MusicBeatState
{
    var avaibleCharactersGrp:FlxTypedGroup<CharSelectObject>;
    var avaibleCharactersArr:Array<String> = [
        'bf',
        'bf'
    ];

    static var curSelected:Int = 0;
    var waterShader:WaterShader;

    override function create()
    {
        super.create();

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

        var bg = new FlxSprite();
        bg.loadGraphic(Paths.image('charSelect/bglol'));
        bg.screenCenter();
        bg.x += 10;
        bg.y += 60;
        bg.shader = waterShader;
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

        var blackBg = new FlxSprite();
        blackBg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        blackBg.screenCenter();
        blackBg.alpha = 0.4;
        add(blackBg);
        
        var gradient = new FlxSprite();
        gradient.loadGraphic(Paths.image('charSelect/gradient'));
        gradient.antialiasing = ClientPrefs.data.antialiasing;
        add(gradient);

        avaibleCharactersGrp = new FlxTypedGroup<CharSelectObject>();
        add(avaibleCharactersGrp);

        var light = new FlxSprite();
        light.loadGraphic(Paths.image('charSelect/light'));
        light.blend = ADD;
        light.alpha = 0.55;
        light.antialiasing = ClientPrefs.data.antialiasing;
        add(light);

        var selectorLeft = new Alphabet(300, 0, '<', true);
        selectorLeft.screenCenter(Y);
        add(selectorLeft);

        var selectorRight = new Alphabet(0, 0, '>', true);
        selectorRight.x = FlxG.width - selectorRight.width - 300;
        selectorRight.screenCenter(Y);
        add(selectorRight);

        for(i in 0...avaibleCharactersArr.length)
        {
            var char = new CharSelectObject(0, 0, avaibleCharactersArr[i]);
            char.useTargets = true;
            char.screenCenter();
            char.startPosition = new FlxPoint(char.x, char.y);
            trace('startposition.x is ${char.startPosition.x}');
            char.targetX = i;
            char.targetY = i;
            char.ID = i;
            char.snap();
            avaibleCharactersGrp.add(char);
        }

        changeSelect();
    }

    var selectedCharacter:Bool = false;
    var currentCharacter:CharSelectObject; // reference of the selected char
    var acceptTimer:FlxTimer;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(waterShader != null) waterShader.iTime.value[0] += elapsed;

        if(!selectedCharacter)
        {
            if(controls.UI_LEFT_P)
            {
                changeSelect(-1);
            }

            if(controls.UI_RIGHT_P)
            {
                changeSelect(1);
            }

            if(controls.ACCEPT)
            {
                selectedCharacter = true;

                FlxG.sound.music.fadeOut(1);
                FlxG.sound.play(Paths.sound('charSelect/CS_confirm'));

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

                acceptTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
                {
                    FlxG.sound.music.stop();
                    MusicBeatState.switchState(new FreeplayState());
                });
            }
        }

        if(controls.BACK)
        {
            if(selectedCharacter)
            {
                trace('SELECTED CHAR TRUE! Reverse anim...');
                selectedCharacter = false;
                acceptTimer.cancel();

                FlxTween.cancelTweensOf(FlxG.sound.music);
                FlxG.sound.music.fadeIn(0.6, FlxG.sound.music.volume);
                FlxG.sound.music.pitch = 0.4;
                FlxTween.tween(FlxG.sound.music, {pitch: 1}, 0.6);

                // cancel anim
                if(currentCharacter == null) throw "Ermm, what the hell? currentCharacter seems to be null.";

                currentCharacter.animation.play('accept', true, true);
                currentCharacter.animation.finishCallback = function(name)
                {
                    if(name == 'accept') 
                    {
                        currentCharacter.animation.play('idle');
                    }
                }
            }
            else
            {
                goBack();
            }
        }
    }

    function goBack()
    {
        MusicBeatState.switchState(new FreeplayState());
    }

    function changeSelect(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, avaibleCharactersArr.length - 1);

        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

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

    public function new(x:Float = 0, y:Float = 0, name:String = '')
    {
        super(x, y);

        frames = Paths.getSparrowAtlas('charSelect/characters/$name');
        animation.addByPrefix('idle', 'bf', 24, true);
        animation.addByPrefix('accept', 'accept', 24, false);
        animation.play('idle');

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