package states.vault;

class ShopSubState extends MusicBeatSubstate
{
    public function new()
    {
        super();
    }

    var bg:FlxSprite;
    override function create()
    {
        super.create();

        bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        add(bg);

        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.2}, 1, {ease: FlxEase.quartOut});
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.BACK)
        {
            close();
        }
    }
}