package states.vault;

import cpp.abi.Abi;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxSort;
import backend.GameProgress;

class ShopSubState extends MusicBeatSubstate
{
    public function new()
    {
        super();
    }

    public static var boughtItems:Map<String, Bool> = new Map<String, Bool>();

    public static function buildItemsList():Map<String, Bool>
    {
        for(item in itemsListArr)
        {
            boughtItems.set(item[0], false);
        }
        return boughtItems;
    }

    public static function isItemUnlocked(name:String):Bool 
    {
        return boughtItems.get(name);
    }

    public static function unlockItem(name:String)
    {
        if(!boughtItems.get(name)) boughtItems.set(name, true);
        trace('Unlocked item $name (${boughtItems.get(name)})');

        Achievements.unlock('first_purchase');

        FlxG.save.data.boughtItems = boughtItems;
        FlxG.save.flush();
    }

    public static function hasBoughtAllItems():Bool
    {
        for(item in itemsListArr)
        {
            if(!boughtItems.get(item[0])) return false;
        }
        return true;
    }

    public static var money:Int;

    public static function addMoney(value:Int)
    {
        money += value;
        FlxG.save.data.money = money;
        FlxG.save.flush();

        trace('Added the amount of $value coins (Total: $money)');
    }

    public static var itemsListArr:Array<Dynamic> = [ // Name - Price - Stars - Image name
        ['Picostola', 300, 5, 'picostola'],
        ['Tricky Sign', 250, 4, 'tricky'],
        ['Tennis Racket', 175, 4, 'racket'],
        ['Banana', 150, 4, 'banana'],
        ['Mic Bulb', 150, 4, 'micbulb'],
        ['Singing Module', 100, 3, 'micbulb'],
        ['Bumbell', 75, 2, 'dumbell'],
        ['Sunglasses', 50, 2, 'sunglasses']
    ];
    var itemsListGrp:FlxTypedGroup<ItemShop>;

    var itemsImageGrp:FlxTypedGroup<ItemShopImage>;

    private var curSelected:Int = 0;

    var bg:FlxSprite;
    var blackThingie:FlxSprite;
    var border:FlxSprite;
    var pattern:FlxSprite;
    public static var itemsCamera:FlxCamera;
    public static var cursorCamera:FlxCamera;

    var moneyBox:MoneyBox;
    var pressEnterToConfirm:FlxText;

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

        cursorCamera = new FlxCamera();
        cursorCamera.bgColor.alpha = 0;
        add(cursorCamera);

        //FlxG.cameras.list.insert(FlxG.cameras.list.length - 3, itemsCamera);
        FlxG.cameras.add(itemsCamera, false);
        FlxG.cameras.add(cursorCamera, false);

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

            if(boughtItems.get(item.title)) 
            {
                item.bought = true;
                item.ID = i + itemsListArr.length; // push to the end, then the sort function will place it correctly
            }
            else
            {
                item.bought = false;
                item.ID = i;
            }

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
            image.parentItem = item;

            if(boughtItems.get(item.title)) 
            {
                image.ID = i + itemsListArr.length; // push to the end, then the sort function will place it correctly
            }
            else
            {
                image.ID = i;
            }

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

        initialSort();

        moneyBox = new MoneyBox(0, 90);
        add(moneyBox);

        pressEnterToConfirm = new FlxText(0, 0, FlxG.width, 'Press ENTER to confirm your purchase.');
        pressEnterToConfirm.setFormat(Paths.font('GAU_pop_magic.ttf'), 25, 0xFFE0DEEA, CENTER);
        pressEnterToConfirm.y = FlxG.height - moneyBox.height - 80 - pressEnterToConfirm.height - 10;
        pressEnterToConfirm.antialiasing = ClientPrefs.data.antialiasing;
        pressEnterToConfirm.alpha = 0;
        add(pressEnterToConfirm);

        // adjust background size

        closeCallback = function()
        {
            FlxTimer.globalManager.clear();
        }

        new FlxTimer().start(0.2, function(tmr:FlxTimer)
        {
            canAccept = true;
        });

        //FlxTween.tween(item, {y: 0}, 1, {type: PINGPONG});

        initTransition();
        changeSelection();
    }

    function initTransition()
    {
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.2}, 1, {ease: FlxEase.quartOut});

        moneyBox.x = FlxG.width;
        FlxTween.tween(moneyBox, {x: FlxG.width - moneyBox.width}, 0.7, {ease: FlxEase.quartOut});
        FlxTween.num(0, money, 0.7, {ease: FlxEase.quartOut}, function(v:Float)
        {
            moneyBox.money = Std.int(v);
        });
        moneyBox.updateWidth('$money');
    }

    function initialSort()
    {
        function sortByID(_, a:Dynamic, b:Dynamic):Int
        {
		    return FlxSort.byValues(FlxSort.ASCENDING, a.ID, b.ID);
        }

        itemsListGrp.sort(sortByID);
        itemsImageGrp.sort(sortByID);

        // reset ids, but with correct order depending on bought products
        for(num => item in itemsListGrp)
        {
            item.ID = num;
            item.targetY = num;
            item.snapToPosition();
        }

        for(num => item in itemsImageGrp)
        {
            item.ID = num;
            item.targetY = num;
            item.snapToPosition();
        }
    }

    function changeSelection(change:Int = 0)
    {
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + change, 0, itemsListArr.length - 1);

		for (num => item in itemsListGrp.members)
		{
            if(item == null) continue;

            FlxTween.cancelTweensOf(item);
            if(itemsListGrp.length > 5)
            {
			    switch(curSelected)
			    {

			    }

                if(itemsListGrp.length - curSelected == 4)
                {
			        item.targetY = item.ID - curSelected + 1;
			        item.alpha = 0.6;
			        if (item.targetY == 1) item.alpha = 1;
                }
                else if(itemsListGrp.length - curSelected == 3)
                {
			        item.targetY = item.ID - curSelected + 2;
			        item.alpha = 0.6;
			        if (item.targetY == 2) item.alpha = 1;
                }
                else if(itemsListGrp.length - curSelected == 2)
                {
			        item.targetY = item.ID - curSelected + 3;
			        item.alpha = 0.6;
			        if (item.targetY == 3) item.alpha = 1;
                }
                else if(itemsListGrp.length - curSelected == 1)
                {
			        item.targetY = item.ID - curSelected + 4;
			        item.alpha = 0.6;
			        if (item.targetY == 4) item.alpha = 1;
                }
                else
                {
			        item.targetY = item.ID - curSelected;
			        item.alpha = 0.6;
			        if (item.targetY == 0) item.alpha = 1;
                }
            }
            else
            {
			    item.targetY = item.ID - curSelected;
			    item.alpha = 0.6;
			    if (item.targetY == 0) item.alpha = 1;
            }

            item.targetAlpha = item.alpha;

            // length - 4
		}

		for (num => item in itemsImageGrp.members)
		{
			item.targetY = item.ID - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
		}
    }

    var isAboutToBuy:Bool = false;
    var canAccept:Bool = false; // tiny delay
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(moneyBox != null && moneyBox.updatePositions) 
        {
            var targetPosX:Float = FlxMath.lerp(moneyBox.x, FlxG.width - moneyBox.width, elapsed * 17);
            moneyBox.x = targetPosX;

            var targetPosY:Float = FlxMath.lerp(moneyBox.y, 90, elapsed * 13);
            moneyBox.y = targetPosY;
        }

        if(!isAboutToBuy)
        {
            if(controls.UI_UP_P)
            {
                changeSelection(-1);
            }

            if(controls.UI_DOWN_P)
            {
                changeSelection(1);
            }

            if(canAccept)
            {
                if(controls.ACCEPT)
                {
                    if(boughtItems.get(itemsListGrp.members[curSelected].title)) {
                        FlxG.sound.play(Paths.sound('cancelMenu'));
                        return;
                    }

                    isAboutToBuy = true;
                    selectItemToBuy();
                }
            }
                
            if(controls.BACK)
            {
                close();
            }
        }
        else
        {
            if(controls.ACCEPT)
            {
                var item = itemsImageGrp.members[curSelected];
                if(itemsListGrp.members[curSelected].price > money) {
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                    return;
                }
                else {
                    buyItem();
                }

                isAboutToBuy = false;
                showBuyThingie();
                FlxG.sound.play(Paths.sound('vault/shop/zoomOut'));
                item.updatePositions = true;

                FlxTween.cancelTweensOf(item);
                FlxTween.cancelTweensOf(moneyBox);

                moneyBox.updatePositions = true;
                FlxTween.tween(item, {x: blackThingie.x + blackThingie.width + ((FlxG.width - (blackThingie.x + blackThingie.width)) / 2) - (item.width / 2), "scale.x": 1, "scale.y": 1}, 0.4, {ease: FlxEase.quartOut});
            }

            if(controls.BACK)
            {
                isAboutToBuy = false;
                showBuyThingie();

                FlxG.sound.play(Paths.sound('vault/shop/zoomOut'));
                var item = itemsImageGrp.members[curSelected];
                item.updatePositions = true;
                moneyBox.updatePositions = true;

                FlxTween.cancelTweensOf(item);
                FlxTween.cancelTweensOf(moneyBox);

                FlxTween.tween(item, {x: blackThingie.x + blackThingie.width + ((FlxG.width - (blackThingie.x + blackThingie.width)) / 2) - (item.width / 2), "scale.x": 1, "scale.y": 1}, 0.4, {ease: FlxEase.quartOut});
            }
        }

        #if debug
            if(FlxG.keys.justPressed.TAB)
            {
                var oldMoney = money;
                addMoney(100);
                FlxTween.num(oldMoney, money, 0.7, {ease: FlxEase.quartOut}, function(v:Float)
                {
                    moneyBox.money = Std.int(v);
                });
                moneyBox.updateWidth('$money');
            }
        #end
    }

    var moneyTween:FlxTween;
    function selectItemToBuy()
    {
        FlxG.sound.play(Paths.sound('vault/shop/zoomIn'));

        var item = itemsImageGrp.members[curSelected];

        // quick move
        var ogItemX:Float = item.x;
        var ogItemY:Float = item.y;

        item.screenCenter();
        item.scale.set(1.15, 1.15);

        var screenCenterItemX = item.x;
        var screenCenterItemY = item.y - 20;

        item.x = ogItemX;
        item.y = ogItemY;
        item.scale.set(1, 1);

        // now animate lmao
        // i know this code sucks, but well if you think that maybe
        // you could just contribute and improve it ;)

        item.updatePositions = false;

        if(itemsListGrp.members[curSelected].price > money)
        {
            pressEnterToConfirm.text = "You don't have enough money to purchase this item.";
            pressEnterToConfirm.color = 0xFFFFA69C;
        }
        else
        {
            pressEnterToConfirm.text = "Press ENTER to confirm your purchase.";
            pressEnterToConfirm.color = 0xFFFFFFFF;
        }
                
        FlxTween.cancelTweensOf(item);
        FlxTween.cancelTweensOf(moneyBox);

        moneyBox.updatePositions = false;
        FlxTween.tween(item, {x: screenCenterItemX, y: screenCenterItemY, "scale.x": 1.15, "scale.y": 1.15}, 0.6, {ease: FlxEase.quartOut});
        FlxTween.tween(moneyBox, {x: FlxG.width / 2 - moneyBox.width / 2, y: FlxG.height - moneyBox.height - 80}, 0.6, {ease: FlxEase.quartOut});
        hideBuyThingie();
    }

    function buyItem()
    {
        var oldMoney = FlxG.save.data.money;
        var curItem = itemsListGrp.members[curSelected];

        addMoney(-curItem.price);
        unlockItem(curItem.title);
        resortShopItems(curItem);

        switch(curItem.title)
        {
            case 'Picostola': 
                Achievements.unlock('unlock_pico');
                GameProgress.completeTask(5);
            case 'Tricky Sign': GameProgress.completeTask(6);
            case 'Tennis Racket': GameProgress.completeTask(7);
            case 'Mic Bulb': GameProgress.completeTask(8);
            case 'Singing Module': GameProgress.completeTask(9);
        }

        if(hasBoughtAllItems()) GameProgress.completeTask(10);

        FlxG.sound.play(Paths.sound('vault/shop/confirmPurchase'));
        if(moneyTween != null) moneyTween.cancel();
        moneyTween = FlxTween.num(oldMoney, money, 0.7, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween) {moneyTween = null;}}, function(v:Float)
        {
            moneyBox.money = Std.int(v);
        });
        moneyBox.updateWidth('$money');
    }

    function resortShopItems(curItem:ItemShop)
    {
        var oldItemID = curItem.ID;
        for(item in itemsListGrp)
        {
            if(item == curItem) 
            {
                //item.targetY = itemsListGrp.length - 1;
                curItem.ID = itemsListGrp.length - 1;
                trace('Bought Item with title ${curItem.title} changed ID! (${curItem.ID})');
                continue;
            }

            if(item.ID > oldItemID)
            {
                item.ID = item.ID - 1;
                trace('Item with title ${item.title} changed ID! (${item.ID})');
            }
        }

        for(item in itemsImageGrp)
        {
            if(item.parentItem == curItem) 
            {
                //item.targetY = itemsListGrp.length - 1;
                item.ID = itemsListGrp.length - 1;
                continue;
            }

            if(item.ID > oldItemID)
            {
                item.ID = item.ID - 1;
            }
        }

        function sortByID(_, a:Dynamic, b:Dynamic):Int
        {
		    return FlxSort.byValues(FlxSort.ASCENDING, a.ID, b.ID);
        }

        itemsListGrp.sort(sortByID);
        itemsImageGrp.sort(sortByID);
        curItem.bought = true;
        changeSelection();
    }

    function hideBuyThingie()
    {
        FlxTween.cancelTweensOf(pressEnterToConfirm);
        FlxTween.tween(pressEnterToConfirm, {alpha: 1}, {ease: FlxEase.quartOut});

        FlxTween.cancelTweensOf(blackThingie);
        FlxTween.cancelTweensOf(border);
        FlxTween.cancelTweensOf(pattern);

        FlxTween.tween(blackThingie, {alpha: 0}, 0.9, {ease: FlxEase.quartOut});
        FlxTween.tween(border, {alpha: 0}, 0.9, {ease: FlxEase.quartOut});
        FlxTween.tween(pattern, {alpha: 0}, 0.9, {ease: FlxEase.quartOut});
        itemsListGrp.forEach(function(item:ItemShop)
        {
            item.updatePositions = false;
            if(item != null) FlxTween.cancelTweensOf(item);
            FlxTween.tween(item, {alpha: 0}, 0.9, {ease: FlxEase.quartOut});
        });
    }

    function showBuyThingie()
    {
        FlxTween.cancelTweensOf(pressEnterToConfirm);
        FlxTween.tween(pressEnterToConfirm, {alpha: 0}, {ease: FlxEase.quartOut});

        FlxTween.cancelTweensOf(blackThingie);
        FlxTween.cancelTweensOf(border);
        FlxTween.cancelTweensOf(pattern);

        FlxTween.tween(blackThingie, {alpha: 0.5}, 0.9, {ease: FlxEase.quartOut});
        FlxTween.tween(border, {alpha: 1}, 0.9, {ease: FlxEase.quartOut});
        FlxTween.tween(pattern, {alpha: 0.85}, 0.9, {ease: FlxEase.quartOut});
        itemsListGrp.forEach(function(item:ItemShop)
        {
            item.updatePositions = true;
            if(item != null) FlxTween.cancelTweensOf(item);
            FlxTween.tween(item, {alpha: item.targetAlpha}, 0.9, {ease: FlxEase.quartOut});
        });
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
    public var targetAlpha:Float = 1;
    public var distancePerItem:FlxPoint = new FlxPoint(0, 0);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    public var updatePositions:Bool = true;
    public var bought:Bool = false;

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
    public var yoinIcon:FlxSprite;
    public var priceText:FlxText;
    public var startsGrp:FlxTypedGroup<FlxSprite>;

    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);

        bg = new FlxSprite();
        bg.makeGraphic(width, height, 0xFF0F001D);
        add(bg);

        titleText = new FlxText(0, 0, 0, '', 14);
        titleText.setFormat(Paths.font('GAU_pop_magic.ttf'), 16, 0xFFE0DEEA);
        titleText.antialiasing = ClientPrefs.data.antialiasing;
        add(titleText);

        titleText.x += 5;
        titleText.y += 5;

        yoinIcon = new FlxSprite();
        yoinIcon.loadGraphic(Paths.image('vault/shop/yoin'));
        yoinIcon.x += bg.width - yoinIcon.width - 5;
        yoinIcon.y += 5;
        yoinIcon.antialiasing = ClientPrefs.data.antialiasing;
        add(yoinIcon);

        priceText = new FlxText(0, 0, width, '', 14);
        priceText.setFormat(Paths.font('GAU_pop_magic.ttf'), 16, 0xFFE0DEEA, RIGHT);
        priceText.antialiasing = ClientPrefs.data.antialiasing;
        add(priceText);

        priceText.x += -yoinIcon.width - 5;
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

        if(bought) color = 0xFF666666;
        else color = 0xFFFFFFFF;
        
		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		if(updatePositions) y = FlxMath.lerp((targetY * distancePerItem.y) + startPosition.y, y, lerpVal);
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
    public var updatePositions:Bool = true;
    public var parentItem:ItemShop;

    public function new(x:Float = 0, y:Float = 0, image:Dynamic)
    {
        super(x, y);

        loadGraphic(image);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(parentItem.bought) color = 0xFF666666;
        else color = 0xFFFFFFFF;

		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		if(updatePositions) y = FlxMath.lerp((targetY * distancePerItem.y) + startPosition.y, y, lerpVal);
    }

    public function snapToPosition()
    {
        y = startPosition.y + (targetY * distancePerItem.y);
    }
}

class MoneyBox extends FlxSpriteGroup
{
    public var money(default, set):Int = 0;
    private function set_money(value:Int)
    {
        money = value;
        moneyText.text = '$money';
        return value;
    }
    var moneyBackground:FlxSprite;
    var moneyIcon:FlxSprite;
    var moneyText:FlxText;

    public var updatePositions:Bool = true;

    public function updateWidth(?supposedText:String)
    {
        moneyText.text = supposedText;
        moneyBackground.makeGraphic(Std.int(moneyIcon.width + 10 + moneyText.width + 10), 90, 0xFF000000);
        moneyIcon.animation.play('idle', true);
    }

    public function new(x:Float, y:Float)
    {
        super(x, y);

        moneyBackground = new FlxSprite(0, 0);
        moneyBackground.alpha = 0.6;
        moneyBackground.antialiasing = ClientPrefs.data.antialiasing;
        add(moneyBackground);

        moneyIcon = new FlxSprite();
        moneyIcon.frames = Paths.getSparrowAtlas('vault/shop/moneyIcon');
        moneyIcon.animation.addByPrefix('idle', 'money', 12, false);
        moneyIcon.animation.play('idle', true);
        //moneyIcon.scale.set(0.55, 0.55);
        moneyIcon.updateHitbox();
        moneyIcon.y += 5;
        moneyIcon.antialiasing = ClientPrefs.data.antialiasing;
        add(moneyIcon);

        moneyText = new FlxText(0, 0, 0, '${FlxG.save.data.money}', 14);
        moneyText.setFormat(Paths.font('GAU_pop_magic.ttf'), 40, 0xFFE0DEEA, LEFT);
        moneyText.y += 25;
        moneyText.antialiasing = ClientPrefs.data.antialiasing;
        add(moneyText);

        moneyBackground.makeGraphic(Std.int(moneyIcon.width + 10 + moneyText.width + 10), 90, 0xFF000000);
        moneyText.x += moneyBackground.width - moneyText.width - 5;
        moneyIcon.x += moneyBackground.width - moneyText.width - 5 - moneyIcon.width - 5;
    }
}