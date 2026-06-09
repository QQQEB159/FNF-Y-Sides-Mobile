package objects;

import objects.HoldNoteSplash.PixelHoldSplashShaderRef;

class PicoCardboardNote extends FlxSprite
{
	public var rgbShader:PixelHoldSplashShaderRef;
    public var lifeTime:Float = 0.55;

    public function new(x:Float, y:Float, direction:Int)
    {
        super(x, y);

		rgbShader = new PixelHoldSplashShaderRef();
		shader = rgbShader.shader;

		var shaderValues = Note.initializeGlobalRGBShader(direction % Note.colArray.length);
		rgbShader.copyValues(shaderValues);

        loadGraphic(Paths.image('hud/tinyNote${FlxG.random.int(1, 2)}'));
        velocity.set(120, -145);
        acceleration.y = 420;

        angle = FlxG.random.float(0, 360);
        FlxTween.tween(this, {alpha: 0}, lifeTime, {ease: FlxEase.linear});

        FlxTween.tween(this, {angle: this.angle + (360 * FlxG.random.float(0.25, 0.5))}, lifeTime, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
        {
            this.destroy();
        }});
    }

    var angleSpeed:Float = 18;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        angle += angleSpeed * elapsed;
    }
}