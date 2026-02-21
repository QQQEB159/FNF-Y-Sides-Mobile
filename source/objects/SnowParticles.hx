package objects;

class SnowParticles extends FlxSpriteGroup
{
    public var imagePath:String = '';
    public var intensity:Int = 9;
    public var spawnDelay:Float = 0.4;
    public var fadeSpeed:Float = 0.9;
    public var xSpeed:Float = 0.9;
    public var xIntensity:Float = -50;
    public var initialScale:Float = 1;
    public var endScale:Float = 0;
    public var randomX:Float = 15;
    public var randomY:Float = 15;
    public var startY:Float = 0;
    public var endY:Float = 0;
    public var particleWidthField:Int = 1280;
    public var particleHeightField:Int = 720;

    var debugSprRatio:FlxSprite;

    public function new(x:Float, y:Float, _width:Int, _height:Int, _imagePath:String)
    {
        super(x, y);

        particleWidthField = _width;
        particleHeightField = _height;
        imagePath = _imagePath;

        debugSprRatio = new FlxSprite().makeGraphic(Std.int(particleWidthField), Std.int(particleHeightField), FlxColor.GREEN);
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
                var spr = new FlxSprite((particleWidthField / intensity) * (i+1), startY);
                spr.loadGraphic(Paths.image(imagePath));
                spr.scale.set(initialScale, initialScale);
                spr.updateHitbox();

                trace('Initial x: ${spr.x} (($particleWidthField / $intensity) * ${i+1})');

                spr.x += FlxG.random.float(-randomX, randomX);
                spr.y += FlxG.random.float(-randomY, randomY);

                //FlxTween.tween(spr, {x: spr.x + xIntensity}, xSpeed);
                spr.velocity.x = xIntensity;
                FlxTween.tween(spr, {"scale.x": endScale, "scale.y": endScale, y: endY}, fadeSpeed, {onComplete: function(twn:FlxTween)
                {
                    spr.destroy();
                }});
                add(spr);
            }
        }
    }
}