package states;

import flixel.addons.display.FlxBackdrop;
import states.FreeplayState.SongMetadata;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

class NewFreeplayState extends MusicBeatState
{
    private static var curSelected:Int = 0;
	private static var lastDifficultyName:String = Difficulty.getDefault();
	var curDifficulty:Int = -1;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songs:Array<SongMetadata> = [];
    var background:FlxSprite;
    var checker:FlxBackdrop;
    var backgroundLight:FlxSprite;
    var backgroundHint:FlxSprite;
    var hint:FlxBackdrop;
    var backgroundDiff:FlxSprite;
    var backgroundDiffLight:FlxSprite;
    var poloUp:FlxSprite;
    var poloDown:FlxSprite;
    var bombox:FlxSprite;
    var character:FlxSprite;
    var grpSongs:FlxTypedGroup<FreeplayCapsule>;
    var scoreText:FlxText;
    var difText:FlxSprite;

	public var isPicoMix:Bool = false;
	public function new(_isPicoMix:Bool = false)
	{
		isPicoMix = _isPicoMix;
		super();
	}

    override function create()
    {
        super.create();

		if(FlxG.sound.music != null)
		{
			if(!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.music.fadeIn(1);
			}
		}
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				if(!isPicoMix) addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				else
				{
					if(!song[3]) continue;
					addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				}
			}
		}
		Mods.loadTopMod();

        background = new FlxSprite();
        //background.loadGraphic(Paths.image('freePlay/NEW/background'));
        background.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
        background.antialiasing = ClientPrefs.data.antialiasing;
        background.color = 0xFFE7E0FF;
        add(background);

        backgroundLight = new FlxSprite();
        backgroundLight.loadGraphic(Paths.image('freePlay/NEW/backgroundlight'));
        backgroundLight.antialiasing = ClientPrefs.data.antialiasing;
        add(backgroundLight);

        checker = new FlxBackdrop(Paths.image('freePlay/NEW/checker'));
        checker.antialiasing = ClientPrefs.data.antialiasing;
        checker.velocity.set(15, 15);
        add(checker);

		grpSongs = new FlxTypedGroup<FreeplayCapsule>();
		add(grpSongs);

        backgroundHint = new FlxSprite();
        backgroundHint.loadGraphic(Paths.image('freePlay/NEW/backgroundHint'));
        backgroundHint.y = FlxG.height - backgroundHint.height;
        backgroundHint.antialiasing = ClientPrefs.data.antialiasing;
        add(backgroundHint);

        hint = new FlxBackdrop(Paths.image('freePlay/NEW/hint'), X, 35);
        hint.antialiasing = ClientPrefs.data.antialiasing;
        hint.y = backgroundHint.y + 19;
        hint.velocity.set(-40, 0);
        hint.screenCenter(X);
        add(hint);
        
        bombox = new FlxSprite(705, 315);
        bombox.frames = Paths.getSparrowAtlas('freePlay/NEW/char/${CharSelectState.currentFreeplaySelectedName}/bombox');
        bombox.animation.addByPrefix('idle', 'idle', 12, false);
        bombox.animation.play('idle', true, true);
        bombox.antialiasing = ClientPrefs.data.antialiasing;
        if(CharSelectState.currentFreeplaySelectedName == 'pico') bombox.y += -95;
        add(bombox);

        backgroundDiff = new FlxSprite(695, 12);
        backgroundDiff.loadGraphic(Paths.image('freePlay/NEW/backgroundDiff'));
        backgroundDiff.antialiasing = ClientPrefs.data.antialiasing;
        add(backgroundDiff);

        difText = new FlxSprite(0, 55);
        difText.loadGraphic(Paths.image('freePlay/NEW/diff/hard'));
        add(difText);

        backgroundDiffLight = new FlxSprite();
        backgroundDiffLight.loadGraphic(Paths.image('freePlay/NEW/light'));
        backgroundDiffLight.antialiasing = ClientPrefs.data.antialiasing;
        backgroundDiffLight.blend = ADD;
        add(backgroundDiffLight);

        poloUp = new FlxSprite();
        poloUp.loadGraphic(Paths.image('freePlay/NEW/poloUp'));
        poloUp.antialiasing = ClientPrefs.data.antialiasing;
        add(poloUp);

        poloDown = new FlxSprite();
        poloDown.loadGraphic(Paths.image('freePlay/NEW/poloDown'));
        poloDown.antialiasing = ClientPrefs.data.antialiasing;
        poloDown.y = FlxG.height - poloDown.height;
        poloDown.screenCenter(X);
        add(poloDown);

        character = new FlxSprite(895, 390);
        character.frames = Paths.getSparrowAtlas('freePlay/NEW/char/${CharSelectState.currentFreeplaySelectedName}/char');
        character.animation.addByPrefix('idle', 'coso', 24, false);
        character.animation.play('idle', true);
        character.antialiasing = ClientPrefs.data.antialiasing;
        add(character);

        scoreText = new FlxText(0, 0, 0, 'Score: 0');
        scoreText.setFormat(Paths.font('GAU_pop_magic.ttf'), 28, 0xFFFFFFFF);
        scoreText.x = backgroundDiff.x + 130;
        scoreText.y = backgroundDiff.y + backgroundDiff.height - scoreText.height - 10;
        add(scoreText);

        for(i in 0...songs.length)
        {
            var capsule = new FreeplayCapsule(0, 0, songs[i].songName, songs[i].songCharacter);
			capsule.targetX = i;
			capsule.targetY = i;
            capsule.x = 120;
            capsule.screenCenter(Y);
            capsule.y += 40;
            capsule.startPosition.x = capsule.x;
            capsule.startPosition.y = capsule.y;
			capsule.snapToPosition();
            grpSongs.add(capsule);
        }

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
        changeSelect(0, true);

        initTransition();
    }

    var transitionDuration:Float = 0.5;
    var transitionHintDelay:Float = 0.4;
    function initTransition()
    {
        checker.alpha = 0;
        FlxTween.tween(checker, {alpha: 1}, transitionDuration, {ease: FlxEase.expoOut});
    
        poloUp.y = 0 - poloUp.height;
        FlxTween.tween(poloUp, {y: 0}, transitionDuration, {ease: FlxEase.expoOut});

        poloDown.y = FlxG.height;
        FlxTween.tween(poloDown, {y: FlxG.height - poloDown.height}, transitionDuration, {ease: FlxEase.expoOut});

        backgroundHint.y = FlxG.height;
        FlxTween.tween(backgroundHint, {y: FlxG.height - backgroundHint.height}, transitionDuration, {ease: FlxEase.expoOut, startDelay: transitionHintDelay});

        hint.y = FlxG.height;
        FlxTween.tween(hint, {y: FlxG.height - backgroundHint.height + 16}, transitionDuration, {ease: FlxEase.expoOut, startDelay: transitionHintDelay});

        backgroundDiff.y = 12 - backgroundDiff.height;
        FlxTween.tween(backgroundDiff, {y: 12}, transitionDuration, {ease: FlxEase.expoOut});

        difText.y = 55 - difText.height;
        difText.alpha = 0;
        FlxTween.tween(difText, {y: 55, alpha: 1}, transitionDuration, {ease: FlxEase.expoOut});

        backgroundDiffLight.y = -300;
        FlxTween.tween(backgroundDiffLight, {y: 0}, transitionDuration, {ease: FlxEase.expoOut});

        scoreText.y = backgroundDiff.y + backgroundDiff.height - scoreText.height - 10;
        FlxTween.tween(scoreText, {y: 12 + backgroundDiff.height - scoreText.height - 10}, transitionDuration, {ease: FlxEase.expoOut});

        bombox.x = FlxG.width;
        FlxTween.tween(bombox, {x: 705}, transitionDuration, {ease: FlxEase.expoOut});

        character.x = FlxG.width + (895 - 705);
        FlxTween.tween(character, {x: 895}, transitionDuration, {ease: FlxEase.expoOut});

		for (num => item in grpSongs.members)
        {
            item.x -= 500;
        }
    }

	var stopMusicPlay:Bool = false;
    var canInteract:Bool = true;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = 'Score: $lerpScore';

        if(canInteract)
        {
            if(controls.UI_UP_P)
            {
                changeSelect(-1);
            }

            if(controls.UI_DOWN_P)
            {
                changeSelect(1);
            }

            if(controls.UI_LEFT_P)
            {
                changeDiff(-1);
                _updateSongLastDifficulty();
            }

            if(controls.UI_RIGHT_P)
            {
                changeDiff(1);
                _updateSongLastDifficulty();
            }

            if(controls.BACK)
            {
                canInteract = false;
                FlxG.sound.play(Paths.sound('cancelMenu'));

                FlxTween.cancelTweensOf(background);
                FlxTween.cancelTweensOf(checker);
                FlxTween.cancelTweensOf(poloUp);
                FlxTween.cancelTweensOf(poloDown);
                FlxTween.cancelTweensOf(backgroundHint);
                FlxTween.cancelTweensOf(hint);
                FlxTween.cancelTweensOf(backgroundDiff);
                FlxTween.cancelTweensOf(difText);
                FlxTween.cancelTweensOf(scoreText);
                FlxTween.cancelTweensOf(bombox);
                FlxTween.cancelTweensOf(character);

                grpSongs.forEach(function(cap:FreeplayCapsule)
                {
                    cap.copyPositions = false;
                    FlxTween.cancelTweensOf(cap);
                    //cap.startPosition.x += -700;
                    FlxTween.tween(cap, {x: cap.x - 700}, transitionDuration, {ease: FlxEase.expoIn});
                });

                FlxTween.color(background, transitionDuration, background.color, 0xFFBFB4F1, {ease: FlxEase.expoIn});

                FlxTween.tween(checker, {alpha: 0}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(poloUp, {y: 0 - poloUp.height}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(poloDown, {y: FlxG.height}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(backgroundHint, {y: FlxG.height}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(hint, {y: FlxG.height}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(backgroundDiff, {y: -backgroundDiff.height}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(difText, {y: -backgroundDiff.height + 60}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(backgroundDiffLight, {y: -backgroundDiff.height}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(scoreText, {y: -backgroundDiff.height + 230}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(bombox, {x: FlxG.width}, transitionDuration, {ease: FlxEase.expoIn});
                FlxTween.tween(character, {x: FlxG.width + (895 - 705)}, transitionDuration, {ease: FlxEase.expoIn});

                new FlxTimer().start(transitionDuration, function(tmr:FlxTimer)
                {
                    FlxTransitionableState.skipNextTransIn = true;
                    FlxTransitionableState.skipNextTransOut = true;
                    MusicBeatState.switchState(new MainMenuState());
                });
            }

            if(controls.ACCEPT)
            {
                canInteract = false;
                persistentUpdate = false;
                var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
                var poop:String = Highscore.formatSong(songLowercase + '-' + CharSelectState.currentFreeplaySelectedName, curDifficulty);

                try
                {
                    Song.loadFromJson(poop, songLowercase);
                    trace('Loading song: $poop');
                    PlayState.isStoryMode = false;
                    PlayState.storyDifficulty = curDifficulty;

                    trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
                }
                catch(e:haxe.Exception)
                {
                    super.update(elapsed);
                    return;
                }

                @:privateAccess
                if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
                {
                    trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
                    Paths.freeGraphicsFromMemory();
                }
                #if !debug LoadingState.prepareToSong(); #end
                LoadingState.loadAndSwitchState(new PlayState());
                #if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
                stopMusicPlay = true;

                #if (MODS_ALLOWED && DISCORD_ALLOWED)
                DiscordClient.loadModRPC();
                #end
            }

            if(FlxG.keys.justPressed.TAB)
            {
                if(MusicBeatState.timePassedOnState < 0.8) return;

                canInteract = false;
                FlxG.sound.music.fadeOut(0.1, 0, function(twn:FlxTween) {FlxG.sound.music.stop();});
                MusicBeatState.switchStateIcon(new CharSelectState(), CharSelectState.currentFreeplaySelectedName, 0.8);
            }
        }
    }

    function changeSelect(change:Int = 0, firstTime:Bool = false)
    {
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
        
		for (num => item in grpSongs.members)
		{
			item.targetY = num - curSelected;
			item.targetX = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
            if(firstTime) item.snapToPosition();
		}

		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();

		changeDiff();
		_updateSongLastDifficulty();
    }

	function changeDiff(change:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);
        difText.loadGraphic(Paths.image('freePlay/NEW/diff/$displayDiff'));
        difText.x = 1020 - difText.width / 2;
        difText.y = 55;
        if(change != 0)
        {
            difText.y += 10;
            difText.alpha = 0;
            FlxTween.tween(difText, {alpha: 1, y: 55}, 0.1, {ease: FlxEase.quartOut});
        }
	}

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

    override function beatHit()
    {
        super.beatHit();

        bombox.animation.play('idle', true, true);
        character.animation.play('idle', true);
    }

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}
}

class FreeplayCapsule extends FlxSpriteGroup
{
    public var targetX:Float = 0;
    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(120, 230);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    public var copyPositions:Bool = true;

    public var background:FlxSprite;
    public var text:FlxText;
    public var icon:FlxSprite;
    public function new(x:Float, y:Float, songName:String, songCharacter:String)
    {
        super(x, y);

        background = new FlxSprite();
        background.loadGraphic(Paths.image('freePlay/NEW/capsule'));
        background.antialiasing = ClientPrefs.data.antialiasing;
        add(background);

        text = new FlxText(0, 0, background.width, songName, 28);
        text.setFormat(Paths.font('GAU_pop_magic.ttf'), 28, 0xFFFFFFFF);
        text.x += 70;
        text.y += background.height / 2 - text.height / 2 - 10;
        text.antialiasing = ClientPrefs.data.antialiasing;
        add(text);

        icon = new FlxSprite();
        icon.loadGraphic(Paths.image('freePlay/NEW/icons/$songCharacter'));
        icon.y += -(icon.height / 2) + 10;
        icon.x += -(icon.width / 2) + 5;
        icon.scale.set(0.8, 0.8);
        icon.antialiasing = ClientPrefs.data.antialiasing;
        add(icon);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpVal:Float = Math.exp(-elapsed * 9.6);

        var realTargetX = targetX;
        if(realTargetX > 0) realTargetX *= -1;

        if(copyPositions)
        {
            x = FlxMath.lerp((realTargetX * distancePerItem.x) + startPosition.x, x, lerpVal);
            y = FlxMath.lerp((targetY * distancePerItem.y) + startPosition.y, y, lerpVal);
        }
    }

    public function snapToPosition()
    {
        var realTargetX = targetX;
        if(realTargetX > 0) realTargetX *= -1;

        x = startPosition.x + (realTargetX * distancePerItem.x);
        y = startPosition.y + (targetY * distancePerItem.y);
    }
}