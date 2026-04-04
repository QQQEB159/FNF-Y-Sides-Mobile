package states.gallery;

import flixel.addons.display.FlxBackdrop;
import states.gallery.GalleryState.GalleryStateImages;
import shaders.WaterShader;

class NewGalleryState extends MusicBeatState
{
    private static var curSelected:Int = 0;

    var optionsGrp:FlxTypedGroup<GalleryObject>;
    var optionsArr:Array<String> = [
        'outdated_concepts',
        'music',
        'bored'
    ];

    var bg:FlxSprite;
    var leftDownBars:FlxSprite;
    var icons:FlxBackdrop;
    var polo:FlxSprite;
    var galleryTheme:FlxSprite;
    var disk:FlxSprite;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    var waterShader:WaterShader;

    override function create()
    {
        super.create();

		if(FlxG.sound.music != null)
		{
			if(!FlxG.sound.music.playing)
			{
				trace('Main menu music is not playing, starting gallery menu music!');
                FlxG.sound.playMusic(Paths.music('galleryMenu'), 0);
				FlxG.sound.music.fadeIn(1);
			}
		}

        waterShader = new WaterShader();
        waterShader.iTime.value = [0];

        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('gallery/NEW/bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.shader = waterShader;
        add(bg);

        optionsGrp = new FlxTypedGroup<GalleryObject>();
        add(optionsGrp);

        leftDownBars = new FlxSprite();
        leftDownBars.loadGraphic(Paths.image('gallery/NEW/leftDownBars'));
        leftDownBars.antialiasing = ClientPrefs.data.antialiasing;
        add(leftDownBars);

        icons = new FlxBackdrop(Paths.image('gallery/NEW/icons'), Y, 0, -15);
        icons.velocity.set(0, 15);
        icons.antialiasing = ClientPrefs.data.antialiasing;
        icons.blend = ADD;
        add(icons);

        galleryTheme = new FlxBackdrop(Paths.image('gallery/NEW/galleryTheme'), X, 50);
        galleryTheme.x = 375;
        galleryTheme.y = 653;
        galleryTheme.antialiasing = ClientPrefs.data.antialiasing;
        galleryTheme.velocity.set(-20, 0);
        add(galleryTheme);

        polo = new FlxSprite();
        polo.loadGraphic(Paths.image('gallery/NEW/polo'));
        polo.antialiasing = ClientPrefs.data.antialiasing;
        add(polo);

        disk = new FlxSprite(37, 490);
        disk.loadGraphic(Paths.image('gallery/NEW/disk'));
        disk.antialiasing = ClientPrefs.data.antialiasing;
        add(disk);

        leftArrow = new FlxSprite(430, 0);
        leftArrow.frames = Paths.getSparrowAtlas('gallery/NEW/arrow');
        leftArrow.animation.addByPrefix('idle', 'idle', 2, true);
        leftArrow.animation.addByPrefix('press', 'press', 24, false);
        leftArrow.animation.play('idle');
        leftArrow.antialiasing = ClientPrefs.data.antialiasing;
        leftArrow.screenCenter(Y);
        add(leftArrow);

        rightArrow = new FlxSprite(1080, 0);
        rightArrow.frames = Paths.getSparrowAtlas('gallery/NEW/arrow');
        rightArrow.animation.addByPrefix('idle', 'idle', 2, true);
        rightArrow.animation.addByPrefix('press', 'press', 24, false);
        rightArrow.animation.play('idle');
        rightArrow.antialiasing = ClientPrefs.data.antialiasing;
        rightArrow.screenCenter(Y);
        rightArrow.flipX = true;
        add(rightArrow);

        for(i in 0...optionsArr.length)
        {
            var obj:GalleryObject = new GalleryObject();
            obj.frames = Paths.getSparrowAtlas('gallery/NEW/${optionsArr[i]}Spr');
            obj.animation.addByPrefix('idle', 'idle', 2, true);
            obj.animation.play('idle');
            obj.antialiasing = ClientPrefs.data.antialiasing;
            obj.x = 470;
            obj.y = 150;
            obj.startPosition = new FlxPoint(obj.x, obj.y);
            obj.targetX = i;
            obj.x += FlxG.width * i;
            obj.snapToPosition();
            optionsGrp.add(obj);
        }

        for(obj in optionsGrp)
        {
            var angleTarget = 1;
            new FlxTimer().start(0.5, function(tmr:FlxTimer)
            {
                obj.angle = obj.angle == angleTarget ? -angleTarget : angleTarget;
            }, 0);
        }

        var angleTarget = 1;
        new FlxTimer().start(0.5, function(tmr:FlxTimer)
        {
            icons.angle = icons.angle == angleTarget ? -angleTarget : angleTarget;
        }, 0);

        changeSelect();
    }

    var angleSpeed:Float = 15;
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        disk.angle += angleSpeed * elapsed;
        if(waterShader != null) waterShader.iTime.value[0] += elapsed;

        if(controls.UI_RIGHT_P)
        {
            changeSelect(1);
            rightArrow.animation.play('press', true);
            rightArrow.animation.finishCallback = function(name)
            {
                rightArrow.animation.play('idle', true);
            };
        }
        if(controls.UI_LEFT_P)
        {
            changeSelect(-1);
            leftArrow.animation.play('press', true);
            leftArrow.animation.finishCallback = function(name)
            {
                leftArrow.animation.play('idle', true);
            };
        }

        if(controls.BACK)
        {
            new FlxTimer().start(0.8, function(t:FlxTimer)
            {
		    	FlxTransitionableState.skipNextTransIn = true;
		    	FlxTransitionableState.skipNextTransOut = true;
                MusicBeatState.switchState(new MainMenuState());
            });
        }

        if(controls.ACCEPT)
        {
            var selectedItem:String = optionsArr[curSelected];
            switch(selectedItem)
            {
                    case 'outdated_concepts':
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        FlxTween.cancelTweensOf(leftArrow);
                        for(obj in optionsGrp)
                        {
                            FlxTween.cancelTweensOf(obj);
                        }
                        FlxTween.cancelTweensOf(rightArrow);

                        FlxTween.tween(leftArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn});
                        FlxTween.tween(optionsGrp.members[curSelected], {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.1});
                        FlxTween.tween(rightArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.2});

                        new FlxTimer().start(0.8, function(t:FlxTimer)
                        {
		    				FlxTransitionableState.skipNextTransIn = true;
		    				FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(new GalleryStateImages(selectedItem));
                        });
                    case 'music':
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        FlxTween.cancelTweensOf(leftArrow);
                        for(obj in optionsGrp)
                        {
                            FlxTween.cancelTweensOf(obj);
                        }
                        FlxTween.cancelTweensOf(rightArrow);

                        FlxTween.tween(leftArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn});
                        FlxTween.tween(optionsGrp.members[curSelected], {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.1});
                        FlxTween.tween(rightArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.2});

                        new FlxTimer().start(0.8, function(t:FlxTimer)
                        {
		    				FlxTransitionableState.skipNextTransIn = true;
		    				FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(new GalleryStateMusic());
                        });
                    case 'bored':
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        FlxTween.cancelTweensOf(leftArrow);
                        for(obj in optionsGrp)
                        {
                            FlxTween.cancelTweensOf(obj);
                        }
                        FlxTween.cancelTweensOf(rightArrow);

                        FlxTween.tween(leftArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn});
                        FlxTween.tween(optionsGrp.members[curSelected], {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.1});
                        FlxTween.tween(rightArrow, {y: 800}, 0.6, {ease: FlxEase.quartIn, startDelay: 0.2});

                        new FlxTimer().start(0.8, function(t:FlxTimer)
                        {
		    				FlxTransitionableState.skipNextTransIn = true;
		    				FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(new GalleryStateImages(selectedItem));
                        });
                    default:
            }
        }
    }

    function changeSelect(change:Int = 0, firstTime:Bool = false)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, optionsArr.length - 1);

		for (num => item in optionsGrp.members)
		{
			item.targetX = num - curSelected;
			item.alpha = 0.6;
			if (item.targetX == 0) item.alpha = 1;
            if (firstTime) item.snapToPosition();
		}
    }
}