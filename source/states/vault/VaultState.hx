package states.vault;

import flixel.addons.display.FlxBackdrop;

class VaultState extends MusicBeatState
{
    var colorBg:FlxSprite;
    var bg:FlxSprite;
    var checker:FlxBackdrop;
    var bgCoolEffect:FlxBackdrop;
    var floor:FlxSprite;
    var shelf:FlxSprite;
    var sign:FlxSprite;
    var gbvCharacter:FlxSprite;
    var tapiCharacter:FlxSprite;
    var table:FlxSprite;
    var machine:FlxSprite;

    var madreaCharacter:FlxSprite;
    var heroCharacter:FlxSprite;

    var poloUp:FlxSprite;
    var poloDown:FlxSprite;

    var camMain:FlxCamera;
    var camHUD:FlxCamera;

    override function create()
    {
        super.create();

		if(FlxG.sound.music != null)
		{
			if(!FlxG.sound.music.playing)
			{
				trace('Main menu music is not playing, starting vault menu music!');
				FlxG.sound.playMusic(Paths.music('vault/vaultTheme'), 0);
				FlxG.sound.music.fadeIn(4);
			}
		}

        FlxG.mouse.visible = true;

        camMain = initPsychCamera();

        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        add(camHUD);
        
        FlxG.cameras.add(camHUD, false);

        colorBg = new FlxSprite();
        colorBg.makeGraphic(1350, 800, 0xFFD9B4FD);
        add(colorBg);

        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('vault/background'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

        var checkerSpeed:Float = 15;
        checker = new FlxBackdrop(Paths.image('freePlay/NEW/checker'));
        checker.antialiasing = ClientPrefs.data.antialiasing;
        checker.velocity.set(0, checkerSpeed);
        add(checker);

        var coolEffectSpeed:Float = 15;
        bgCoolEffect = new FlxBackdrop(Paths.image('vault/background_cool_effect'), X);
        bgCoolEffect.antialiasing = ClientPrefs.data.antialiasing;
        bgCoolEffect.velocity.set(coolEffectSpeed, 0);
        bgCoolEffect.blend = OVERLAY;
        add(bgCoolEffect);

        floor = new FlxSprite();
        floor.loadGraphic(Paths.image('vault/floor'));
        floor.antialiasing = ClientPrefs.data.antialiasing;
        floor.y = FlxG.height - floor.height;
        add(floor);

        bgCoolEffect.y = floor.y - (bgCoolEffect.height / 2);

        shelf = new FlxSprite();
        shelf.loadGraphic(Paths.image('vault/shlef'));
        shelf.antialiasing = ClientPrefs.data.antialiasing;
        shelf.x = 45;
        shelf.y = 60;
        add(shelf);

        sign = new FlxSprite();
        sign.loadGraphic(Paths.image('vault/sign'));
        sign.antialiasing = ClientPrefs.data.antialiasing;
        sign.screenCenter(X);
        sign.y = 20;
        add(sign);

        gbvCharacter = new FlxSprite();
        gbvCharacter.frames = Paths.getSparrowAtlas('vault/characters/uva');
        gbvCharacter.animation.addByPrefix('idle', 'idle', 24, true);
        gbvCharacter.animation.addByPrefix('walk', 'walking', 24, true);
        gbvCharacter.animation.play('idle');
        gbvCharacter.antialiasing = ClientPrefs.data.antialiasing;
        gbvCharacter.x = FlxG.width + 30;
        gbvCharacter.y = floor.y - gbvCharacter.height + 50;
        add(gbvCharacter);

        tapiCharacter = new FlxSprite();
        tapiCharacter.frames = Paths.getSparrowAtlas('vault/characters/GAMERTAP64');
        tapiCharacter.animation.addByPrefix('walk', 'walk', 24, true);
        tapiCharacter.animation.addByPrefix('placing', 'recolocating', 24, true);
        tapiCharacter.animation.play('idle');
        tapiCharacter.antialiasing = ClientPrefs.data.antialiasing;
        tapiCharacter.x = FlxG.width + 30;
        tapiCharacter.y = floor.y - tapiCharacter.height + 70;
        add(tapiCharacter);

        madreaCharacter = new FlxSprite();
        madreaCharacter.frames = Paths.getSparrowAtlas('vault/characters/madrea');
        madreaCharacter.animation.addByPrefix('idle', 'idle', 24, true);
        madreaCharacter.animation.addByPrefix('talk', 'talk', 24, true);
        madreaCharacter.animation.play('idle');
        madreaCharacter.antialiasing = ClientPrefs.data.antialiasing;
        add(madreaCharacter);

        table = new FlxSprite();
        table.loadGraphic(Paths.image('vault/table'));
        table.antialiasing = ClientPrefs.data.antialiasing;
        table.x = 738;
        table.y = 442;
        add(table);

        madreaCharacter.x = table.x + 110;
        madreaCharacter.y = table.y - madreaCharacter.height + 45;

        machine = new FlxSprite();
        machine.loadGraphic(Paths.image('vault/money'));
        machine.antialiasing = ClientPrefs.data.antialiasing;
        machine.x = table.x + table.width - machine.width - 30;
        machine.y = table.y - machine.height + 20;
        add(machine);

        heroCharacter = new FlxSprite();
        heroCharacter.frames = Paths.getSparrowAtlas('vault/characters/termomix');
        heroCharacter.animation.addByPrefix('walk', 'walking', 24, true);
        heroCharacter.animation.play('idle');
        heroCharacter.antialiasing = ClientPrefs.data.antialiasing;
        heroCharacter.scale.set(1.1, 1.1);
        heroCharacter.updateHitbox();
        heroCharacter.x = FlxG.width + 30;
        heroCharacter.y = table.y + table.height - heroCharacter.height + 50;
        add(heroCharacter);

        poloUp = new FlxSprite();
        poloUp.loadGraphic(Paths.image('vault/poloUp'));
        poloUp.antialiasing = ClientPrefs.data.antialiasing;
        poloUp.cameras = [camHUD];
        add(poloUp);

        poloDown = new FlxSprite();
        poloDown.loadGraphic(Paths.image('vault/poloDown'));
        poloDown.antialiasing = ClientPrefs.data.antialiasing;
        poloDown.y = FlxG.height - poloDown.height;
        poloDown.cameras = [camHUD];
        add(poloDown);

        spawnGbv();
        new FlxTimer().start(3, function(tmr:FlxTimer)
        {
            spawnTapi();
        });
        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            spawnHero();
        });
    }

    function spawnGbv()
    {
        gbvCharacter.flipX = false;
        gbvCharacter.animation.play('walk', true);
        FlxTween.tween(gbvCharacter, {x: 535}, 6, {onComplete: function(twn:FlxTween)
        {
            gbvCharacter.animation.play('idle', true);
            new FlxTimer().start(FlxG.random.float(3, 5), function(tmr:FlxTimer)
            {
                gbvCharacter.flipX = true;
                gbvCharacter.animation.play('walk', true);
                FlxTween.tween(gbvCharacter, {x: FlxG.width + 30}, 6, {onComplete: function(twn:FlxTween)
                {
                    new FlxTimer().start(FlxG.random.float(2, 3), function(tmr:FlxTimer)
                    {
                        spawnGbv();
                    });
                }});
            });
        }});
    }

    var rightSpawnTapi:Bool = false;
    function spawnTapi()
    {
        if(!rightSpawnTapi)
        {
            rightSpawnTapi = true;
            tapiCharacter.flipX = false;
            tapiCharacter.animation.play('walk', true);
            FlxTween.tween(tapiCharacter, {x: 220}, 6, {onComplete: function(twn:FlxTween)
            {
                tapiCharacter.animation.play('placing', true);
                new FlxTimer().start(FlxG.random.float(3, 5), function(tmr:FlxTimer)
                {
                    tapiCharacter.animation.play('walk', true);
                    FlxTween.tween(tapiCharacter, {x: -tapiCharacter.width}, 2, {onComplete: function(twn:FlxTween)
                    {
                        // start loop again after random time
                        new FlxTimer().start(FlxG.random.float(2, 3), function(tmr:FlxTimer)
                        {
                            spawnTapi();
                        });
                    }});
                });
            }});
        }
        else
        {
            rightSpawnTapi = false;
            tapiCharacter.flipX = true;
            tapiCharacter.animation.play('walk', true);
            FlxTween.tween(tapiCharacter, {x: 190}, 2, {onComplete: function(twn:FlxTween)
            {
                tapiCharacter.animation.play('placing', true);
                new FlxTimer().start(FlxG.random.float(3, 5), function(tmr:FlxTimer)
                {
                    tapiCharacter.animation.play('walk', true);
                    FlxTween.tween(tapiCharacter, {x: FlxG.width + 30}, 6, {onComplete: function(twn:FlxTween)
                    {
                        // start loop again after random time
                        new FlxTimer().start(FlxG.random.float(2, 3), function(tmr:FlxTimer)
                        {
                            spawnTapi();
                        });
                    }});
                });
            }});
        }
    }

    var rightSpawnHero:Bool = false;
    function spawnHero()
    {
        if(!rightSpawnHero)
        {
            rightSpawnHero = true;
            heroCharacter.flipX = false;
            heroCharacter.animation.play('walk', true);
            FlxTween.tween(heroCharacter, {x: -heroCharacter.width}, 9, {onComplete: function(twn:FlxTween)
            {
                new FlxTimer().start(FlxG.random.float(2, 3), function(tmr:FlxTimer)
                {
                    spawnHero();
                });
            }});
        }
        else
        {
            rightSpawnHero = false;
            heroCharacter.flipX = true;
            heroCharacter.animation.play('walk', true);
            FlxTween.tween(heroCharacter, {x: FlxG.width + 30}, 9, {onComplete: function(twn:FlxTween)
            {
                new FlxTimer().start(FlxG.random.float(2, 3), function(tmr:FlxTimer)
                {
                    spawnHero();
                });
            }});
        }
    }

	var scrollMultiplier:Float = 3;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

		final hudMousePos = FlxG.mouse.getScreenPosition(camMain);

		var multX = (hudMousePos.x - (FlxG.width / 2)) / (FlxG.width / 2);
		var multY = (hudMousePos.y - (FlxG.height / 2)) / (FlxG.height / 2);

		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (multX * scrollMultiplier), elapsed * 10);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (multY * scrollMultiplier), elapsed * 10);

        if(controls.BACK)
        {
			FlxG.sound.music.fadeOut(0.2);
			FlxG.sound.play(Paths.sound('cancelMenu'));
            new FlxTimer().start(0.4, function(tmr:FlxTimer)
            {
                MusicBeatState.switchState(new MainMenuState());
            });
        }
    }
}