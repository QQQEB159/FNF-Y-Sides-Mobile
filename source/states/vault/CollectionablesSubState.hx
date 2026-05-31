package states.vault;

import backend.GameProgress;
import backend.PsychCamera;
import objects.Bar;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxSort;

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
	var platiniumAchievement:FlxSprite;
	var gotPlatinium:Bool = false;
	var confetti:FlxSprite;
    public static var collectionableCamera:FlxCamera;
    public static var awardCamera:FlxCamera;
    public static var progressCamera:FlxCamera;
    public static var splashCamera:FlxCamera;

    // progress thingie
    var progressItemsGrp:FlxTypedGroup<ProgressItem>;

    override function create()
    {
        super.create();

        bg = new FlxSprite();
        bg.makeGraphic(1280, 720, 0xFF000000);
        add(bg);

        collectBackground = new FlxSprite();
        collectBackground.makeGraphic(750, 541, 0xFFB19BE7);
        collectBackground.antialiasing = ClientPrefs.data.antialiasing;
        collectBackground.screenCenter(X);
        collectBackground.y = FlxG.height;
        collectBackground.alpha = 0.75;
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
        awardCamera.scroll.y = mouseScrollAwards;
        add(awardCamera);

        progressCamera = new FlxCamera(collectBackground.x, FlxG.height - collectBackground.height - 30 + 90, Std.int(collectBackground.width), Std.int(collectBackground.height - 90));
        progressCamera.bgColor.alpha = 0;
        progressCamera.scroll.y = mouseScrollProgress;
        add(progressCamera);

        splashCamera = new FlxCamera();
        splashCamera.bgColor.alpha = 0;

        FlxG.cameras.add(collectionableCamera, false);
        FlxG.cameras.add(awardCamera, false);
        FlxG.cameras.add(progressCamera, false);
        FlxG.cameras.add(splashCamera, false);

        pattern = new FlxBackdrop(Paths.image('vault/collectionables/weird_checker'), XY);
        pattern.alpha = 0;
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

        var group:Array<Dynamic> = [];
        for(key => value in Achievements.achievements)
        {
			var unlocked:Bool = Achievements.isUnlocked(key);
			if(value.hidden != true || unlocked)
				group.push(makeAchievement(key, value, unlocked, value.mod));
        }

		group.sort(sortByID);

        var awardNum:Int = 0;
        for(award in group)
        {
            var item:AwardItem = new AwardItem(0, 0, award.name);
            //item.makeGraphic(120, 120, 0xFFFFFFFF);
            item.cameras = [awardCamera];
            item.antialiasing = ClientPrefs.data.antialiasing;
            //item.x = collectBackground.x + 40;
            //item.y = 60 + ((item.height + 25) * awardNum);
            item.x = 5;
            item.y = FlxG.height - collectBackground.height - 30 + 60 + ((item.height + 10) * awardNum);
            item.ID = awardNum;
            awardItemsGrp.add(item);

            awardNum++;
        }

		platiniumAchievement = new FlxSprite();
		platiniumAchievement.loadGraphic(Paths.image('achievements/platiniumTrophie'));
		platiniumAchievement.scrollFactor.set(0, 0);
		platiniumAchievement.scale.set(0.35, 0.35);
		platiniumAchievement.updateHitbox();
		platiniumAchievement.antialiasing = ClientPrefs.data.antialiasing;
		platiniumAchievement.x = FlxG.width - platiniumAchievement.width - 20;
		platiniumAchievement.y = FlxG.height - platiniumAchievement.height - 20;
		add(platiniumAchievement);

		confetti = new FlxSprite();
		confetti.frames = Paths.getSparrowAtlas('achievements/confeti');
		confetti.animation.addByPrefix('play', 'confeti idle', 24, false);
		confetti.animation.play('play');
		confetti.scrollFactor.set(0, 0);
		confetti.alpha = 0.001;
		confetti.x = platiniumAchievement.x + platiniumAchievement.width / 2 - confetti.width / 2;
		confetti.y = platiniumAchievement.y + platiniumAchievement.height / 2 - confetti.height / 2;
		confetti.antialiasing = ClientPrefs.data.antialiasing;
		//confetti.x = platiniumAchievement.x;
		//confetti.y = platiniumAchievement.y;
		//confetti.screenCenter();
		add(confetti);

		gotPlatinium = Achievements.checkPlatiniumAchievement();
		if(!gotPlatinium) platiniumAchievement.color = 0xFF000000;

        progressItemsGrp = new FlxTypedGroup<ProgressItem>();
        add(progressItemsGrp);

        for(i in 0...GameProgress.todoTasks.length)
        {
            var item:ProgressItem = new ProgressItem(0, 0, 0, GameProgress.todoTasks[i][0]);
            item.antialiasing = ClientPrefs.data.antialiasing;
            item.cameras = [progressCamera];
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

	public static function sortByID(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.ID, Obj2.ID);

	function makeAchievement(achievement:String, data:Achievement, unlocked:Bool, mod:String = null)
	{
		return {
			name: achievement,
			displayName: unlocked ? Language.getPhrase('achievement_$achievement', data.name) : '???',
			description: Language.getPhrase('description_$achievement', data.description),
			curProgress: data.maxScore > 0 ? Achievements.getScore(achievement) : 0,
			maxProgress: data.maxScore > 0 ? data.maxScore : 0,
			decProgress: data.maxScore > 0 ? data.maxDecimals : 0,
			unlocked: unlocked,
			ID: data.ID,
			mod: mod
		};
	}

    function initTransition()
    {
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 0.2}, 0.8, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
        {
            FlxTween.tween(pattern, {alpha: 0.65}, 0.8, {ease: FlxEase.quartOut});
        }});

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
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height - 30 + 60 + ((spr.height - 20) * spr.ID)}, 0.8, {ease: FlxEase.quartOut});
        });
    }

    function initProgressTransition()
    {
        progressItemsGrp.forEach(function(spr:ProgressItem)
        {
            FlxTween.tween(spr, {y: FlxG.height - collectBackground.height - 30 + 40 + ((spr.height + 4) * spr.ID) + 50}, 0.8, {ease: FlxEase.quartOut});
        });
    }

	var platiniumScale:Float = 0.35;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        handleMouseBehaviour(elapsed);

        if(gotPlatinium)
        {
            var mult = FlxMath.lerp(platiniumAchievement.scale.x, platiniumScale, elapsed * 13);
            platiniumAchievement.scale.set(mult, mult);

            if(FlxG.mouse.overlaps(platiniumAchievement))
            {
                platiniumScale = 0.4;
                if(FlxG.mouse.justPressed)
                {
                    confetti.alpha = 1;
                    confetti.animation.play('play', true);
                    FlxG.sound.play(Paths.sound('confetti'));
                    FlxG.camera.shake(0.001, 0.5);
                }
            }
            else platiniumScale = 0.35;
        }

        if(controls.BACK)
        {
            FlxTween.cancelTweensOf(collectBackground);
            FlxTween.cancelTweensOf(border);
            FlxTween.cancelTweensOf(VaultState.poloDown);
            FlxTween.cancelTweensOf(platiniumAchievement);
            FlxTween.cancelTweensOf(pattern);
            pattern.alpha = 0;

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
            FlxTween.tween(platiniumAchievement, {y: FlxG.height}, 0.15, {ease: FlxEase.quartOut});
        }
    }

    var mouseScrollAwards:Float = 190;
    var mouseScrollProgress:Float = 230;
    var mousePointerX:Float = 0;
    var mousePointerY:Float = 0;
    function handleMouseBehaviour(elapsed:Float)
    {
        // awards thingie
        if(FlxG.mouse.wheel != 0)
        {
            // note: i really hope there's another way to do this shitty effect instead that with tons of camera, my eyes are about to fall and my brain's going to rot -madera
            switch(currentPage)
            {
                case AWARDS:
                    var wheelSpeed:Float = 60;
                    mouseScrollAwards -= FlxG.mouse.wheel * wheelSpeed;
                    if(mouseScrollAwards < 190) mouseScrollAwards = 190;
                    if(mouseScrollAwards > 10 + (awardItemsGrp.members.length - 3) * 145 + 135) mouseScrollAwards = 10 + (awardItemsGrp.members.length - 3) * 145 + 135;
                case PROGRESS:
                    if(progressItemsGrp.members.length < 11) return;

                    var wheelSpeed:Float = 60;
                    mouseScrollProgress -= FlxG.mouse.wheel * wheelSpeed;
                    if(mouseScrollProgress < 230) mouseScrollProgress = 230;
                    if(mouseScrollProgress > 10 + (progressItemsGrp.members.length - 5) * 25 + 75) mouseScrollProgress = 10 + (progressItemsGrp.members.length - 5) * 25 + 75;
                default:
            }
        }

        switch(currentPage)
        {
            case AWARDS: if(awardCamera != null) awardCamera.scroll.y = FlxMath.lerp(awardCamera.scroll.y, mouseScrollAwards, elapsed * 19);
            case PROGRESS: if(progressCamera != null) progressCamera.scroll.y = FlxMath.lerp(progressCamera.scroll.y, mouseScrollProgress, elapsed * 19);
            default:
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
                    mousePointerX = item.x - 3;
                    mousePointerY = item.y - 4;
                    // mousePointer.x = item.x - 3;
                    // mousePointer.y = item.y - 4;
                    break;
                }
                else
                {
                    mousePointer.alpha = 0;
                }
            }
        }

        mousePointer.x = FlxMath.lerp(mousePointer.x, mousePointerX, elapsed * 16);
        mousePointer.y = FlxMath.lerp(mousePointer.y, mousePointerY, elapsed * 16);
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
                    item.canPlaySound = true;
                });

                awardItemsGrp.forEach(function(item:AwardItem)
                {
                    item.visible = false;
                });
                platiniumAchievement.visible = false;

                progressItemsGrp.forEach(function(item:ProgressItem)
                {
                    item.visible = false;
                });
            case AWARDS:
                collectItemsGrp.forEach(function(item:CollectItem)
                {
                    item.visible = false;
                    item.canPlaySound = false;
                });

                awardItemsGrp.forEach(function(item:AwardItem)
                {
                    item.visible = true;
                });
                platiniumAchievement.visible = true;

                progressItemsGrp.forEach(function(item:ProgressItem)
                {
                    item.visible = false;
                });
            case PROGRESS:
                collectItemsGrp.forEach(function(item:CollectItem)
                {
                    item.visible = false;
                    item.canPlaySound = false;
                });

                awardItemsGrp.forEach(function(item:AwardItem)
                {
                    item.visible = false;
                });
                platiniumAchievement.visible = false;
                
                progressItemsGrp.forEach(function(item:ProgressItem)
                {
                    item.visible = true;
                });
        }
    }
}

class CollectItem extends FlxSpriteGroup
{
    public var row:Int = 0;
    public var arrayData:Array<Dynamic> = [];

    public var background:FlxSprite;
    public var itemSpr:FlxSprite;

    public function new(arrayData:Array<Dynamic>)
    {
        super();

        this.arrayData = arrayData;

        background = new FlxSprite();
        background.makeGraphic(120, 120, 0xFF0F001D);
        background.alpha = 0.5;
        add(background);

        itemSpr = new FlxSprite();
        if(ShopSubState.isItemUnlocked(arrayData[0]) && FileSystem.exists('assets/shared/images/vault/collectionables/items/${arrayData[3]}.png'))
        {
            itemSpr.loadGraphic(Paths.image('vault/collectionables/items/${arrayData[3]}'));
            var newHeight = (120 * itemSpr.height) / itemSpr.width;
            itemSpr.setGraphicSize(120, newHeight);
            itemSpr.updateHitbox();
        }
        else
        {
            itemSpr.makeGraphic(120, 120);
        }
        add(itemSpr);

        antialiasing = ClientPrefs.data.antialiasing;
    }

    public var hasPlayedSound:Bool = false;
    public var canPlaySound:Bool = true;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(!this.active) return;

        var hudMousePos = FlxG.mouse.getWorldPosition(CollectionablesSubState.collectionableCamera);
        if(itemSpr.overlapsPoint(hudMousePos))
        {
            if(!canPlaySound) return;

            if(!hasPlayedSound) FlxG.sound.play(Paths.sound('scrollMenu'));
            hasPlayedSound = true;
        }
        else hasPlayedSound = false;
    }
}

class UpOption extends FlxSpriteGroup
{
    public var background:FlxSprite;
    public var blackBackground:FlxSprite;
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

        blackBackground = new FlxSprite();
        blackBackground.makeGraphic(250, 90, 0xFF130024);
        blackBackground.alpha = 0.65;
        add(blackBackground);

        spr = new FlxSprite();
        spr.loadGraphic(Paths.image('vault/collectionables/${sprName}Spr'));
        spr.antialiasing = ClientPrefs.data.antialiasing;
        spr.x += background.width / 2 - spr.width / 2;
        spr.y += background.height / 2 - spr.height / 2;
        add(spr);
    }

    var targetScale:Float = 1;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(!this.active) return;

        var mult = FlxMath.lerp(spr.scale.x, targetScale, elapsed * 18);
        spr.scale.set(mult, mult);

        if(parentCamera != null)
        {
            var hudMousePos = FlxG.mouse.getWorldPosition(parentCamera);
            if(this.overlapsPoint(hudMousePos))
            {
                blackBackground.visible = true;
                targetScale = 1.05;
                spr.color = 0xFFEADEFF;
            }
            else
            {
                blackBackground.visible = false;
                targetScale = 1;
                spr.color = 0xFFFFFFFF;
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

    // TODO: update this whenever a progress is made (e.g. the click thingie)
    // ! i wont do it so free pr :D
    public function new(x:Float = 0, y:Float = 0, awardName:String)
    {
        super(x, y);

        var achievementData = Achievements.get(awardName);

        background = new FlxSprite();
        //background.makeGraphic(710, 130, 0xFF000000);
        background.loadGraphic(Paths.image('vault/collectionables/awardBackground'));
        background.alpha = 1;
        background.antialiasing = ClientPrefs.data.antialiasing;
        add(background);

        awardLogo = new FlxSprite();
        if(Achievements.isUnlocked(awardName)) awardLogo.loadGraphic(Paths.image('achievements/$awardName'));
        else awardLogo.loadGraphic(Paths.image('achievements/lockedachievement'));
        awardLogo.antialiasing = ClientPrefs.data.antialiasing;
        awardLogo.scale.set(0.85, 0.85);
        awardLogo.updateHitbox();
        awardLogo.x += 30;
        awardLogo.y += 10;
        add(awardLogo);

        awardNameText = new FlxText(0, 0, background.width - awardLogo.width - 20 - 30 - 10, Achievements.isUnlocked(awardName) ? achievementData.name : '???');
        awardNameText.setFormat(Paths.font('GAU_pop_magic.ttf'), 20, 0xFFE0DEEA, LEFT);
        awardNameText.antialiasing = ClientPrefs.data.antialiasing;
        awardNameText.x += 30 + awardLogo.width + 10;
        awardNameText.y += 10;
        add(awardNameText);

        awardDescriptionText = new FlxText(0, 0, background.width - awardLogo.width - 20 - 30 - 10, achievementData.description);
        awardDescriptionText.setFormat(Paths.font('GAU_pop_magic.ttf'), 16, 0xFFE0DEEA, LEFT);
        awardDescriptionText.antialiasing = ClientPrefs.data.antialiasing;
        awardDescriptionText.x += 30 + awardLogo.width + 10;
        awardDescriptionText.y += 10 + awardNameText.height + 5;
        add(awardDescriptionText);

        awardProgressText = new FlxText(0, 0, background.width - awardLogo.width - 20, '${Achievements.getScore(awardName)}/${achievementData.maxScore}');
        awardProgressText.visible = false;
        awardProgressText.setFormat(Paths.font('GAU_pop_magic.ttf'), 10, 0xFFE0DEEA, LEFT);
        awardProgressText.antialiasing = ClientPrefs.data.antialiasing;
        awardProgressText.x += 30 + awardLogo.width + 10;

		awardProgressBar = new Bar(0, 0, 'vault/collectionables/award_bar', function():Float {
            final score:Float = Achievements.getScore(awardName);
            awardProgressText.text = '${score}/${achievementData.maxScore}';
            final value:Float = score / achievementData.maxScore;
            return value;
        });
        awardProgressBar.visible = false;
		awardProgressBar.barOffset = new FlxPoint(0, 0);
		awardProgressBar.setColors(0xFFFFFFFF, 0xFF000000);

        awardProgressBar.percent = Achievements.getScore(awardName) / achievementData.maxScore;
        awardProgressBar.updateBar();

        awardProgressBar.x += 30 + awardLogo.width + 10;
        awardProgressBar.y += 10 + awardNameText.height + 5 + awardDescriptionText.height + 5;
        
		awardProgressBar.leftToRight = true;
        add(awardProgressBar);

        awardProgressText.y += 10 + awardNameText.height + 5 + awardDescriptionText.height + 5 + awardProgressBar.height + 5;
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
            awardProgressBar.x += 1280;
            awardProgressText.x += 1280;
        }
    }
}

class ProgressItem extends FlxSpriteGroup
{
    public var completed:Bool = false;
    public function updateText()
    {
        if(!completed) 
        {
            completedLine.x = FlxG.width;
            checkSprite.x = FlxG.width;
        }
    }

    public var progressText:FlxText;
    public var completedLine:FlxSprite;
    public var checkSprite:FlxSprite;

    public function new(x:Float, y:Float, fieldWidth:Int, text:String)
    {
        super(x, y);

        progressText = new FlxText();
        progressText.text = text;
        progressText.setFormat(Paths.font('AudioNugget.ttf'), 30, 0xFF0F001D, LEFT);
        add(progressText);

        completedLine = new FlxSprite();
        completedLine.makeGraphic(Std.int(progressText.width + 4), 2, 0xFFFFFFFF);
        completedLine.x += -2;
        completedLine.y += progressText.height / 2 - completedLine.height / 2;
        completedLine.visible = false;
        add(completedLine);

        checkSprite = new FlxSprite();
        checkSprite.loadGraphic(Paths.image('vault/collectionables/check'));
        checkSprite.antialiasing = ClientPrefs.data.antialiasing;
        checkSprite.x += progressText.width + 10;
        checkSprite.setGraphicSize(30, 30);
        checkSprite.updateHitbox();
        add(checkSprite);
    }
}