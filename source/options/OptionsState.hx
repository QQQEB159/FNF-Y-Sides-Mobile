package options;

import states.CreditsState;
import flixel.addons.display.FlxBackdrop;
import objects.Character;
import states.MainMenuState;
import backend.StageData;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.addons.text.FlxTypeText;
import states.CreditsStateYSides;

class OptionsState extends MusicBeatState
{
	public static var comingFromOptions:Bool = false;
	public static var iconsPos:Array<Float> = [0, 0];
	public static var songThingPos:Array<Float> = [0, 0];
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

	var blackBehind:FlxSprite;
	var radialLight:FlxSprite;
	var blackBackgroundOver:FlxSprite;

	function openSelectedSubstate(label:String) 
	{
		
		iconsPos.insert(0, icons.x);
		iconsPos.insert(1, icons.y);

		songThingPos.insert(0, songThing.x);
		songThingPos.insert(1, songThing.y);

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

				FlxG.sound.play(Paths.sound('scrollMenu'));

          		FlxTween.cancelTweensOf(FlxG.camera);
          		FlxTween.cancelTweensOf(blackBackgroundOver);

				FlxTween.tween(FlxG.camera, {zoom: 1.15}, 0.7, {ease: FlxEase.expoOut});
				FlxTween.tween(blackBackgroundOver, {alpha: 1}, 0.7, {ease: FlxEase.expoOut, onComplete: function(t:FlxTween)
				{
					MusicBeatState.switchState(new options.SaveFilesMenu());
				}});
		}
	}

	var icons:FlxBackdrop;

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var character:Character;
	var isDoingSpecialAnim:Bool = false;

	private var dialogueBox:FlxSprite;
	private var dialogueText:FlxTypeText;
    var dialogueBoxContinueSprite:FlxSprite;

	var welcomeBack1:String = 'Hello again!';
	var welcomeBack2:String = 'Welcome back! Looks like you wanna change something here...';
	var welcomeBack3:String = 'Hey! How are you doing with the mod?';

	var skipTransition:Bool = false;
	public function new(skipTrans:Bool = false)
	{
		super();

		skipTransition = skipTrans;
		WeekData.reloadWeekFiles(false);
		Difficulty.loadFromWeek();
	}

	var bgColorr:FlxSprite;
	var bg:FlxSprite;
	var behindPoloUp:FlxSprite;
	var songThing:FlxBackdrop;
	var poloUp:FlxSprite;
	var poloDown:FlxSprite;
	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		if(FlxG.sound.music != null)
		{
			if(!FlxG.sound.music.playing)
			{
				trace('Main menu music is not playing, starting options menu music!');
				FlxG.sound.playMusic(Paths.music('optionsMenu'), 0);

				if(ShopSubState.isItemUnlocked('Gear') && !FlxG.save.data.gaveGearToRobot) FlxG.sound.music.fadeIn(1.5, 0, 0.6);
				else FlxG.sound.music.fadeIn(1);
			}
		}

		bgColorr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bgColorr.color = 0xFF6C75D4;
		bgColorr.scrollFactor.set(0, 0);
		add(bgColorr);

		bg = new FlxSprite();
		//bg.makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.loadGraphic(Paths.image('optionsMenu/new/bg'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, 0);
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		icons = new FlxBackdrop(Paths.image('optionsMenu/new/checkerthing'), XY);
		icons.setPosition(iconsPos[0], iconsPos[1]);
		icons.velocity.set(10, 10);
		icons.alpha = 0.45;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		add(icons);

		blackBehind = new FlxSprite();
		blackBehind.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackBehind.alpha = 0;
		if(ShopSubState.isItemUnlocked('Gear') && !FlxG.save.data.gaveGearToRobot) FlxTween.tween(blackBehind, {alpha: 0.4}, transDuration, {ease: FlxEase.quartOut});
		blackBehind.scrollFactor.set(0, 0);
		add(blackBehind);

		radialLight = new FlxSprite();
		radialLight.loadGraphic(Paths.image('optionsMenu/new/radiallight'));
		radialLight.antialiasing = ClientPrefs.data.antialiasing;
		radialLight.blend = ADD;
		radialLight.alpha = 0;
		if(ShopSubState.isItemUnlocked('Gear') && !FlxG.save.data.gaveGearToRobot) FlxTween.tween(radialLight, {alpha: 0.4}, transDuration, {ease: FlxEase.quartOut});
		add(radialLight);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (num => option in options)
		{
			var optionText:Alphabet = new Alphabet(0, 0, Language.getPhrase('options_$option', option), true);
			optionText.isMenuItem = true;
			optionText.ID = num;
			optionText.startPosition = new FlxPoint(50, 160);
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

		character = new Character(730, 140, 'options-guy');
		character.playAnim('idle', false, false, OptionsState.currentFrame);
		character.antialiasing = ClientPrefs.data.antialiasing;
		add(character);

		radialLight.x = 730 + character.width / 2 - radialLight.width / 2;
		radialLight.y = FlxG.height - radialLight.height;

		behindPoloUp = new FlxSprite(0, 56);
		behindPoloUp.loadGraphic(Paths.image('optionsMenu/new/poloUpBehind'));
		behindPoloUp.antialiasing = ClientPrefs.data.antialiasing;
		behindPoloUp.scrollFactor.set(0, 0);
		add(behindPoloUp);

		songThing = new FlxBackdrop(Paths.image('optionsMenu/new/song'), X);
		songThing.antialiasing = ClientPrefs.data.antialiasing;
		songThing.x = 50;
		songThing.y = behindPoloUp.y + behindPoloUp.height / 2 - songThing.height / 2;
		songThing.velocity.set(10, 0);
		songThing.scrollFactor.set(0, 0);
		add(songThing);

		poloUp = new FlxSprite();
		poloUp.loadGraphic(Paths.image('optionsMenu/new/poloUp'));
		poloUp.antialiasing = ClientPrefs.data.antialiasing;
		poloUp.scrollFactor.set(0, 0);
		add(poloUp);

		poloDown = new FlxSprite();
		poloDown.loadGraphic(Paths.image('optionsMenu/new/poloDown'));
		poloDown.antialiasing = ClientPrefs.data.antialiasing;
		poloDown.y = FlxG.height - poloDown.height;
		poloDown.scrollFactor.set(0, 0);
		add(poloDown);

		dialogueBox = new FlxSprite(40, 600).makeGraphic(1200, 80, FlxColor.BLACK);
		dialogueBox.alpha = 0;
		dialogueBox.antialiasing = ClientPrefs.data.antialiasing;
		dialogueBox.scrollFactor.set(0, 0);
		add(dialogueBox);

		dialogueText = new FlxTypeText(50, dialogueBox.y + 10, 1180, "", 32);
		dialogueText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dialogueText.scrollFactor.set(0, 0);
		dialogueText.sounds = [
			FlxG.sound.load(Paths.sound('dialogue1'), 0.6),
			FlxG.sound.load(Paths.sound('dialogue2'), 0.6),
			FlxG.sound.load(Paths.sound('dialogue3'), 0.6)
		];
		dialogueText.antialiasing = ClientPrefs.data.antialiasing;

		if(FlxG.save.data.firstTimeInOptions == null && onPlayState)
		{
			FlxG.save.data.firstTimeInOptions = false;
			FlxG.save.flush();

			if(character != null) try {
				character.playAnim('happy');
			}
			catch(exc) { trace ('Error: $exc'); }
			dialogueBox.y += 10;
			dialogueText.y += 10;
			FlxTween.tween(dialogueBox, {alpha: 0.6, y: dialogueBox.y - 10}, 0.35, {ease: FlxEase.quartOut});
			FlxTween.tween(dialogueText, {alpha: 1, y: dialogueText.y - 10}, 0.35, {ease: FlxEase.quartOut});
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
					dialogueBox.y += 10;
					dialogueText.y += 10;
					FlxTween.tween(dialogueBox, {alpha: 0.6, y: dialogueBox.y - 10}, 0.35, {ease: FlxEase.quartOut});
					FlxTween.tween(dialogueText, {alpha: 1, y: dialogueText.y - 10}, 0.35, {ease: FlxEase.quartOut});
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

        dialogueBoxContinueSprite = new FlxSprite();
        dialogueBoxContinueSprite.loadGraphic(Paths.image('vault/continueDialogue'));
        dialogueBoxContinueSprite.x = dialogueBox.x + dialogueBox.width - dialogueBoxContinueSprite.width - 3;
        dialogueBoxContinueSprite.y = (dialogueBox.y - 10) + dialogueBox.height - dialogueBoxContinueSprite.height - 3;
        dialogueBoxContinueSprite.alpha = 0;
		dialogueBoxContinueSprite.scrollFactor.set(0, 0);
        add(dialogueBoxContinueSprite);
        
        FlxTween.tween(dialogueBoxContinueSprite, {x: dialogueBoxContinueSprite.x - 15}, 0.92, {ease: FlxEase.cubeInOut, type: PINGPONG});

		if(!onPlayState && !skipTransition)
		{
			character.alpha = 0;

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
					dialogueBox.y += 10;
					dialogueText.y += 10;
					FlxTween.tween(dialogueBox, {alpha: 0.6, y: dialogueBox.y - 10}, 0.35, {ease: FlxEase.quartOut});
					FlxTween.tween(dialogueText, {alpha: 1, y: dialogueText.y - 10}, 0.35, {ease: FlxEase.quartOut});
					if(ShopSubState.isItemUnlocked('Gear'))
					{
						if(FlxG.save.data.gaveGearToRobot == null) FlxG.save.data.gaveGearToRobot = false;
						if(!FlxG.save.data.gaveGearToRobot)
						{
							dialogueText.resetText("Oh, what is that thing you're holding...");

							if(character != null) try {
								character.playAnim('question');
							}
							catch(exc) { trace ('Error: $exc'); }

							//FlxG.save.data.firstTimeWithGearUnlocked = false;
							//FlxG.save.flush();
						}
						else
						{
							dialogueText.resetText('Welcome to the options menu! Here you can tweak with some of the option we offer to you...');
						}
					}
					else
					{
						dialogueText.resetText('Welcome to the options menu! Here you can tweak with some of the option we offer to you...');
					}
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
					dialogueBox.y += 10;
					dialogueText.y += 10;
					FlxTween.tween(dialogueBox, {alpha: 0.6, y: dialogueBox.y - 10}, 0.35, {ease: FlxEase.quartOut});
					FlxTween.tween(dialogueText, {alpha: 1, y: dialogueText.y - 10}, 0.35, {ease: FlxEase.quartOut});
					if(ShopSubState.isItemUnlocked('Gear'))
					{
						if(FlxG.save.data.gaveGearToRobot == null) FlxG.save.data.gaveGearToRobot = false;
						if(!FlxG.save.data.gaveGearToRobot)
						{
							dialogueText.resetText("Oh, what is that thing you're holding...");

							if(character != null) try {
								character.playAnim('question');
							}
							catch(exc) { trace ('Error: $exc'); }

							//FlxG.save.data.firstTimeWithGearUnlocked = false;
							//FlxG.save.flush();
						}
						else
						{
							dialogueText.resetText(FlxG.random.getObject([welcomeBack1, welcomeBack2, welcomeBack3]));
						}
					}
					else
					{
						dialogueText.resetText(FlxG.random.getObject([welcomeBack1, welcomeBack2, welcomeBack3]));
					}
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

		blackBackgroundOver = new FlxSprite();
		blackBackgroundOver.makeGraphic(1280, 720, FlxColor.BLACK);
		blackBackgroundOver.alpha = 0;
		add(blackBackgroundOver);

		if(SaveFilesMenu.comingFromSaveFilesMenu)
		{
			SaveFilesMenu.comingFromSaveFilesMenu = false;

			blackBackgroundOver.alpha = 1;
			FlxG.camera.zoom = 1.15;

			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.9, {ease: FlxEase.expoOut});
			FlxTween.tween(blackBackgroundOver, {alpha: 0}, 0.7, {ease: FlxEase.expoOut});
		}

		if(ShopSubState.isItemUnlocked('Gear'))
		{
			FlxG.mouse.visible = true;
		}

		initTrans();
		super.create();
	}

	var transDuration:Float = 0.57;
	function initTrans()
	{
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 1}, transDuration);
		
		icons.alpha = 0;
		FlxTween.tween(icons, {alpha: 1}, transDuration);

		poloUp.y = -poloUp.height;
		FlxTween.tween(poloUp, {y: 0}, transDuration, {ease: FlxEase.quartOut});

		behindPoloUp.y = -100;
		FlxTween.tween(behindPoloUp, {y: 56}, transDuration, {ease: FlxEase.quartOut, startDelay: 0.35});

		songThing.y = -100;
		FlxTween.tween(songThing, {y: 56 + behindPoloUp.height / 2 - songThing.height / 2}, transDuration, {ease: FlxEase.quartOut, startDelay: 0.35});
		
		poloDown.y = FlxG.height;
		FlxTween.tween(poloDown, {y: FlxG.height - poloDown.height}, transDuration, {ease: FlxEase.quartOut});

		character.alpha = 0;
		character.y += 10;
		FlxTween.tween(character, {alpha: 1, y: character.y - 10}, transDuration, {ease: FlxEase.quartOut});
	}

	override function closeSubState()
	{
		super.closeSubState();

		icons.setPosition(iconsPos[0], iconsPos[1]);
		songThing.x = songThingPos[0];

		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

    var currentDialogue:Array<String> = [];
    var interactiveDialogueSpeed:Float = 0.04;
    var interactiveDialogueEndCallback:Void->Void;

    var dialogueEnded:Bool = false;
    var isInInteractiveDialogue:Bool = false;
    public var dialogueTimer:FlxTimer;
	public var thingTimer:Float = 1.8;
    public function startInteractiveDialogue(text:Array<String>, speed:Float = 0.04, ?endCallback:Void->Void)
    {
        isInInteractiveDialogue = true;
        dialogueEnded = false;

        currentDialogue = text;
        interactiveDialogueSpeed = speed;
        interactiveDialogueEndCallback = endCallback;

        if(currentDialogue.length > 0)
        {
            var currentLine:String = currentDialogue[0];
            character.playAnim('talk');

            if(dialogueTimer != null)
            {
                if(!dialogueTimer.finished) dialogueTimer.cancel();
                dialogueTimer.destroy();
            }

            FlxTween.cancelTweensOf(dialogueBox);
            FlxTween.cancelTweensOf(dialogueText);

            dialogueBox.y = 600;
            dialogueText.y = dialogueBox.y + 10;

            FlxTween.tween(dialogueBox, {alpha: 0.6, y: dialogueBox.y - 10}, 0.35, {ease: FlxEase.linear});
            FlxTween.tween(dialogueText, {alpha: 1, y: dialogueText.y - 10}, 0.35, {ease: FlxEase.linear});
            //dialogueBox.alpha = 0;
            //dialogueText.alpha = 0;

            dialogueText.resetText(currentLine);
            dialogueText.start(speed, true);
            dialogueText.completeCallback = function() 
            {
                dialogueEnded = true;
                character.playAnim('idle');
                currentDialogue.remove(currentLine);
                FlxTween.tween(dialogueBoxContinueSprite, {alpha: 1}, 0.4);
                //dialogueBoxContinueSprite.visible = true;
                dialogueTimer = new FlxTimer().start(thingTimer, function(t:FlxTimer)
                {
                    if(endCallback != null) endCallback();
                    //endDialogue(false);
                    //if(endCallback != null) endCallback();
                });
            }
        }
        else
        {
            isInInteractiveDialogue = false;
            endDialogue(true);
            if(endCallback != null) endCallback();
        }
    }

    function endDialogue(playAnimation:Bool = true)
    {
        if(playAnimation) character.playAnim('idle');
		dialogueText.resetText('');
		dialogueText.start(0.01, true);

        FlxTween.cancelTweensOf(dialogueBox);
        FlxTween.cancelTweensOf(dialogueText);
            
        FlxTween.tween(dialogueBox, {alpha: 0, y: dialogueBox.y + 10}, 0.35, {ease: FlxEase.linear});
        FlxTween.tween(dialogueText, {alpha: 0, y: dialogueText.y + 10}, 0.35, {ease: FlxEase.linear});
    }

	var canInteract:Bool = true;
	function giveGearToRobot(firstTime:Bool)
	{
		if(firstTime)
		{
			canInteract = false;
			FlxTween.tween(FlxG.camera, {zoom: 1.06, "scroll.x": 70}, 0.8, {ease: FlxEase.quartOut});

			FlxG.mouse.visible = false;

			var dialogue:Array<String> = [
				"Wait! That's my gear.",
				"Thank you so much for finding it! Now I can activate the singing module I've been missing this whole time...",
				"Now that you gave it to me, let's see if it still works as it used to. >:)",
			];

			startInteractiveDialogue(dialogue, 0.04, function()
			{
				FlxG.save.data.gaveGearToRobot = true;
				FlxG.save.flush();

				var songLowercase:String = Paths.formatToSongPath('Settings');
				var poop:String = Highscore.formatSong(songLowercase, 'bf', 2);

				try
				{
					Song.loadFromJson(poop, songLowercase);
					trace('Loading song: $poop');
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;

					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				}
				catch(e:haxe.Exception)
				{
					trace('Did not found $songLowercase/$poop!');
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

				#if (MODS_ALLOWED && DISCORD_ALLOWED)
				DiscordClient.loadModRPC();
				#end
			});
		}
		else
		{
			var songLowercase:String = Paths.formatToSongPath('Settings');
			var poop:String = Highscore.formatSong(songLowercase, 'bf', 2);

			try
			{
				Song.loadFromJson(poop, songLowercase);
				trace('Loading song: $poop');
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 2;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch(e:haxe.Exception)
			{
				trace('Did not found $songLowercase/$poop!');
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

			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
	}

	override function update(elapsed:Float) 
	{
		super.update(elapsed);

		if(character != null)
		{
			currentFrame = character.animation.curAnim.name == 'idle' ? character.animation.curAnim.curFrame : 0;

			if(ShopSubState.isItemUnlocked('Gear'))
			{
				if(FlxG.mouse.overlaps(character))
				{
					if(FlxG.mouse.justPressed)
					{
						giveGearToRobot(!FlxG.save.data.gaveGearToRobot);
					}
				}
			}
		}

		#if debug
			if(FlxG.keys.justPressed.T)
			{
				giveGearToRobot(true);
			}
		#end

        if(isInInteractiveDialogue)
        {
            if(controls.ACCEPT)
            {
                if(!dialogueEnded) 
                {
                    dialogueText.skip();
                    currentDialogue.remove(currentDialogue[0]);
                }
                startInteractiveDialogue(currentDialogue, interactiveDialogueSpeed, interactiveDialogueEndCallback);

                FlxTween.tween(dialogueBoxContinueSprite, {alpha: 0}, 0.2);
                //dialogueBoxContinueSprite.visible = false;
            }
        }

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if(canInteract)
		{
			if (controls.UI_UP_P)
				changeSelection(-1);
			if (controls.UI_DOWN_P)
				changeSelection(1);

			if (controls.BACK)
			{
				FlxG.sound.music.fadeOut(0.2);
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

					FlxTween.cancelTweensOf(bgColorr);
					FlxTween.cancelTweensOf(dialogueBox);
					FlxTween.cancelTweensOf(dialogueText);
					FlxTween.cancelTweensOf(character);
					FlxTween.cancelTweensOf(poloUp);
					FlxTween.cancelTweensOf(poloDown);
					FlxTween.cancelTweensOf(behindPoloUp);
					FlxTween.cancelTweensOf(songThing);
					FlxTween.cancelTweensOf(icons);

					var finalTimer:Float = 0.4;
					grpOptions.forEachAlive(function(spr:Alphabet)
					{
						FlxTween.cancelTweensOf(spr);
						FlxTween.tween(spr, {alpha: 0}, finalTimer);
					});

					FlxTween.tween(bg, {alpha: 0}, finalTimer);
					FlxTween.tween(icons, {alpha: 0}, finalTimer);
					FlxTween.tween(dialogueBox, {alpha: 0}, finalTimer);
					FlxTween.tween(dialogueText, {alpha: 0}, finalTimer);
					FlxTween.tween(character, {alpha: 0, y: character.y + 10}, finalTimer, {onComplete: function(t:FlxTween)
					{
						MainMenuState.iconsPos.insert(0, icons.x);
						MainMenuState.iconsPos.insert(1, icons.y);

						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						MusicBeatState.switchState(new MainMenuState());
					}});

					FlxTween.tween(poloUp, {y: -poloUp.height}, finalTimer, {ease: FlxEase.quartOut});
					FlxTween.tween(behindPoloUp, {y: -100}, finalTimer, {ease: FlxEase.quartOut});
					FlxTween.tween(songThing, {y: -100}, finalTimer, {ease: FlxEase.quartOut});
					FlxTween.tween(poloDown, {y: FlxG.height}, finalTimer, {ease: FlxEase.quartOut});
					FlxTween.color(bgColorr, finalTimer, bgColorr.color, 0xFFBFB4F1);
				}
			}
			else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
		}

		if(grpOptions != null)
		{
			for (num => item in grpOptions.members)
			{
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
			else
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
		FlxG.sound.play(Paths.sound('options/optionsScrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}