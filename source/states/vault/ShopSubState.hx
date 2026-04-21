package states.vault;

import flixel.addons.display.FlxBackdrop;

class ShopSubState extends MusicBeatSubstate
{
    public function new()
    {
        super();
    }

    var itemsListArr:Array<Dynamic> = [ // Name - Price - Stars - Image name
        ['Picostola', 150, 2, 'picostola'],
        ['Tricky Sign', 150, 2, 'tricky'],
        ['Calcetines', 75, 2, 'picostola'],
        ['Chocha de gbv', 75, 5, 'picostola'],
    ];
    var itemsListGrp:FlxTypedGroup<ItemShop>;

    var itemsImageGrp:FlxTypedGroup<ItemShopImage>;

    private var curSelected:Int = 0;

    var bg:FlxSprite;
    var blackThingie:FlxSprite;
    var border:FlxSprite;
    var pattern:FlxSprite;
    public static var itemsCamera:FlxCamera;

    var moneyBackground:FlxSprite;
    var moneyText:FlxText;

    override function create()
    {
        super.create();

        bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        add(bg);

        blackThingie = new FlxSprite(130, 0);
        blackThingie.makeGraphic(520, 540, 0xFFB19BE7);
        blackThingie.alpha = 0.5;
        blackThingie.y = FlxG.height - blackThingie.height;
        add(blackThingie);

        border = new FlxSprite(blackThingie.x - 21, blackThingie.y - 36);
        border.loadGraphic(Paths.image('vault/shop/border'));
        border.antialiasing = ClientPrefs.data.antialiasing;
        add(border);

        itemsCamera = new FlxCamera(130, blackThingie.y, Std.int(blackThingie.width), Std.int(blackThingie.height));
        itemsCamera.bgColor.alpha = 0;
        add(itemsCamera);

        //FlxG.cameras.list.insert(FlxG.cameras.list.length - 3, itemsCamera);
        FlxG.cameras.add(itemsCamera, false);

        pattern = new FlxBackdrop(Paths.image('vault/shop/weird_checker'), XY);
        pattern.alpha = 0.85;
        pattern.cameras = [itemsCamera];
        pattern.antialiasing = ClientPrefs.data.antialiasing;
        pattern.velocity.set(10, 10);
        add(pattern);

        itemsListGrp = new FlxTypedGroup<ItemShop>();
        add(itemsListGrp);

        itemsImageGrp = new FlxTypedGroup<ItemShopImage>();
        add(itemsImageGrp);

        var imageTargetAngle:Int = 2;
        for(i in 0...itemsListArr.length)
        {
            var item = new ItemShop(0, 0, 400, 70);
            item.cameras = [itemsCamera];
            item.x = 60;
            item.y = 20;
            item.antialiasing = ClientPrefs.data.antialiasing;
            //item.y = blackThingie.y + 20;

            item.title = itemsListArr[i][0];
            item.price = itemsListArr[i][1];
            item.stars = itemsListArr[i][2];
            item.ID = i;

            item.startPosition.y = item.y;
            item.distancePerItem.y = 90;

            item.targetY = i;
            item.snapToPosition();

            itemsListGrp.add(item);

            var image = new ItemShopImage(0, 0, Paths.image('vault/shop/items/${itemsListArr[i][3]}'));
            //image.cameras = [itemsCamera];
            image.screenCenter(Y);
            image.y += 20;
            image.x = blackThingie.x + blackThingie.width + ((FlxG.width - (blackThingie.x + blackThingie.width)) / 2) - (image.width / 2);
            image.antialiasing = ClientPrefs.data.antialiasing;

            image.startPosition.y = image.y;
            image.distancePerItem.y = FlxG.height;

            image.targetY = i;
            image.snapToPosition();
            image.angle = -imageTargetAngle;

            itemsImageGrp.add(image);

            new FlxTimer().start(0.65, function(tmr:FlxTimer)
            {
                image.angle = image.angle == imageTargetAngle ? -imageTargetAngle : imageTargetAngle;
            }, 0);

            image.x = FlxG.width;
            FlxTween.tween(image, {x: blackThingie.x + blackThingie.width + ((FlxG.width - (blackThingie.x + blackThingie.width)) / 2) - (image.width / 2)}, 0.7, {ease: FlxEase.quartOut});
        }

        moneyBackground = new FlxSprite(0, 90);
        moneyBackground.makeGraphic(200, 60, 0xFF000000);
        moneyBackground.alpha = 0.6;
        moneyBackground.antialiasing = ClientPrefs.data.antialiasing;
        add(moneyBackground);

        moneyText = new FlxText(0, 0, moneyBackground.width - 10, '100', 14);
        moneyText.setFormat(Paths.font('GAU_pop_magic.ttf'), 40, 0xFFFFFFFF, RIGHT);
        moneyText.y = moneyBackground.y + 10;
        moneyText.antialiasing = ClientPrefs.data.antialiasing;
        add(moneyText);

        // adjust background size
        moneyBackground.makeGraphic(Std.int(moneyText.width + 10), Std.int(moneyBackground.height), 0xFF000000);

        closeCallback = function()
        {
            FlxTimer.globalManager.clear();
        }


        //FlxTween.tween(item, {y: 0}, 1, {type: PINGPONG});

        initTransition();
        changeSelection();
    }

    function initTransition()
    {
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.2}, 1, {ease: FlxEase.quartOut});

        moneyBackground.x = FlxG.width;
        FlxTween.tween(moneyBackground, {x: FlxG.width - moneyBackground.width}, 0.7, {ease: FlxEase.quartOut});

        moneyText.x = FlxG.width + 5;
        FlxTween.tween(moneyText, {x: FlxG.width - moneyBackground.width + 5}, 0.7, {ease: FlxEase.quartOut});
        FlxTween.num(0, 100, 0.7, {ease: FlxEase.quartOut}, function(v:Float)
        {
            moneyText.text = '${Std.int(v)}';
        });
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

		for (num => item in itemsImageGrp.members)
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
            //starSpr.makeGraphic(20, 20, 0xFFFFFFFF);
            starSpr.frames = Paths.getSparrowAtlas('vault/shop/star');
            starSpr.animation.addByPrefix('idle', 'idle', 24, true);
            starSpr.animation.addByPrefix('light', 'light', 24, false);
            starSpr.animation.play('idle');
            add(starSpr);
            startsGrp.add(starSpr);

            starSpr.ID = i;
            starSpr.x += 5 + (starSpr.width + 10) * i;
            starSpr.y += height - starSpr.height - 5;
        }

        playStarsAnim();

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
            //starSpr.makeGraphic(20, 20, 0xFFFFFFFF);
            starSpr.frames = Paths.getSparrowAtlas('vault/shop/star');
            starSpr.animation.addByPrefix('idle', 'idle', 24, true);
            starSpr.animation.addByPrefix('light', 'light', 24, false);
            starSpr.animation.play('idle');
            add(starSpr);
            startsGrp.add(starSpr);

            starSpr.ID = i;
            starSpr.x += 5 + (starSpr.width + 10) * i;
            starSpr.y += height - starSpr.height - 5;
        }

        new FlxTimer().start(8, function(tmr:FlxTimer)
        {
            playStarsAnim();
        }, 0);
    }

    function playStarsAnim()
    {
        startsGrp.forEach(function(star:FlxSprite)
        {
            new FlxTimer().start(0.15 * star.ID, function(tmr:FlxTimer)
            {
                star.animation.play('light', true);
                star.animation.finishCallback = function(name:String)
                {
                    if(name == 'light') star.animation.play('idle');
                }
            });
        });
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

class ItemShopImage extends FlxSprite
{
    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(0, 0);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);

    public function new(x:Float = 0, y:Float = 0, image:Dynamic)
    {
        super(x, y);

        loadGraphic(image);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		y = FlxMath.lerp((targetY * distancePerItem.y) + startPosition.y, y, lerpVal);
    }

    public function snapToPosition()
    {
        y = startPosition.y + (targetY * distancePerItem.y);
    }
}