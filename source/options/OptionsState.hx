package options;

import states.CreditsState;
import flixel.addons.display.FlxBackdrop;
import objects.Character;
import states.MainMenuState;
import backend.StageData;
import flixel.addons.text.FlxTypeText;
import states.CreditsStateYSides;

class OptionsState extends MusicBeatState
{
	public static var comingFromOptions:Bool = false;
	public static var iconsPos:Array<Float> = [0, 0];
	public static var verticalTriangleLeftPos:Float = 0;
	public static var verticalTriangleRightPos:Float = 0;
	public static var currentFrame:Int = 0;

	var options:Array<String> = [
		'Controls',
		'Adjust Delay',
		'Graphics',
		'Visuals',
		'Gameplay',
		'Save Files'
		#if TRANSLATIONS_ALLOWED , 'Language' #end
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	function openSelectedSubstate(label:String) 
	{
		
		iconsPos.insert(0, icons.x);
		iconsPos.insert(1, icons.y);

		verticalTriangleLeftPos = verticalTriangleLeft.y;
		verticalTriangleRightPos = verticalTriangleRight.y;

		switch(label)
		{
			case 'Note Colors':
				openSubState(new options.NotesColorSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals':
				openSubState(new options.VisualsSettingsSubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Language':
				openSubState(new options.LanguageSubState());
			case 'Save Files':
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				
				MusicBeatState.switchState(new options.SaveFilesMenu());
		}
	}

	var icons:FlxBackdrop;
	var verticalTriangleLeft:FlxBackdrop;
	var verticalTriangleRight:FlxBackdrop;

	var boardThing:FlxSprite;
	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var character:Character;
	var isDoingSpecialAnim:Bool = false;

	private var dialogueBox:FlxSprite;
	private var dialogueText:FlxTypeText;

	var welcomeBack1:String = 'Hello again!';
	var welcomeBack2:String = 'Welcome back! Looks like you wanna change something here...';
	var welcomeBack3:String = 'Hey! How are you doing with the mod?';

	var skipTransition:Bool = false;
	public function new(skipTrans:Bool = false)
	{
		super();

		skipTransition = skipTrans;
	}

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		FlxG.sound.playMusic(Paths.music('optionsMenu'));
		FlxG.sound.music.fadeIn(1);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.setPosition(iconsPos[0], iconsPos[1]);
		icons.velocity.set(10, 10);
		icons.alpha = 0.45;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);

		FlxTween.tween(icons, {alpha: 0.2}, 0.7);

		verticalTriangleLeft = new FlxBackdrop(Paths.image('optionsMenu/verticalTriangleThing'), Y);
		verticalTriangleLeft.x = 138;
		verticalTriangleLeft.y = verticalTriangleLeftPos;
		verticalTriangleLeft.velocity.set(0, 20);
		verticalTriangleLeft.antialiasing = ClientPrefs.data.antialiasing;
		add(verticalTriangleLeft);

		verticalTriangleRight = new FlxBackdrop(Paths.image('optionsMenu/verticalTriangleThing'), Y);

		verticalTriangleRight.angle = 180;
		//verticalTriangleRight.flipX = true;
		verticalTriangleRight.updateHitbox();

		verticalTriangleRight.x = FlxG.width - verticalTriangleRight.width - 138;
		verticalTriangleRight.y = verticalTriangleRightPos;
		verticalTriangleRight.velocity.set(0, -20);
		verticalTriangleRight.antialiasing = ClientPrefs.data.antialiasing;
		add(verticalTriangleRight);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (num => option in options)
		{
			var optionText:Alphabet = new Alphabet(0, 0, Language.getPhrase('options_$option', option), true);
			optionText.isMenuItem = true;
			optionText.ID = num;
			optionText.startPosition = new FlxPoint(150, 160);
			optionText.distancePerItem = new FlxPoint(0, 92);
			optionText.snapToPosition();
			optionText.screenCenter(Y);
			//optionText.x = 150;
			//optionText.y = 160;
			//optionText.y += (92 * (num - (options.length / 2)));
			optionText.alpha = 0;
			FlxTween.tween(optionText, {alpha: num == curSelected ? 1 : 0.6}, 0.2, {startDelay: 0.1 + (0.03 * num)});
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		//add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		//add(selectorRight);

		boardThing = new FlxSprite().loadGraphic(Paths.image('optionsMenu/boardThing'));
		boardThing.screenCenter();
		boardThing.antialiasing = ClientPrefs.data.antialiasing;
		add(boardThing);

		character = new Character(800, 200, 'options-guy');
		character.playAnim('idle', false, false, OptionsState.currentFrame);
		character.antialiasing = ClientPrefs.data.antialiasing;
		add(character);

		dialogueBox = new FlxSprite(40, 600).makeGraphic(1200, 80, FlxColor.BLACK);
		dialogueBox.alpha = 0.6;
		dialogueBox.antialiasing = ClientPrefs.data.antialiasing;
		add(dialogueBox);

		dialogueText = new FlxTypeText(50, dialogueBox.y + 10, 1180, "", 32);
		dialogueText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dialogueText.scrollFactor.set();
		dialogueText.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
		dialogueText.antialiasing = ClientPrefs.data.antialiasing;

		if(FlxG.save.data.firstTimeInOptions == null && onPlayState)
		{
			FlxG.save.data.firstTimeInOptions = false;
			FlxG.save.flush();

			if(character != null) try {
				character.playAnim('happy');
			}
			catch(exc) { trace ('Error: $exc'); }
			dialogueText.resetText('Welcome to the options menu! Here you can tweak with some of the option we offer to you...');
			dialogueText.start(0.04, true);
			dialogueText.completeCallback = function() 
			{
				new FlxTimer().start(1.8, function(t:FlxTimer)
				{
					if(character != null) try {
						character.playAnim('idle', false, false, OptionsState.currentFrame);
					}
					catch(exc) { trace ('Error: $exc'); }
					FlxTween.tween(dialogueBox, {alpha: 0, y: dialogueBox.y + 10}, 0.35, {ease: FlxEase.linear});
					FlxTween.tween(dialogueText, {alpha: 0, y: dialogueText.y + 10}, 0.35, {ease: FlxEase.linear});
				});
			}
		}
		else if(onPlayState)
		{
			if(character != null) try {
				character.playAnim('happy');
			}
			catch(exc) { trace ('Error: $exc'); }
			dialogueText.resetText(FlxG.random.getObject([welcomeBack1, welcomeBack2, welcomeBack3]));
			dialogueText.start(0.04, true);
			dialogueText.completeCallback = function() 
			{
				new FlxTimer().start(1.8, function(t:FlxTimer)
				{
					if(character != null) try {
						character.playAnim('idle', false, false, OptionsState.currentFrame);
					}
					catch(exc) { trace ('Error: $exc'); }
					FlxTween.tween(dialogueBox, {alpha: 0, y: dialogueBox.y + 10}, 0.35, {ease: FlxEase.linear});
					FlxTween.tween(dialogueText, {alpha: 0, y: dialogueText.y + 10}, 0.35, {ease: FlxEase.linear});
				});
			}
		}

		add(dialogueText);

		if(!onPlayState && !skipTransition)
		{
			boardThing.alpha = 0;
			verticalTriangleLeft.alpha = 0;
			verticalTriangleRight.alpha = 0;
			character.alpha = 0;

			FlxTween.tween(boardThing, {alpha: 1}, 0.2);
			FlxTween.tween(verticalTriangleLeft, {alpha: 1}, 0.2, {startDelay: 0.05});
			FlxTween.tween(verticalTriangleRight, {alpha: 1}, 0.2, {startDelay: 0.1});
			FlxTween.tween(character, {alpha: 1}, 0.2, {startDelay: 0.15});

			new FlxTimer().start(0.45, function(t:FlxTimer)
			{
				if(FlxG.save.data.firstTimeInOptions == null)
				{
					FlxG.save.data.firstTimeInOptions = false;
					FlxG.save.flush();
		
					if(character != null) try {
						character.playAnim('happy');
					}
					catch(exc) { trace ('Error: $exc'); }
					dialogueText.resetText('Welcome to the options menu! Here you can tweak with some of the option we offer to you...');
					dialogueText.start(0.04, true);
					dialogueText.completeCallback = function() 
					{
						new FlxTimer().start(1.8, function(t:FlxTimer)
						{
							if(character != null) try {
								character.playAnim('idle', false, false, currentFrame);
							}
							catch(exc) { trace ('Error: $exc'); }
							FlxTween.tween(dialogueBox, {alpha: 0, y: dialogueBox.y + 10}, 0.35, {ease: FlxEase.linear});
							FlxTween.tween(dialogueText, {alpha: 0, y: dialogueText.y + 10}, 0.35, {ease: FlxEase.linear});
						});
					}
				}
				else
				{
					if(character != null) try {
						character.playAnim('happy');
					}
					catch(exc) { trace ('Error: $exc'); }
					dialogueText.resetText(FlxG.random.getObject([welcomeBack1, welcomeBack2, welcomeBack3]));
					dialogueText.start(0.04, true);
					dialogueText.completeCallback = function() 
					{
						new FlxTimer().start(1.8, function(t:FlxTimer)
						{
							if(character != null) try {
								character.playAnim('idle', false, false, OptionsState.currentFrame);
							}
							catch(exc) { trace ('Error: $exc'); }
							FlxTween.tween(dialogueBox, {alpha: 0, y: dialogueBox.y + 10}, 0.35, {ease: FlxEase.linear});
							FlxTween.tween(dialogueText, {alpha: 0, y: dialogueText.y + 10}, 0.35, {ease: FlxEase.linear});
						});
					}
				}
			});
		}

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();

		icons.setPosition(iconsPos[0], iconsPos[1]);
		verticalTriangleLeft.y = verticalTriangleLeftPos;
		verticalTriangleRight.y = verticalTriangleRightPos;

		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) 
	{

		super.update(elapsed);

		if(character != null)
		{
			currentFrame = character.animation.curAnim.name == 'idle' ? character.animation.curAnim.curFrame : 0;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.BACK)
		{
			FlxG.sound.music.fadeOut(0.65);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else
			{
				CreditsStateYSides.backFromCredits = true;
				comingFromOptions = true;

				FlxTween.cancelTweensOf(boardThing);
				FlxTween.cancelTweensOf(verticalTriangleLeft);
				FlxTween.cancelTweensOf(verticalTriangleRight);
				FlxTween.cancelTweensOf(character);
				FlxTween.cancelTweensOf(icons);

				grpOptions.forEachAlive(function(spr:Alphabet)
				{
					FlxTween.cancelTweensOf(spr);
					FlxTween.tween(spr, {alpha: 0}, 0.2);
				});

				FlxTween.tween(icons, {alpha: 0.45}, 0.2);
				FlxTween.tween(boardThing, {alpha: 0}, 0.2);
				FlxTween.tween(verticalTriangleLeft, {alpha: 0}, 0.2);
				FlxTween.tween(verticalTriangleRight, {alpha: 0}, 0.2);
				FlxTween.tween(character, {alpha: 0}, 0.2, {onComplete: function(t:FlxTween)
				{
					MainMenuState.iconsPos.insert(0, icons.x);
					MainMenuState.iconsPos.insert(1, icons.y);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new MainMenuState());
				}});
			}
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);

		if(grpOptions != null)
		{
			for (num => item in grpOptions.members)
			{
				item.alpha = 0.6;
				if (item.ID == curSelected)
				{
					item.alpha = 1;
					selectorLeft.x = item.x - 63;
					selectorLeft.y = item.y;
					selectorRight.x = item.x + item.width + 15;
					selectorRight.y = item.y;
				}
			}
		}
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (num => item in grpOptions.members)
		{
			switch(curSelected)
			{
				case 0 | 1 | 2:
					item.targetY = num - curSelected;
				case 3:
					item.targetY = num - curSelected + 1;
				case 4:
					item.targetY = num - curSelected + 2;
				case 5:
					item.targetY = num - curSelected + 3;
			}

			if(change == 0) item.snapToPosition();
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}