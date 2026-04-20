package states.vault;

class ShopSubState extends MusicBeatSubstate
{
    public function new()
    {
        super();
    }

    var itemsListArr:Array<Dynamic> = [ // Name - Price - Stars
        ['Picostola', 150, 2],
        ['Tricky Sign', 150, 2]
    ];
    var itemsListGrp:FlxTypedGroup<ItemShop>;

    private var curSelected:Int = 0;

    var bg:FlxSprite;
    var blackThingie:FlxSprite;
    var itemsCamera:FlxCamera;

    override function create()
    {
        super.create();

        bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        add(bg);

        blackThingie = new FlxSprite(130, 0);
        blackThingie.makeGraphic(520, 540, 0xFF000000);
        blackThingie.alpha = 0.5;
        blackThingie.y = FlxG.height - blackThingie.height;
        add(blackThingie);

        itemsCamera = new FlxCamera(130, blackThingie.y, Std.int(blackThingie.width), Std.int(blackThingie.height));
        itemsCamera.bgColor.alpha = 0;
        add(itemsCamera);

        //FlxG.cameras.list.insert(FlxG.cameras.list.length - 3, itemsCamera);
        FlxG.cameras.add(itemsCamera, false);

        itemsListGrp = new FlxTypedGroup<ItemShop>();
        add(itemsListGrp);

        for(i in 0...itemsListArr.length)
        {
            var item = new ItemShop(0, 0, 400, 70);
            item.cameras = [itemsCamera];
            item.x = 60;
            item.y = 20 + ((item.height + 20) * i);
            //item.y = blackThingie.y + 20;

            item.title = itemsListArr[i][0];
            item.price = itemsListArr[i][1];
            item.stars = itemsListArr[i][2];
            item.ID = i;

            item.startPosition.y = item.y;

            item.targetY = i;
            item.snapToPosition();

            itemsListGrp.add(item);
        }


        //FlxTween.tween(item, {y: 0}, 1, {type: PINGPONG});

        initTransition();
        changeSelection();
    }

    function initTransition()
    {
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.2}, 1, {ease: FlxEase.quartOut});
    }

    function changeSelection(change:Int = 0)
    {
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + change, 0, itemsListArr.length - 1);

		for (num => item in itemsListGrp.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.UI_UP_P)
        {
            changeSelection(-1);
        }

        if(controls.UI_DOWN_P)
        {
            changeSelection(1);
        }

        if(controls.BACK)
        {
            close();
        }
    }
}

class ItemShop extends FlxSpriteGroup
{
    public var title(default, set):String = '';
    private function set_title(value:String)
    {
        title = value;
        titleText.text = title;
        return value;
    }
    public var price(default, set):Int = 0;
    private function set_price(value:Int)
    {
        price = value;
        priceText.text = '$price';
        return value;
    }
    public var stars(default, set):Int = 0;

    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(0, 0);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);

    private function set_stars(value:Int)
    {
        stars = value;

        startsGrp.forEach(function(spr:FlxSprite) spr.destroy());
        startsGrp.clear();

        for(i in 0...stars)
        {
            var starSpr = new FlxSprite();
            starSpr.makeGraphic(30, 30, 0xFFFFFFFF);
            add(starSpr);
            startsGrp.add(starSpr);

            starSpr.x += 10 + (starSpr.width + 10) * i;
            starSpr.y += height - starSpr.height - 10;
        }

        return value;
    }

    public var bg:FlxSprite;
    public var titleText:FlxText;
    public var priceText:FlxText;
    public var startsGrp:FlxTypedGroup<FlxSprite>;

    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);

        bg = new FlxSprite();
        bg.makeGraphic(width, height, 0xFF000000);
        add(bg);

        titleText = new FlxText(0, 0, 0, '', 14);
        titleText.setFormat(Paths.font('GAU_pop_magic.ttf'), 16, 0xFFFFFFFF);
        titleText.antialiasing = ClientPrefs.data.antialiasing;
        add(titleText);

        titleText.x += 5;
        titleText.y += 5;

        priceText = new FlxText(0, 0, width, '', 14);
        priceText.setFormat(Paths.font('GAU_pop_magic.ttf'), 16, 0xFFFFFFFF, RIGHT);
        priceText.antialiasing = ClientPrefs.data.antialiasing;
        add(priceText);

        priceText.x += -5;
        priceText.y += 5;

        startsGrp = new FlxTypedGroup<FlxSprite>();

        for(i in 0...stars)
        {
            var starSpr = new FlxSprite();
            starSpr.makeGraphic(20, 20, 0xFFFFFFFF);
            add(starSpr);
            startsGrp.add(starSpr);

            starSpr.x += 5 + (starSpr.width + 10) * i;
            starSpr.y += height - starSpr.height - 5;
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		y = FlxMath.lerp((targetY * distancePerItem.y) + startPosition.y, y, lerpVal);
    }

    public function snapToPosition()
    {
		y = (targetY * distancePerItem.y) + startPosition.y;
    }
}