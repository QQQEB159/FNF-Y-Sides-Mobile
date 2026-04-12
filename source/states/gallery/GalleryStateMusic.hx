package states.gallery;

import flixel.util.helpers.FlxBounds;
import haxe.Json;
import flixel.addons.display.FlxBackdrop;
import shaders.WiggleEffect;

class GalleryStateMusic extends MusicBeatState
{
    var bg:FlxSprite;
    var barLeft:FlxSprite;
    var barRight:FlxSprite;
    var lines:FlxBackdrop = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);

    var panel:FlxSprite;
    var bf:FlxSprite;
    var arrowUp:FlxSprite;
    var arrowDown:FlxSprite;

	var wiggle:WiggleEffect = null;
	var wiggleBg:WiggleEffect = null;

    var musicSongsGrp:FlxTypedGroup<GalleryMusicObject>;
    static var musicSongsArray:Array<String> = [
        'tutorial',
    ];

    // used to preload
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
        'test'
    ];

    var loadMusicTxt:FlxText;
    var progressMusicTxt:FlxText;
    public function new()
    {
        super();

        //preloadMusic();
        lockedWeeks(#if debug true #else false #end);

		wiggle = new WiggleEffect(2, 4, 0.002, WiggleEffectType.DREAMY);
		wiggleBg = new WiggleEffect(2, 4, 0.002, WiggleEffectType.DREAMY);

		var colorBg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFFBFB4F1);
		add(colorBg);
        
        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('gallery/bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.shader = wiggleBg;
        add(bg);

        lines.velocity.set(75, 75);
        lines.alpha = 0.45;
        lines.antialiasing = ClientPrefs.data.antialiasing;
        lines.setPosition(GalleryState.linesPos[0], GalleryState.linesPos[1]);
        add(lines);

        barLeft = new FlxSprite();
        barLeft.loadGraphic(Paths.image('gallery/bars_vertical'));
        barLeft.antialiasing = ClientPrefs.data.antialiasing;
        add(barLeft);

        barRight = new FlxSprite();
        barRight.loadGraphic(Paths.image('gallery/bars_vertical'));
        barRight.antialiasing = ClientPrefs.data.antialiasing;
        barRight.flipX = true;
        barRight.x = FlxG.width - barRight.width;
        add(barRight);

        panel = new FlxSprite(775, 0);
        panel.loadGraphic(Paths.image('gallery/music/panel'));
        panel.antialiasing = ClientPrefs.data.antialiasing;
        panel.screenCenter(Y);
        add(panel);

        bf = new FlxSprite(0, 0);
        bf.loadGraphic(Paths.image('gallery/music/bf'));
        bf.antialiasing = ClientPrefs.data.antialiasing;
        bf.screenCenter(Y);
        bf.x = panel.x + (panel.width / 2) - (bf.width / 2) - 15;
        bf.y = panel.y + (panel.height / 2) - (bf.height / 2) - 15;
        add(bf);

        musicSongsGrp = new FlxTypedGroup<GalleryMusicObject>();
        add(musicSongsGrp);

        arrowUp = new FlxSprite(355, 130);
        arrowUp.loadGraphic(Paths.image('gallery/music/arrow'));
        arrowUp.antialiasing = ClientPrefs.data.antialiasing;
        add(arrowUp);

        arrowDown = new FlxSprite(355, 530);
        arrowDown.loadGraphic(Paths.image('gallery/music/arrow'));
        arrowDown.antialiasing = ClientPrefs.data.antialiasing;
        arrowDown.flipY = true;
        add(arrowDown);

        for(i in 0...musicSongsArray.length)
        {
            if(!GalleryPreload.hasPreloadedMusic) break;

            var spr = new GalleryMusicObject();
		    spr.loadGraphic(Paths.image('songCards/${Paths.formatToSongPath(musicSongsArray[i])}'));
            spr.scale.set(0.6, 0.6);
            spr.updateHitbox();
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.screenCenter(Y);
            spr.x = arrowUp.x + (arrowUp.width / 2) - (spr.width / 2);
            spr.startPosition = new FlxPoint(spr.x, spr.y);
            spr.targetY = i;
            spr.ID = i;
            spr.y += FlxG.height * i;
            musicSongsGrp.add(spr);
        }

        if(GalleryPreload.hasPreloadedMusic) changeSelect(0, true);
        else
        {
            var string = "Music gallery hasn't loaded yet. Please wait a moment!";

            loadMusicTxt = new FlxText(0, 0, FlxG.width, string, 12);
            loadMusicTxt.setFormat(Paths.font("FredokaOne-Regular.ttf"), 32, FlxColor.WHITE, CENTER);
            loadMusicTxt.screenCenter(Y);
            loadMusicTxt.antialiasing = ClientPrefs.data.antialiasing;
            add(loadMusicTxt);

            progressMusicTxt = new FlxText(0, 0, FlxG.width, "", 12);
            progressMusicTxt.setFormat(Paths.font("FredokaOne-Regular.ttf"), 24, FlxColor.WHITE, CENTER);
            progressMusicTxt.y = loadMusicTxt.y + loadMusicTxt.height + 10;
            progressMusicTxt.antialiasing = ClientPrefs.data.antialiasing;
            add(progressMusicTxt);

            bf.visible = false;
            panel.visible = false;
            arrowDown.visible = false;
            arrowUp.visible = false;
        }
    }

    function lockedWeeks(unlockEverything:Bool = false)
    {
        musicSongsArray = ['tutorial'];

        if(unlockEverything)
        {
            musicSongsArray.push('bopeebo');
            musicSongsArray.push('fresh');
            musicSongsArray.push('dad-battle');
            musicSongsArray.push('spookeez');
            musicSongsArray.push('south');
            musicSongsArray.push('monster');
            musicSongsArray.push('pico');
            musicSongsArray.push('philly-nice');
            musicSongsArray.push('blammed');
            musicSongsArray.push('satin-panties');
            musicSongsArray.push('high');
            musicSongsArray.push('milf');
            musicSongsArray.push('cocoa');
            musicSongsArray.push('eggnog');
            musicSongsArray.push('winter-horrorland');
            return;
        }

        if(NewStoryMenuState.weekCompleted.exists('week1'))
        {
            musicSongsArray.push('bopeebo');
            musicSongsArray.push('fresh');
            musicSongsArray.push('dad-battle');
        }

        if(NewStoryMenuState.weekCompleted.exists('week2'))
        {
            musicSongsArray.push('spookeez');
            musicSongsArray.push('south');
            musicSongsArray.push('monster');
        }

        if(NewStoryMenuState.weekCompleted.exists('week3'))
        {
            musicSongsArray.push('pico');
            musicSongsArray.push('philly-nice');
            musicSongsArray.push('blammed');
        }

        if(NewStoryMenuState.weekCompleted.exists('week4'))
        {
            musicSongsArray.push('satin-panties');
            musicSongsArray.push('high');
            musicSongsArray.push('milf');
        }

        if(NewStoryMenuState.weekCompleted.exists('week5'))
        {
            musicSongsArray.push('cocoa');
            musicSongsArray.push('eggnog');
            musicSongsArray.push('winter-horrorland');
        }

        // last song on the playlist
        musicSongsArray.push('test');
    }

    override function create()
    {
        super.create();

        barLeft.x = 0 - barLeft.width;
        FlxTween.tween(barLeft, {x: 0}, 0.3, {ease: FlxEase.quartOut});

        barRight.x = FlxG.width;
        FlxTween.tween(barRight, {x: FlxG.width - barRight.width}, 0.3, {ease: FlxEase.quartOut});

        panel.y += 10;
        panel.alpha = 0;
        FlxTween.tween(panel, {y: panel.y - 10, alpha: 1}, 0.3, {ease: FlxEase.quartOut});

        bf.y += 10;
        bf.alpha = 0;
        FlxTween.tween(bf, {y: bf.y - 10, alpha: 1}, 0.3, {ease: FlxEase.quartOut});

        arrowUp.alpha = 0;
        FlxTween.tween(arrowUp, {alpha: 1}, 0.6, {ease: FlxEase.quartOut, startDelay: 0.3});

        arrowDown.alpha = 0;
        FlxTween.tween(arrowDown, {alpha: 1}, 0.6, {ease: FlxEase.quartOut, startDelay: 0.3});

        for(obj in musicSongsGrp)
        {
            obj.alpha = 0;
            obj.x += -10;
            FlxTween.tween(obj, {x: obj.x + 10, alpha: 1}, 0.4, {ease: FlxEase.quartOut, startDelay: 0.1 * obj.ID});
        }
    }

    var alreadyPressedSmth:Bool = false;
    var updateArrowScale:Bool = true;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(progressMusicTxt != null)
        {
            progressMusicTxt.text = 'Current progress: ${GalleryPreload.musicPreloadProgress}/${musicSongsArrayFull.length}';
        }

		if (wiggle != null) {
			wiggle.update(elapsed);
		}

		if (wiggleBg != null) {
			wiggleBg.update(elapsed);
		}

        var upMult:Float = FlxMath.lerp(arrowUp.scale.x, 1, elapsed * 9);
        if(updateArrowScale) arrowUp.scale.set(upMult, upMult);

        var rightMult:Float = FlxMath.lerp(arrowDown.scale.x, 1, elapsed * 9);
        if(updateArrowScale) arrowDown.scale.set(rightMult, rightMult);

        if(!alreadyPressedSmth)
        {
            if(controls.UI_DOWN_P)
            {
                if(!GalleryPreload.hasPreloadedMusic) return;

                changeSelect(1);
                arrowDown.scale.set(0.9, 0.85);
            }
            if(controls.UI_UP_P)
            {
                if(!GalleryPreload.hasPreloadedMusic) return;
                
                changeSelect(-1);
                arrowUp.scale.set(0.9, 0.85);
            }

            if(FlxG.mouse.wheel != 0) changeSelect(-FlxG.mouse.wheel);

            if(controls.BACK)
            {
                goBack();
                //MusicBeatState.switchState(new GalleryState());
            }
        }
    }

    function goBack()
    {
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

        var tweenDuration:Float = 0.3;

        FlxTween.tween(barLeft, {x: -barLeft.width}, tweenDuration, {ease: FlxEase.quartOut});
        FlxTween.tween(barRight, {x: FlxG.width}, tweenDuration, {ease: FlxEase.quartOut});
        FlxTween.tween(panel, {y: panel.y - 10, alpha: 0}, tweenDuration, {ease: FlxEase.quartOut});
        FlxTween.tween(bf, {y: bf.y - 10, alpha: 0}, tweenDuration, {ease: FlxEase.quartOut});
        FlxTween.tween(arrowUp, {alpha: 0}, tweenDuration, {ease: FlxEase.quartOut});
        FlxTween.tween(arrowDown, {alpha: 0}, tweenDuration, {ease: FlxEase.quartOut});
        if(loadMusicTxt != null) FlxTween.tween(loadMusicTxt, {alpha: 0}, tweenDuration, {ease: FlxEase.quartOut});
        if(progressMusicTxt != null) FlxTween.tween(progressMusicTxt, {alpha: 0}, tweenDuration, {ease: FlxEase.quartOut});
        for(obj in musicSongsGrp)
        {
            FlxTween.tween(obj, {y: obj.y - 10, alpha: 0}, tweenDuration, {ease: FlxEase.quartOut});
        }

        new FlxTimer().start(tweenDuration + 0.2, function(t:FlxTimer)
        {
		    GalleryState.linesPos.insert(0, lines.x);
		    GalleryState.linesPos.insert(1, lines.y);

            MusicBeatState.switchState(new GalleryState());
        });
    }
    
    private static var curSelected:Int = 0;

    var inst:FlxSound;

    function changeSelect(change:Int = 0, firstTime:Bool = false)
    {
        if(!GalleryPreload.hasPreloadedMusic) return;

        curSelected = FlxMath.wrap(curSelected + change, 0, musicSongsGrp.length - 1);

		for (num => item in musicSongsGrp.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
            if(firstTime) item.snapToPosition();
		}

        if(FileSystem.exists('assets/songs/${musicSongsArray[curSelected]}/Inst.ogg'))
        {
            if(FlxG.sound.music != null)
                FlxG.sound.music.stop();

		    FlxG.sound.list.remove(inst);

            #if debug trace('Changing song to ${musicSongsArray[curSelected]}'); #end

            //FlxG.sound.playMusic('assets/songs/${musicSongsArray[curSelected]}/Full.ogg');
            //inst = preloadedInstMap.get(musicSongsArray[curSelected]);

            inst = new FlxSound();
            inst.loadEmbedded('assets/songs/${musicSongsArray[curSelected]}/Inst.ogg');
            
		    FlxG.sound.list.add(inst);

		    @:privateAccess
            FlxG.sound.playMusic(inst._sound);

            #if debug
            trace('INST ' + FlxG.sound.music);
            #end
        }
        else
        {
            #if debug
            trace('No music found for ${musicSongsArray[curSelected]}');
            #end
        }
    }
}

class GalleryMusicObject extends FlxSprite
{
    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(0, 350);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    
    public function new(x:Float = 0, y:Float = 0, ?graphic:Dynamic = null)
    {
        super(x, y, graphic);
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