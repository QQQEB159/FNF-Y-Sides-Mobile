package states.gallery;

class GalleryObject extends FlxSprite
{
    public var targetX:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(1280, 0);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    
    public function new(x:Float = 0, y:Float = 0, ?graphic:Dynamic = null)
    {
        super(x, y, graphic);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		x = FlxMath.lerp((targetX * distancePerItem.x) + startPosition.x, x, lerpVal);
    }

    public function snapToPosition()
    {
        x = startPosition.x + (targetX * distancePerItem.x);
    }
}