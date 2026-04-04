package states;

import flixel.addons.display.FlxBackdrop;

class NewFreeplayState extends MusicBeatState
{
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

	public var isPicoMix:Bool = false;
	public function new(_isPicoMix:Bool = false)
	{
		isPicoMix = _isPicoMix;
		super();
	}

    override function create()
    {
        super.create();

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

    override function beatHit()
    {
        super.beatHit();

        bombox.animation.play('idle', true, true);
        character.animation.play('idle', true);
    }
}