package states.gallery;

import flixel.addons.display.FlxBackdrop;
import states.gallery.GalleryState.GalleryStateImages;
import shaders.WaterShader;
import shaders.Dubswitcher;
import shaders.ColorSwap.ColorSwapShader;
import openfl.filters.ShaderFilter;
import haxe.Json;

class NewGalleryState extends MusicBeatState
{
    public static var comingFromGallery:Bool = false;
    private static var curSelected:Int = 0;
    private static var curSelectedImages:Int = 0;
    private static var curSelectedMusics:Int = 0;
    public static var musicSongsArrayFull:Array<String> = [
        'tutorial',
        'bopeebo',
        'fresh',
        'dad-battle',
        'spookeez',
        'south',
        'monster',
        'pico',
        'philly-nice',
        'blammed',
        'satin-panties',
        'high',
        'milf',
        'cocoa',
        'eggnog',
        'winter-horrorland',
        'test',
        'improbable-outset',
        'madness',
        'ram'
    ];
    static var musicSongsArray:Array<Dynamic> = [ // Song name - Is pico mix?
        ['tutorial', false],
    ];

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
    var infoButtonBackground:FlxSprite;
    var infoButton:FlxSprite;
    var infoBackground:FlxSprite;
    var infoText:FlxText;
    var blackTop:FlxSprite;

    var waterShader:WaterShader;
    var waterShaderFilter:ShaderFilter;
	var dubswitcherShader:Dubswitcher;
	var dubswitcherFilter:ShaderFilter;
	var colorSwapShader:ColorSwapShader;
	var colorSwapFilter:ShaderFilter;

    // Images section
    var imagesGrp:FlxTypedGroup<GalleryObject>;
    var imageDataArray:Array<Dynamic> = [];

    // Music
    var inst:FlxSound;

    // Characters handler shit
    public var curCharacter:Int = 0;

    var mainCam:FlxCamera;
    var bgCamera:FlxCamera;
    var hudCamera:FlxCamera;

    var curtainsTransition:FlxSprite;

    var glitchEffect(default, set):Bool = false;
    function set_glitchEffect(value:Bool)
    {
        glitchEffect = value;
        if(value)
        {
            FlxTween.num(0.025, 0, 0.3, {ease: FlxEase.quartOut}, function(v:Float)
            {
                dubswitcherShader.intensity.value[0] = v;
            });

            FlxTween.num(-0.1, 0, 0.3, {ease: FlxEase.quartOut}, function(v:Float)
            {
                colorSwapShader.uTime.value[1] = v;
            });

            FlxTween.cancelTweensOf(bg);
            FlxTween.cancelTweensOf(FlxG.camera);
            FlxTween.tween(bg, {alpha: 1}, 0.3, {ease: FlxEase.quartOut});
            FlxTween.tween(bgCamera, {zoom: 1}, 0.3, {ease: FlxEase.quartOut});
        }
        else
        {
            FlxTween.num(0, 0.025, 0.3, {ease: FlxEase.quartOut}, function(v:Float)
            {
                dubswitcherShader.intensity.value[0] = v;
            });

            FlxTween.num(0, -0.1, 0.3, {ease: FlxEase.quartOut}, function(v:Float)
            {
                colorSwapShader.uTime.value[1] = v;
            });

            FlxTween.cancelTweensOf(bg);
            FlxTween.cancelTweensOf(FlxG.camera);
            FlxTween.tween(bg, {alpha: 0.75}, 0.3, {ease: FlxEase.quartOut});
            FlxTween.tween(bgCamera, {zoom: 1.05}, 0.3, {ease: FlxEase.quartOut});
        }
        return value;
    }

    override function create()
    {
        super.create();

        FlxG.mouse.visible = true;

        lockedWeeks(#if debug true #else false #end);
		if(FlxG.sound.music != null)
		{
			if(!FlxG.sound.music.playing)
			{
				trace('Main menu music is not playing, starting gallery menu music!');
                FlxG.sound.playMusic(Paths.music('galleryMenu'), 0);
				FlxG.sound.music.fadeIn(1);
			}
		}

        mainCam = initPsychCamera();
        
        bgCamera = new FlxCamera();
        bgCamera.bgColor.alpha = 0;
        FlxG.cameras.add(bgCamera, false);

        hudCamera = new FlxCamera();
        hudCamera.bgColor.alpha = 0;
        FlxG.cameras.add(hudCamera, false);
        FlxG.cameras.setDefaultDrawTarget(hudCamera, true);

        if(ClientPrefs.data.shaders)
        {
            waterShader = new WaterShader();
            waterShader.iTime.value = [0];

            waterShaderFilter = new ShaderFilter(waterShader);

            dubswitcherShader = new Dubswitcher();
            dubswitcherShader.intensity.value = [0.0];

            dubswitcherFilter = new ShaderFilter(dubswitcherShader);

            colorSwapShader = new ColorSwapShader();
            colorSwapShader.uTime.value = [0, 0, 0];

            colorSwapFilter = new ShaderFilter(colorSwapShader);
            bgCamera.filters = [dubswitcherFilter, colorSwapFilter];
        }

        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('gallery/NEW/bg'));
        bg.x += 50;
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.shader = waterShader;
        bg.cameras = [bgCamera];
        add(bg);

        optionsGrp = new FlxTypedGroup<GalleryObject>();
        add(optionsGrp);

        imagesGrp = new FlxTypedGroup<GalleryObject>();
        add(imagesGrp);

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

        infoButtonBackground = new FlxSprite();
        infoButtonBackground.makeGraphic(53, 51, 0xFF000000);
        infoButtonBackground.alpha = 0;
        add(infoButtonBackground);

        infoButton = new FlxSprite();
        infoButton.loadGraphic(Paths.image('gallery/NEW/infoButton'));
        infoButton.x = FlxG.width - infoButton.width - 10;
        infoButton.y = 90;
        infoButton.alpha = 0;
        infoButton.active = false;
        infoButton.antialiasing = ClientPrefs.data.antialiasing;
        add(infoButton);

        infoButtonBackground.x = infoButton.x;
        infoButtonBackground.y = infoButton.y;

        infoBackground = new FlxSprite();
        infoBackground.makeGraphic(400, 40, 0xFF000000);
        infoBackground.alpha = 0.5;
        infoBackground.visible = false;
        add(infoBackground);

        infoText = new FlxText(0, 0, 650, '');
        infoText.setFormat(Paths.font("vcr.ttf"), 36, 0xFFFFFFFF);
        infoText.visible = false;
        infoText.antialiasing = ClientPrefs.data.antialiasing;
        add(infoText);
        
        blackTop = new FlxSprite();
        blackTop.makeGraphic(Std.int(FlxG.width * 1.2), FlxG.height, 0xFF000000);
        //blackTop.alpha = 0;
        blackTop.screenCenter();
        add(blackTop);

        // transition
        blackTop.alpha = 1;
        FlxG.camera.zoom = 1.05;

		FlxTween.tween(blackTop, {alpha: 0}, 1.3, {ease: FlxEase.expoOut});
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.expoOut});

        curtainsTransition = new FlxSprite();
        curtainsTransition.frames = Paths.getSparrowAtlas('transition/transCurtains');
        curtainsTransition.animation.addByPrefix('close', 'closeCurtains', 12, false);
        curtainsTransition.animation.addByPrefix('open', 'openCurtains', 12, false);
        curtainsTransition.animation.play('open');
        //curtainsTransition.visible = false;
        curtainsTransition.antialiasing = ClientPrefs.data.antialiasing;
        curtainsTransition.screenCenter();
        curtainsTransition.y += 10;
        add(curtainsTransition);

        changeSelect(0, true);
    }

    var tweenTransSpeed:Float = 0.4;
    var angleSpeed:Float = 15;
    var canInteract:Bool = true;
    var isPreviewingImages:Bool = false;
    var isPreviewingMusics:Bool = false;
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        disk.angle += angleSpeed * elapsed;
        if(waterShader != null) waterShader.iTime.value[0] += elapsed;
        if(dubswitcherShader != null) dubswitcherShader.iTime.value[0] += elapsed;
        if(isPreviewingMusics)
        {
            playMusicTimer += elapsed;
            if(playMusicTimer > 1 && !playedMusic)
            {
                playedMusic = true;
                glitchEffect = true;
                playMusic();
            }
        }

        if(canInteract) handleInputs();
    }

    function handleInputs()
    {
        if(isPreviewingImages || isPreviewingMusics)
        {
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
                FlxG.sound.play(Paths.sound('cancelMenu'));

                destroyInstrumental();

                FlxTween.tween(infoButtonBackground, {alpha: 0}, tweenTransSpeed, {ease: FlxEase.quartInOut});
                FlxTween.tween(infoButton, {alpha: 0}, tweenTransSpeed, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
                {
                    infoButton.active = false;
                    infoBackground.visible = false;
                    infoText.visible = false;
                }});

                for(obj in imagesGrp)
                {
                    FlxTween.cancelTweensOf(obj);
                    FlxTween.tween(obj, {y: 1280}, tweenTransSpeed, {ease: FlxEase.quartInOut});
                }

                FlxTween.tween(optionsGrp.members[curSelected], {y: 150}, tweenTransSpeed, {ease: FlxEase.quartInOut});

                playMusicTimer = 0;
                //if(isPreviewingMusics) resetTimer();
                if(inst != null)
                {
                    if(!inst.playing) 
                    {
                        FlxG.sound.playMusic(Paths.music('galleryMenu'), 0);
                        FlxG.sound.music.fadeIn(1);
                    }
                }

                FlxTween.cancelTweensOf(galleryTheme);
                FlxTween.tween(galleryTheme, {alpha: 1}, tweenTransSpeed, {ease: FlxEase.quartOut});

                FlxTween.num(0.025, 0, 0.3, {ease: FlxEase.quartOut}, function(v:Float)
                {
                    dubswitcherShader.intensity.value[0] = v;
                });

                FlxTween.num(-0.1, 0, 0.3, {ease: FlxEase.quartOut}, function(v:Float)
                {
                    colorSwapShader.uTime.value[1] = v;
                });

                FlxTween.cancelTweensOf(bg);
                FlxTween.cancelTweensOf(FlxG.camera);
                FlxTween.tween(bg, {alpha: 1}, 0.3, {ease: FlxEase.quartOut});
                FlxTween.tween(bgCamera, {zoom: 1}, 0.3, {ease: FlxEase.quartOut});

                isPreviewingImages = false;
                isPreviewingMusics = false;
            }

            if(infoButton.active)
            {
                if(FlxG.mouse.overlaps(infoButton))
                {
                    infoBackground.visible = true;
                    infoText.visible = true;

                    infoText.text = imageDataArray[curSelectedImages].description;
                    infoBackground.makeGraphic(Std.int(infoText.width + 4), Std.int(infoText.height + 4), 0xFF000000);

                    final mousePos = FlxG.mouse.getWorldPosition();
                    infoBackground.setPosition(mousePos.x - infoBackground.width - 10, mousePos.y);
                    infoText.setPosition(infoBackground.x + 2, infoBackground.y + 2);
                }
                else
                {
                    infoBackground.visible = false;
                    infoText.visible = false;
                }
            }
            else
            {
                infoBackground.visible = false;
                infoText.visible = false;
            }
        }
        else
        {
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
                comingFromGallery = true;
                
                curtainsTransition.animation.play('close', true);

		        FlxTween.tween(blackTop, {alpha: 1}, 1.3, {ease: FlxEase.expoOut});
		        FlxTween.tween(FlxG.camera, {zoom: 1.05}, 1, {ease: FlxEase.expoOut});

                FlxG.sound.play(Paths.sound('cancelMenu'));
                new FlxTimer().start(1, function(t:FlxTimer)
                {
		            	FlxTransitionableState.skipNextTransIn = true;
		            	FlxTransitionableState.skipNextTransOut = true;
                    MusicBeatState.switchState(new MainMenuState());
                });
            }

            if(controls.ACCEPT)
            {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                var selectedItem:String = optionsArr[curSelected];
                switch(selectedItem)
                {
                    case 'outdated_concepts' | 'bored':
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        for(obj in optionsGrp)
                        {
                            FlxTween.cancelTweensOf(obj);
                        }

                        isPreviewingImages = true;
                        disposeImages();
                        generateImages(selectedItem);

                        FlxTween.tween(optionsGrp.members[curSelected], {y: -380}, tweenTransSpeed, {ease: FlxEase.quartInOut});
                    case 'music':
                        FlxG.sound.play(Paths.sound('confirmMenu'));

                        for(obj in optionsGrp)
                        {
                            FlxTween.cancelTweensOf(obj);
                        }

                        FlxTween.cancelTweensOf(galleryTheme);
                        FlxTween.tween(galleryTheme, {alpha: 0}, tweenTransSpeed, {ease: FlxEase.quartOut});

                        isPreviewingMusics = true;
                        disposeImages();
                        generateMusics();

                        FlxTween.tween(optionsGrp.members[curSelected], {y: -380}, tweenTransSpeed, {ease: FlxEase.quartInOut});
                    default:
                }
            }
        }
    }

    var playMusicTimer:Float = 0;
    var playedMusic:Bool = false;
    function changeSelect(change:Int = 0, firstTime:Bool = false)
    {
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        if(isPreviewingImages)
        {
            curSelectedImages = FlxMath.wrap(curSelectedImages + change, 0, imageDataArray.length - 1);

		    for (num => item in imagesGrp.members)
		    {
		    	item.targetX = num - curSelectedImages;
		    	item.alpha = 0.6;
		    	if (item.targetX == 0) item.alpha = 1;
                if (firstTime) item.snapToPosition();
		    }
        }
        else if(isPreviewingMusics)
        {
            resetTimer(firstTime);
            curSelectedMusics = FlxMath.wrap(curSelectedMusics + change, 0, musicSongsArray.length - 1);

		    for (num => item in imagesGrp.members)
		    {
		    	item.targetX = num - curSelectedMusics;
		    	item.alpha = 0.6;
		    	if (item.targetX == 0) item.alpha = 1;
                if (firstTime) item.snapToPosition();
		    }
        }
        else
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

    function resetTimer(firstTime:Bool = false)
    {
        if(playMusicTimer > 1 || firstTime) FlxG.sound.playMusic(Paths.sound('gallery/whiteNoise')); // behaviour as music so it loops

        glitchEffect = false;
        playMusicTimer = 0;
        playedMusic = false;

        if(inst != null)
        {
            if(inst.playing) inst.pause();
        }

        destroyInstrumental();
    }

    function playMusic()
    {
        var charSuffix:String = musicSongsArray[curSelectedMusics][1] ? 'pico' : 'bf';
        if(FileSystem.exists('assets/songs/${musicSongsArray[curSelectedMusics][0]}/Inst-$charSuffix.ogg'))
        {
            if(FlxG.sound.music != null)
                FlxG.sound.music.stop();
        
            destroyInstrumental();

            #if debug trace('Changing song to ${musicSongsArray[curSelectedMusics][0]}$charSuffix'); #end

            //FlxG.sound.playMusic('assets/songs/${musicSongsArray[curSelected]}/Full.ogg');
            //inst = preloadedInstMap.get(musicSongsArray[curSelected]);

            inst = new FlxSound();
            inst.loadEmbedded(Paths.inst(musicSongsArray[curSelectedMusics][0], charSuffix));
            
            FlxG.sound.list.add(inst);

            //@:privateAccess
            //FlxG.sound.playMusic(inst._sound);
            inst.play();

            #if debug
            trace('INST ' + FlxG.sound.music);
            #end
        }
        else
        {
            #if debug
            trace('No music found for ${musicSongsArray[curSelectedMusics][0]}$charSuffix');
            #end
        }

        trace('MUSIC SHIT LENGTH -> ${FlxG.sound.list.length}');
    }

    function generateImages(folderName:String)
    {
        var imagesOnFolder:Array<String> = [];

        // Delete json files
        for(obj in FileSystem.readDirectory('assets/shared/images/gallery/$folderName'))
        {
            trace(obj, obj.endsWith('.png'));
            if(obj.endsWith('.png'))
            {
                imagesOnFolder.push(obj);
            }
        }

        for(num => image in imagesOnFolder)
        {
            #if debug
                trace(' * $image');
            #end
            
            // removing the extension .png
            var imageName = StringTools.replace(image, '.png', '');

            try {
                var content = File.getContent('assets/shared/images/gallery/$folderName/$imageName.json');
                var imageData = Json.parse(content);

                #if debug
                trace('$num: ${imageData.name}');
                trace('$num: ${imageData.description}');
                #end

                imageDataArray.push(imageData);
            } 
            catch(exc)
            {
                #if debug trace('No json has been found for the image with ID $num'); #end
            }

            var spr = new GalleryObject();
            trace(imageName);
            spr.loadGraphic(Paths.image('gallery/$folderName/$imageName'));
            #if debug
            trace(' - [$num] Path: ${'assets/shared/images/gallery/$folderName/$imageName.png'}');
            #end
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.setGraphicSize((spr.width * 400) / spr.height, 400);
            spr.screenCenter();
            spr.x = 800;
            spr.x += -(spr.width / 2);
            spr.startPosition = new FlxPoint(spr.x, spr.y);
            spr.targetX = num;
            spr.x += FlxG.width * num;
            spr.snapToPosition();
            imagesGrp.add(spr);
        }

        curSelectedImages = 0;
        changeSelect(0, true);

        for(obj in imagesGrp)
        {
            obj.y = 1280;
            FlxTween.tween(obj, {y: obj.startPosition.y}, tweenTransSpeed, {ease: FlxEase.quartInOut});
        }

        FlxTween.tween(infoButtonBackground, {alpha: 0.6}, tweenTransSpeed, {ease: FlxEase.quartInOut});
        FlxTween.tween(infoButton, {alpha: 1}, tweenTransSpeed, {ease: FlxEase.quartInOut, onComplete: function(twn:FlxTween)
        {
            infoButton.active = true;
        }});
    }

    function disposeImages()
    {
        imagesGrp.forEach(function(spr:FlxSprite) spr.destroy());
        imagesGrp.clear();
        imageDataArray = [];
    }

    function generateMusics()
    {
        for(num => arr in musicSongsArray)
        {
            var image = arr[0];

            #if debug
                trace(' * $image');
            #end
            
            // removing the extension .png
            var imageName = StringTools.replace(image, '.png', '');

            var spr = new GalleryObject();
            spr.loadGraphic(Paths.image('songCards/$imageName'));
            #if debug
            trace(' - [$num] Path: ${'assets/shared/images/songCards/$imageName.png'}');
            #end
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.scale.set(0.7, 0.7);
            spr.updateHitbox();
            spr.screenCenter();
            spr.x = 800;
            spr.x += -(spr.width / 2);
            spr.startPosition = new FlxPoint(spr.x, spr.y);
            spr.targetX = num;
            spr.x += FlxG.width * num;
            spr.snapToPosition();
            imagesGrp.add(spr);
        }

        curSelectedMusics = 0;
        changeSelect(0, true);

        for(obj in imagesGrp)
        {
            obj.y = 1280;
            FlxTween.tween(obj, {y: obj.startPosition.y}, tweenTransSpeed, {ease: FlxEase.quartInOut});
        }
    }

    function lockedWeeks(unlockEverything:Bool = false)
    {
        musicSongsArray = [['tutorial', false]];

        if(unlockEverything)
        {
            musicSongsArray.push(['bopeebo', false]);
            musicSongsArray.push(['fresh', false]);
            musicSongsArray.push(['dad-battle', false]);
            musicSongsArray.push(['spookeez', false]);
            musicSongsArray.push(['south', false]);
            musicSongsArray.push(['monster', false]);
            musicSongsArray.push(['pico', false]);
            musicSongsArray.push(['philly-nice', false]);
            musicSongsArray.push(['blammed', false]);
            musicSongsArray.push(['satin-panties', false]);
            musicSongsArray.push(['high', false]);
            musicSongsArray.push(['milf', false]);
            musicSongsArray.push(['cocoa', false]);
            musicSongsArray.push(['eggnog', false]);
            musicSongsArray.push(['winter-horrorland', false]);
            musicSongsArray.push(['improbable-outset', false]);
            musicSongsArray.push(['madness', false]);
            musicSongsArray.push(['ram', false]);
            return;
        }

        if(NewStoryMenuState.weekCompleted.exists('week1'))
        {
            musicSongsArray.push(['bopeebo', false]);
            musicSongsArray.push(['fresh', false]);
            if(picoUnlocked()) musicSongsArray.push(['fresh', true]);
            musicSongsArray.push(['dad-battle', false]);
        }

        if(NewStoryMenuState.weekCompleted.exists('week2'))
        {
            musicSongsArray.push(['spookeez', false]);
            musicSongsArray.push(['south', false]);
            if(picoUnlocked()) musicSongsArray.push(['south', true]);
            musicSongsArray.push(['monster', false]);
        }

        if(NewStoryMenuState.weekCompleted.exists('week3'))
        {
            musicSongsArray.push(['pico', false]);
            if(picoUnlocked()) musicSongsArray.push(['pico', true]);
            musicSongsArray.push(['philly-nice', false]);
            musicSongsArray.push(['blammed', false]);
        }

        if(NewStoryMenuState.weekCompleted.exists('week4'))
        {
            musicSongsArray.push(['satin-panties', false]);
            musicSongsArray.push(['high', false]);
            if(picoUnlocked()) musicSongsArray.push(['high', true]);
            musicSongsArray.push(['milf', false]);
            if(picoUnlocked()) musicSongsArray.push(['milf', true]);
        }

        if(NewStoryMenuState.weekCompleted.exists('week5'))
        {
            musicSongsArray.push(['cocoa', false]);
            musicSongsArray.push(['eggnog', false]);
            musicSongsArray.push(['winter-horrorland', false]);
        }

        if(ShopSubState.isItemUnlocked('Tricky Sign'))
        {
            musicSongsArray.push(['improbable-outset', false]);
            musicSongsArray.push(['madness', false]);
        }

        if(ShopSubState.isItemUnlocked('Tennis Racket'))
        {
            musicSongsArray.push(['ram', false]);
        }

        // last song on the playlist
        musicSongsArray.push(['test', false]);
    }

    function picoUnlocked():Bool
    {
        return ShopSubState.isItemUnlocked('Picostola');
    }

    function destroyInstrumental()
    {
        if(inst != null)
        {
            inst.stop();
            FlxG.sound.list.remove(inst);
            inst.destroy();
            inst = null;
        }
    }

    override function destroy()
    {
        destroyInstrumental();

        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        super.destroy();
    }
}