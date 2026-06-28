package states;

import flixel.FlxObject;
import objects.AttachedSprite;
import flixel.addons.display.FlxBackdrop;
import shaders.WiggleEffect;

typedef Credit = {
	name:String,
	icon:String,
	roles:Array<String>,
	socialMedias:Array<SocialMedia>,
	color:FlxColor
}

typedef SocialMedia = {
	icon:String,
	link:String
}

class CreditsStateYSides extends MusicBeatState
{
	public var canGoBack:Bool = false;
	public static var backFromCredits:Bool = false;
	public static var creditsTransition:Bool = false;
	var wentBack:Bool = false;

	var devs:Array<Credit> = [
		{
			name: 'gBv2209',
			icon: 'gbv',
			roles: ['Director', 'Concept Artist', 'Artist', 'Animator', 'Musician', 'Charter', 'Coder'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@gBv2209'
				},
				{
					icon: 'x',
					link: 'https://x.com/gbv2209'
				}
			],
			color: 0xFF2F6662
		},
		{
			name: 'Mr. Madera',
			icon: 'madera',
			roles: ['Director', 'Main Coder', 'Charter', 'Musician', 'Voice Actor'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@mrmadera1237'
				},
				{
					icon: 'x',
					link: 'https://x.com/MrMadera625'
				}
			],
			color: 0xFF8ACCE1
		},
		{
			name: 'Heromax',
			icon: 'hero',
			roles: ['Co-Director', 'Concept Artist', 'Artist', 'Charter'],
			socialMedias: [
				{
					icon: 'x',
					link: 'https://x.com/heromax_2498'
				}
			],
			color: 0xFF424452
		},
		{
			name: 'SFoxyDAC',
			icon: 'foxy',
			roles: ['Co-Director', 'Artist', 'Animator', 'Musician', 'Voice Actor'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@SFoxyDAC'
				},
				{
					icon: 'x',
					link: 'https://x.com/SFoxyDAC'
				}
			],
			color: 0xFFDC7D6F
		},
		{
			name: 'CloudyWave',
			icon: 'cloudy',
			roles: ['Co-Director', 'Musician', 'Charter'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@Cltp_fla'
				}
			],
			color: 0xFF363676
		},
		{
			name: 'Zhadnii',
			icon: 'ema',
			roles: ['Musician'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@zhadnii_'
				}
			],
			color: 0xFF3A3A75
		},
		{
			name: 'FlashMan07',
			icon: 'flash',
			roles: ['Musician', 'Concept Artist', 'Artist'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@FlashMan07'
				}
			],
			color: 0xFF912197
		},
		{
			name: 'Snowlui',
			icon: 'snowlui',
			roles: ['Musician'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/channel/UCSt4Fyu2syVMeGBHeZaWzyA'
				},
				{
					icon: 'x',
					link: 'https://x.com/Snowlui0831'
				}
			],
			color: 0xFF9C0053
		},
		{
			name: 'E1000MC',
			icon: 'emil',
			roles: ['Artist', 'Charter'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@E1000YT'
				},
				{
					icon: 'x',
					link: 'https://x.com/E1000TWOF'
				}
			],
			color: 0xFF1A8758
		},
		{
			name: 'JabaNSL',
			icon: 'jaba',
			roles: ['Musician', 'Charter'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@jabansl'
				}
			],
			color: 0xFFB8519D
		},
		{
			name: 'EliAnima',
			icon: 'elianimador',
			roles: ['Musician'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@EliMusic-v1i'
				},
				{
					icon: 'x',
					link: 'https://x.com/EliAnima_'
				}
			],
			color: 0xFFFFDD8E
		},
		{
			name: 'Dyscarn',
			icon: 'dyscarn',
			roles: ['Guest Coder'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://www.youtube.com/@Dyscarn'
				},
				{
					icon: 'x',
					link: 'https://x.com/Dyscarn'
				}
			],
			color: 0xFF5B556D
		},
		{
			name: 'Saturn',
			icon: 'sas',
			roles: ['- Me composer... -', 'drawer', 'I not cook'],
			socialMedias: [
				{
					icon: 'yt',
					link: 'https://youtu.be/-ThnaxyC6J8?si=1IuB_kx1GUeJ-4Ad'
				},
				{
					icon: 'x',
					link: 'https://youtu.be/MvRARbFMCBI?si=bfBbcig20FQwUgGL'
				}
			],
			color: 0xFF45725F
		}
	];

	var bg:FlxSprite;

	var backgroundGradientBottom:FlxSprite;

    var currentCharacter:FlxSprite;
    var devInfo:InfoAboutPerson;

	var psychText:FlxText;
	var icons:FlxBackdrop;

	var topY:Float;
	var bottomY:Float = 850;

	var tweenDuration:Float = 0.1;
    static var curSelected:Int = 0;

	var leftArrow:Alphabet;
	var rightArrow:Alphabet;

	var transition:FlxSprite;
	var callMeAGoodBOOOY:FlxSound;

	override function create() 
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		if(FlxG.sound.music.volume < 0.1) {
			FlxG.sound.playMusic(Paths.music('creditsMenu'));
			FlxG.sound.music.fadeIn(1);
		}

		bg = new FlxSprite(-80).makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		backgroundGradientBottom = new FlxSprite();
		backgroundGradientBottom.loadGraphic(Paths.image('titleState/gradientBottom'));
		backgroundGradientBottom.antialiasing = ClientPrefs.data.antialiasing;
		backgroundGradientBottom.scale.set(1, 1.3);
		backgroundGradientBottom.blend = ADD;
		backgroundGradientBottom.alpha = 0.38;
		backgroundGradientBottom.y = FlxG.height - backgroundGradientBottom.height;
		add(backgroundGradientBottom);

		icons = new FlxBackdrop(Paths.image('mainmenu/icons'), XY);
		icons.velocity.set(10, 10);
		icons.alpha = 0.45;
		icons.antialiasing = ClientPrefs.data.antialiasing;
		icons.scrollFactor.set();
		add(icons);

		icons.setPosition(MainMenuState.iconsPos[0], MainMenuState.iconsPos[1]);

        currentCharacter = new FlxSprite(60, 200);
		currentCharacter.loadGraphic(Paths.image('credits2/people/gbv'));
        currentCharacter.screenCenter(Y);
		currentCharacter.antialiasing = ClientPrefs.data.antialiasing;
		add(currentCharacter);

        devInfo = new InfoAboutPerson(devs[0].name, devs[0].roles, devs[0].socialMedias, devs[0].color);
        devInfo.x += 200;
        add(devInfo);

		psychText = new FlxText(0, 0, FlxG.width, 'Press TAB to view Psych Engine credits', 16);
		psychText.setFormat(Paths.font("FredokaOne-Regular.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		psychText.borderSize = 1.25;
		psychText.y = FlxG.height - psychText.height - 10;
		psychText.scrollFactor.set(0, 1);
		psychText.antialiasing = ClientPrefs.data.antialiasing;
		add(psychText);

		leftArrow = new Alphabet(10, 300, '<', true);
		add(leftArrow);

		rightArrow = new Alphabet(10, 300, '>', true);
		rightArrow.x = FlxG.width - rightArrow.width - 10;
		add(rightArrow);

        changeSelection();
		super.create();

		transition = new FlxSprite(-650, 0);
		transition.antialiasing = ClientPrefs.data.antialiasing;
		transition.loadGraphic(Paths.image('transition'));
		add(transition);

		FlxTween.tween(transition, {x: -2100}, 1, {ease: FlxEase.quartOut, onComplete: function(twn:FlxTween)
		{
			canGoBack = true;
		}});

		callMeAGoodBOOOY = new FlxSound();
		callMeAGoodBOOOY.loadEmbedded(Paths.sound('call-me-a-good-boy'), true);
		FlxG.sound.list.add(callMeAGoodBOOOY);
		callMeAGoodBOOOY.volume = 0;
		callMeAGoodBOOOY.play();
	}

	var psychScale:Float = 1;
	var targetScaleLeft:Float = 1;
	var targetScaleRight:Float = 1;
	override function update(elapsed:Float) {

		super.update(elapsed);

		var multLeft = FlxMath.lerp(leftArrow.scale.x, targetScaleLeft, elapsed * 20);
		leftArrow.scale.set(multLeft, multLeft);

		var multRight = FlxMath.lerp(rightArrow.scale.x, targetScaleRight, elapsed * 20);
		rightArrow.scale.set(multRight, multRight);

		if (controls.BACK && canGoBack) {

			FlxG.sound.music.fadeOut(0.65);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			wentBack = true;

			transition.x = FlxG.width;
			FlxTween.tween(transition, {x: -650}, 1, {ease: FlxEase.quartOut});
		
			backFromCredits = true;
			creditsTransition = true;
			canGoBack = false;
            
			MainMenuState.iconsPos.insert(0, icons.x);
			MainMenuState.iconsPos.insert(1, icons.y);

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				MusicBeatState.switchState(new MainMenuState());
			});
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if(controls.UI_LEFT_P)
        {
			leftArrow.scale.set(1.1, 1.1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
            changeSelection(-1);
        }

        if(controls.UI_RIGHT_P)
        {
			rightArrow.scale.set(1.1, 1.1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
            changeSelection(1);
        }

		if(FlxG.mouse.overlaps(leftArrow))
		{
			targetScaleLeft = 1.1;
			leftArrow.color = FlxColor.YELLOW;
			if(FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
			}
		}
		else
		{
			targetScaleLeft = 1;
			leftArrow.color = FlxColor.WHITE;
		}

		if(FlxG.mouse.overlaps(rightArrow))
		{
			targetScaleRight = 1.1;
			rightArrow.color = FlxColor.YELLOW;
			if(FlxG.mouse.justPressed)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
			}
		}
		else
		{
			targetScaleRight = 1;
			rightArrow.color = FlxColor.WHITE;
		}

		if(FlxG.keys.justPressed.TAB)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			MusicBeatState.switchState(new CreditsState());	
		}

		if(devs[curSelected].name == 'Saturn') callMeAGoodBOOOY.volume = 1;
		else callMeAGoodBOOOY.volume = 0;

		FlxG.mouse.visible = true;
	}

    function changeSelection(change:Int = 0)
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, devs.length - 1);

		final selectedDev: Credit = devs[curSelected];
		if(selectedDev.name == 'Saturn') FlxG.sound.play(Paths.sound('sosoasoas'));

		FlxTween.cancelTweensOf(currentCharacter);

		currentCharacter.scale.set(1.05, 1.05);
		FlxTween.tween(currentCharacter, {"scale.x": 1, "scale.y": 1}, 0.3, {ease: FlxEase.quartOut});

        // reload char
		currentCharacter.loadGraphic(Paths.image('credits2/people/${selectedDev.icon}'));
        currentCharacter.screenCenter(Y);
		currentCharacter.antialiasing = ClientPrefs.data.antialiasing;
		add(currentCharacter);

		// background color tween
		FlxTween.cancelTweensOf(bg);
		FlxTween.color(bg, 0.7, bg.color, selectedDev.color, {ease: FlxEase.quartOut});

        // reload info
        devInfo.refresh(selectedDev.name, selectedDev.roles, selectedDev.socialMedias, selectedDev.color);
    }
}

class InfoAboutPerson extends FlxSpriteGroup
{
	var squareBg:FlxSprite;
	var personName:Alphabet;
	var rolsGrp:FlxSpriteGroup;
	var socialMediasGrp:FlxSpriteGroup;
	var socialMedias:Array<SocialMedia> = [];

	public function new(name:String, rols:Array<String>, avaibleSocialMedias:Array<SocialMedia>, color:FlxColor)
	{
		super();

		socialMedias = avaibleSocialMedias;

		squareBg = new FlxSprite();
		//squareBg.makeGraphic(600, 550, 0xFF000000);
		squareBg.loadGraphic(Paths.image('credits2/background'));
		squareBg.alpha = 0.7;
		squareBg.scrollFactor.set();
		squareBg.screenCenter();
		add(squareBg);

		personName = new Alphabet(0, squareBg.y + 10, name, true);
		personName.setScale(0.85);
		personName.x = squareBg.x + squareBg.width / 2 - personName.width / 2;
		personName.scrollFactor.set();
		personName.color = color;
		add(personName);

		rolsGrp = new FlxSpriteGroup();
		add(rolsGrp);

		socialMediasGrp = new FlxSpriteGroup();
		add(socialMediasGrp);

		for(i in 0...rols.length)
		{
			var rolTxt = new Alphabet(0, 0, rols[i], true);
			rolTxt.setScale(0.7);
			if(rols[i] == 'Director' || rols[i] == 'Co-Director') rolTxt.color = 0xFFFFDA8F;
			rolTxt.y = personName.y + personName.height + 30 + ((rolTxt.height + 10) * i);
			rolTxt.scrollFactor.set();
			rolTxt.screenCenter(X);
			rolsGrp.add(rolTxt);
		}

		for(i in 0...avaibleSocialMedias.length)
		{
			if(socialMediasGrp.members[i-1] != null) socialMediasGrp.members[i-1].x -= socialMediasGrp.members[i-1].width;

			var socialMediaIcon = new FlxSprite();
			trace('Loading the following social media ($name): ${avaibleSocialMedias[i].icon}');
			switch(avaibleSocialMedias[i].icon)
			{
				case 'yt':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/yt'));
				case 'disc':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/disc'));
				case 'x':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/X'));
			}
			socialMediaIcon.scrollFactor.set();
			socialMediaIcon.y = squareBg.y + squareBg.height - socialMediaIcon.height - 10;
			socialMediaIcon.x = squareBg.x + squareBg.width - socialMediaIcon.width - 10;
			socialMediaIcon.ID = i;
			socialMediasGrp.add(socialMediaIcon);
		}
	}

    public function refresh(name:String, rols:Array<String>, avaibleSocialMedias:Array<SocialMedia>, color:FlxColor)
    {
		socialMedias = avaibleSocialMedias;

        personName.text = name;
		personName.x = squareBg.x + squareBg.width / 2 - personName.width / 2;
		if(color != personName.color) personName.color = color;
        
        // reset groups
        rolsGrp.forEach(function(obj:FlxSprite) { rolsGrp.remove(obj); });
        socialMediasGrp.forEach(function(obj:FlxSprite) { socialMediasGrp.remove(obj); });

		for(i in 0...rols.length)
		{
			var rolTxt = new Alphabet(0, 0, rols[i], true);
			rolTxt.setScale(0.7);
			if(rols[i] == 'Director' || rols[i] == 'Co-Director') rolTxt.color = 0xFFFFDA8F;
			rolTxt.y = personName.y + personName.height + 30 + ((rolTxt.height + 10) * i);
			rolTxt.scrollFactor.set();
			rolTxt.screenCenter(X);
			rolsGrp.add(rolTxt);
		}

		for(i in 0...avaibleSocialMedias.length)
		{
			if(socialMediasGrp.members[i-1] != null) socialMediasGrp.members[i-1].x -= socialMediasGrp.members[i-1].width;

			var socialMediaIcon = new FlxSprite();
			trace('Loading the following social media ($name): ${avaibleSocialMedias[i].icon}');
			switch(avaibleSocialMedias[i].icon)
			{
				case 'yt':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/yt'));
				case 'disc':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/disc'));
				case 'x':
					socialMediaIcon.loadGraphic(Paths.image('credits2/icons/X'));
			}
			socialMediaIcon.scrollFactor.set();
			socialMediaIcon.y = squareBg.y + squareBg.height - socialMediaIcon.height - 10;
			socialMediaIcon.x = squareBg.x + squareBg.width - socialMediaIcon.width - 210;
			socialMediaIcon.ID = i;
			socialMediasGrp.add(socialMediaIcon);
		}
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		socialMediasGrp.forEach(function(spr:FlxSprite)
		{
			if(FlxG.mouse.overlaps(spr))
			{
				spr.alpha = 1;
				if(FlxG.mouse.justPressed)
				{
					CoolUtil.browserLoad(socialMedias[spr.ID].link);
				}
			}
			else spr.alpha = 0.7;
		});
	}
}