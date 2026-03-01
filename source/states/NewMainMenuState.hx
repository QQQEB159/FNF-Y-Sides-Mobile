package states;

import flixel.addons.display.FlxBackdrop;

class NewMainMenuState extends MusicBeatState 
{
	var bg:FlxSprite;
	var backgroundGradientBottom:FlxSprite;
	var icons:FlxBackdrop;
    var character:FlxSprite;
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
		icons.alpha = 0.45;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);
		
		icons.setPosition(MainMenuState.iconsPos[0], MainMenuState.iconsPos[1]);

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
        add(character);

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
    }

	var scrollMultiplier:Float = 3;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

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