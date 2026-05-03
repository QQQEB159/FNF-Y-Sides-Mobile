package states.vault;

import backend.GameProgress;
import backend.PsychCamera;
import objects.Bar;

enum CollectPage
{
    ITEMS;
    AWARDS;
    PROGRESS;
}

class CollectionablesSubState extends MusicBeatSubstate
{
    var bg:FlxSprite;
    var collectBackground:FlxSprite;
    var currentPage:CollectPage = ITEMS;

    var itemsPageText:FlxText;
    var awardsPageText:FlxText;
    var progressPageText:FlxText;

    // collectionables thingie
    var collectItemsGrp:FlxTypedGroup<CollectItem>;

    // awards thingie
    var awardItemsGrp:FlxTypedGroup<AwardItem>;
    var awardCamera:FlxCamera;
    var splashCamera:FlxCamera;

    // progress thingie
    var progressItemsGrp:FlxTypedGroup<ProgressItem>;

    override function create()
    {
        super.create();

        bg = new FlxSprite();
        bg.makeGraphic(1280, 720, 0xFF000000);
        add(bg);

        collectBackground = new FlxSprite();
        collectBackground.makeGraphic(750, 570, 0xFFDAB5FE);
        collectBackground.antialiasing = ClientPrefs.data.antialiasing;
        collectBackground.screenCenter(X);
        collectBackground.y = FlxG.height;
        add(collectBackground);

        awardCamera = new FlxCamera(collectBackground.x, FlxG.height - collectBackground.height + 15, Std.int(collectBackground.width), Std.int(collectBackground.height));
        awardCamera.bgColor.alpha = 0;
        awardCamera.scroll.y = 200;
        add(awardCamera);

        splashCamera = new FlxCamera();
        splashCamera.bgColor.alpha = 0;

        FlxG.cameras.add(awardCamera, false);
        FlxG.cameras.add(splashCamera, false);

        collectItemsGrp = new FlxTypedGroup<CollectItem>();
        add(collectItemsGrp);

        var rowAmount:Int = 5;
        var rows:Int = -1;
        for(i in 0...ShopSubState.itemsListArr.length)
        {
            if(i % rowAmount == 0) rows++;

            var item:CollectItem = new CollectItem(ShopSubState.itemsListArr[i]);
            //item.makeGraphic(120, 120, 0xFFFFFFFF);
            item.antialiasing = ClientPrefs.data.antialiasing;
            item.x = collectBackground.x + 20 + ((item.width + 25) * (i % rowAmount));
            item.y = collectBackground.y + 60 + ((120 + 25) * rows);
            if(ShopSubState.isItemUnlocked(ShopSubState.itemsListArr[i][0])) item.y += 60 - item.height / 2;
            item.ID = i;
            item.row = rows;
            collectItemsGrp.add(item);
        }

        awardItemsGrp = new FlxTypedGroup<AwardItem>();
        add(awardItemsGrp);

        var awardNum:Int = 0;
        for(key => value in Achievements.achievements)
        {
            var item:AwardItem = new AwardItem(0, 0, key);
            item.makeGraphic(120, 120, 0xFFFFFFFF);
            item.cameras = [awardCamera];
            item.antialiasing = ClientPrefs.data.antialiasing;
            //item.x = collectBackground.x + 40;
            //item.y = 60 + ((item.height + 25) * awardNum);
            item.x = 20;
            item.y = FlxG.height - collectBackground.height + 60 + ((item.height + 10) * awardNum);
            item.ID = awardNum;
            awardItemsGrp.add(item);

            awardNum++;
        }

        progressItemsGrp = new FlxTypedGroup<ProgressItem>();
        add(progressItemsGrp);

        for(i in 0...GameProgress.todoTasks.length)
        {
            var item:ProgressItem = new ProgressItem(0, 0, 0, GameProgress.todoTasks[i][0]);
            item.setFormat(Paths.font('GAU_pop_magic.ttf'), 14, 0xFFFFFFFF, LEFT);
            item.antialiasing = ClientPrefs.data.antialiasing;
            item.x = collectBackground.x + 20;
            item.y = FlxG.height - collectBackground.height + 40 + ((item.height + 4) * i);
            item.ID = i;
            progressItemsGrp.add(item);
        }

        itemsPageText = new FlxText(0, collectBackground.y, 250, 'Items');
        itemsPageText.setFormat(Paths.font('GAU_pop_magic.ttf'), 25, 0xFFE0DEEA, CENTER);
        itemsPageText.antialiasing = ClientPrefs.data.antialiasing;
        itemsPageText.x = collectBackground.x;
        add(itemsPageText);

        awardsPageText = new FlxText(0, collectBackground.y, 250, 'Awards');
        awardsPageText.setFormat(Paths.font('GAU_pop_magic.ttf'), 25, 0xFFE0DEEA, CENTER);
        awardsPageText.antialiasing = ClientPrefs.data.antialiasing;
        awardsPageText.x = collectBackground.x + 250;
        add(awardsPageText);

        progressPageText = new FlxText(0, collectBackground.y, 250, 'Progress');
        progressPageText.setFormat(Paths.font('GAU_pop_magic.ttf'), 25, 0xFFE0DEEA, CENTER);
        progressPageText.antialiasing = ClientPrefs.data.antialiasing;
        progressPageText.x = collectBackground.x + 500;
        add(progressPageText);

        setCurrentPage(currentPage);
        initTransition();
    }

    function initTransition()
    {
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.2}, 0.8, {ease: FlxEase.quartOut});

        collectBackground.y = FlxG.height;
        FlxTween.tween(collectBackground, {y: FlxG.height - collectBackground.height}, 0.8, {ease: FlxEase.quartOut});

        itemsPageText.y = FlxG.height;
        FlxTween.tween(itemsPageText, {y: FlxG.height - collectBackground.height - itemsPageText.height / 2}, 0.8, {ease: FlxEase.quartOut});

        awardsPageText.y = FlxG.height;
        FlxTween.tween(awardsPageText, {y: FlxG.height - collectBackground.height - awardsPageText.height / 2}, 0.8, {ease: FlxEase.quartOut});

        progressPageText.y = FlxG.height;
        FlxTween.tween(progressPageText, {y: FlxG.height - collectBackground.height - progressPageText.height / 2}, 0.8, {ease: FlxEase.quartOut});

        /*
        switch(currentPage)
        {
            case ITEMS: initCollectTransition();
            case AWARDS: initAwardsTransition();
            default: 
        }
        */

        initCollectTransition();
        initAwardsTransition();
        initProgressTransition();
    }

    function initCollectTransition()
    {
        collectItemsGrp.forEach(function(spr:CollectItem)
        {
            var offset:Float = 0;
            if(ShopSubState.isItemUnlocked(spr.arrayData[0])) offset = 60 - spr.height / 2;
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height + 60 + ((120 + 10) * spr.row) + offset}, 0.8, {ease: FlxEase.quartOut});
        });
    }

    function initAwardsTransition()
    {
        awardItemsGrp.forEach(function(spr:AwardItem)
        {
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height + 60 + ((spr.height + 10) * spr.ID)}, 0.8, {ease: FlxEase.quartOut});
        });
    }

    function initProgressTransition()
    {
        progressItemsGrp.forEach(function(spr:ProgressItem)
        {
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height + 40 + ((spr.height + 4) * spr.ID)}, 0.8, {ease: FlxEase.quartOut});
        });
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        handleMouseBehaviour();

        if(controls.BACK)
        {
            FlxTween.cancelTweensOf(collectBackground);
            FlxTween.cancelTweensOf(VaultState.poloDown);

            FlxTween.cancelTweensOf(itemsPageText);
            FlxTween.cancelTweensOf(awardsPageText);
            FlxTween.cancelTweensOf(progressPageText);

            collectItemsGrp.forEach(function(spr:CollectItem)
            {
                FlxTween.cancelTweensOf(spr);
                FlxTween.tween(spr, {y: FlxG.height + ((spr.height + 10) * spr.row)}, 0.15, {ease: FlxEase.quartOut});
            });

            FlxTween.tween(itemsPageText, {y: FlxG.height}, 0.15, {ease: FlxEase.quartOut});
            FlxTween.tween(awardsPageText, {y: FlxG.height}, 0.15, {ease: FlxEase.quartOut});
            FlxTween.tween(progressPageText, {y: FlxG.height}, 0.15, {ease: FlxEase.quartOut});

            awardItemsGrp.forEach(function(spr:AwardItem)
            {
                FlxTween.cancelTweensOf(spr);
                FlxTween.tween(spr, {y: FlxG.height + 60 + ((spr.height + 10) * spr.ID)}, 0.15, {ease: FlxEase.quartOut});
            });

            progressItemsGrp.forEach(function(spr:ProgressItem)
            {
                FlxTween.cancelTweensOf(spr);
                FlxTween.tween(spr, {y: FlxG.height + 60 + ((spr.height + 10) * spr.ID)}, 0.15, {ease: FlxEase.quartOut});
            });

            FlxG.sound.play(Paths.sound('vault/shop/zoomOut'));
            if(VaultState.blurShaderTween != null) VaultState.blurShaderTween.cancel();
            VaultState.blurShaderTween = FlxTween.num(5, 0, 1, {ease: FlxEase.quartOut, onComplete: (_) -> VaultState.blurShaderTween = null}, function(v:Float)
            {
                VaultState.blurShader.radius.value[0] = v;
            });

            FlxG.cameras.remove(awardCamera);
            FlxG.cameras.remove(splashCamera);
            FlxTween.tween(collectBackground, {y: FlxG.height}, 0.15, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
            {
                close();
            }});
            FlxTween.tween(VaultState.poloDown, {y: FlxG.height - VaultState.poloDown.height}, 0.15, {ease: FlxEase.quintOut});
        }
    }

    function handleMouseBehaviour()
    {
        //
        if(FlxG.mouse.wheel != 0)
        {
            if(currentPage != AWARDS) return;

            var wheelSpeed:Float = 20;
            awardCamera.followLerp = 0.8;
            awardCamera.scroll.y -= FlxG.mouse.wheel * wheelSpeed;
            if(awardCamera.scroll.y < 200) awardCamera.scroll.y = 200;
            if(awardCamera.scroll.y > 10 + (awardItemsGrp.members.length - 3) * 145 + 25) awardCamera.scroll.y = 10 + (awardItemsGrp.members.length - 3) * 145 + 25;
        }

        // changing shitty pages
        // items
        if(FlxG.mouse.overlaps(itemsPageText))
        {
            if(FlxG.mouse.justPressed)
            {
                currentPage = ITEMS;
                setCurrentPage(currentPage);
            }
        }

        if(FlxG.mouse.overlaps(awardsPageText))
        {
            if(FlxG.mouse.justPressed)
            {
                currentPage = AWARDS;
                setCurrentPage(currentPage);
            }
        }

        if(FlxG.mouse.overlaps(progressPageText))
        {
            if(FlxG.mouse.justPressed)
            {
                currentPage = PROGRESS;
                setCurrentPage(currentPage);
            }
        }

        // depending on the page
        switch(currentPage)
        {
            case AWARDS:
                var wheelSpeed:Int = 10;
            default:
        }
    }

    function setCurrentPage(page:CollectPage)
    {
        switch(page)
        {
            case ITEMS:
                collectItemsGrp.forEach(function(item:CollectItem)
                {
                    item.visible = true;
                });

                awardItemsGrp.forEach(function(item:AwardItem)
                {
                    item.visible = false;
                });

                progressItemsGrp.forEach(function(item:ProgressItem)
                {
                    item.visible = false;
                });
            case AWARDS:
                collectItemsGrp.forEach(function(item:CollectItem)
                {
                    item.visible = false;
                });

                awardItemsGrp.forEach(function(item:AwardItem)
                {
                    item.visible = true;
                });

                progressItemsGrp.forEach(function(item:ProgressItem)
                {
                    item.visible = false;
                });
            case PROGRESS:
                collectItemsGrp.forEach(function(item:CollectItem)
                {
                    item.visible = false;
                });

                awardItemsGrp.forEach(function(item:AwardItem)
                {
                    item.visible = false;
                });
                
                progressItemsGrp.forEach(function(item:ProgressItem)
                {
                    item.visible = true;
                });
        }
    }
}

class CollectItem extends FlxSprite
{
    public var row:Int = 0;
    public var arrayData:Array<Dynamic> = [];

    public function new(arrayData:Array<Dynamic>)
    {
        super();

        this.arrayData = arrayData;

        if(ShopSubState.isItemUnlocked(arrayData[0]) && FileSystem.exists('assets/shared/images/vault/shop/items/${arrayData[3]}.png'))
        {
            loadGraphic(Paths.image('vault/shop/items/${arrayData[3]}'));
            var newHeight = (120 * height) / width;
            setGraphicSize(120, newHeight);
            updateHitbox();
        }
        else
        {
            makeGraphic(120, 120);
        }

        antialiasing = ClientPrefs.data.antialiasing;
    }
}

class AwardItem extends FlxSpriteGroup
{
    public var background:FlxSprite;
    public var awardLogo:FlxSprite;
    public var awardNameText:FlxText;
    public var awardDescriptionText:FlxText;
    public var awardProgressBar:Bar;
    public var awardProgressText:FlxText;

    public function new(x:Float = 0, y:Float = 0, awardName:String)
    {
        super(x, y);

        var achievementData = Achievements.get(awardName);

        background = new FlxSprite();
        background.makeGraphic(710, 130, 0xFF000000);
        background.alpha = 0.56;
        background.antialiasing = ClientPrefs.data.antialiasing;
        add(background);

        awardLogo = new FlxSprite();
        awardLogo.loadGraphic(Paths.image('achievements/$awardName'));
        awardLogo.antialiasing = ClientPrefs.data.antialiasing;
        awardLogo.scale.set(0.85, 0.85);
        awardLogo.updateHitbox();
        add(awardLogo);

        awardNameText = new FlxText(0, 0, background.width - awardLogo.width - 20, achievementData.name);
        awardNameText.setFormat(Paths.font('GAU_pop_magic.ttf'), 20, 0xFFE0DEEA, LEFT);
        awardNameText.antialiasing = ClientPrefs.data.antialiasing;
        awardNameText.x += awardLogo.width + 10;
        add(awardNameText);

        awardDescriptionText = new FlxText(0, 0, background.width - awardLogo.width - 20, achievementData.description);
        awardDescriptionText.setFormat(Paths.font('GAU_pop_magic.ttf'), 16, 0xFFE0DEEA, LEFT);
        awardDescriptionText.antialiasing = ClientPrefs.data.antialiasing;
        awardDescriptionText.x += awardLogo.width + 10;
        awardDescriptionText.y += awardNameText.height + 5;
        add(awardDescriptionText);

		awardProgressBar = new Bar(0, 0, 'vault/collectionables/award_bar');
        awardProgressBar.visible = false;
		awardProgressBar.barOffset = new FlxPoint(0, 0);
		awardProgressBar.setColors(0xFF000000, 0xFFFFFFFF);

        awardProgressBar.percent = Achievements.getScore(awardName) / achievementData.maxScore;
        awardProgressBar.updateBar();

        awardProgressBar.x += awardLogo.width + 10;
        awardProgressBar.y += awardNameText.height + 5 + awardDescriptionText.height + 5;
        
		awardProgressBar.leftToRight = true;
        add(awardProgressBar);

        awardProgressText = new FlxText(0, 0, background.width - awardLogo.width - 20, '${Achievements.getScore(awardName)}/${achievementData.maxScore}');
        awardProgressText.visible = false;
        awardProgressText.setFormat(Paths.font('GAU_pop_magic.ttf'), 10, 0xFFE0DEEA, LEFT);
        awardProgressText.antialiasing = ClientPrefs.data.antialiasing;
        awardProgressText.x += awardLogo.width + 10;
        awardProgressText.y += awardNameText.height + 5 + awardDescriptionText.height + 5 + awardProgressBar.height + 5;
        add(awardProgressText);

        if(achievementData.maxScore != null && achievementData.maxScore > 0) 
        {
            trace('is really ${achievementData.maxScore} > 0 ?????');
            awardProgressBar.visible = true;
            awardProgressText.visible = true;
        }
        else
        {
            trace('WHY ARENT YOU VISIBLE FALSE???');
            awardProgressBar.visible = false;
            awardProgressText.visible = false;

            // this is ridiculous...
            awardProgressBar.x += 600;
            awardProgressText.x += 600;
        }
    }
}

class ProgressItem extends FlxText
{
    public function new(x:Float, y:Float, fieldWidth:Int, text:String)
    {
        super(x, y, fieldWidth, text);
    }
}