package backend;

import shaders.IconTransition;

class IconFadeTransition extends MusicBeatSubstate
{
    public static var instance:IconFadeTransition;
    var shader:IconTransition;
    var icon:FlxSprite;

    public function new(duration:Float = 0.5, iconName:String, transIn:Bool = true, onComplete:Void->Void)
    {
        super();

        if(instance != null) instance.close();
        instance = this;

        var transparentBackground = new FlxSprite();
        transparentBackground.makeGraphic(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2), 0xFF000000);
        transparentBackground.screenCenter();
        add(transparentBackground);

        icon = new FlxSprite();
        icon.loadGraphic(Paths.image('freePlay/NEW/icons/$iconName'));
        icon.antialiasing = ClientPrefs.data.antialiasing;
        icon.updateHitbox();
        icon.scale.set(0, 0);

        shader = new IconTransition();
        shader.scale.value = [0.5];
        shader.icon.input = icon.pixels;
        transparentBackground.shader = shader;

        FlxTween.cancelTweensOf(icon);
        if(transIn)
        {
            icon.scale.set(2, 2);
            shader.scale.value = [icon.scale.x];
            FlxTween.tween(icon, {"scale.x": 0, "scale.y": 0}, duration, {
                ease: FlxEase.quartOut,
                onUpdate: (_) -> shader.scale.value = [icon.scale.x],
                onComplete: function(twn:FlxTween) 
                {
                    instance = null;
                    onComplete();
                }
            });
        }
        else
        {
            icon.scale.set(0, 0);
            FlxTween.tween(icon, {"scale.x": 2, "scale.y": 2}, duration, {
                ease: FlxEase.quartOut,
                onUpdate: (_) -> shader.scale.value = [icon.scale.x],
                onComplete: function(twn:FlxTween) 
                {
                    instance = null;
                    onComplete();
                }
            });
        }
    }
}