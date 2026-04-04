package states;

import flixel.addons.display.FlxBackdrop;
import states.FreeplayState.SongMetadata;
import backend.WeekData;

class NewFreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
    var background:FlxSprite;
    var checker:FlxBackdrop;
    var backgroundLight:FlxSprite;
    var backgroundHint:FlxSprite;
    var hint:FlxSprite;
    var backgroundDiff:FlxSprite;
    var backgroundDiffLight:FlxSprite;
    var polo:FlxSprite;
    var bombox:FlxSprite;
    var character:FlxSprite;
    var grpSongs:FlxTypedGroup<FreeplayCapsule>;

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
        background.loadGraphic(Paths.image('freePlay/NEW/background'));
        background.antialiasing = ClientPrefs.data.antialiasing;
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

        hint = new FlxSprite();
        hint.loadGraphic(Paths.image('freePlay/NEW/hint'));
        hint.antialiasing = ClientPrefs.data.antialiasing;
        hint.y = backgroundHint.y + 25;
        hint.screenCenter(X);
        add(hint);

        backgroundDiff = new FlxSprite(695, 12);
        backgroundDiff.loadGraphic(Paths.image('freePlay/NEW/backgroundDiff'));
        backgroundDiff.antialiasing = ClientPrefs.data.antialiasing;
        add(backgroundDiff);

        backgroundDiffLight = new FlxSprite();
        backgroundDiffLight.loadGraphic(Paths.image('freePlay/NEW/light'));
        backgroundDiffLight.antialiasing = ClientPrefs.data.antialiasing;
        backgroundDiffLight.blend = ADD;
        add(backgroundDiffLight);

        polo = new FlxSprite();
        polo.loadGraphic(Paths.image('freePlay/NEW/polo'));
        polo.antialiasing = ClientPrefs.data.antialiasing;
        add(polo);

        bombox = new FlxSprite(705, 315);
        bombox.frames = Paths.getSparrowAtlas('freePlay/NEW/bombox');
        bombox.animation.addByPrefix('idle', 'idle', 12, false);
        bombox.animation.play('idle', true, true);
        bombox.antialiasing = ClientPrefs.data.antialiasing;
        add(bombox);

        character = new FlxSprite(895, 390);
        character.frames = Paths.getSparrowAtlas('freePlay/NEW/char/bf');
        character.animation.addByPrefix('idle', 'coso', 24, false);
        character.animation.play('idle', true);
        character.antialiasing = ClientPrefs.data.antialiasing;
        add(character);

        for(i in 0...songs.length)
        {
            var capsule = new FreeplayCapsule(0, 0, songs[i].songName);
			capsule.targetX = i;
			capsule.targetY = i;
            capsule.x = 0;
            capsule.screenCenter(Y);
            capsule.startPosition.x = capsule.x;
            capsule.startPosition.y = capsule.y;
			capsule.snapToPosition();
            add(capsule);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if(FlxG.keys.justPressed.TAB)
		{
			FlxG.sound.music.fadeOut(0.1, 0, function(twn:FlxTween) {FlxG.sound.music.stop();});
			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new CharSelectState());
			});
		}
    }

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
}

class FreeplayCapsule extends FlxSpriteGroup
{
    public var targetX:Float = 0;
    public var targetY:Float = 0;
    public var distancePerItem:FlxPoint = new FlxPoint(120, 270);
    public var startPosition:FlxPoint = new FlxPoint(0, 0);

    public var background:FlxSprite;
    public var text:FlxText;
    public var icon:FlxSprite;
    public function new(x:Float, y:Float, songName:String)
    {
        super(x, y);

        background = new FlxSprite();
        background.loadGraphic(Paths.image('freePlay/NEW/capsule'));
        add(background);

        text = new FlxText(0, 0, background.width, songName, 32);
        text.setFormat(Paths.font('GAU_pop_magic.ttf'), 32, 0xFFFFFFFF);
        text.x += 80;
        text.y += background.height / 2 - text.height / 2;
        add(text);

        icon = new FlxSprite();
        icon.loadGraphic(Paths.image('freePlay/NEW/icons/dad'));
        icon.y += -(icon.height / 2);
        icon.x += -(icon.width / 2);
        add(icon);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpVal:Float = Math.exp(-elapsed * 9.6);
		x = FlxMath.lerp((targetX * distancePerItem.x) + startPosition.x, x, lerpVal);
		y = FlxMath.lerp((targetY * distancePerItem.y) + startPosition.y, y, lerpVal);
    }

    public function snapToPosition()
    {
        x = startPosition.x + (targetX * distancePerItem.x);
        y = startPosition.y + (targetY * distancePerItem.y);
    }
}