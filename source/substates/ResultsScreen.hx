package substates;

import flixel.addons.display.FlxBackdrop;

import states.CharSelectState;
import states.NewStoryMenuState;
import states.NewFreeplayState;
import options.OptionsState;

import objects.Character;

class ResultsScreen extends MusicBeatSubstate
{
    var stripeSpeed:Int = 25;
    var iconSpeed:Int = 15;
    var patternSpeed:Int = 15;

    var bg:FlxSprite;
    var lines:FlxBackdrop;
    var bgStripe:FlxBackdrop;

    public var boyfriend:Character;

    var bfIconLeft:FlxBackdrop;
    var bfIconRight:FlxBackdrop;
    var patternDown:ResultsScreenPattern;
    var patternUp:ResultsScreenPattern;
    var board:FlxSprite;

    var scoreTxt:FlxText;
    var missesTxt:FlxText;
    var ratingTxt:FlxText;
    
    var statsTxt:FlxText;
    var sicksTxt:FlxText;
    var goodsTxt:FlxText;
    var badsTxt:FlxText;
    var shitsTxt:FlxText;

    var ratingName = '';
    var bfAnimName = '';

    var sick:Int = 0;
    var good:Int = 0;
    var bad:Int = 0;
    var shit:Int = 0;

    var rank:ResultsScreenRank;
    var rankName:String = "";

    var yoinsEarnedTxt:Alphabet;

    var blackBackground:FlxSprite;
    var whiteBackground:FlxSprite;
    var fullBlackBackground:FlxSprite;

    var totalScore:Int = 0;
    var totalMisses:Int = 0;
    var totalRating:Float = 0;

    public var picoMix:Bool = false;

    public function new(_picoMix)
    {
        picoMix = _picoMix;
        super();
    }

    var yoinsEarnedOnSession:Int = 0;
    var yoinsEarnMult:Float = 0.2;
    override function create() 
    {
        super.create();

        totalScore = PlayState.isStoryMode ? PlayState.campaignScore : PlayState.instance.songScore;
        totalMisses = PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.instance.songMisses;
        totalRating = PlayState.isStoryMode ? PlayState.campaignRating / PlayState.totalSongsPlayed : PlayState.instance.ratingPercent * 100;
        trace('${PlayState.campaignRating} / ${PlayState.totalSongsPlayed} = $totalRating');

        sick = PlayState.isStoryMode ? PlayState.campaignSicks : PlayState.instance.ratingsData[0].hits;
        good = PlayState.isStoryMode ? PlayState.campaignGoods : PlayState.instance.ratingsData[1].hits;
        bad = PlayState.isStoryMode ? PlayState.campaignBads : PlayState.instance.ratingsData[2].hits;
        shit = PlayState.isStoryMode ? PlayState.campaignShits : PlayState.instance.ratingsData[3].hits;

        if(PlayState.isStoryMode)
            yoinsEarnedOnSession = Std.int(PlayState.totalPlayedWeek * yoinsEarnMult);
        else
            yoinsEarnedOnSession = Std.int(PlayState.instance.totalPlayed * yoinsEarnMult);

        rank = new ResultsScreenRank(0, 0, getRankName());
        yoinsEarnedTxt = new Alphabet(0, 0, '+0 yoins', false);

        //FlxG.sound.playMusic(Paths.music(getRankName() == 'e' ? 'winScreenbad' : 'winScreen'));
        //Conductor.bpm = getRankName() == 'e' ? 100 : 127;

        var bgColor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        add(bgColor);

        bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFFCFC6F3);
        add(bg);

        lines = new FlxBackdrop(Paths.image('gallery/lines'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else XY #end);
        lines.velocity.set(75, 75);
        lines.antialiasing = ClientPrefs.data.antialiasing;
        add(lines);

        bgStripe = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/stripe'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        bgStripe.antialiasing = ClientPrefs.data.antialiasing;
        bgStripe.velocity.set(stripeSpeed, 0);
        bgStripe.blend = ADD;
        add(bgStripe);

        blackBackground = new FlxSprite();
        blackBackground.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        blackBackground.alpha = 0.5;
        add(blackBackground);

        whiteBackground = new FlxSprite();
        whiteBackground.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        whiteBackground.alpha = 0;
        add(whiteBackground);

        boyfriend = new Character(0, 300, '${CharSelectState.currentFreeplaySelectedName}-WinScreen');
        boyfriend.screenCenter(Y);
        boyfriend.y += 20;
        boyfriend.antialiasing = ClientPrefs.data.antialiasing;
        boyfriend.isPlayer = true;
        boyfriend.alpha = 0;
        if(CharSelectState.currentFreeplaySelectedName == 'pico') boyfriend.y += -40;

        boyfriend.animation.finishCallback = function(name:String)
        {
            boyfriend.playAnim('${name}loop');
        }
        add(boyfriend);

        bfIconLeft = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/icon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y #end);
        bfIconLeft.velocity.set(0, -iconSpeed);
        bfIconLeft.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconLeft);
        
        bfIconRight = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/icon'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else Y #end);
        bfIconRight.x = FlxG.width - bfIconRight.width;
        bfIconRight.velocity.set(0, iconSpeed);
        bfIconRight.antialiasing = ClientPrefs.data.antialiasing;
        add(bfIconRight);

        patternDown = new ResultsScreenPattern(0, 0);
        patternDown.darkPattern.velocity.set(patternSpeed, 0);
        patternDown.lightPattern.velocity.set(-patternSpeed, 0);
        patternDown.antialiasing = ClientPrefs.data.antialiasing;
        add(patternDown);

        patternUp = new ResultsScreenPattern(0, 0, true);
        patternUp.flipY = true;
        patternUp.darkPattern.velocity.set(-patternSpeed, 0);
        patternUp.lightPattern.velocity.set(patternSpeed, 0);
        patternUp.antialiasing = ClientPrefs.data.antialiasing;
        add(patternUp);

        board = new FlxSprite();
        board.loadGraphic(Paths.image('resultsScreen/newResultsScreen/board'));
        board.screenCenter();
        board.x += FlxG.width / 6;
        board.antialiasing = ClientPrefs.data.antialiasing;
        add(board);

        //boyfriend.x = board.x - 390;
        boyfriend.x = 0 - boyfriend.width - 100;
        FlxTween.tween(boyfriend, {x: board.x - 400}, 1.2, {ease: FlxEase.quartOut, startDelay: 0.25});

        scoreTxt = new FlxText(0, board.y + 30, 0, "SCORE: 0");
        scoreTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        scoreTxt.x = board.x + 25;
        scoreTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(scoreTxt);

        missesTxt = new FlxText(board.x + 30, scoreTxt.y, board.width - 80, "MISSES: 0");
        missesTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, RIGHT);
        missesTxt.x = board.x + 25;
        missesTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(missesTxt);

        ratingTxt = new FlxText(0, missesTxt.y + 45, 0, "RATING: 0%");
        ratingTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        ratingTxt.x = board.x + 25;
        ratingTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(ratingTxt);

        statsTxt = new FlxText(0, ratingTxt.y + 100, 0, "STATUS:");
        statsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 28, 0xFFB996D4, LEFT);
        statsTxt.x = board.x + 25;
        statsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(statsTxt);

        sicksTxt = new FlxText(0, statsTxt.y + 40, 0, "Sicks: 0");
        sicksTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        sicksTxt.x = board.x + 25;
        sicksTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(sicksTxt);

        goodsTxt = new FlxText(0, sicksTxt.y + 25, 0, "Goods: 0");
        goodsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        goodsTxt.x = board.x + 25;
        goodsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(goodsTxt);

        badsTxt = new FlxText(0, goodsTxt.y + 25, 0, "Bads: 0");
        badsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        badsTxt.x = board.x + 25;
        badsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(badsTxt);

        shitsTxt = new FlxText(0, badsTxt.y + 25, 0, "Shits: 0");
        shitsTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFFB996D4, LEFT);
        shitsTxt.x = board.x + 25;
        shitsTxt.antialiasing = ClientPrefs.data.antialiasing;
        add(shitsTxt);

        rank.x = board.x + board.width - rank.width - 30;
        rank.y = board.y + board.height - rank.height - 20;
        rank.antialiasing = ClientPrefs.data.antialiasing;
        rank.alpha = 0;
        add(rank);

        yoinsEarnedTxt.setScale(0.4, 0.4);
        yoinsEarnedTxt.x = board.x + 25;
        yoinsEarnedTxt.y = board.y + board.height - yoinsEarnedTxt.height - 30;
        yoinsEarnedTxt.antialiasing = ClientPrefs.data.antialiasing;
        yoinsEarnedTxt.alpha = 0;
        add(yoinsEarnedTxt);

        FlxTween.angle(rank, -5, 5, 4, {ease: FlxEase.quartInOut, type: PINGPONG});

        fullBlackBackground = new FlxSprite();
        fullBlackBackground.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        fullBlackBackground.alpha = 0;
        add(fullBlackBackground);

        ratingAnimData();
        bfAnimChoose();
        initTransition();
        //startBfAnim();

        new FlxTimer().start(2, (_) -> {
            var tweenDur:Float = 1.5;
            FlxG.sound.play(Paths.sound('resultsScreenScoreUp'));
            FlxTween.num(0, totalScore, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                scoreTxt.text = 'SCORE: ${Std.int(value)}';
                //FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
            });

            FlxTween.num(0, totalMisses, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                missesTxt.text = 'MISSES: ${Std.int(value)}';
            });

            FlxTween.num(0, totalRating, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                ratingTxt.text = 'RATING: ${FlxMath.roundDecimal(value, 2)}%';
            });

            FlxTween.num(0, sick, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                sicksTxt.text = 'Sicks: ${Std.int(value)}';
            });
            
            FlxTween.num(0, good, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                goodsTxt.text = 'Goods: ${Std.int(value)}';
            });
            
            FlxTween.num(0, bad, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                badsTxt.text = 'Bads: ${Std.int(value)}';
            });
            
            FlxTween.num(0, shit, tweenDur, {ease: FlxEase.linear}, function(value:Float)
            {
                shitsTxt.text = 'Shits: ${Std.int(value)}';
            });

            new FlxTimer().start(tweenDur + 0.4, (_) -> {
                startBeating = true;
                var musicPath:String = getRankName() == 'e' ? 'winScreenbad' : 'winScreen';
                musicPath += '-${CharSelectState.currentFreeplaySelectedName}';
                FlxG.sound.playMusic(Paths.music(musicPath));
                Conductor.bpm = getRankName() == 'e' ? 100 : 127;
                if(CharSelectState.currentFreeplaySelectedName == 'pico') Conductor.bpm = getRankName() == 'e' ? 100 : 105;

                if(getRankName() == 'e' && !picoMix)
                {
                    trace('curbeat 0');
                    FlxTween.cancelTweensOf(PlayState.instance.camOther.zoom);

                    PlayState.instance.camOther.zoom = 1.03;
                    FlxTween.tween(PlayState.instance.camOther, {zoom: 1}, Conductor.crochet / 1000, {ease: FlxEase.quartOut});
                }
            });
        });
    }

    var transDuration:Float = 0.7;
    function initTransition()
    {
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 1}, transDuration, {ease: FlxEase.quartOut});

        lines.alpha = 0;
        FlxTween.tween(lines, {alpha: 0.45}, 0.7);

        bgStripe.alpha = 0;
        FlxTween.tween(bgStripe, {alpha: 1}, 0.7);

        patternDown.y = FlxG.height;
        FlxTween.tween(patternDown, {y: FlxG.height - patternDown.height}, 1, {ease: FlxEase.expoOut});

        patternUp.y = 0 - patternUp.height;
        FlxTween.tween(patternUp, {y: 0}, 1, {ease: FlxEase.expoOut});
    }

    function getRankName():String
    {
        if (totalRating >= 90) return 's';
        if (totalRating >= 75) return 'a';
        if (totalRating >= 65) return 'b';
        if (totalRating >= 55) return 'c';
        if (totalRating >= 40) return 'd';
        return 'e';
    }

    function bfAnimChoose()
    {
        boyfriend.alpha = 1;
        boyfriend.playAnim('choose');
    }

    function startBfAnim()
    {
        boyfriend.alpha = 1;
        //ranks.alpha = 1;

        boyfriend.playAnim(bfAnimName);
        //ranks.animation.play(ratingName);
    }

    function ratingAnimData()
    {
        switch(getRankName())
        {
            case 's': bfAnimName = '90%'; ratingName = 'S';
            case 'a': bfAnimName = '75%'; ratingName = 'A';
            case 'b': bfAnimName = '65%'; ratingName = 'B';
            case 'c': bfAnimName = '55%'; ratingName = 'C';
            case 'd': bfAnimName = '0%'; ratingName = 'D';
            case 'e': bfAnimName = '0%'; ratingName = 'E';
            default: bfAnimName = '90%'; ratingName = 'S';
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.watch.addQuick("beatShit", curBeat);

        if(controls.BACK || controls.ACCEPT)
        {
            FlxTween.tween(fullBlackBackground, {alpha: 1}, 0.6);

            FlxTween.num(1, 4, 0.1, {ease: FlxEase.linear, onComplete: (_) -> {
                FlxTween.num(4, 0.1, 0.5, {ease: FlxEase.linear}, function(value:Float) {FlxG.sound.music.pitch = value;});    
            }}, function(value:Float) {FlxG.sound.music.pitch = value;});

            FlxTween.num(1, 0, 0.6, {ease: FlxEase.linear, onComplete: (_) -> {
                new FlxTimer().start(0.6,(_) -> {

                    ShopSubState.addMoney(yoinsEarnedOnSession);

		            trace('Earned ${ShopSubState.money} yoins!');

                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    if(OptionsState.playsSongFromOptions)
                    {
                        OptionsState.playsSongFromOptions = false;
                        BeatenSongs.beatSong('${Paths.formatToSongPath(PlayState.instance.curSong)}-${CharSelectState.currentFreeplaySelectedName}');

                        FlxTransitionableState.skipNextTransIn = true;
                        FlxTransitionableState.skipNextTransOut = true;
                        MusicBeatState.switchState(new OptionsState());
                    }
                    else
                    {
                        if(PlayState.isStoryMode)
                        {
                            var songs = backend.WeekData.getCurrentWeek().songs;
                            for(song in cast(songs, Array<Dynamic>))
                            {
                                trace('STORYMODE BEAT!');
                                BeatenSongs.beatSong('${Paths.formatToSongPath(song[0])}-${CharSelectState.currentFreeplaySelectedName}');
                            }
                            FlxTransitionableState.skipNextTransIn = true;
                            FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(new NewStoryMenuState());
                        }
                        else
                        {
                            BeatenSongs.beatSong('${Paths.formatToSongPath(PlayState.instance.curSong)}-${CharSelectState.currentFreeplaySelectedName}');

                            if(BeatenSongs.isSongBeaten('improbable-outset-bf') && BeatenSongs.isSongBeaten('madness-bf')) 
                            {
                                Achievements.unlock('beat_tricky');
                            }

                            FlxTransitionableState.skipNextTransIn = true;
                            FlxTransitionableState.skipNextTransOut = true;
                            MusicBeatState.switchState(new NewFreeplayState(CharSelectState.currentFreeplaySelectedName == 'pico'));
                        }
                    }
                });
            }}, function(value:Float)
            {
                FlxG.sound.music.volume = value;
            });
            
        }
    }

	var lastBeatHit:Int = -1;
    var sickBeats:Int = 1;
    var startBeating:Bool = false;
    
    function handlePicoBeats(beat:Int)
    {
        switch(beat)
        {
            case 4:
                FlxTween.tween(blackBackground, {alpha: 0.65}, Conductor.crochet / 1000, {ease: FlxEase.quartOut});
            case 5:
                startBfAnim();

                if(getRankName() == 'e')
                {
                    var pathSound = 'resultsScreenBadRanking';
                    FlxG.sound.play(Paths.sound(pathSound), 0.7);
                }
                else
                {
                    var pathSound = 'resultsScreenGoodRanking';
                    FlxG.sound.play(Paths.sound(pathSound), 0.7);
                }

                PlayState.instance.camOther.zoom = 1;

                boyfriend.scale.set(1.05, 1.05);
                FlxTween.tween(boyfriend, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.quartOut});
                FlxTween.angle(boyfriend, -3, 3, 3, {ease: FlxEase.cubeInOut, type: PINGPONG});
                FlxTween.tween(blackBackground, {alpha: getRankName() == 'e' ? 0.25 : 0}, 0.5);

                whiteBackground.alpha = 1;
                FlxTween.tween(whiteBackground, {alpha: 0}, 0.5);

                // rank anim
                rank.scale.set(0.01, 0.01);
                rank.alpha = 1;

                FlxTween.tween(rank, {"scale.x": 1.04, "scale.y": 1.04}, 0.3, {ease: FlxEase.quartOut, onComplete: (_) ->{
                    FlxTween.tween(rank, {"scale.x": 1, "scale.y": 1}, 0.3, {ease: FlxEase.quartInOut});
                }});

                if(PlayState.isStoryMode)
                    yoinsEarnedTxt.text = '+$yoinsEarnedOnSession yoins';
                else
                    yoinsEarnedTxt.text = '+$yoinsEarnedOnSession yoins';

                FlxTween.tween(yoinsEarnedTxt, {alpha: 1, y: yoinsEarnedTxt.y - 15}, 0.3, {ease: FlxEase.quartOut});
                new FlxTimer().start(2.05, function(tmr:FlxTimer)
                {
                    FlxTween.tween(yoinsEarnedTxt, {alpha: 0, y: yoinsEarnedTxt.y + 15}, 0.3, {ease: FlxEase.quartOut});
                });
        }
    }

    override function beatHit()
    {
        trace('BEAT HIT: ' + curBeat);

        if(startBeating) sickBeats++;
        trace('SIIIICK BEAT HIT: ' + sickBeats);
        if(picoMix)
            handlePicoBeats(sickBeats);
        else
        {
            switch(sickBeats)
            {
                case 2 | 3:
                    if(getRankName() != 'e') return;

                    trace('curbeat $sickBeats');

                    FlxTween.cancelTweensOf(PlayState.instance.camOther.zoom);

                    PlayState.instance.camOther.zoom = 1.03;
                    FlxTween.tween(PlayState.instance.camOther, {zoom: 1}, Conductor.crochet / 1000, {ease: FlxEase.quartOut});

                    if(sickBeats == 3)
                    {
                        startBfAnim();

                        var pathSound = 'resultsScreenBadRanking';
                        FlxG.sound.play(Paths.sound(pathSound), 0.7);

                        boyfriend.scale.set(1.05, 1.05);
                        FlxTween.tween(boyfriend, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.quartOut});
                        FlxTween.angle(boyfriend, -3, 3, 3, {ease: FlxEase.cubeInOut, type: PINGPONG});
                        FlxTween.tween(blackBackground, {alpha: getRankName() == 'e' ? 0.25 : 0}, 0.5);

                        whiteBackground.alpha = 1;
                        FlxTween.tween(whiteBackground, {alpha: 0}, 0.5);

                        // rank anim
                        rank.scale.set(0.01, 0.01);
                        rank.alpha = 1;

                        FlxTween.tween(rank, {"scale.x": 1.04, "scale.y": 1.04}, 0.3, {ease: FlxEase.quartOut, onComplete: (_) ->{
                            FlxTween.tween(rank, {"scale.x": 1, "scale.y": 1}, 0.3, {ease: FlxEase.quartInOut});
                        }});

                        if(PlayState.isStoryMode)
                            yoinsEarnedTxt.text = '+$yoinsEarnedOnSession yoins';
                        else
                            yoinsEarnedTxt.text = '+$yoinsEarnedOnSession yoins';

                        FlxTween.tween(yoinsEarnedTxt, {alpha: 1, y: yoinsEarnedTxt.y - 10}, 0.3, {ease: FlxEase.quartOut});
                        new FlxTimer().start(2.05, function(tmr:FlxTimer)
                        {
                            FlxTween.tween(yoinsEarnedTxt, {alpha: 0, y: yoinsEarnedTxt.y + 10}, 0.3, {ease: FlxEase.quartOut});
                        });
                    }
                case 5:
                    if(getRankName() == 'e') return;

                    startBfAnim();

                    var pathSound = 'resultsScreenGoodRanking';
                    FlxG.sound.play(Paths.sound(pathSound), 0.7);

                    boyfriend.scale.set(1.05, 1.05);
                    FlxTween.tween(boyfriend, {"scale.x": 1, "scale.y": 1}, 1, {ease: FlxEase.quartOut});
                    FlxTween.angle(boyfriend, -3, 3, 3, {ease: FlxEase.cubeInOut, type: PINGPONG});
                    FlxTween.tween(blackBackground, {alpha: getRankName() == 'e' ? 0.25 : 0}, 0.5);

                    whiteBackground.alpha = 1;
                    FlxTween.tween(whiteBackground, {alpha: 0}, 0.5);

                    // rank anim
                    rank.scale.set(0.01, 0.01);
                    rank.alpha = 1;

                    FlxTween.tween(rank, {"scale.x": 1.04, "scale.y": 1.04}, 0.3, {ease: FlxEase.quartOut, onComplete: (_) ->{
                        FlxTween.tween(rank, {"scale.x": 1, "scale.y": 1}, 0.3, {ease: FlxEase.quartInOut});
                    }});

                    if(PlayState.isStoryMode)
                        yoinsEarnedTxt.text = '+$yoinsEarnedOnSession yoins';
                    else
                        yoinsEarnedTxt.text = '+$yoinsEarnedOnSession yoins';

                    FlxTween.tween(yoinsEarnedTxt, {alpha: 1, y: yoinsEarnedTxt.y - 10}, 0.3, {ease: FlxEase.quartOut});
                    new FlxTimer().start(2.05, function(tmr:FlxTimer)
                    {
                        FlxTween.tween(yoinsEarnedTxt, {alpha: 0, y: yoinsEarnedTxt.y + 10}, 0.3, {ease: FlxEase.quartOut});
                    });
            }
        }

        super.beatHit();
    }
}

/**
 * Lettabox
 */
class ResultsScreenPattern extends FlxSpriteGroup
{
    public var darkPattern:FlxBackdrop;
    public var lightPattern:FlxBackdrop;

    public function new(x:Float, y:Float, flipPatternY:Bool = false)
    {
        super(x, y);

        darkPattern = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/lettaBoxDark'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        darkPattern.antialiasing = ClientPrefs.data.antialiasing;
        add(darkPattern);

        lightPattern = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/lettaBoxLight'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        lightPattern.y = flipPatternY ? darkPattern.y : darkPattern.y + darkPattern.height - lightPattern.height;
        lightPattern.antialiasing = ClientPrefs.data.antialiasing;
        add(lightPattern);
    }
}

class ResultsScreenRank extends FlxSprite
{
    public function new(x:Float, y:Float, rank:String)
    {
        super(x, y);

        if(rank == null || rank == '') rank = 's'; // duh avoiding silly crashes

        var gFrames = Paths.getSparrowAtlas('resultsScreen/newResultsScreen/ranks');
        //var iSize = Math.round(graphic.width / graphic.height);
        //loadGraphic(graphic, true, 228, 232);
        frames = gFrames;

		animation.addByPrefix(rank, rank, 24, false, false);
		animation.play(rank);
    }
}