package states;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.graphics.FlxGraphic;

import backend.Highscore;
import backend.Song;
import backend.WeekData;
import backend.StageData;

import shaders.BlurShader;
import openfl.filters.ShaderFilter;

import objects.MenuItem;

class NewStoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var backFromStoryMode:Bool = false;
	private static var curWeek:Int = 0;
	private static var curDifficulty:Int = 0;
    private static var difficultyColors:Array<FlxColor> = [0xFF5AFF94, 0xFFFFE461, 0xFFFF5B84];
	private static var lastDifficultyName:String = '';
	var loadedWeeks:Array<WeekData> = [];
    var characterY:Float = 0;
    var stripeSpeed:Int = 25;

	//var songTextTemp:FlxBitmapText;
    var weekBackground:FlxSprite;
    var bgStripe:FlxBackdrop;
    var gradient:FlxSprite;
    var character:FlxSprite;
    var songsThingie:FlxSprite;
	var weekTitle:FlxText;
	var txtTracks:FlxBitmapText;
	var txtTracklistGrp:FlxTypedGroup<FlxBitmapText>;
    var weekTextBackground:FlxSprite;
    var diffBackground:FlxSprite;
    var sprDifficulty:FlxSprite;
	var grpWeekText:FlxTypedGroup<WeekItem>;
    var poloUp:FlxSprite;
    var poloDown:FlxSprite;
	var scoreText:FlxText;
	var topBlackBg:FlxSprite;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var blurShader:BlurShader;
	var blurFilter:ShaderFilter;

	var grpLocks:FlxTypedGroup<FlxSprite>;

    override function create()
    {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		// BeatenSongs.init();

		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		blurShader = new BlurShader();
        blurShader.radius.value = [0];
		blurFilter = new ShaderFilter(blurShader);
		FlxG.camera.filters = [blurFilter];

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		if(curWeek >= WeekData.weeksList.length) curWeek = 0;

        super.create();

        /*
		var fontLetters:String = "abcgipydefhjqzklmnorstuvwx";
		songTextTemp = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("storymenu/new/storyfont"), fontLetters, FlxPoint.get(42, 56)));
		songTextTemp.text = "";
		songTextTemp.antialiasing = ClientPrefs.data.antialiasing;
        songTextTemp.text = 'hola gbv princesa';
        songTextTemp.screenCenter();
        add(songTextTemp);
        */

		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0xFFE7E0FF);
		add(bg);

        weekBackground = new FlxSprite();
        weekBackground.loadGraphic(Paths.image('storymenu/new/bgs/week5'));
        weekBackground.antialiasing = ClientPrefs.data.antialiasing;
        add(weekBackground);

        bgStripe = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/stripe'), #if (flixel <= "5.0.0") 0.2, 0.2, true, true #else X #end);
        bgStripe.antialiasing = ClientPrefs.data.antialiasing;
        bgStripe.velocity.set(stripeSpeed, 0);
        bgStripe.blend = ADD;
        add(bgStripe);

        gradient = new FlxSprite();
        gradient.loadGraphic(Paths.image('storymenu/new/gradient'));
        gradient.blend = ADD;
        gradient.alpha = 0.8;
        add(gradient);

        character = new FlxSprite();
        character.loadGraphic(Paths.image('storymenu/new/characters/frank'));
        character.screenCenter();
        character.antialiasing = ClientPrefs.data.antialiasing;
        add(character);

        characterY = character.y;

        weekTextBackground = new FlxSprite(0, 0);
        weekTextBackground.makeGraphic(290, FlxG.height, 0xFF130024);
        weekTextBackground.alpha = 0.5;
		weekTextBackground.x = (375 / 2) - (weekTextBackground.width / 2);
        add(weekTextBackground);

        diffBackground = new FlxSprite(0, 155);
        diffBackground.makeGraphic(290, 135, 0xFF130024);
        diffBackground.x = FlxG.width - diffBackground.width - 20;
        diffBackground.alpha = 0.5;
        add(diffBackground);

		sprDifficulty = new FlxSprite(0, diffBackground.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		sprDifficulty.alpha = 0;
		add(sprDifficulty);

		grpWeekText = new FlxTypedGroup<WeekItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);

				var weekThing:WeekItem = new WeekItem(0, 0, WeekData.weeksList[i]);
                weekThing.screenCenter(Y);
				weekThing.x = weekTextBackground.x + weekTextBackground.width / 2 - weekThing.width / 2;
                weekThing.startPosition.x = weekThing.x;
                weekThing.startPosition.y = weekThing.y;
                weekThing.targetY = i;
				weekThing.ID = i;

				grpWeekText.add(weekThing);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite();
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.x = weekThing.x + weekThing.width / 2 - lock.width / 2;
					grpLocks.add(lock);

					weekThing.color = 0xFF777777;
				}
			}
        }

        songsThingie = new FlxSprite();
        songsThingie.loadGraphic(Paths.image('storymenu/new/songsThingie'));
        songsThingie.x = FlxG.width - songsThingie.width - 20;
        songsThingie.y = diffBackground.y + diffBackground.height + 10;
        add(songsThingie);

		var fontLetters:String = "abcgipydefhjqzklmnorstuvwx";
		txtTracks = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("storymenu/new/storyfont"), fontLetters, FlxPoint.get(42, 56)));
		txtTracks.antialiasing = ClientPrefs.data.antialiasing;
		txtTracks.scale.set(0.65, 0.65);
		txtTracks.text = 'songs';
		txtTracks.updateHitbox();
        txtTracks.screenCenter();
		txtTracks.x = songsThingie.x + songsThingie.width / 2 - txtTracks.width / 2;
		txtTracks.y = songsThingie.y;
        add(txtTracks);

		txtTracklistGrp = new FlxTypedGroup<FlxBitmapText>();
		add(txtTracklistGrp);

        poloUp = new FlxSprite();
        poloUp.loadGraphic(Paths.image('storymenu/new/poloUp'));
        add(poloUp);

        poloDown = new FlxSprite();
        poloDown.loadGraphic(Paths.image('storymenu/new/poloDown'));
        poloDown.y = FlxG.height - poloDown.height;
        add(poloDown);

		weekTitle = new FlxText(0, 0, FlxG.width, 'Score: 0');
		weekTitle.setFormat(Paths.font('RETRRG__.ttf'), 32, 0xFFFFFFFF, CENTER);
		weekTitle.antialiasing = ClientPrefs.data.antialiasing;
		weekTitle.y = 10;
		add(weekTitle);

		scoreText = new FlxText(0, 0, FlxG.width, 'Score: 0');
		scoreText.setFormat(Paths.font('RETRRG__.ttf'), 32, 0xFFFFFFFF, CENTER);
		scoreText.antialiasing = ClientPrefs.data.antialiasing;
		scoreText.y = FlxG.height - scoreText.height - 10;
		add(scoreText);

		topBlackBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		topBlackBg.alpha = 0;
		add(topBlackBg);

		changeWeek(0, true);
		changeDifficulty();

		initTransition();
    }

    var characterScaleX:Float = 0.85;
    var characterScaleY:Float = 0.85;
    var squishiIntensity:Float = 0.05;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

		for (num => lock in grpLocks.members)
		{
			lock.x = grpWeekText.members[lock.ID].x + grpWeekText.members[lock.ID].width/2 - lock.width/2;
			lock.y = grpWeekText.members[lock.ID].y + grpWeekText.members[lock.ID].height/2 - lock.height/2;
		}

		if(!selectedWeek && !goneBack)
		{
			if(controls.UI_DOWN_P)
			{
				changeWeek(1);
			}

			if(controls.UI_UP_P)
			{
				changeWeek(-1);
			}

			if(controls.UI_LEFT_P)
			{
				changeDifficulty(-1);
			}

			if(controls.UI_RIGHT_P)
			{
				changeDifficulty(1);
			}

			if(controls.BACK)
			{
				goneBack = true;

				FlxTween.cancelTweensOf(weekBackground);
				FlxTween.cancelTweensOf(bgStripe);
				FlxTween.cancelTweensOf(poloUp);
				FlxTween.cancelTweensOf(poloDown);
				FlxTween.cancelTweensOf(scoreText);
				FlxTween.cancelTweensOf(weekTitle);
				FlxTween.cancelTweensOf(weekTextBackground);
				FlxTween.cancelTweensOf(songsThingie);
				FlxTween.cancelTweensOf(txtTracks);
				FlxTween.cancelTweensOf(gradient);
				FlxTween.cancelTweensOf(sprDifficulty);
				FlxTween.cancelTweensOf(character);

				txtTracklistGrp.forEach(function(text:FlxBitmapText)
				{
					FlxTween.cancelTweensOf(text);
				});
				grpWeekText.forEach(function(item:WeekItem)
				{
					FlxTween.cancelTweensOf(item);
				});

				FlxTween.tween(weekBackground, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
        		FlxTween.tween(bgStripe, {alpha: 0}, transitionDuration);
				FlxTween.tween(poloUp, {y: -poloUp.height}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(poloDown, {y: FlxG.height}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(scoreText, {y: FlxG.height + 10}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(weekTitle, {y: -poloUp.height + 10}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(weekTextBackground, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(diffBackground, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(songsThingie, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(txtTracks, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(gradient, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(sprDifficulty, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
				FlxTween.tween(character, {alpha: 0, y: character.y + 10}, transitionDuration, {ease: FlxEase.expoOut});

				txtTracklistGrp.forEach(function(text:FlxBitmapText)
				{
					text.alpha = 0;
					FlxTween.tween(text, {alpha: 0}, transitionDuration, {ease: FlxEase.expoOut});
				});

				grpWeekText.forEach(function(item:WeekItem)
				{
					item.copyPositions = false;
					FlxTween.tween(item, {x: -600}, transitionDuration, {ease: FlxEase.expoOut});
				});

 				FlxG.sound.play(Paths.sound('cancelMenu'));
				new FlxTimer().start(transitionDuration, function(tmr:FlxTimer)
				{
                    FlxTransitionableState.skipNextTransIn = true;
                    FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new MainMenuState());
				});

			}

			if (controls.ACCEPT && !stopspamming)
				selectWeek();
		}

        var multX = FlxMath.lerp(character.scale.x, characterScaleX, elapsed * 9);
        var multY = FlxMath.lerp(character.scale.y, characterScaleY, elapsed * 9);
        character.scale.set(multX, multY);

		if(intendedScore != lerpScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
			scoreText.text = 'Score: $lerpScore';
	
			//scoreText.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
		}
    }

    var transitionDuration:Float = 0.5;
	function initTransition()
	{
		weekBackground.alpha = 0;
		FlxTween.tween(weekBackground, {alpha: 1}, transitionDuration, {ease: FlxEase.expoOut});

		bgStripe.alpha = 0;
        FlxTween.tween(bgStripe, {alpha: 1}, transitionDuration);

		poloUp.y = -poloUp.height;
		FlxTween.tween(poloUp, {y: 0}, transitionDuration, {ease: FlxEase.expoOut});

		poloDown.y = FlxG.height;
		FlxTween.tween(poloDown, {y: FlxG.height - poloDown.height}, transitionDuration, {ease: FlxEase.expoOut});
		
		scoreText.y = FlxG.height + 10;
		FlxTween.tween(scoreText, {y: FlxG.height - scoreText.height - 10}, transitionDuration, {ease: FlxEase.expoOut});

		weekTitle.y = -poloUp.height + 10;
		FlxTween.tween(weekTitle, {y: 10}, transitionDuration, {ease: FlxEase.expoOut});

		weekTextBackground.alpha = 0;
		FlxTween.tween(weekTextBackground, {alpha: 0.5}, transitionDuration, {ease: FlxEase.expoOut});

		diffBackground.alpha = 0;
		FlxTween.tween(diffBackground, {alpha: 0.5}, transitionDuration, {ease: FlxEase.expoOut});

		songsThingie.alpha = 0;
		FlxTween.tween(songsThingie, {alpha: 1}, transitionDuration, {ease: FlxEase.expoOut});

		txtTracks.alpha = 0;
		FlxTween.tween(txtTracks, {alpha: 1}, transitionDuration, {ease: FlxEase.expoOut});

		txtTracklistGrp.forEach(function(text:FlxBitmapText)
		{
			text.alpha = 0;
			FlxTween.tween(text, {alpha: 1}, transitionDuration, {ease: FlxEase.expoOut});
		});

		grpWeekText.forEach(function(item:WeekItem)
		{
			item.x = -600;
		});

		grpLocks.forEach(function(item:FlxSprite)
		{
			item.x = -600;
		});
	}
	
	var goneBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;
	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			stopspamming = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			var item = grpWeekText.members[curWeek];
			item.copyPositions = false;
			item.changeScale = false;
			item.cameras = [camHUD];

			var oldItemX:Float = item.x;
			var oldItemY:Float = item.y;

			item.screenCenter();

			var screenCenterX:Float = item.x;
			var screenCenterY:Float = item.y;

			item.x = oldItemX;
			item.y = oldItemY;

			FlxTween.num(0, 5, 0.9, {ease: FlxEase.quartOut}, function(v:Float)
			{
        		blurShader.radius.value[0] = v;
			});
			FlxTween.tween(item, {x: screenCenterX, y: screenCenterY, "scale.x": 1.45, "scale.y": 1.45}, 0.75, {ease: FlxEase.quartOut});
			FlxTween.tween(topBlackBg, {alpha: 0.4}, 0.75);

			FlxTween.tween(FlxG.camera, {zoom: 1.02}, 0.75, {ease: FlxEase.quartOut});
			FlxTween.tween(camHUD, {zoom: 1.02}, 0.75, {ease: FlxEase.quartOut});

			new FlxTimer().start(0.9, function(tmr:FlxTimer)
			{
				// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
				var songArray:Array<String> = [];
				var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
				for (i in 0...leWeek.length) {
					songArray.push(leWeek[i][0]);
				}

				// Nevermind that's stupid lmao
				try
				{
					PlayState.storyPlaylist = songArray;
					PlayState.isStoryMode = true;
					selectedWeek = true;
		
					var diffic = Difficulty.getFilePath(curDifficulty);
					if(diffic == null) diffic = '';
		
					PlayState.storyDifficulty = curDifficulty;
		
					Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() +  '-' + CharSelectState.currentFreeplaySelectedName + diffic, PlayState.storyPlaylist[0].toLowerCase());

					PlayState.totalSongsPlayed = 0;
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;
					PlayState.campaignRating = 0;
					PlayState.totalPlayedWeek = 0;

					PlayState.campaignSicks = 0;
					PlayState.campaignGoods = 0;
					PlayState.campaignBads = 0;
					PlayState.campaignShits = 0;
				}
				catch(e:Dynamic)
				{
					trace('ERROR! $e');
					return;
				}

				var directory = StageData.forceNextDirectory;
				LoadingState.loadNextDirectory();
				StageData.forceNextDirectory = directory;

				@:privateAccess
				if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
				{
					trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
					Paths.freeGraphicsFromMemory();
				}
				LoadingState.prepareToSong();
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
					LoadingState.loadAndSwitchState(new PlayState(), true);
					FreeplayState.destroyFreeplayVocals();
				});
				
				#if (MODS_ALLOWED && DISCORD_ALLOWED)
				DiscordClient.loadModRPC();
				#end
			});
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	var lerpScore:Int = 49324858;
	var intendedScore:Int = 0;
	function changeDifficulty(change:Int = 0):Void
	{
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty, false);
		var newImage:FlxGraphic = Paths.image('storymenu/new/difficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = diffBackground.x + diffBackground.width / 2 - sprDifficulty.width / 2;
			//sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = diffBackground.y + diffBackground.height/2 - sprDifficulty.height/2;
			sprDifficulty.y += -30;

			FlxTween.cancelTweensOf(sprDifficulty);
			FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 30, alpha: 1}, 0.07);
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, CharSelectState.currentFreeplaySelectedName, curDifficulty);
		#end

        FlxTween.cancelTweensOf(gradient);
        FlxTween.color(gradient, 0.7, gradient.color, difficultyColors[curDifficulty], {ease: FlxEase.expoOut});
	}

	function changeWeek(change:Int = 0, firstTime:Bool = false):Void
	{
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		for (num => item in grpWeekText.members)
		{
			item.targetY = num - curWeek;
			item.alpha = 0.6;
			if (item.targetY == 0) item.alpha = 1;
            if(firstTime) item.snapToPosition();
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		weekTitle.text = leWeek.storyName;

		character.loadGraphic(Paths.image('storymenu/new/characters/${leWeek.weekCharacters[0]}'));
        character.screenCenter();
		character.y += 40;

        characterY = character.y;

        character.y = characterY + 10;
		character.alpha = 0;
        character.scale.set(characterScaleX - squishiIntensity, characterScaleY + squishiIntensity);

		FlxTween.cancelTweensOf(character);
		
        character.angle = FlxG.random.bool(50) ? 1 : -1;
        FlxTween.tween(character, {alpha: 1, y: characterY, angle: 0}, 0.25, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
		{
			FlxTween.tween(character, {angle: -3}, 6, {ease: FlxEase.quartInOut, type: PINGPONG});
		}});

		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();

		weekBackground.loadGraphic(Paths.image('storymenu/new/bgs/${leWeek.fileName}'));

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		updateText();
	}

	function updateText()
	{
		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklistGrp.forEach(function(spr:FlxBitmapText) spr.destroy());
		txtTracklistGrp.clear();

		FlxTimer.globalManager.clear();

		for (i in 0...stringThing.length)
		{
			var fontLetters:String = "abcgipydefhjqzklmnorstuvwx";
			var txtTracklist = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("storymenu/new/storyfont"), fontLetters, FlxPoint.get(42, 56)));
			txtTracklist.text = stringThing[i].toLowerCase();
			txtTracklist.antialiasing = ClientPrefs.data.antialiasing;
			txtTracklist.scale.set(0.5, 0.5);
			txtTracklist.updateHitbox();
        	txtTracklist.screenCenter();
			txtTracklist.x = songsThingie.x + songsThingie.width / 2 - txtTracklist.width / 2;
			txtTracklist.y = songsThingie.y + 60 + (txtTracklist.height * i);
        	txtTracklistGrp.add(txtTracklist);

			var angleTarget = 1;
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				txtTracklist.angle = txtTracklist.angle == angleTarget ? -angleTarget : angleTarget;
			}, 0);
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, CharSelectState.currentFreeplaySelectedName, curDifficulty);
		#end
	}
}

class WeekItem extends FlxSprite
{
    public var targetX:Float = 0;
    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(0, 160);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    public var copyPositions:Bool = true;
    public var changeScale:Bool = true;

    public function new(x:Float, y:Float, weekName:String)
    {
        super(x, y);

        loadGraphic(Paths.image('storymenu/new/items/$weekName'));
		antialiasing = ClientPrefs.data.antialiasing;
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

		var targetScale:Float = 0.9;
		if(targetY == 0) targetScale = 1;
		if(changeScale)
		{
			var mult = FlxMath.lerp(scale.x, targetScale, elapsed * 7);
			scale.set(mult, mult);
		}
    }

    public function snapToPosition()
    {
        var realTargetX = targetX;
        if(realTargetX > 0) realTargetX *= -1;

        x = startPosition.x + (realTargetX * distancePerItem.x);
        y = startPosition.y + (targetY * distancePerItem.y);

		// also snap scale
		var targetScale:Float = 0.9;
		if(targetY == 0) targetScale = 1;
		scale.set(targetScale, targetScale);
    }
}