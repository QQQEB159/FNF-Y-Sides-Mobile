package states;

import flixel.addons.display.FlxBackdrop;

enum Column
{
    LEFT;
    RIGHT;
}

class NewMainMenuState extends MusicBeatState 
{
	var bg:FlxSprite;
	var backgroundGradientBottom:FlxSprite;
	var icons:FlxBackdrop;
    var lines:FlxBackdrop;
    var linesSpeed:Float = 20;
    var circle:FlxSprite;
    var circle2:FlxSprite;
    var character:FlxSprite;
    var characterY:Float = 0;
    var leftBar:FlxSprite;
    var leftBarThorns:FlxBackdrop; // THORNS?!
    var rightBarThorns:FlxBackdrop; // THORNS 2?!
    var thornsSpeed:Float = 15;
    var rightBar:FlxSprite;

    var menuItemsLeftArr:Array<String> = [
        'story',
        'freeplay',
        'credits'
    ];
    var menuItemsLeftGrp:FlxTypedGroup<FlxSprite>;
    
    var menuItemsRightArr:Array<String> = [
        'options',
        'awards',
        'gallery'
    ];
    var menuItemsRightGrp:FlxTypedGroup<FlxSprite>;
    var curSelected:Int = 0;
    var curColumn:Column = LEFT;

    override function create()
    {
        super.create();

        FlxG.mouse.visible = true;

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		backgroundGradientBottom = new FlxSprite();
		backgroundGradientBottom.loadGraphic(Paths.image('titleState/gradientBottom'));
		backgroundGradientBottom.antialiasing = ClientPrefs.data.antialiasing;
		backgroundGradientBottom.scale.set(1, 1.3);
		backgroundGradientBottom.blend = ADD;
		backgroundGradientBottom.alpha = 0.38;
		backgroundGradientBottom.y = FlxG.height - backgroundGradientBottom.height;
		add(backgroundGradientBottom);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(10, 10);
		icons.alpha = 0.3;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);
		
		icons.setPosition(MainMenuState.iconsPos[0], MainMenuState.iconsPos[1]);

        lines = new FlxBackdrop(Paths.image('mainmenu/new/lines'), X);
        lines.antialiasing = ClientPrefs.data.antialiasing;
        lines.y = 10;
        lines.velocity.set(linesSpeed, 0);
        add(lines);

        circle = new FlxSprite();
        circle.loadGraphic(Paths.image('mainmenu/new/circle'));
        circle.antialiasing = ClientPrefs.data.antialiasing;
        add(circle);

        circle2 = new FlxSprite();
        circle2.loadGraphic(Paths.image('mainmenu/new/circle'));
        circle2.antialiasing = ClientPrefs.data.antialiasing;
        add(circle2);

        character = new FlxSprite();
        character.frames = Paths.getSparrowAtlas('mainmenu/new/menu_characters');
        var totalOpts = menuItemsLeftArr.concat(menuItemsRightArr);
        for(i in 0...totalOpts.length)
        {
            character.animation.addByPrefix(totalOpts[i], '${totalOpts[i]}_characters', 24, true);
        }
        character.animation.play('story');
        character.updateHitbox();
        character.screenCenter();
        character.antialiasing = ClientPrefs.data.antialiasing;
        add(character);

        characterY = character.y;

        leftBarThorns = new FlxBackdrop(Paths.image('resultsScreen/lettabox'), Y);
        leftBarThorns.velocity.set(0, thornsSpeed);
        leftBarThorns.antialiasing = ClientPrefs.data.antialiasing;
        add(leftBarThorns);

        leftBar = new FlxSprite();
        leftBar.makeGraphic(370, Std.int(FlxG.height * 1.2), 0xFF130024);
        leftBar.x = -20;
        leftBar.y = -20;
        add(leftBar);

        leftBarThorns.x = leftBar.x + leftBar.width - 1;
        circle.x = leftBar.x + leftBar.width - (circle.width / 2);
        circle.y = leftBar.y + -100;

        rightBarThorns = new FlxBackdrop(Paths.image('resultsScreen/lettabox'), Y);
        rightBarThorns.velocity.set(0, -thornsSpeed);
        rightBarThorns.antialiasing = ClientPrefs.data.antialiasing;
        rightBarThorns.flipX = true;
        add(rightBarThorns);

        rightBar = new FlxSprite();
        rightBar.makeGraphic(370, Std.int(FlxG.height * 1.2), 0xFF130024);
        rightBar.x = FlxG.width - rightBar.width + (rightBar.width - 350);
        rightBar.y = -20;
        add(rightBar);

        rightBarThorns.x = rightBar.x - rightBarThorns.width + 1;
        circle2.scale.set(1.15, 1.15);
        circle2.updateHitbox();
        circle2.x = rightBar.x - (circle2.width / 1.8);
        circle2.y = FlxG.height - circle2.height + 210;

        menuItemsLeftGrp = new FlxTypedGroup<FlxSprite>();
        add(menuItemsLeftGrp);

        menuItemsRightGrp = new FlxTypedGroup<FlxSprite>();
        add(menuItemsRightGrp);

        for(i in 0...menuItemsLeftArr.length)
        {
            var item = new FlxSprite(0, 80 + (i * 220));
            item.frames = Paths.getSparrowAtlas('mainmenu/new/${menuItemsLeftArr[i]}');
            item.animation.addByPrefix('idle', menuItemsLeftArr[i], 24, true);
            item.animation.play('idle');
            item.x = leftBar.x + (leftBar.width / 2) - (item.width / 2);
            item.ID = i;
            item.antialiasing = ClientPrefs.data.antialiasing;
            menuItemsLeftGrp.add(item);
        }

        for(i in 0...menuItemsRightArr.length)
        {
            var item = new FlxSprite(0, 80 + (i * 200));
            item.frames = Paths.getSparrowAtlas('mainmenu/new/${menuItemsRightArr[i]}');
            item.animation.addByPrefix('idle', menuItemsRightArr[i], 24, true);
            item.animation.play('idle');
            item.x = rightBar.x + (rightBar.width / 2) - (item.width / 2) - 30;
            item.ID = i;
            
            if(i == 1) item.x += 70; // lil offset :)

            item.antialiasing = ClientPrefs.data.antialiasing;
            menuItemsRightGrp.add(item);
        }

        changeSelection(0, true);
    }

    var circleAngleSpeed:Float = 10;
    var circle2AngleSpeed:Float = -8;
	var scrollMultiplier:Float = 3;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // spin anim
        circle.angle += circleAngleSpeed * elapsed;
        circle2.angle += circle2AngleSpeed * elapsed;

		final hudMousePos = FlxG.mouse.getScreenPosition(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

		var multX = (hudMousePos.x - (FlxG.width / 2)) / (FlxG.width / 2);
		var multY = (hudMousePos.y - (FlxG.height / 2)) / (FlxG.height / 2);

		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (multX * scrollMultiplier), elapsed * 10);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (multY * scrollMultiplier), elapsed * 10);

		if (controls.BACK)
		{
			selectedSomethin = true;
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			transitionBack();
		}

        if(!selectedSomethin)
        {
            if(controls.UI_UP_P)
            {
                changeSelection(-1);
            }

            if(controls.UI_DOWN_P)
            {
                changeSelection(1);
            }

            if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
            {
                changeColumn();
            }

            if(controls.ACCEPT)
            {
				FlxG.sound.play(Paths.sound('confirmMenu'));
                selectedSomethin = true;
				FlxG.mouse.visible = false;

                var option = curColumn == LEFT ? menuItemsLeftArr[curSelected] : menuItemsRightArr[curSelected];
                var item = curColumn == LEFT ? menuItemsLeftGrp.members[curSelected] : menuItemsRightGrp.members[curSelected];
                switch(option)
                {
                    case 'freeplay' | 'credits' | 'options' | 'awards' | 'gallery': // default transitions
                        trace('Transitioning to $option');
                        var state = getTargetState(option);

                        new FlxTimer().start(1, function(tmr:FlxTimer)
                        {
						    FlxTransitionableState.skipNextTransIn = true;
						    FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(state);
                        });
                    default:
						trace('Menu Item ${option} doesn\'t do anything');
						selectedSomethin = false;
						item.visible = true;
                        return;
                }

                for(obj in menuItemsLeftGrp)
                {
                    if(obj == item) continue;

                    FlxTween.tween(obj, {alpha: 0, y: obj.y + 10}, 0.2);
                }

                for(obj in menuItemsRightGrp)
                {
                    if(obj == item) continue;

                    FlxTween.tween(obj, {alpha: 0, y: obj.y + 10}, 0.2);
                }
            }
        }
    }

    function changeSelection(change:Int = 0, firstTime:Bool = false)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + change, 0, curColumn == LEFT ? menuItemsLeftArr.length - 1 : menuItemsRightArr.length - 1);

        character.animation.play(curColumn == LEFT ? menuItemsLeftArr[curSelected] : menuItemsRightArr[curSelected]);
        character.updateHitbox();
        character.screenCenter();
        character.y = characterY + 10;
        character.alpha = 0;

        FlxTween.cancelTweensOf(character);
        FlxTween.tween(character, {alpha: 1, y: characterY}, 0.25, {ease: FlxEase.quartOut});

        switch(curColumn)
        {
            case LEFT:
                for(obj in menuItemsLeftGrp)
                {
                    if(obj.ID == curSelected)
                    {
                        obj.color = 0xFFFFFFFF;
                    }
                    else
                    {
                        obj.color = 0xFF666666;
                    }
                }

                for(obj in menuItemsRightGrp)
                {
                    obj.color = 0xFF666666;
                }
            case RIGHT:
                for(obj in menuItemsRightGrp)
                {
                    if(obj.ID == curSelected)
                    {
                        obj.color = 0xFFFFFFFF;
                    }
                    else
                    {
                        obj.color = 0xFF666666;
                    }
                }

                for(obj in menuItemsLeftGrp)
                {
                    obj.color = 0xFF666666;
                }
        }
    }

    function changeColumn() {
        curColumn = curColumn == LEFT ? RIGHT : LEFT;
        changeSelection();
    }

    function getTargetState(opt:String):Dynamic {
        return switch(opt)
        {
            case 'freeplay':
                new FreeplayState();
            case 'credits':
                new CreditsStateYSides();
            case 'options':
                new options.OptionsState();
            case 'awards':
                new AchievementsMenuState();
            case 'gallery': 
                new states.gallery.GalleryState();
            default:
                null;
        }
    }
    
	var selectedSomethin:Bool = false;
	function transitionBack()
	{
        /*
		for (memb in menuItems)
		{
			FlxTween.tween(memb, {x: -350}, 0.5, {ease: FlxEase.quadOut});
		}

		for (memb in menuItems2)
		{
			FlxTween.tween(memb, {x: FlxG.width + 10}, 0.5, {ease: FlxEase.quadOut});
		}
        */

		FlxTween.tween(FlxG.camera, {zoom: 1.05}, 0.3, {ease: FlxEase.quadOut});
		FlxG.camera.fade(0xFF000000, 0.4, false, null, true);

		new FlxTimer().start(1, function(t:FlxTimer) 
		{
			MusicBeatState.switchState(new TitleState());
		});
	}
}