package substates;

import openfl.filters.ShaderFilter;
import shaders.BlurShader;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.addons.display.FlxBackdrop;

import flixel.util.FlxStringUtil;
import flixel.math.FlxMath;
import states.NewStoryMenuState;
import states.NewFreeplayState;

class NewPauseSubState extends MusicBeatSubstate
{
	var grpMenuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Int = 1;

	var pauseMusic:FlxSound;
	var bg:FlxSprite;
	var dots:FlxBackdrop;
    var paperObject:PaperObject;
    var isResumeSelected:Bool = true;
    var isRestartSelected:Bool = true;

    var blurShaderFilter:ShaderFilter;

    override function create()
    {
        super.create();

		pauseMusic = new FlxSound();
		try {
			var pauseSong:String = getPauseSong();
			if (pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		} catch (e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.fadeIn(4);
		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0; // empieza invisible para el fade in
		bg.scrollFactor.set();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6}, 0.5, {ease: FlxEase.linear});

		dots = new FlxBackdrop(Paths.image('gallery/lines'), XY);
		dots.velocity.set(10, 10);
		dots.alpha = 0;
		dots.antialiasing = ClientPrefs.data.antialiasing;
		add(dots);

		FlxTween.tween(dots, {alpha: 0.25}, 0.5, {ease: FlxEase.linear});

        paperObject = new PaperObject(0, 0, PlayState.instance.songPercent);
        paperObject.screenCenter();
        add(paperObject);

        paperObject.alpha = 0;
        paperObject.y += 10;
        FlxTween.tween(paperObject, {y: paperObject.y - 10, alpha: 1}, 0.5, {ease: FlxEase.quartOut});

        var shader = new BlurShader();
        shader.radius.value = [0];

        blurShaderFilter = new ShaderFilter(shader);

        // preventing crash
        if(FlxG.camera.filters == null) FlxG.camera.filters = [];
        if(PlayState.instance.camHUD.filters == null) PlayState.instance.camHUD.filters = [];

        FlxG.camera.filters.push(blurShaderFilter);
        PlayState.instance.camHUD.filters.push(blurShaderFilter);

        FlxTween.num(0, 3, 0.5, {ease: FlxEase.quartOut}, function(v:Float){
            shader.radius.value[0] = v;
        });

        camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

        // because it's the first one displayed and no controls are input, the resume button has to already start with the animation
        resumeAngleTween = FlxTween.num(-coolAnimAngleValue, coolAnimAngleValue, coolAnimDurationValue, {ease: coolAnimEaseValue, type: PINGPONG}, function(v:Float)
        {
            resumeAngleTarget = v;
        });
    }

	public static var songName:String = null;
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if (formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;
		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

    var resumeButtonScale:Float = 1;
    var restartButtonScale:Float = 1;
    var exitButtonScale:Float = 1;

    var resumeAngleTarget:Float = 0;
    var restartAngleTarget:Float = 0;
    var exitAngleTarget:Float = 0;

    var resumeAngleTween:FlxTween;
    var restartAngleTween:FlxTween;
    var exitAngleTween:FlxTween;

    var coolAnimAngleValue:Float = 2;
    var coolAnimDurationValue:Float = 1.5;
    var coolAnimEaseValue:EaseFunction = FlxEase.smoothStepInOut;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var lerpSpeed:Float = elapsed * 10;

        var resumeMult:Float = FlxMath.lerp(paperObject.resumeButton.scale.x, resumeButtonScale, lerpSpeed);
        var restartMult:Float = FlxMath.lerp(paperObject.restartButton.scale.x, restartButtonScale, lerpSpeed);
        var exitMult:Float = FlxMath.lerp(paperObject.exitButton.scale.x, exitButtonScale, lerpSpeed);

        var resumeAngle:Float = FlxMath.lerp(paperObject.resumeButton.angle, resumeAngleTarget, lerpSpeed);
        var restartAngle:Float = FlxMath.lerp(paperObject.restartButton.angle, restartAngleTarget, lerpSpeed);
        var exitAngle:Float = FlxMath.lerp(paperObject.exitButton.angle, exitAngleTarget, lerpSpeed);

        paperObject.resumeButton.scale.set(resumeMult, resumeMult);
        paperObject.restartButton.scale.set(restartMult, restartMult);
        paperObject.exitButton.scale.set(exitMult, exitMult);

        paperObject.resumeButton.angle = resumeAngle;
        paperObject.restartButton.angle = restartAngle;
        paperObject.exitButton.angle = exitAngle;

        if(controls.UI_UP_P || controls.UI_DOWN_P)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 1);
            isResumeSelected = !isResumeSelected;
            if(isResumeSelected)
            {
                resumeAngleTween = FlxTween.num(-coolAnimAngleValue, coolAnimAngleValue, coolAnimDurationValue, {ease: coolAnimEaseValue, type: PINGPONG}, function(v:Float)
                {
                    resumeAngleTarget = v;
                });
                if(restartAngleTween != null) restartAngleTween.cancel();
                if(exitAngleTween != null) exitAngleTween.cancel();

                restartAngleTarget = 0;
                exitAngleTarget = 0;
            }
            else
            {
                if(isRestartSelected)
                {
                    if(resumeAngleTween != null) resumeAngleTween.cancel();
                    resumeAngleTarget = 0;
                    restartAngleTween = FlxTween.num(-coolAnimAngleValue, coolAnimAngleValue, coolAnimDurationValue, {ease: coolAnimEaseValue, type: PINGPONG}, function(v:Float)
                    {
                        restartAngleTarget = v;
                    });
                    if(exitAngleTween != null) exitAngleTween.cancel();
                    exitAngleTarget = 0;
                }
                else
                {
                    if(resumeAngleTween != null) resumeAngleTween.cancel();
                    if(restartAngleTween != null) restartAngleTween.cancel();
                    if(exitAngleTween != null) exitAngleTween.cancel();

                    resumeAngleTarget = 0;
                    restartAngleTarget = 0;
                    exitAngleTween = FlxTween.num(-coolAnimAngleValue, coolAnimAngleValue, coolAnimDurationValue, {ease: coolAnimEaseValue, type: PINGPONG}, function(v:Float)
                    {
                        exitAngleTarget = v;
                    });
                }
            }
        }

        if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 1);
            isRestartSelected = !isRestartSelected;
            if(isRestartSelected)
            {
                if(resumeAngleTween != null) resumeAngleTween.cancel();
                resumeAngleTarget = 0;
                restartAngleTween = FlxTween.num(-coolAnimAngleValue, coolAnimAngleValue, coolAnimDurationValue, {ease: coolAnimEaseValue, type: PINGPONG}, function(v:Float)
                {
                    restartAngleTarget = v;
                });
                if(exitAngleTween != null) exitAngleTween.cancel();
                exitAngleTarget = 0;
            }
            else
            {
                if(resumeAngleTween != null) resumeAngleTween.cancel();
                if(restartAngleTween != null) restartAngleTween.cancel();
                if(exitAngleTween != null) exitAngleTween.cancel();

                resumeAngleTarget = 0;
                restartAngleTarget = 0;
                exitAngleTween = FlxTween.num(-coolAnimAngleValue, coolAnimAngleValue, coolAnimDurationValue, {ease: coolAnimEaseValue, type: PINGPONG}, function(v:Float)
                {
                    exitAngleTarget = v;
                });
            }
        }

        if(controls.ACCEPT)
        {
            FlxG.camera.filters.remove(blurShaderFilter);
            PlayState.instance.camHUD.filters.remove(blurShaderFilter);

            if(isResumeSelected) closePauseMenu();
            else if(isRestartSelected) restartSong();
            else
            {
		        //if(Achievements.getScore('50misses') < 50) Achievements.setScore('50misses', 0);
                //if(Achievements.getScore('10deaths') < 10) Achievements.setScore('10deaths', 0);

				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				Mods.loadTopMod();
				if (PlayState.isStoryMode)
					MusicBeatState.switchState(new NewStoryMenuState());
				else
					MusicBeatState.switchState(new NewFreeplayState(CharSelectState.currentFreeplaySelectedName == 'pico'));
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				PlayState.changedDifficulty = false;
				PlayState.chartingMode = false;
				FlxG.camera.followLerp = 0;
            }
        }

        if(isResumeSelected)
        {
            paperObject.resumeButton.color = 0xFFFFFFFF;
            paperObject.restartButton.color = 0xFFD9D8ED;
            paperObject.exitButton.color = 0xFFD9D8ED;

            resumeButtonScale = 1;
            restartButtonScale = 0.95;
            exitButtonScale = 0.95;
        }
        else if(isRestartSelected)
        {
            paperObject.resumeButton.color = 0xFFD9D8ED;
            paperObject.restartButton.color = 0xFFFFFFFF;
            paperObject.exitButton.color = 0xFFD9D8ED;

            resumeButtonScale = 0.95;
            restartButtonScale = 1;
            exitButtonScale = 0.95;
        }
        else
        {
            paperObject.resumeButton.color = 0xFFD9D8ED;
            paperObject.restartButton.color = 0xFFD9D8ED;
            paperObject.exitButton.color = 0xFFFFFFFF;

            resumeButtonScale = 0.95;
            restartButtonScale = 0.95;
            exitButtonScale = 1;
        }
    }

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true;
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;
		if(noTrans) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

    function closePauseMenu()
    {
			pauseMusic.stop();
            close();
    }
}

class PaperObject extends FlxSpriteGroup
{
    var paperBack:FlxSprite;
    public var resumeButton:FlxSprite;
    public var restartButton:FlxSprite;
    public var exitButton:FlxSprite;
    var progressArrow:FlxSprite;
    var progressBar:FlxSprite;
    var progress:Float;

    public function new(x:Float = 0, y:Float = 0, _progress:Float)
    {
        super(x, y);

        progress = _progress;

        function centerSprite(spr1:FlxSprite, spr2:FlxSprite)
        {
            spr1.x = spr2.x + (spr2.width / 2) - (spr1.width / 2);
            spr1.y = spr2.y + (spr2.height / 2) - (spr1.height / 2);
        }

        paperBack = new FlxSprite();
        //paperBack.loadGraphic(Paths.image('pause/new/paper'));
        paperBack.frames = Paths.getSparrowAtlas('pause/new/paper');
        paperBack.animation.addByPrefix('idle', 'papersos', 24, true);
        paperBack.animation.play('idle');
        paperBack.antialiasing = ClientPrefs.data.antialiasing;
        add(paperBack);

        resumeButton = new FlxSprite();
        resumeButton.loadGraphic(Paths.image('pause/new/resume'));
        centerSprite(resumeButton, paperBack);
        resumeButton.antialiasing = ClientPrefs.data.antialiasing;
        resumeButton.y += -110;
        add(resumeButton);

        restartButton = new FlxSprite();
        restartButton.loadGraphic(Paths.image('pause/new/restart'));
        centerSprite(restartButton, paperBack);
        restartButton.antialiasing = ClientPrefs.data.antialiasing;
        restartButton.y += 10;
        restartButton.x += -90;
        add(restartButton);

        exitButton = new FlxSprite();
        exitButton.loadGraphic(Paths.image('pause/new/exit'));
        centerSprite(exitButton, paperBack);
        exitButton.antialiasing = ClientPrefs.data.antialiasing;
        exitButton.y += 10;
        exitButton.x += 90;
        add(exitButton);

        progressBar = new FlxSprite();
        progressBar.loadGraphic(Paths.image('pause/new/progressBar'));
        centerSprite(progressBar, paperBack);
        progressBar.y += 150;
        progressBar.antialiasing = ClientPrefs.data.antialiasing;
        add(progressBar);

        progressArrow = new FlxSprite();
        progressArrow.loadGraphic(Paths.image('pause/new/progressArrow'));
        progressArrow.antialiasing = ClientPrefs.data.antialiasing;
        progressArrow.y = progressBar.y - 25;
        progressArrow.x = progressBar.x;
        add(progressArrow);

        // old code lmao
        /*
        var distance:Float = progressBar.width;
        progressArrow.x = progressBar.x + (progressBar.width * progress);
        var targetPos = progressArrow.x;
        progressArrow.x = progressBar.x;
        FlxTween.tween(progressArrow, {x: targetPos}, 1.5, {ease: FlxEase.quartOut});
        */
    }

    override function update(delta:Float)
    {
        super.update(delta);
        var mult:Float = FlxMath.lerp(progressArrow.x, progressBar.x + ((progressBar.width - progressArrow.width) * progress), delta * 4);
        progressArrow.x = mult;
    }
}