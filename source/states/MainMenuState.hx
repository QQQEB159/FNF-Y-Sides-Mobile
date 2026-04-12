package states;

import flixel.addons.display.FlxBackdrop;
import states.gallery.NewGalleryState;
import states.gallery.GalleryState;
import options.OptionsState;

enum Column
{
    LEFT;
    RIGHT;
}

class MainMenuState extends MusicBeatState 
{
	public static var psychEngineVersion:String = '1.0.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var iconsPos:Array<Float> = [0, 0];
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	var bg:FlxSprite;
	var backgroundGradientBottom:FlxSprite;
	var icons:FlxBackdrop;
    var lines:FlxBackdrop;
    var linesSpeed:Float = 20;
    var circle:FlxSprite;
    var circle2:FlxSprite;
    var character:FlxSprite;
    var characterWhite:FlxSprite;
    var characterY:Float = 0;
    var leftBar:FlxSprite;
    var leftBarThorns:FlxBackdrop; // THORNS?!
    var rightBarThorns:FlxBackdrop; // THORNS 2?!
    var thornsSpeed:Float = 15;
    var rightBar:FlxSprite;
    var transition:FlxSprite;

    var menuItemsLeftArr:Array<String> = [
        'story',
        'freeplay',
        'credits'
    ];
    var menuItemsLeftGrp:FlxTypedGroup<MenuItemObj>;
    
    var menuItemsRightArr:Array<String> = [
        'options',
        'awards',
        'gallery'
    ];
    var menuItemsRightGrp:FlxTypedGroup<MenuItemObj>;
    var curColumn:Column = LEFT;
    var menuItemsAngle:Int = 1;
    var menuItemsAngleReverse:Int = -1;

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

		bg = new FlxSprite(-80).makeGraphic(1280, 720, 0xFFFFFFFF);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
        bg.color = 0xFFBFB4F1;
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
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);
		
		icons.setPosition(MainMenuState.iconsPos[0], MainMenuState.iconsPos[1]);

		icons.alpha = 0;
        FlxTween.tween(icons, {alpha: 0.3}, 0.7, {ease: FlxEase.quartOut});

        lines = new FlxBackdrop(Paths.image('mainmenu/new/lines'), X);
        lines.antialiasing = ClientPrefs.data.antialiasing;
        lines.y = 10;
        lines.velocity.set(linesSpeed, 0);
        add(lines);

        lines.alpha = 0;
        FlxTween.tween(lines, {alpha: 1}, 0.7, {ease: FlxEase.quartOut});

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
            character.animation.addByPrefix(totalOpts[i], '${totalOpts[i]}_character', 24, true);
        }
        character.animation.play('story');
        character.updateHitbox();
        character.screenCenter();
        character.antialiasing = ClientPrefs.data.antialiasing;
        add(character);

        characterY = character.y;

        leftBarThorns = new FlxBackdrop(Paths.image('mainmenu/new/lettabox'), Y);
        leftBarThorns.velocity.set(0, thornsSpeed);
        leftBarThorns.antialiasing = ClientPrefs.data.antialiasing;
        add(leftBarThorns);

        leftBar = new FlxSprite();
        leftBar.makeGraphic(370, Std.int(FlxG.height * 1.2), 0xFF130024);
        leftBar.x = -20;
        leftBar.y = -20;
        add(leftBar);

        leftBar.x = -450;
        FlxTween.tween(leftBar, {x: -20}, 0.7, {ease: FlxEase.quartOut});

        leftBarThorns.x = leftBar.x + leftBar.width - 1;
        FlxTween.tween(leftBarThorns, {x: 349}, 0.7, {ease: FlxEase.quartOut});

        circle.x = leftBar.x + leftBar.width - (circle.width / 2);
        FlxTween.tween(circle, {x: 370 - (circle.width / 2)}, 0.7, {ease: FlxEase.quartOut});

        circle.y = leftBar.y + -100;

        rightBarThorns = new FlxBackdrop(Paths.image('mainmenu/new/lettabox'), Y);
        rightBarThorns.velocity.set(0, -thornsSpeed);
        rightBarThorns.antialiasing = ClientPrefs.data.antialiasing;
        rightBarThorns.flipX = true;
        add(rightBarThorns);

        rightBar = new FlxSprite();
        rightBar.makeGraphic(370, Std.int(FlxG.height * 1.2), 0xFF130024);
        rightBar.y = -20;
        add(rightBar);

        rightBar.x = FlxG.width + 80;
        FlxTween.tween(rightBar, {x: FlxG.width - rightBar.width + (rightBar.width - 350)}, 0.7, {ease: FlxEase.quartOut});

        rightBarThorns.x = rightBar.x - rightBarThorns.width + 1;
        FlxTween.tween(rightBarThorns, {x: FlxG.width - rightBar.width + (rightBar.width - 350) - rightBarThorns.width + 1}, 0.7, {ease: FlxEase.quartOut});

        circle2.scale.set(1.15, 1.15);
        circle2.updateHitbox();

        circle2.x = rightBar.x - (circle2.width / 1.8);
        FlxTween.tween(circle2, {x: FlxG.width - rightBar.width + (rightBar.width - 350) - (circle2.width / 1.8)}, 0.7, {ease: FlxEase.quartOut});

        circle2.y = FlxG.height - circle2.height + 210;

        menuItemsLeftGrp = new FlxTypedGroup<MenuItemObj>();
        add(menuItemsLeftGrp);

        menuItemsRightGrp = new FlxTypedGroup<MenuItemObj>();
        add(menuItemsRightGrp);

        for(i in 0...menuItemsLeftArr.length)
        {
            var item = new MenuItemObj(0, 80 + (i * 220));
            item.frames = Paths.getSparrowAtlas('mainmenu/new/${menuItemsLeftArr[i]}');
            item.animation.addByPrefix('idle', menuItemsLeftArr[i], 24, true);
            item.animation.play('idle');
            item.updateHitbox();
            item.x = leftBar.x + (leftBar.width / 2) - (item.width / 2);
            item.ID = i;
            item.antialiasing = ClientPrefs.data.antialiasing;
            item.angle = i == 1 ? menuItemsAngleReverse : menuItemsAngle;
            menuItemsLeftGrp.add(item);

            FlxTween.tween(item, {x: -20 + (leftBar.width / 2) - (item.width / 2)}, 0.7, {ease: FlxEase.quartOut, startDelay: 0.01 * i});

            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                if(i != 1)
                    item.angle = item.angle == menuItemsAngle ? -menuItemsAngle : menuItemsAngle;
                else
                    item.angle = item.angle == menuItemsAngleReverse ? -menuItemsAngleReverse : menuItemsAngleReverse;
            }, 0);
        }

		if(NewStoryMenuState.backFromStoryMode) {
			NewStoryMenuState.backFromStoryMode = false;
			
			icons.alpha = 0;
			FlxTween.tween(icons, {alpha: 0.45}, 0.7, {ease: FlxEase.quartOut});

			character.alpha = 0;
			FlxTween.cancelTweensOf(character);
			FlxTween.tween(character, {alpha: 1}, 0.7, {ease: FlxEase.quartOut});
		}
		else if(CreditsStateYSides.backFromCredits) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.fadeIn(1);
			CreditsStateYSides.backFromCredits = false;

			character.alpha = 0;
			FlxTween.cancelTweensOf(character);
			FlxTween.tween(character, {alpha: 1}, 0.7, {ease: FlxEase.quartOut});
		}

        for(i in 0...menuItemsRightArr.length)
        {
            var item = new MenuItemObj(0, 80 + (i * 200));
            item.frames = Paths.getSparrowAtlas('mainmenu/new/${menuItemsRightArr[i]}');
            item.animation.addByPrefix('idle', menuItemsRightArr[i], 24, true);
            item.animation.play('idle');
            item.updateHitbox();
            item.x = rightBar.x + (rightBar.width / 2) - (item.width / 2) - 30;
            item.ID = i;
            item.angle = i == 1 ? menuItemsAngleReverse : menuItemsAngle;

            var targetX:Float = FlxG.width - rightBar.width + (rightBar.width - 350) + (rightBar.width / 2) - (item.width / 2) - 30;
            if(i == 1) targetX += 70; // lil offset :)

            FlxTween.tween(item, {x: targetX}, 0.7, {ease: FlxEase.quartOut, startDelay: 0.03 * i});
            

            item.antialiasing = ClientPrefs.data.antialiasing;
            menuItemsRightGrp.add(item);

            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                if(i != 1)
                    item.angle = item.angle == menuItemsAngle ? -menuItemsAngle : menuItemsAngle;
                else
                    item.angle = item.angle == menuItemsAngleReverse ? -menuItemsAngleReverse : menuItemsAngleReverse;
            }, 0);
        }

		if(AchievementsMenuState.comingFromAchievements) {
			AchievementsMenuState.comingFromAchievements = false;
			changeColumn(RIGHT, true);
		}

		if(OptionsState.comingFromOptions) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.fadeIn(1);
			OptionsState.comingFromOptions = false;
			changeColumn(RIGHT, true);
		}

		if(GalleryState.comingFromGallery) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.fadeIn(1);
			GalleryState.comingFromGallery = false;
			changeColumn(RIGHT, true);
		}

		transition = new FlxSprite(FlxG.width, 0);
		transition.antialiasing = ClientPrefs.data.antialiasing;
		transition.loadGraphic(Paths.image('transition'));
		transition.scale.set(1, 1.2);
		add(transition);

        characterWhite = new FlxSprite();
        characterWhite.frames = Paths.getSparrowAtlas('mainmenu/new/menu_characters_white');
        characterWhite.animation.addByPrefix('story', 'story_character', 24, true);
        characterWhite.animation.play('story');
        characterWhite.updateHitbox();
        characterWhite.screenCenter();
        characterWhite.antialiasing = ClientPrefs.data.antialiasing;
        characterWhite.alpha = 0;
        add(characterWhite);
                    
		if(CreditsStateYSides.creditsTransition)
		{
			CreditsStateYSides.creditsTransition = false;
			transition.x = -650;
			selectedSomethin = true;
			FlxTween.tween(transition, {x: -2100}, 0.5, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
			{
				selectedSomethin = false;
				transition.x = FlxG.width;
			}});
		}

        changeSelection(0, true);

        //openSubState(new backend.IconFadeTransition(4, 'test', true));
    }

    var circleAngleSpeed:Float = 10;
    var circle2AngleSpeed:Float = -8;
	var scrollMultiplier:Float = 3;
    var characterScaleX:Float = 1;
    var characterScaleY:Float = 1;
    var squishiIntensity:Float = 0.05;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // spin anim
        circle.angle += circleAngleSpeed * elapsed;
        circle2.angle += circle2AngleSpeed * elapsed;

        // squishi squishi anim
        var multX = FlxMath.lerp(character.scale.x, characterScaleX, elapsed * 9);
        var multY = FlxMath.lerp(character.scale.y, characterScaleY, elapsed * 9);
        character.scale.set(multX, multY);

		final hudMousePos = FlxG.mouse.getScreenPosition(FlxG.cameras.list[FlxG.cameras.list.length - 1]);

		var multX = (hudMousePos.x - (FlxG.width / 2)) / (FlxG.width / 2);
		var multY = (hudMousePos.y - (FlxG.height / 2)) / (FlxG.height / 2);

		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (multX * scrollMultiplier), elapsed * 10);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (multY * scrollMultiplier), elapsed * 10);

        if(!selectedSomethin)
        {
            mouseBehaviour(elapsed);

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
                pressAccept();
            }

		    if (controls.BACK)
		    {
		    	selectedSomethin = true;
		    	FlxG.mouse.visible = false;
		    	FlxG.sound.play(Paths.sound('cancelMenu'));
		    	transitionBack();
		    }
        }
    }

    function changeSelection(change:Int = 0, firstTime:Bool = false)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + change, 0, curColumn == LEFT ? menuItemsLeftArr.length - 1 : menuItemsRightArr.length - 1);

        var targetOption = curColumn == LEFT ? menuItemsLeftArr[curSelected] : menuItemsRightArr[curSelected];
        characterScaleX = characterScaleY = switch(targetOption)
        {
            case 'freeplay' | 'awards':
                0.85;
            default:
                1;
        }
        character.animation.play(targetOption);
        character.alpha = 0;
        character.scale.set(characterScaleX - squishiIntensity, characterScaleY + squishiIntensity);
        character.updateHitbox();
        character.screenCenter();
        if(targetOption == 'freeplay') character.x += -5;
        characterY = character.y;

        character.y = characterY + 10;
        character.angle = FlxG.random.bool(50) ? 1 : -1;

        FlxTween.cancelTweensOf(character);
        FlxTween.tween(character, {alpha: 1, y: characterY, angle: 0}, 0.25, {ease: FlxEase.quartOut});

        switch(curColumn)
        {
            case LEFT:
                for(obj in menuItemsLeftGrp)
                {
                    if(obj.ID == curSelected)
                    {
                        obj.color = 0xFFFFFFFF;
                        obj.scaleTarget = 1.05;
                    }
                    else
                    {
                        obj.color = 0xFF666666;
                        obj.scaleTarget = 1;
                    }
                }

                for(obj in menuItemsRightGrp)
                {
                    obj.color = 0xFF666666;
                    obj.scaleTarget = 1;
                }
            case RIGHT:
                for(obj in menuItemsRightGrp)
                {
                    if(obj.ID == curSelected)
                    {
                        obj.color = 0xFFFFFFFF;
                        obj.scaleTarget = 1.05;
                    }
                    else
                    {
                        obj.color = 0xFF666666;
                        obj.scaleTarget = 1;
                    }
                }

                for(obj in menuItemsLeftGrp)
                {
                    obj.color = 0xFF666666;
                    obj.scaleTarget = 1;
                }
        }
    }

    function changeColumn(targetColumn:Column = null, firstTime:Bool = false) {
        if(targetColumn == null) curColumn = curColumn == LEFT ? RIGHT : LEFT;
        else curColumn = targetColumn;
        changeSelection(0, firstTime);
    }

    function pressAccept()
    {
		FlxG.sound.play(Paths.sound('confirmMenu'));
        selectedSomethin = true;
		FlxG.mouse.visible = false;

        var option = curColumn == LEFT ? menuItemsLeftArr[curSelected] : menuItemsRightArr[curSelected];
        var item = curColumn == LEFT ? menuItemsLeftGrp.members[curSelected] : menuItemsRightGrp.members[curSelected];
        switch(option)
        {
            // default transitions
            case 'freeplay' | 'options' | 'awards' | 'gallery':
                trace('Transitioning to $option');
                var state = getTargetState(option);

				if(option == 'options' || option == 'gallery')
				{
					FlxG.sound.music.fadeOut(0.65, 0, function(twn:FlxTween)
					{
						FlxG.sound.music.stop();
					});
				}

                new FlxTimer().start(0.4, function(tmr:FlxTimer)
                {
                    if(option == 'freeplay')
                    {
                        FlxTween.cancelTweensOf(icons);
                        FlxTween.tween(icons, {alpha: 0}, 0.35, {ease: FlxEase.quartIn});

                        FlxTween.cancelTweensOf(bg);
                        FlxTween.color(bg, 0.35, bg.color, 0xFFE7E0FF);
                    }

		            FlxTween.cancelTweensOf(character);
                    FlxTween.cancelTweensOf(lines);
                    FlxTween.cancelTweensOf(circle);
                    FlxTween.cancelTweensOf(circle2);
		            FlxTween.cancelTweensOf(leftBar);
		            FlxTween.cancelTweensOf(leftBarThorns);
		            FlxTween.cancelTweensOf(rightBar);
		            FlxTween.cancelTweensOf(rightBarThorns);
                    FlxTween.tween(character, {alpha: 0, y: characterY - 100}, 0.35, {ease: FlxEase.quartIn, onComplete: function(twn:FlxTween)
                    {
                        //new FlxTimer().start(0.15, function(tmr:FlxTimer)
                        //{
				            FlxTransitionableState.skipNextTransIn = true;
				            FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(state);
                        //});
                    }});
                    FlxTween.tween(lines, {alpha: 0}, 0.35, {ease: FlxEase.quartIn});
                    FlxTween.tween(leftBar, {x: -450}, 0.35, {ease: FlxEase.quartIn});
                    FlxTween.tween(leftBarThorns, {x: -79}, 0.35, {ease: FlxEase.quartIn});
                    FlxTween.tween(circle, {x: -400 - (circle.width / 2)}, 0.35, {ease: FlxEase.quartIn});
                    FlxTween.tween(rightBar, {x: FlxG.width + 80}, 0.35, {ease: FlxEase.quartIn});
                    FlxTween.tween(rightBarThorns, {x: FlxG.width + 80 - rightBarThorns.width + 1}, 0.35, {ease: FlxEase.quartIn});
                    FlxTween.tween(circle2, {x: FlxG.width + 400 - (circle2.width / 1.8)}, 0.35, {ease: FlxEase.quartIn});
                    FlxTween.tween(item, {x: curColumn == LEFT ? item.x - 450 : item.x + 450}, 0.35, {ease: FlxEase.quartIn});
                });

            // special anims
            case 'story':
                new FlxTimer().start(0.4, function(tmr:FlxTimer)
                {
                    FlxTween.tween(characterWhite, {alpha: 1}, 0.25, {onComplete: function(twn:FlxTween)
                    {
		                new FlxTimer().start(0.35, function(tmr:FlxTimer)
		                {
		                	FlxTween.tween(icons, {alpha: 0}, 0.3, {ease: FlxEase.quartIn});
		                	FlxTween.tween(characterWhite, {"scale.x": 15, "scale.y": 15}, 0.3, {ease: FlxEase.quartIn, onComplete: function(twn2:FlxTween) {
		                		FlxTransitionableState.skipNextTransIn = true;
		                		FlxTransitionableState.skipNextTransOut = true;
		                		MusicBeatState.switchState(new NewStoryMenuState());
		                	}});
		                });
                    }});
                });
            case 'credits':
		        FlxG.sound.music.fadeOut(0.65);
		        new FlxTimer().start(0.4, function(tmr:FlxTimer)
		        {
		        	FlxTween.tween(transition, {x: -650}, 1, {ease: FlxEase.quartOut});
		        	FlxTween.cancelTweensOf(character);
		        	FlxTween.tween(character, {alpha: 0, y: character.y + 10}, 0.35, {ease: FlxEase.quartIn, onComplete: function(twn:FlxTween)
		        	{
		        		new FlxTimer().start(1, function(tmr:FlxTimer)
		        		{
		        			#if ACHIEVEMENTS_ALLOWED
		        				FlxTransitionableState.skipNextTransIn = true;
		        				FlxTransitionableState.skipNextTransOut = true;
		        				MusicBeatState.switchState(new CreditsStateYSides());
                        
		        				MainMenuState.iconsPos.insert(0, icons.x);
		        				MainMenuState.iconsPos.insert(1, icons.y);
		        			#end
		        		});
		        	}});
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

    function getTargetState(opt:String):Dynamic {
        return switch(opt)
        {
            case 'freeplay':
                new NewFreeplayState(CharSelectState.currentFreeplaySelectedName == 'pico');
            case 'credits':
                new CreditsStateYSides();
            case 'options':
                new options.OptionsState();
            case 'awards':
                new AchievementsMenuState();
            case 'gallery': 
                new NewGalleryState();
            default:
                null;
        }
    }
    
	var selectedSomethin:Bool = false;
	function transitionBack()
	{
        /*
		for (memb in menuItemsLeftGrp)
		{
			FlxTween.tween(memb, {x: -350}, 0.5, {ease: FlxEase.quadOut});
		}

		for (memb in menuItemsRightGrp)
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

    function mouseBehaviour(elapsed:Float)
    {
		if (allowMouse)
		{
            menuItemsLeftGrp.forEach(function(spr:MenuItemObj)
            {
                if(FlxG.mouse.overlaps(spr))
                {
                    if(FlxG.mouse.justPressed)
                    {
                        pressAccept();
                    }
                    if(spr.ID == curSelected && curColumn == LEFT) return;

                    curColumn = LEFT;
                    curSelected = spr.ID;
                    if(!spr.overlaping) changeSelection();
                    if(!spr.overlaping) spr.overlaping = true;
                }
                else
                {
                    spr.overlaping = false;
                }
            });

            menuItemsRightGrp.forEach(function(spr:MenuItemObj)
            {
                if(FlxG.mouse.overlaps(spr))
                {
                    if(FlxG.mouse.justPressed)
                    {
                        pressAccept();
                    }
                    if(spr.ID == curSelected && curColumn == RIGHT) return;

                    curColumn = RIGHT;
                    curSelected = spr.ID;
                    if(!spr.overlaping) changeSelection();
                    if(!spr.overlaping) spr.overlaping = true;
                }
                else
                {
                    spr.overlaping = false;
                }
            });
		}
    }
}

class MenuItemObj extends FlxSprite
{
    public var overlaping:Bool = false;
    public var scaleTarget:Float = 1;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var mult = FlxMath.lerp(scale.x, scaleTarget, elapsed * 9);
        scale.set(mult, mult);
    }
}