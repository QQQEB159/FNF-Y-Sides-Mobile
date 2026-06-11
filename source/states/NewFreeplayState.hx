package states;

import flixel.addons.display.FlxBackdrop;
import states.FreeplayState.SongMetadata;

import options.OptionsState;
import backend.BeatenSongs;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

enum SongCategory
{
    OG;
    MODS;
}

typedef FreeplayTransProperties = {
    initialProperties:Map<String, Dynamic>,
    tweenProperties:Dynamic,
    // Listen, I KNOW I could make this a TweenOptions field, but who gives a shit?
    // Every option in each tween has the same ease, the only thing that changes is the delay. Fuck it!
    // -Dyscarn
    tweenDelay:Float,
}

class NewFreeplayState extends MusicBeatState
{
    private static var curSelected:Int = 0;
    private static var curCategory:SongCategory = OG;
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
    var categoryBackground:FlxSprite;
    var categoryOg:FlxSprite;
    var categoryDot:FlxSprite;
    var categoryMods:FlxSprite;
    var qeSwitch:FlxSprite;
    var poloUp:FlxSprite;
    var poloDown:FlxSprite;
    var bombox:FlxSprite;
    var character:FlxSprite;
    var grpSongs:FlxTypedGroup<FreeplayCapsule>;
    var scoreText:FlxText;
    var difText:FlxSprite;

    public static var unlockedModSongs:Map<String, Bool> = [
        'Improbable Outset' => false,
        'Madness' => false,
        'R.A.M' => false,
        'Returny' => false
    ];

    public var moddedSongs:Bool = true;
	public var isPicoMix:Bool = false;
    public var unlockedPico:Bool = false;
	public function new(_isPicoMix:Bool = false)
	{
		isPicoMix = _isPicoMix;
		super();
	}

    override function create()
    {
        super.create();

        OptionsState.playsSongFromOptions = false;

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
		BeatenSongs.init();

        unlockedPico = ShopSubState.isItemUnlocked('Picostola');

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
				if(!isPicoMix) 
                {
                    // modded songs (maybe you hate this code, but i won't change it)
                    // so your eyes can bleed ;) (and mine too)
                    if(song[4] != null)
                    {
                        // quick explanation so there's no lose
                        // when this equals '' it means no item has to be unlocked, so basically the song just appears.
                        // if you have something inside, like ':sob:' then you have to unlock :sob: to play the song.
                        // and now i'm wondering who's gonna read this like i'm the only coder who writes this shit
                        if(song[4] != '')
                        {
                            unlockedModSongs.set(song[0], ShopSubState.isItemUnlocked(song[4]));
                            if(!unlockedModSongs.get(song[0])) continue;
                            addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                        }
                        else
                        {
                            addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                        }
                    }
                    else
                    {
                        // just ignore that shitty code up there right? i love you y sides main content, fuck mods. -madera <3
                        addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                    }
                }
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
        transOptions.set(checker, {
            initialProperties: [
                "alpha" => 0
            ],
            tweenProperties: {
                alpha: 1,
            },
            tweenDelay: 0
        });
        backOptions.set(checker, {
            alpha: 0
        });
        add(checker);

		grpSongs = new FlxTypedGroup<FreeplayCapsule>();
		add(grpSongs);

        backgroundHint = new FlxSprite();
        backgroundHint.loadGraphic(Paths.image('freePlay/NEW/backgroundHint'));
        backgroundHint.y = FlxG.height - backgroundHint.height;
        backgroundHint.antialiasing = ClientPrefs.data.antialiasing;
        transOptions.set(backgroundHint, {
            initialProperties: [
                "y" => FlxG.height, // I know height could be dynamic, but since the game is locked at 1280x720, who cares? -Dyscarn
            ],
            tweenProperties: {
                y: FlxG.height - backgroundHint.height
            },
            tweenDelay: transitionHintDelay
        });
        backOptions.set(backgroundHint, {
            y: FlxG.height
        });
        add(backgroundHint);

        if(unlockedPico) hint = new FlxBackdrop(Paths.image('freePlay/NEW/hint'), X, 35);
        else hint = new FlxBackdrop(Paths.image('freePlay/NEW/hint2'), X, 35);
        hint.antialiasing = ClientPrefs.data.antialiasing;
        hint.y = backgroundHint.y + 19;
        hint.velocity.set(-40, 0);
        hint.screenCenter(X);
        transOptions.set(hint, {
            initialProperties: [
                "y" => FlxG.height
            ],
            tweenProperties: {
                y: FlxG.height - backgroundHint.height + 16
            },
            tweenDelay: transitionHintDelay
        });
        backOptions.set(hint, {
            y: FlxG.height
        });
        add(hint);
        
        bombox = new FlxSprite(705, 315);
        bombox.frames = Paths.getSparrowAtlas('freePlay/NEW/char/${CharSelectState.currentFreeplaySelectedName}/bombox');
        bombox.animation.addByPrefix('idle', 'idle', 12, false);
        bombox.animation.play('idle', true, true);
        bombox.antialiasing = ClientPrefs.data.antialiasing;
        if(CharSelectState.currentFreeplaySelectedName == 'pico') bombox.y += -95;
        transOptions.set(bombox, {
            initialProperties: [
                "x" => FlxG.width
            ],
            tweenProperties: {
                x: 705
            },
            tweenDelay: 0
        });
        backOptions.set(bombox, {
            x: FlxG.width
        });
        add(bombox);

        backgroundDiff = new FlxSprite(695, 12);
        backgroundDiff.loadGraphic(Paths.image('freePlay/NEW/backgroundDiff'));
        backgroundDiff.antialiasing = ClientPrefs.data.antialiasing;
        transOptions.set(backgroundDiff, {
            initialProperties: [
                "y" => 12 - backgroundDiff.height
            ],
            tweenProperties: {
                y: 12
            },
            tweenDelay: 0
        });
        backOptions.set(backgroundDiff, {
            y: -backgroundDiff.height
        });
        add(backgroundDiff);

        difText = new FlxSprite(0, 55);
        difText.loadGraphic(Paths.image('freePlay/NEW/diff/hard'));
        transOptions.set(difText, {
            initialProperties: [
                "y" => 12 - backgroundDiff.height,
                "alpha" => 0
            ],
            tweenProperties: {
                y: 55,
                alpha: 1
            },
            tweenDelay: 0
        });
        backOptions.set(difText, {
            y: -backgroundDiff.height + 60
        });
        add(difText);

        backgroundDiffLight = new FlxSprite();
        backgroundDiffLight.loadGraphic(Paths.image('freePlay/NEW/light'));
        backgroundDiffLight.antialiasing = ClientPrefs.data.antialiasing;
        backgroundDiffLight.blend = ADD;
        transOptions.set(backgroundDiffLight, {
            initialProperties: [
                "y" => -300
            ],
            tweenProperties: {
                y: 0
            },
            tweenDelay: 0
        });
        backOptions.set(backgroundDiffLight, {
            y: -backgroundDiff.height
        });
        add(backgroundDiffLight);
        
        poloUp = new FlxSprite();
        poloUp.loadGraphic(Paths.image('freePlay/NEW/poloUp'));
        poloUp.antialiasing = ClientPrefs.data.antialiasing;
        transOptions.set(poloUp, {
            initialProperties: [
                "y" => 0 - poloUp.height
            ],
            tweenProperties: {
                y: 0
            },
            tweenDelay: 0
        });
        backOptions.set(poloUp, {
            y: 0 - poloUp.height
        });

        categoryBackground = new FlxSprite();
        categoryBackground.loadGraphic(Paths.image('freePlay/NEW/categorySelectorBackground'));
        categoryBackground.x = 0;
        transOptions.set(categoryBackground, {
            initialProperties: [
                "y" => -poloUp.height + 55
            ],
            tweenProperties: {
                y: 55
            },
            tweenDelay: 0
        });
        backOptions.set(categoryBackground, {
            y: -poloUp.height + 55
        });
        add(categoryBackground);

        categoryOg = new FlxSprite();
        categoryOg.loadGraphic(Paths.image('freePlay/NEW/categoryOg'));
        categoryOg.antialiasing = ClientPrefs.data.antialiasing;
        categoryOg.x = 120;
        transOptions.set(categoryOg, {
            initialProperties: [
                "y" => -poloUp.height + 55
            ],
            tweenProperties: {
                y: 55 + (categoryBackground.height / 2) - (categoryOg.height / 2)
            },
            tweenDelay: 0.03
        });
        backOptions.set(categoryOg, {
            y: -poloUp.height + 55
        });
        add(categoryOg);

        categoryDot = new FlxSprite();
        categoryDot.loadGraphic(Paths.image('freePlay/NEW/categoryDot'));
        categoryDot.antialiasing = ClientPrefs.data.antialiasing;
        categoryDot.x = 250;
        transOptions.set(categoryDot, {
            initialProperties: [
                "y" => -poloUp.height + 55
            ],
            tweenProperties: {
                y: 55 + (categoryBackground.height / 2) - (categoryDot.height / 2)
            },
            tweenDelay: 0.06
        });
        backOptions.set(categoryDot, {
            y: -poloUp.height + 55
        });
        add(categoryDot);

        categoryMods = new FlxSprite();
        categoryMods.loadGraphic(Paths.image('freePlay/NEW/categoryMods'));
        categoryMods.antialiasing = ClientPrefs.data.antialiasing;
        categoryMods.x = 290;
        transOptions.set(categoryMods, {
            initialProperties: [
                "y" => -poloUp.height + 55
            ],
            tweenProperties: {
                y: 55 + (categoryBackground.height / 2) - (categoryMods.height / 2)
            },
            tweenDelay: 0.09
        });
        backOptions.set(categoryMods, {
            y: -poloUp.height + 55
        });
        add(categoryMods);

        qeSwitch = new FlxSprite();
        qeSwitch.loadGraphic(Paths.image('freePlay/NEW/qeswitch'));
        qeSwitch.antialiasing = ClientPrefs.data.antialiasing;
        qeSwitch.x = FlxG.width - qeSwitch.width - 10;
        qeSwitch.y = 290;
        qeSwitch.alpha = 0;
        add(qeSwitch);

        add(poloUp);

        poloDown = new FlxSprite();
        poloDown.loadGraphic(Paths.image('freePlay/NEW/poloDown'));
        poloDown.antialiasing = ClientPrefs.data.antialiasing;
        poloDown.y = FlxG.height - poloDown.height;
        poloDown.screenCenter(X);
        transOptions.set(poloDown, {
            initialProperties: [
                "y" => FlxG.height
            ],
            tweenProperties: {
                y: FlxG.height - poloDown.height
            },
            tweenDelay: 0
        });
        backOptions.set(poloDown, {
            y: FlxG.height
        });
        add(poloDown);

        character = new FlxSprite(895, 390);
        character.frames = Paths.getSparrowAtlas('freePlay/NEW/char/${CharSelectState.currentFreeplaySelectedName}/char');
        character.animation.addByPrefix('idle', 'coso', 24, false);
        character.animation.play('idle', true);
        character.antialiasing = ClientPrefs.data.antialiasing;
        backOptions.set(character, {
            x: FlxG.width
        });
        add(character);

        scoreText = new FlxText(0, 0, 0, 'Score: 0');
        scoreText.setFormat(Paths.font('GAU_pop_magic.ttf'), 28, 0xFFFFFFFF);
        scoreText.x = backgroundDiff.x + 130;
        scoreText.y = backgroundDiff.y + backgroundDiff.height - scoreText.height - 10;
        transOptions.set(scoreText, {
            initialProperties: [
                "y" => 12 - scoreText.height - 10
            ],
            tweenProperties: {
                y: 12 + backgroundDiff.height - scoreText.height - 10
            },
            tweenDelay: 0
        });
        backOptions.set(scoreText, {
            y: -backgroundDiff.height + 230
        });
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

            var fullSongName = '${Paths.formatToSongPath(songs[i].songName)}-${CharSelectState.currentFreeplaySelectedName}';
            capsule.isNewSong = (!BeatenSongs.isSongBeaten(fullSongName) && BeatenSongs.isSongNew(fullSongName));
            grpSongs.add(capsule);
        }
        
        moddedSongs = hasModdedSongs();
        if(!moddedSongs)
        {
            categoryBackground.visible = false;
            categoryOg.visible = false;
            categoryDot.visible = false;
            categoryMods.visible = false;
            qeSwitch.visible = false;
        }
        
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
        changeCategory(moddedSongs ? curCategory : OG, false);
        changeSelect(0, true);

        initTransition();
    }

    public function hasModdedSongs():Bool
    {
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
				if(!isPicoMix) 
                {
                    if(song[4] == null) continue;
                    if(song[4] == '')
                    {
                        return true;
                    }

                    if(song[4] != '')
                    {
                        unlockedModSongs.set(song[0], ShopSubState.isItemUnlocked(song[4]));
                        if(unlockedModSongs.get(song[0])) return true;
                    }
                }
				else
				{
					if(!song[3]) continue; // pico mix thingie

                    if(song[4] == null) continue;
                    if(song[4] == '')
                    {
                        return true;
                    }

                    if(song[4] != '')
                    {
                        unlockedModSongs.set(song[0], ShopSubState.isItemUnlocked(song[4]));
                        if(unlockedModSongs.get(song[0])) return true;
                    }
				}
			}
		}
        return false;
    }

    var transitionDuration:Float = 0.5;
    var transitionHintDelay:Float = 0.4;
    final transOptions:Map<FlxSprite, FreeplayTransProperties> = new Map<FlxSprite, FreeplayTransProperties>();
    function initTransition()
    {
        for(object in transOptions.keys())
        {
            final info:FreeplayTransProperties = transOptions.get(object);

            if(info.initialProperties != null)
                for(key in info.initialProperties.keys()) {
                    final value:Dynamic = info.initialProperties.get(key);
                    if (key == "x")
                        object.x = value;
                    else if(key == "y")
                        object.y = value;
                    else
                        // WHY can Reflect NOT read `x` and `y` properties of an FlxSprite??? FUCK REFLECT!!1! -Dyscarn
                        Reflect.setProperty(object, key, value);
                }

            FlxTween.tween(object, info.tweenProperties, {ease: FlxEase.expoOut, startDelay: info.tweenDelay ?? 0});
        }

        character.x = FlxG.width + (895 - 705);
        FlxTween.tween(character, {x: CharSelectState.currentFreeplaySelectedName == 'bf' ? 895 : 845}, transitionDuration, {ease: FlxEase.expoOut});

		for (num => item in grpSongs.members)
            item.x -= 500;
    }

    var tinyScale:Float = 0.85;
    var tinyAlpha:Float = 0.75;
    function changeCategory(targetCategory:SongCategory = OG, playSound:Bool = true)
    {
        if(!moddedSongs) targetCategory = OG;

        switch(targetCategory)
        {
            case OG:
                targetScaleOg = 1;
                targetAlphaOg = 1;
                targetScaleMods = tinyScale;
                targetAlphaMods = tinyAlpha;
            case MODS:
                targetScaleOg = tinyScale;
                targetAlphaOg = tinyAlpha;
                targetScaleMods = 1;
                targetAlphaMods = 1;
        }

        // if(curCategory == targetCategory) return;

        curCategory = targetCategory;
        reloadSongsList(targetCategory);

        if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    function reloadSongsList(category:SongCategory)
    {
        songs = [];
        grpSongs.forEach(function(cap:FreeplayCapsule)
        {
            cap.destroy();
        });
        grpSongs.clear();

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
				if(!isPicoMix) 
                {
                    switch(category)
                    {
                        // modded songs (maybe you hate this code, but i won't change it)
                        // so your eyes can bleed ;) (and mine too)
                        case MODS:
                            // quick explanation so there's no lose
                            // when this equals '' it means no item has to be unlocked, so basically the song just appears.
                            // if you have something inside, like ':sob:' then you have to unlock :sob: to play the song.
                            // and now i'm wondering who's gonna read this like i'm the only coder who writes this shit
                            if(song[4] == '')
                            {
                                addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                                continue;
                            }

                            unlockedModSongs.set(song[0], ShopSubState.isItemUnlocked(song[4]));
                            if(!unlockedModSongs.get(song[0])) continue;
                            addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                            trace('Added ${song[0]} via MODS');
                        case OG:
                            // just ignore that shitty code up there right? i love you y sides main content, fuck mods. -madera <3
                            if(song[4] != null) continue;

                            // this code really do sucks af.-
                            if(song[0] == 'Test' && ShopSubState.isItemUnlocked('Mic Bulb')) 
                            {
                                addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                            }
                            else if(song[0] != 'Test')
                            {
                                addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                            } 

                            trace('Added ${song[0]} via OG');
                    }
                }
				else
				{
					if(!song[3]) continue;
                    //if(song[4] == null) continue;
					addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
                    trace('Added ${song[0]} via OG (Pico Mix)');
				}
			}
		}

        if(category == OG && ShopSubState.isItemUnlocked('Singing Module') && BeatenSongs.isSongBeaten('options-bf')) addSong('Options', 6, 'options', FlxColor.fromRGB(255, 255, 255));

		Mods.loadTopMod();

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

            var fullSongName = '${Paths.formatToSongPath(songs[i].songName)}-${CharSelectState.currentFreeplaySelectedName}';
            capsule.isNewSong = (!BeatenSongs.isSongBeaten(fullSongName) && BeatenSongs.isSongNew(fullSongName));
            grpSongs.add(capsule);
        }

		for (num => item in grpSongs.members)
        {
            item.x -= 500;
        }
    }

	var stopMusicPlay:Bool = false;
    var canInteract:Bool = true;
    var alphaSine:Float = 90;

    var targetsSpeed:Float = 20;
    var targetScaleOg:Float = 1;
    var targetScaleMods:Float = 1;
    var targetAlphaOg:Float = 1;
    var targetAlphaMods:Float = 1;

    final backOptions:Map<FlxSprite, Dynamic> = new Map<FlxSprite, Dynamic>();
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var multScaleOg:Float = FlxMath.lerp(categoryOg.scale.x, targetScaleOg, elapsed * targetsSpeed);
        var multScaleMods:Float = FlxMath.lerp(categoryMods.scale.x, targetScaleMods, elapsed * targetsSpeed);
        var multAlphaOg:Float = FlxMath.lerp(categoryOg.alpha, targetAlphaOg, elapsed * targetsSpeed);
        var multAlphaMods:Float = FlxMath.lerp(categoryMods.alpha, targetAlphaMods, elapsed * targetsSpeed);

        categoryOg.scale.set(multScaleOg, multScaleOg);
        categoryMods.scale.set(multScaleMods, multScaleMods);
        categoryOg.alpha = multAlphaOg;
        categoryMods.alpha = multAlphaMods;

        if(MusicBeatState.timePassedOnState > transitionDuration)
        {
            alphaSine += elapsed * 180;
            qeSwitch.alpha = 1 - Math.sin((Math.PI * alphaSine) / 180);
        }

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = 'Score: $lerpScore';

        if(canInteract)
        {
            if(controls.UI_UP_P)
                changeSelect(-1);

            if(controls.UI_DOWN_P)
                changeSelect(1);

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

            if(FlxG.keys.justPressed.Q)
                changeCategory(OG);

            if(FlxG.keys.justPressed.E)
                changeCategory(MODS);

            if(controls.BACK)
            {
                canInteract = false;
                FlxG.sound.play(Paths.sound('cancelMenu'));

                // FlxTween.cancelTweensOf(background);
                // FlxTween.cancelTweensOf(checker);
                // FlxTween.cancelTweensOf(categoryBackground);
                // FlxTween.cancelTweensOf(categoryOg);
                // FlxTween.cancelTweensOf(categoryDot);
                // FlxTween.cancelTweensOf(categoryMods);
                // FlxTween.cancelTweensOf(poloUp);
                // FlxTween.cancelTweensOf(poloDown);
                // FlxTween.cancelTweensOf(backgroundHint);
                // FlxTween.cancelTweensOf(hint);
                // FlxTween.cancelTweensOf(backgroundDiff);
                // FlxTween.cancelTweensOf(difText);
                // FlxTween.cancelTweensOf(scoreText);
                // FlxTween.cancelTweensOf(bombox);
                // FlxTween.cancelTweensOf(character);

                grpSongs.forEach(function(cap:FreeplayCapsule)
                {
                    cap.copyPositions = false;
                    FlxTween.cancelTweensOf(cap);
                    //cap.startPosition.x += -700;
                    FlxTween.tween(cap, {x: cap.x - 700}, transitionDuration, {ease: FlxEase.expoIn});
                });

                FlxTween.color(background, transitionDuration, background.color, 0xFFBFB4F1, {ease: FlxEase.expoIn});

                for(object in backOptions.keys())
                {
                    FlxTween.cancelTweensOf(object);
                    FlxTween.tween(object, backOptions.get(object), transitionDuration, {ease: FlxEase.expoIn});
                }

                // FlxTween.tween(categoryBackground, {y: -poloUp.height + 55}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(categoryOg, {y: -poloUp.height + 55}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(categoryDot, {y: -poloUp.height + 55}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(categoryMods, {y: -poloUp.height + 55}, transitionDuration, {ease: FlxEase.expoIn});
                qeSwitch.visible = false;

                // FlxTween.tween(checker, {alpha: 0}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(poloUp, {y: 0 - poloUp.height}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(poloDown, {y: FlxG.height}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(backgroundHint, {y: FlxG.height}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(hint, {y: FlxG.height}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(backgroundDiff, {y: -backgroundDiff.height}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(difText, {y: -backgroundDiff.height + 60}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(backgroundDiffLight, {y: -backgroundDiff.height}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(scoreText, {y: -backgroundDiff.height + 230}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(bombox, {x: FlxG.width}, transitionDuration, {ease: FlxEase.expoIn});
                // FlxTween.tween(character, {x: FlxG.width + (895 - 705)}, transitionDuration, {ease: FlxEase.expoIn});

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
                var poop:String = Highscore.formatSong(songLowercase, CharSelectState.currentFreeplaySelectedName, curDifficulty);

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
                if(!unlockedPico) return;
                
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
		intendedScore = Highscore.getScore(songs[curSelected].songName, CharSelectState.currentFreeplaySelectedName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty).toLowerCase();
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
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!NewStoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !NewStoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

    override function beatHit()
    {
        super.beatHit();

        bombox.animation.play('idle', true, true);
        character.animation.play('idle', true);
        grpSongs.forEach(function(cap:FreeplayCapsule)
        {
            cap.newSprite.animation.play('idle', true);
        });
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
    public var isNewSong(default, set):Bool = false;
    private function set_isNewSong(value:Bool)
    {
        isNewSong = value;
        newSprite.visible = isNewSong;
        return value;
    }

    public var background:FlxSprite;
    public var text:FlxText;
    public var icon:FlxSprite;
    public var newSprite:FlxSprite;

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

        newSprite = new FlxSprite();
        newSprite.frames = Paths.getSparrowAtlas('freePlay/NEW/newNoti');
        newSprite.animation.addByPrefix('idle', 'idle', 12, false);
        newSprite.animation.play('idle', true);
        newSprite.x += background.width - (newSprite.width / 2) - 30;
        newSprite.y = 0;
        newSprite.antialiasing = ClientPrefs.data.antialiasing;
        add(newSprite);

        if(!isNewSong) newSprite.visible = false;
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