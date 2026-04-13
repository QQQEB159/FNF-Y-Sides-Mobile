package states;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.graphics.FlxGraphic;

import backend.Highscore;
import backend.Song;
import backend.WeekData;

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

	//var songTextTemp:FlxBitmapText;
    var weekBackground:FlxSprite;
    var gradient:FlxSprite;
    var character:FlxSprite;
    var songsThingie:FlxSprite;
    var weekTextBackground:FlxSprite;
    var diffBackground:FlxSprite;
    var sprDifficulty:FlxSprite;
	var grpWeekText:FlxTypedGroup<WeekItem>;
    var poloUp:FlxSprite;
    var poloDown:FlxSprite;

    override function create()
    {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

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

        weekBackground = new FlxSprite();
        weekBackground.loadGraphic(Paths.image('storymenu/new/bgs/week5'));
        weekBackground.antialiasing = ClientPrefs.data.antialiasing;
        add(weekBackground);

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

        weekTextBackground = new FlxSprite(20, 0);
        weekTextBackground.makeGraphic(290, FlxG.height, 0xFF8E8596);
        weekTextBackground.alpha = 0.5;
        add(weekTextBackground);

        diffBackground = new FlxSprite(0, 155);
        diffBackground.makeGraphic(290, 135, 0xFF8E8596);
        diffBackground.x = FlxG.width - diffBackground.width - 20;
        diffBackground.alpha = 0.5;
        add(diffBackground);

		sprDifficulty = new FlxSprite(0, diffBackground.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		sprDifficulty.alpha = 0;
		add(sprDifficulty);

		grpWeekText = new FlxTypedGroup<WeekItem>();
		add(grpWeekText);

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
                weekThing.startPosition.y = weekThing.y;
                weekThing.targetY = i;
				weekThing.ID = i;

				grpWeekText.add(weekThing);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					//grpLocks.add(lock);

					weekThing.color = 0xFF777777;
				}
			}
        }

        songsThingie = new FlxSprite();
        songsThingie.loadGraphic(Paths.image('storymenu/new/songsThingie'));
        songsThingie.x = FlxG.width - songsThingie.width - 20;
        songsThingie.y = diffBackground.y + diffBackground.height + 10;
        add(songsThingie);

        poloUp = new FlxSprite();
        poloUp.loadGraphic(Paths.image('storymenu/new/poloUp'));
        add(poloUp);

        poloDown = new FlxSprite();
        poloDown.loadGraphic(Paths.image('storymenu/new/poloDown'));
        poloDown.y = FlxG.height - poloDown.height;
        add(poloDown);

		changeWeek(0, true);
		changeDifficulty();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

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
            MusicBeatState.switchState(new MainMenuState());
        }

		if(intendedScore != lerpScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
	
			//scoreText.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
		}
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

			FlxTween.cancelTweensOf(sprDifficulty);
			FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 30, alpha: 1}, 0.07);
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
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

		character.loadGraphic(Paths.image('storymenu/new/characters/${leWeek.weekCharacters[0]}'));
        character.screenCenter();

		character.y += 5;
		character.alpha = 0;

		FlxTween.cancelTweensOf(character);
		FlxTween.tween(character, {alpha: 1, y: character.y - 10}, 0.1, {ease: FlxEase.quartOut});
		
		character.angle = 3;
		FlxTween.tween(character, {angle: -3}, 6, {ease: FlxEase.quartInOut, type: PINGPONG});

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
	}
}

class WeekItem extends FlxSprite
{
    public var targetX:Float = 0;
    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(0, 160);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);
    public var copyPositions:Bool = true;

    public function new(x:Float, y:Float, weekName:String)
    {
        super(x, y);

        loadGraphic(Paths.image('storymenu/new/items/$weekName'));
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