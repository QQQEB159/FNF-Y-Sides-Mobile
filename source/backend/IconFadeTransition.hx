package backend;

import shaders.IconTransition;

class IconFadeTransition extends MusicBeatSubstate
{
    public static var instance:IconFadeTransition;
    public var shader:IconTransition;
    public var icon:FlxSprite;

   public var borderLeft:FlxSprite;
   public var borderRight:FlxSprite;
   public var borderUp:FlxSprite;
   public var borderDown:FlxSprite;

    var targetScale:Float = 12;
    public function new(duration:Float = 0.5, iconName:String, transIn:Bool = true, onComplete:Void->Void)
    {
        super();

        if(instance != null) {
            FlxTween.cancelTweensOf(instance.icon);
            instance.close();
        }
        instance = this;

        shader = new IconTransition();

        icon = new FlxSprite();
        icon.loadGraphic(Paths.image('freePlay/NEW/icons/$iconName'));
        icon.antialiasing = ClientPrefs.data.antialiasing;
        icon.screenCenter();
        icon.updateHitbox();
        icon.shader = shader;
        add(icon);

        borderLeft = new FlxSprite();
        borderLeft.makeGraphic(1, FlxG.height, 0xFF000000);
        add(borderLeft);

        borderRight = new FlxSprite();
        borderRight.makeGraphic(1, FlxG.height, 0xFF000000);
        add(borderRight);

        borderUp = new FlxSprite();
        borderUp.makeGraphic(FlxG.width, 1, 0xFF000000);
        add(borderUp);

        borderDown = new FlxSprite();
        borderDown.makeGraphic(FlxG.width, 1, 0xFF000000);
        add(borderDown);

        FlxTween.cancelTweensOf(icon);
        if(transIn)
        {
            FlxG.sound.play(Paths.sound('transition/In'));
            icon.scale.set(targetScale, targetScale);
            updateIconStuff();
            FlxTween.tween(icon, {"scale.x": 0, "scale.y": 0}, duration, {
                ease: FlxEase.quartOut,
                onUpdate: (_) -> updateIconStuff(),
                onComplete: function(twn:FlxTween) 
                {
                    onComplete();
                    instance = null;
                }
            });
        }
        else
        {
            FlxG.sound.play(Paths.sound('transition/Out'));
            icon.scale.set(0, 0);
            updateIconStuff();
            FlxTween.tween(icon, {"scale.x": targetScale, "scale.y": targetScale}, duration, {
                ease: FlxEase.quartOut,
                onUpdate: (_) -> updateIconStuff(),
                onComplete: function(twn:FlxTween) 
                {
                    onComplete();
                    instance = null;
                }
            });
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        updateIconStuff();
    }

    function updateIconStuff()
    {
        if(icon == null) return;
        
        try
        {
            icon?.updateHitbox();
            icon?.screenCenter();

            var distanceLeft:Float = icon.x;
            borderLeft.setGraphicSize(distanceLeft, FlxG.height);
            borderLeft.updateHitbox();
            borderLeft.x = 0;

            var distanceRight:Float = FlxG.width - (icon.x + icon.width);
            borderRight.setGraphicSize(distanceRight, FlxG.height);
            borderRight.updateHitbox();
            borderRight.x = icon.x + icon.width;

            var distanceUp:Float = icon.y;
            borderUp.setGraphicSize(FlxG.width, distanceUp);
            borderUp.updateHitbox();
            borderUp.y = 0;

            var distanceDown:Float = FlxG.height - (icon.y + icon.height);
            borderDown.setGraphicSize(FlxG.width, distanceDown);
            borderDown.updateHitbox();
            borderDown.y = icon.y + icon.height;
        }
        catch(exc) {}
    }
}