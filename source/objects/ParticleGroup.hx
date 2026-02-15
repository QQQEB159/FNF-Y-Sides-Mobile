package objects;

class ParticleGroup extends FlxSpriteGroup
{
    public var imagePath:String = '';
    public var intensity:Int = 9;
    public var spawnDelay:Float = 0.4;
    public var fadeSpeed:Float = 0.9;
    public var wiggleSpeed:Float = 0.9;
    public var wiggleIntensity:Float = 50;
    public var initialScale:Float = 1;
    public var randomX:Float = 15;
    public var randomY:Float = 15;
    public var startY:Float = 0;
    public var endY:Float = 0;

    var debugSprRatio:FlxSprite;

    public function new(x:Float, y:Float, _width:Int, _height:Int, _imagePath:String)
    {
        super(x, y);

        width = _width;
        height = _height;
        imagePath = _imagePath;

        debugSprRatio = new FlxSprite().makeGraphic(Std.int(width), Std.int(height), FlxColor.GREEN);
        debugSprRatio.alpha = 0.6;
        //add(debugSprRatio);
    }

    var timer:Float = 0;
    var lastTime:Float = 0;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        timer += elapsed;

        if(timer > lastTime + spawnDelay)
        {
            lastTime = timer;
            for(i in 0...intensity)
            {
                var spr = new FlxSprite((FlxG.width / intensity) * (i+1), startY);
                spr.loadGraphic(Paths.image(imagePath));
                spr.scale.set(initialScale, initialScale);

                spr.x += FlxG.random.float(-randomX, randomX);
                spr.y += FlxG.random.float(-randomY, randomY);

                FlxTween.tween(spr, {x: spr.x + wiggleIntensity}, wiggleSpeed, {type: PINGPONG});
                FlxTween.tween(spr, {"scale.x": 0, "scale.y": 0, y: endY}, fadeSpeed, {onComplete: function(twn:FlxTween)
                {
                    spr.destroy();
                }});
                add(spr);
            }
        }
    }
}