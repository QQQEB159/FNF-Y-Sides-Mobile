package states.vault;

import backend.GameProgress;
import backend.PsychCamera;
import objects.Bar;
import flixel.addons.display.FlxBackdrop;

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
    var border:FlxSprite;
    var pattern:FlxBackdrop;
    var currentPage:CollectPage = ITEMS;

    var upOptionsArray:Array<String> = ['items', 'awards', 'progress'];
    var upOptionsGrp:FlxTypedGroup<UpOption>;

    // collectionables thingie
    var collectItemsGrp:FlxTypedGroup<CollectItem>;
    var mousePointer:FlxSprite;

    // awards thingie
    var awardItemsGrp:FlxTypedGroup<AwardItem>;
    var collectionableCamera:FlxCamera;
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
        collectBackground.makeGraphic(750, 540, 0xFFB19BE7);
        collectBackground.antialiasing = ClientPrefs.data.antialiasing;
        collectBackground.screenCenter(X);
        collectBackground.y = FlxG.height;
        add(collectBackground);

        border = new FlxSprite(collectBackground.x - 33, collectBackground.y - 35);
        border.loadGraphic(Paths.image('vault/collectionables/border'));
        border.antialiasing = ClientPrefs.data.antialiasing;
        add(border);

        collectionableCamera = new FlxCamera(collectBackground.x, FlxG.height - collectBackground.height - 30, Std.int(collectBackground.width), Std.int(collectBackground.height));
        collectionableCamera.bgColor.alpha = 0;
        collectionableCamera.scroll.y = 130;
        add(collectionableCamera);

        awardCamera = new FlxCamera(collectBackground.x, FlxG.height - collectBackground.height - 30 + 90, Std.int(collectBackground.width), Std.int(collectBackground.height - 90));
        awardCamera.bgColor.alpha = 0;
        awardCamera.scroll.y = 200;
        add(awardCamera);

        splashCamera = new FlxCamera();
        splashCamera.bgColor.alpha = 0;

        FlxG.cameras.add(collectionableCamera, false);
        FlxG.cameras.add(awardCamera, false);
        FlxG.cameras.add(splashCamera, false);

        pattern = new FlxBackdrop(Paths.image('vault/collectionables/weird_checker'), XY);
        pattern.alpha = 0.65;
        pattern.cameras = [collectionableCamera];
        pattern.antialiasing = ClientPrefs.data.antialiasing;
        pattern.velocity.set(10, 10);
        add(pattern);

        upOptionsGrp = new FlxTypedGroup<UpOption>();
        add(upOptionsGrp);

        for(i in 0...upOptionsArray.length)
        {
            var opt = new UpOption(250 * i, collectBackground.y, upOptionsArray[i], collectionableCamera);
            opt.cameras = [collectionableCamera];
            upOptionsGrp.add(opt);
        }

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
            item.cameras = [collectionableCamera];
            item.x = 20 + ((item.width + 25) * (i % rowAmount));
            item.y = collectBackground.y + 60 + ((120 + 25) * rows);
            if(ShopSubState.isItemUnlocked(ShopSubState.itemsListArr[i][0])) item.y += 60 - item.height / 2;
            item.ID = i;
            item.row = rows;
            collectItemsGrp.add(item);
        }

        mousePointer = new FlxSprite();
        mousePointer.loadGraphic(Paths.image('vault/collectionables/mouse_thing'));
        mousePointer.cameras = [collectionableCamera];
        mousePointer.antialiasing = ClientPrefs.data.antialiasing;
        mousePointer.x = collectItemsGrp.members[0].x;
        mousePointer.y = collectItemsGrp.members[0].y;
        add(mousePointer);

        awardItemsGrp = new FlxTypedGroup<AwardItem>();
        add(awardItemsGrp);

        var awardNum:Int = 0;
        for(key => value in Achievements.achievements)
        {
            var item:AwardItem = new AwardItem(0, 0, key);
            //item.makeGraphic(120, 120, 0xFFFFFFFF);
            item.cameras = [awardCamera];
            item.antialiasing = ClientPrefs.data.antialiasing;
            //item.x = collectBackground.x + 40;
            //item.y = 60 + ((item.height + 25) * awardNum);
            item.x = 20;
            item.y = FlxG.height - collectBackground.height - 30 + 60 + ((item.height + 10) * awardNum);
            item.ID = awardNum;
            awardItemsGrp.add(item);

            awardNum++;
        }

        progressItemsGrp = new FlxTypedGroup<ProgressItem>();
        add(progressItemsGrp);

        for(i in 0...GameProgress.todoTasks.length)
        {
            var item:ProgressItem = new ProgressItem(0, 0, 0, GameProgress.todoTasks[i][0]);
            item.antialiasing = ClientPrefs.data.antialiasing;
            item.cameras = [collectionableCamera];
            item.x = 20;
            item.y = FlxG.height - collectBackground.height - 30 + 40 + ((item.height + 4) * i);
            item.completed = GameProgress.todoTasks[i][1];
            item.updateText();
            item.ID = i;
            progressItemsGrp.add(item);
        }

        setCurrentPage(currentPage);
        initTransition();
    }

    function initTransition()
    {
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.2}, 0.8, {ease: FlxEase.quartOut});

        collectBackground.y = FlxG.height;
        FlxTween.tween(collectBackground, {y: FlxG.height - collectBackground.height - 30}, 0.8, {ease: FlxEase.quartOut});

        border.y = FlxG.height - 35;
        FlxTween.tween(border, {y: FlxG.height - collectBackground.height - 30 - 35}, 0.8, {ease: FlxEase.quartOut});

        upOptionsGrp.forEach(function(opt:UpOption)
        {
            FlxTween.tween(opt, {y: FlxG.height - collectBackground.height - 30 - 20}, 0.8, {ease: FlxEase.quartOut});
        });

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
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height - 30 + 60 + ((120 + 10) * spr.row) + offset + 30}, 0.8, {ease: FlxEase.quartOut});
        });
    }

    function initAwardsTransition()
    {
        awardItemsGrp.forEach(function(spr:AwardItem)
        {
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height - 30 + 60 + ((spr.height + 10) * spr.ID)}, 0.8, {ease: FlxEase.quartOut});
        });
    }

    function initProgressTransition()
    {
        progressItemsGrp.forEach(function(spr:ProgressItem)
        {
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height - 30 + 40 + ((spr.height + 4) * spr.ID) + 50}, 0.8, {ease: FlxEase.quartOut});
        });
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        handleMouseBehaviour(elapsed);

        if(controls.BACK)
        {
            FlxTween.cancelTweensOf(collectBackground);
            FlxTween.cancelTweensOf(border);
            FlxTween.cancelTweensOf(VaultState.poloDown);

            upOptionsGrp.forEach(function(spr:UpOption)
            {
                spr.active = false;
            });

            collectItemsGrp.forEach(function(spr:CollectItem)
            {
                spr.active = false;
                FlxTween.cancelTweensOf(spr);
                FlxTween.tween(spr, {y: FlxG.height + ((spr.height + 10) * spr.row)}, 0.15, {ease: FlxEase.quartOut});
            });

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

            FlxG.cameras.remove(collectionableCamera);
            FlxG.cameras.remove(splashCamera);
            FlxTween.tween(border, {y: FlxG.height}, 0.15, {ease: FlxEase.quartOut});
            FlxTween.tween(collectBackground, {y: FlxG.height}, 0.15, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
            {
                close();
            }});
            FlxTween.tween(VaultState.poloDown, {y: FlxG.height - VaultState.poloDown.height}, 0.15, {ease: FlxEase.quintOut});
        }
    }

    var mouseScroll:Float = 200;
    function handleMouseBehaviour(elapsed:Float)
    {
        // awards thingie
        if(FlxG.mouse.wheel != 0)
        {
            if(currentPage != AWARDS) return;

            var wheelSpeed:Float = 60;
            mouseScroll -= FlxG.mouse.wheel * wheelSpeed;
            if(mouseScroll < 200) mouseScroll = 200;
            if(mouseScroll > 10 + (awardItemsGrp.members.length - 3) * 145 + 135) mouseScroll = 10 + (awardItemsGrp.members.length - 3) * 145 + 135;
        }

        if(currentPage == AWARDS)
        {
            if(awardCamera != null) awardCamera.scroll.y = FlxMath.lerp(awardCamera.scroll.y, mouseScroll, elapsed * 19);
        }


        // collectionables item select
        if(collectionableCamera != null)
        {
            for(item in collectItemsGrp)
            {
                if(!item.active) return;
                
                var hudMousePos = FlxG.mouse.getWorldPosition(collectionableCamera);
                if(item.overlapsPoint(hudMousePos))
                {
                    mousePointer.alpha = 1;
                    mousePointer.x = item.x - 3;
                    mousePointer.y = item.y - 4;
                    break;
                }
                else
                {
                    mousePointer.alpha = 0;
                }
            }
        }

        mousePointer.visible = currentPage == ITEMS;
        

        // changing shitty pages
        // items
        upOptionsGrp.forEach(function(opt:UpOption)
        {
            if(collectionableCamera == null) return;

            var hudMousePos = FlxG.mouse.getWorldPosition(collectionableCamera);
            if(opt.overlapsPoint(hudMousePos))
            {
                if(FlxG.mouse.justPressed)
                {
                    switch(opt.name)
                    {
                        case 'items':
                            currentPage = ITEMS;
                            setCurrentPage(currentPage);
                        case 'awards':
                            currentPage = AWARDS;
                            setCurrentPage(currentPage);
                        case 'progress':
                            currentPage = PROGRESS;
                            setCurrentPage(currentPage);
                    }
                }
            }
        });
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

        if(ShopSubState.isItemUnlocked(arrayData[0]) && FileSystem.exists('assets/shared/images/vault/collectionables/items/${arrayData[3]}.png'))
        {
            loadGraphic(Paths.image('vault/collectionables/items/${arrayData[3]}'));
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

class UpOption extends FlxSpriteGroup
{
    public var background:FlxSprite;
    public var spr:FlxSprite;

    public var parentCamera:FlxCamera;
    public var name:String = '';

    public function new(x:Float = 0, y:Float = 0, sprName:String, parentCamera:FlxCamera)
    {
        super(x, y);

        this.name = sprName;
        this.parentCamera = parentCamera;

        background = new FlxSprite();
        background.makeGraphic(250, 90, 0xFF130024);
        background.alpha = 0.45;
        add(background);

        spr = new FlxSprite();
        spr.loadGraphic(Paths.image('vault/collectionables/${sprName}Spr'));
        spr.antialiasing = ClientPrefs.data.antialiasing;
        spr.x += background.width / 2 - spr.width / 2;
        spr.y += background.height / 2 - spr.height / 2;
        add(spr);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(!this.active) return;

        if(parentCamera != null)
        {
            var hudMousePos = FlxG.mouse.getWorldPosition(parentCamera);
            if(this.overlapsPoint(hudMousePos))
            {
                background.color = 0xFF666666;
            }
            else
            {
                background.color = 0xFFFFFFFF;
            }
        }
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
        if(Achievements.isUnlocked(awardName)) awardLogo.loadGraphic(Paths.image('achievements/$awardName'));
        else awardLogo.loadGraphic(Paths.image('achievements/lockedachievement'));
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

class ProgressItem extends FlxSpriteGroup
{
    public var completed:Bool = false;
    public function updateText()
    {
        if(!completed) completedLine.x = FlxG.width;
    }

    public var progressText:FlxText;
    public var completedLine:FlxSprite;

    public function new(x:Float, y:Float, fieldWidth:Int, text:String)
    {
        super(x, y);

        progressText = new FlxText();
        progressText.text = text;
        progressText.setFormat(Paths.font('GAU_pop_magic.ttf'), 14, 0xFFFFFFFF, LEFT);
        add(progressText);

        completedLine = new FlxSprite();
        completedLine.makeGraphic(Std.int(progressText.width + 4), 2, 0xFFFFFFFF);
        completedLine.x += -2;
        completedLine.y += progressText.height / 2 - completedLine.height / 2;
        completedLine.visible = false;
        add(completedLine);
    }
}