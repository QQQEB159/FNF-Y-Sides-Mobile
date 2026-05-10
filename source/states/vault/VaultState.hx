package states.vault;

import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.text.FlxTypeText;
import shaders.BlurShader;
import openfl.filters.ShaderFilter;

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

    var blackShopBackground:FlxSprite;

    var madreaCharacter:FlxSprite;
    var heroCharacter:FlxSprite;
    var heroSpawnTimer:FlxTimer;

    var emilCharacter:FlxSprite;
    var snowCharacter:FlxSprite;

    var preShopArr:Array<String> = ['buy', 'talk', 'exit'];
    var preShopGrp:FlxTypedGroup<FlxSprite>;
    var preShopHand:FlxSprite;
    var preShopCurSelected:Int = 0;

    public static var poloUp:FlxSprite;
    public static var poloDown:FlxSprite;

    var camMain:FlxCamera;
    var camHUD:FlxCamera;

    var camFollow:FlxObject;

    var dialogueBox:FlxSprite;
    var dialogueText:FlxTypeText;
    var dialogueBoxContinueSprite:FlxSprite;

    override function create()
    {
        super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Vault", null);
		#end

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

        blurShader = new BlurShader();
        blurShader.radius.value = [0];
        blurFilter = new ShaderFilter(blurShader);

        FlxG.camera.filters = [blurFilter];

        colorBg = new FlxSprite();
        colorBg.makeGraphic(1350, 800, 0xFFBFB4F1);
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
        shelf.frames = Paths.getSparrowAtlas('vault/shlef');
        shelf.animation.addByPrefix('idle', 'idle');
        shelf.animation.addByPrefix('select', 'select');
        shelf.animation.play('idle');
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

        blackShopBackground = new FlxSprite();
        blackShopBackground.makeGraphic(1500, 800, 0xFF000000);
        blackShopBackground.alpha = 0;
        add(blackShopBackground);

        madreaCharacter = new FlxSprite();
        madreaCharacter.frames = Paths.getSparrowAtlas('vault/characters/madrea');
        madreaCharacter.animation.addByPrefix('idle', 'idle', 24, true);
        madreaCharacter.animation.addByPrefix('talk', 'talk', 24, true);
        madreaCharacter.animation.play('idle');
        madreaCharacter.antialiasing = ClientPrefs.data.antialiasing;
        add(madreaCharacter);

        table = new FlxSprite();
        //table.loadGraphic(Paths.image('vault/table'));
        table.frames = Paths.getSparrowAtlas('vault/table');
        table.animation.addByPrefix('idle', 'idle');
        table.animation.addByPrefix('select', 'select');
        table.animation.play('idle');
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
        heroCharacter.color = 0xFFFFFFFF;
        heroCharacter.x = FlxG.width + 30;
        heroCharacter.y = table.y + table.height - heroCharacter.height + 50;
        add(heroCharacter);

        emilCharacter = new FlxSprite();
        emilCharacter.loadGraphic(Paths.image('vault/characters/emil'));
        emilCharacter.x = FlxG.width + 30;
        emilCharacter.y = FlxG.height - emilCharacter.height;
        add(emilCharacter);

        snowCharacter = new FlxSprite();
        snowCharacter.loadGraphic(Paths.image('vault/characters/nieve'));
        snowCharacter.y = FlxG.height - snowCharacter.height;
        snowCharacter.x = -snowCharacter.width;
        snowCharacter.flipX = true;
        add(snowCharacter);

        preShopGrp = new FlxTypedGroup<FlxSprite>();
        preShopGrp.cameras = [camHUD];
        add(preShopGrp);

        for(i in 0...preShopArr.length)
        {
            var spr = new FlxSprite();
            //spr.loadGraphic(Paths.image('vault/shopItems/${preShopArr[i]}'));
            spr.frames = Paths.getSparrowAtlas('vault/shopItems/${preShopArr[i]}');
            spr.animation.addByPrefix('idle', 'idle', 24, true);
            spr.animation.play('idle');
            spr.scale.set(1.05, 1.05);
            spr.updateHitbox();
            spr.antialiasing = ClientPrefs.data.antialiasing;
            spr.x = 270;
            spr.y = (360 - spr.height / 2) + ((spr.height + 25) * (i-1));
            spr.alpha = 0;
            spr.ID = i;
            preShopGrp.add(spr);
        }

        preShopHand = new FlxSprite();
        preShopHand.frames = Paths.getSparrowAtlas('vault/shopItems/hand');
        preShopHand.animation.addByPrefix('idle', 'idle', 24, true);
        preShopHand.animation.play('idle');
        preShopHand.antialiasing = ClientPrefs.data.antialiasing;
        preShopHand.alpha = 0;
        preShopHand.cameras = [camHUD];
        preShopHand.scale.set(0.96, 0.96);
        preShopHand.updateHitbox();
        add(preShopHand);

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

		dialogueBox = new FlxSprite(40, 600).makeGraphic(1200, 80, FlxColor.BLACK);
		dialogueBox.alpha = 0;
		dialogueBox.antialiasing = ClientPrefs.data.antialiasing;
        dialogueBox.cameras = [camHUD];
		add(dialogueBox);

		dialogueText = new FlxTypeText(50, dialogueBox.y + 10, 1180, "", 32);
		dialogueText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dialogueText.scrollFactor.set();
		dialogueText.sounds = [FlxG.sound.load(Paths.sound('vault/maderatalk'), 0.6)];
		dialogueText.antialiasing = ClientPrefs.data.antialiasing;
        dialogueText.cameras = [camHUD];
		add(dialogueText);

        dialogueBoxContinueSprite = new FlxSprite();
        dialogueBoxContinueSprite.loadGraphic(Paths.image('vault/continueDialogue'));
        dialogueBoxContinueSprite.x = dialogueBox.x + dialogueBox.width - dialogueBoxContinueSprite.width - 3;
        dialogueBoxContinueSprite.y = (dialogueBox.y - 10) + dialogueBox.height - dialogueBoxContinueSprite.height - 3;
        dialogueBoxContinueSprite.alpha = 0;
        dialogueBoxContinueSprite.cameras = [camHUD];
		dialogueBoxContinueSprite.scrollFactor.set();
        add(dialogueBoxContinueSprite);
        
        FlxTween.tween(dialogueBoxContinueSprite, {x: dialogueBoxContinueSprite.x - 15}, 0.92, {ease: FlxEase.cubeInOut, type: PINGPONG});

        initTransition();

        // handle spawn times
        new FlxTimer().start(16, function(tmr:FlxTimer)
        {
            spawnGbv();
        });
        new FlxTimer().start(3, function(tmr:FlxTimer)
        {
            spawnTapi();
        });
        heroSpawnTimer = new FlxTimer().start(12, function(tmr:FlxTimer)
        {
            spawnHero();
        }, 0);
        new FlxTimer().start(FlxG.random.float(60, 120), function(tmr:FlxTimer)
        {
            spawnEmil();
        });
        new FlxTimer().start(FlxG.random.float(60, 120), function(tmr:FlxTimer)
        {
            spawnSnow();
        });

        preShopChangeSelection();
        randomStartIndex = FlxG.random.int(0, randomTextsArr.length - 1);

        var dialogue:Array<String> = [
            "Hey! I think it's the first time we see each other.",
            "Welcome to the vault! This is the place where we store your progress",
            "You can also buy some cool stuff here",
            "Well, that's all for now...",
            "Break a leg out there!"
        ];

        new FlxTimer().start(transDuration, function(tmr:FlxTimer)
        {
            FlxG.save.data.firstTimeOnVault = FlxG.save.data.firstTimeOnVault != null ? FlxG.save.data.firstTimeOnVault : true;
            var test = true;
            if(test)
            {
                updateScroll = false;
                FlxTween.cancelTweensOf(FlxG.camera);
                FlxTween.cancelTweensOf(blackShopBackground);

                FlxTween.tween(FlxG.camera, {zoom: 1.25, "scroll.x": 100}, 1.45, {ease: FlxEase.quartOut});
                FlxTween.tween(blackShopBackground, {alpha: 0.07}, 1.45);
                
                startInteractiveDialogue(dialogue, 0.04, function()
                {
                    FlxG.save.data.firstTimeOnVault = false;

                    updateScroll = true;

                    FlxTween.cancelTweensOf(FlxG.camera);
                    FlxTween.cancelTweensOf(blackShopBackground);

                    FlxTween.tween(FlxG.camera, {zoom: 1}, 1.05, {ease: FlxEase.quartOut});
                    FlxTween.tween(blackShopBackground, {alpha: 0}, 1.05);
                });
            }
            else
            {
                    startDialogue('Hey! We are finishing to place your progress...');
            }
        });

    }

    var transDuration:Float = 0.65;
    var backTransDuration:Float = 0.55;
    function initTransition()
    {
        // bg.alpha = 0;
        // FlxTween.tween(bg, {alpha: 1}, transDuration, {ease: FlxEase.quartOut});

        checker.alpha = 0;
        FlxTween.tween(checker, {alpha: 1}, transDuration, {ease: FlxEase.quartOut});

        bgCoolEffect.alpha = 0;
        bgCoolEffect.y = FlxG.height - (bgCoolEffect.height / 2);
        FlxTween.tween(bgCoolEffect, {alpha: 1, y: (FlxG.height - floor.height) - (bgCoolEffect.height / 2)}, transDuration, {ease: FlxEase.quartOut});

        floor.y = FlxG.height;
        FlxTween.tween(floor, {y: FlxG.height - floor.height}, transDuration * 0.5, {ease: FlxEase.quartOut});

        shelf.y = -200;
        FlxTween.tween(shelf, {y: 60}, transDuration, {ease: FlxEase.bounceOut});

        sign.y = -220;
        FlxTween.tween(sign, {y: 20}, transDuration * 2, {ease: FlxEase.quartOut});

        table.x = FlxG.width;
        FlxTween.tween(table, {x: 738}, transDuration, {ease: FlxEase.quartOut});

        madreaCharacter.x = FlxG.width + 110;
        FlxTween.tween(madreaCharacter, {x: 738 + 110}, transDuration, {ease: FlxEase.quartOut});

        machine.x = table.x + table.width - machine.width - 30;
        FlxTween.tween(machine, {x: 738 + table.width - machine.width - 30}, transDuration, {ease: FlxEase.quartOut});

        poloUp.y = -poloUp.height;
        FlxTween.tween(poloUp, {y: 0}, transDuration, {ease: FlxEase.quartOut});

        poloDown.y = FlxG.height;
        FlxTween.tween(poloDown, {y: FlxG.height - poloDown.height}, transDuration, {ease: FlxEase.quartOut});
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
                    new FlxTimer().start(FlxG.random.float(5, 12), function(tmr:FlxTimer)
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
                        new FlxTimer().start(FlxG.random.float(6, 8), function(tmr:FlxTimer)
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
                        new FlxTimer().start(FlxG.random.float(6, 8), function(tmr:FlxTimer)
                        {
                            spawnTapi();
                        });
                    }});
                });
            }});
        }
    }

    var rightSpawnHero:Bool = false;
    var isHeroWalking:Bool = false;
    function spawnHero()
    {
        isHeroWalking = true;
        if(!rightSpawnHero)
        {
            rightSpawnHero = true;
            heroCharacter.flipX = false;
            heroCharacter.animation.play('walk', true);
            FlxTween.tween(heroCharacter, {x: -heroCharacter.width}, 9, {onComplete: function(twn:FlxTween)
            {
                isHeroWalking = false;
            }});
        }
        else
        {
            rightSpawnHero = false;
            heroCharacter.flipX = true;
            heroCharacter.animation.play('walk', true);
            FlxTween.tween(heroCharacter, {x: FlxG.width + 30}, 9, {onComplete: function(twn:FlxTween)
            {
                isHeroWalking = false;
            }});
        }
    }

    function spawnEmil()
    {
        FlxTween.tween(emilCharacter, {x: -emilCharacter.width}, 6);
    }

    function spawnSnow()
    {
        FlxTween.tween(snowCharacter, {x: FlxG.width + 30}, 6);
    }

    var wentBack:Bool = false;
    var updateScroll:Bool = true;
	var scrollMultiplier:Float = 3;
    override function update(elapsed:Float)
    {
        super.update(elapsed);

		final hudMousePos = FlxG.mouse.getScreenPosition(camMain);

		var multX = (hudMousePos.x - (FlxG.width / 2)) / (FlxG.width / 2);
		var multY = (hudMousePos.y - (FlxG.height / 2)) / (FlxG.height / 2);

        if(updateScroll)
        {
		    FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (multX * scrollMultiplier), elapsed * 10);
		    FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (multY * scrollMultiplier), elapsed * 10);
        }

        handleMouseBehaviour(elapsed);

        preShopHand.x = FlxMath.lerp(preShopHand.x, preShopHandXTarget, elapsed * 15);
        preShopHand.y = FlxMath.lerp(preShopHand.y, preShopHandYTarget, elapsed * 15);

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

        if(isOnPreShop && canInteractPreShopUI)
        {
            if(controls.UI_UP_P)
            {
                preShopChangeSelection(-1);
            }

            if(controls.UI_DOWN_P)
            {
                preShopChangeSelection(1);
            }

            if(controls.ACCEPT)
            {
                endDialogue();
                preShopSelect();
            }

            if(controls.BACK)
            {
                endDialogue();
                zoomOutFromShop();
            }
        }
        else if(!isOnPreShop && !isOnCollectionables)
        {
            if(controls.BACK && !wentBack && !isInInteractiveDialogue)
            {
                wentBack = true;
                endDialogue();

                FlxTimer.globalManager.clear();
                FlxG.sound.music.fadeOut(0.2, 0, function(twn:FlxTween)
                {
                    FlxG.sound.music.stop();
                });
                FlxG.sound.play(Paths.sound('cancelMenu'));

                FlxTransitionableState.skipNextTransIn = true;
                FlxTransitionableState.skipNextTransOut = true;

                FlxTween.cancelTweensOf(bg);
                FlxTween.cancelTweensOf(checker);
                FlxTween.cancelTweensOf(bgCoolEffect);
                FlxTween.cancelTweensOf(floor);
                FlxTween.cancelTweensOf(shelf);
                FlxTween.cancelTweensOf(sign);
                FlxTween.cancelTweensOf(table);
                FlxTween.cancelTweensOf(madreaCharacter);
                FlxTween.cancelTweensOf(machine);
                FlxTween.cancelTweensOf(poloUp);
                FlxTween.cancelTweensOf(poloDown);
                
                FlxTween.tween(bg, {alpha: 0}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(checker, {alpha: 0}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(bgCoolEffect, {alpha: 0, y: FlxG.height - (bgCoolEffect.height / 2)}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(floor, {y: FlxG.height}, backTransDuration * 0.5, {ease: FlxEase.quartOut});
                FlxTween.tween(shelf, {y: -500}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(sign, {y: -520}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(table, {x: FlxG.width}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(madreaCharacter, {x: FlxG.width + 110}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(tapiCharacter, {y: FlxG.height}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(gbvCharacter, {y: FlxG.height}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(heroCharacter, {y: FlxG.height}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(emilCharacter, {y: FlxG.height}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(snowCharacter, {y: FlxG.height}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(machine, {x: FlxG.width + table.width - machine.width - 30}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(poloUp, {y: -poloUp.height}, backTransDuration, {ease: FlxEase.quartOut});
                FlxTween.tween(poloDown, {y: FlxG.height}, backTransDuration, {ease: FlxEase.quartOut});

                new FlxTimer().start(backTransDuration, function(tmr:FlxTimer)
                {
                    MusicBeatState.switchState(new MainMenuState());
                });
            }
        }
    }

    function handleMouseBehaviour(elapsed:Float)
    {
        if(isInInteractiveDialogue) return;

        if(isOnPreShop)
        {

        }
        else if(isOnCollectionables)
        {

        }
        else
        {
            // shop table
            if(FlxG.mouse.overlaps(table))
            {
                table.animation.play('select');
                if(FlxG.mouse.justPressed)
                {
                    zoomCameraToShop();
                }
            }
            else
            {
                table.animation.play('idle');
            }

            // shelf
            if(FlxG.mouse.overlaps(shelf))
            {
                shelf.animation.play('select');
                if(FlxG.mouse.justPressed)
                {
                    if(blurShaderTween != null) blurShaderTween.cancel();
                    blurShaderTween = FlxTween.num(0, 5, 1, {ease: FlxEase.quartOut, onComplete: (_) -> blurShaderTween = null}, function(v:Float)
                    {
                        blurShader.radius.value[0] = v;
                    });

                    persistentUpdate = true;

                    var collectionables = new CollectionablesSubState();
                    collectionables.cameras = [camHUD];
                    openSubState(collectionables);

                    isOnCollectionables = true;

                    endDialogue();

                    FlxTween.cancelTweensOf(poloDown);
                    FlxTween.tween(poloDown, {y: FlxG.height}, 0.45, {ease: FlxEase.quintOut});
                }
            }
            else
            {
                shelf.animation.play('idle');
            }
        }
    }

	public var thingTimer:Float = 1.8;
    public var dialogueTimer:FlxTimer;
	public function startDialogue(text:String, speed:Float = 0.04, ?endCallback:Void->Void)
	{
        madreaCharacter.animation.play('talk');

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

		dialogueText.resetText(text);
		dialogueText.start(speed, true);
		dialogueText.completeCallback = function() 
		{
            madreaCharacter.animation.play('idle');
			dialogueTimer = new FlxTimer().start(thingTimer, function(t:FlxTimer)
			{
                endDialogue(false);
                if(endCallback != null) endCallback();
			});
		}
	}

    var currentDialogue:Array<String> = [];
    var interactiveDialogueSpeed:Float = 0.04;
    var interactiveDialogueEndCallback:Void->Void;

    var dialogueEnded:Bool = false;
    var isInInteractiveDialogue:Bool = false;
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
            madreaCharacter.animation.play('talk');

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
                madreaCharacter.animation.play('idle');
                currentDialogue.remove(currentLine);
                FlxTween.tween(dialogueBoxContinueSprite, {alpha: 1}, 0.4);
                //dialogueBoxContinueSprite.visible = true;
                dialogueTimer = new FlxTimer().start(thingTimer, function(t:FlxTimer)
                {
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
        if(playAnimation) madreaCharacter.animation.play('idle');
		dialogueText.resetText('');
		dialogueText.start(0.01, true);

        FlxTween.cancelTweensOf(dialogueBox);
        FlxTween.cancelTweensOf(dialogueText);
            
        FlxTween.tween(dialogueBox, {alpha: 0, y: dialogueBox.y + 10}, 0.35, {ease: FlxEase.linear});
        FlxTween.tween(dialogueText, {alpha: 0, y: dialogueText.y + 10}, 0.35, {ease: FlxEase.linear});
    }

    var isOnPreShop:Bool = false;
    var isOnCollectionables:Bool = false;
    function zoomCameraToShop()
    {
        // if hero is walking make him run so it doesn't bother you while you buy stuff
        if(isHeroWalking)
        {
            isHeroWalking = false;
            FlxTween.cancelTweensOf(heroCharacter);

            heroCharacter.color = 0xFFFFFFFF;
            FlxTween.color(heroCharacter, 2, heroCharacter.color, 0xFF808080);
            FlxTween.tween(heroCharacter, {x: rightSpawnHero ? -heroCharacter.width : FlxG.width + 30}, 2);
        }

        FlxG.sound.play(Paths.sound('vault/zoomIn'));

        heroSpawnTimer.active = false;
        isOnPreShop = true;
        updateScroll = false;
        FlxTween.cancelTweensOf(FlxG.camera);
        FlxTween.cancelTweensOf(blackShopBackground);

        FlxTween.tween(FlxG.camera, {zoom: 1.15, "scroll.x": 70}, 1, {ease: FlxEase.quartOut});
        FlxTween.tween(blackShopBackground, {alpha: 0.5}, 1);

        startDialogue("I'm wondering what are you gonna purchase today...");

        table.animation.play('idle');
        showPreShopUI();
    }

    var canInteractPreShopUI:Bool = false;
    function showPreShopUI()
    {
        canInteractPreShopUI = true;
        for(obj in preShopGrp)
        {
            FlxTween.cancelTweensOf(obj);
            obj.x = 270;
            obj.y = (360 - obj.height / 2) + ((obj.height + 25) * (obj.ID-1));
            FlxTween.tween(obj, {alpha: 1, x: obj.x + 10}, 0.8, {ease: FlxEase.quartOut, startDelay: 0.1 * obj.ID});
        }
        FlxTween.cancelTweensOf(preShopHand);
        FlxTween.tween(preShopHand, {alpha: 1}, 0.8, {ease: FlxEase.quartOut});
    }

    function hidePreShopUI()
    {
        canInteractPreShopUI = false;
        for(obj in preShopGrp)
        {
            FlxTween.cancelTweensOf(obj);
            FlxTween.tween(obj, {alpha: 0, y: obj.y + 10}, 0.5, {ease: FlxEase.quartOut});
        }
        FlxTween.cancelTweensOf(preShopHand);
        FlxTween.tween(preShopHand, {alpha: 0}, 0.5, {ease: FlxEase.quartOut});
    }

    var preShopHandXTarget:Float = 0;
    var preShopHandYTarget:Float = 0;
    function preShopChangeSelection(change:Int = 0)
    {
        if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

        preShopCurSelected = FlxMath.wrap(preShopCurSelected + change, 0, preShopArr.length - 1);

        var curMember:FlxSprite = preShopGrp.members[preShopCurSelected];
        preShopHandXTarget = curMember.x + curMember.width + 15;
        preShopHandYTarget = curMember.y + curMember.height / 2 - preShopHand.height / 2;
    }

    var randomTextsArr:Array<String> = [
        "Many people ask me why I'm a boyfriend... I guess it's just my hair",
        "This shop has tons of employees actually, but only 4 are the ones who really work hard :(",
        "Your progress is stored by Tapi, hopefully he won't erase your save files as he did with mines",
        "Oh, about the name of the company... it's a very gorgeous metaphor, isn't it?",
        "The last meeting we had was about starting to sell plushies. \nI refused.",
    ];
    var randomStartIndex:Int = 0;

    function preShopSelect()
    {
        var name:String = preShopArr[preShopCurSelected];
        switch(name)
        {
            case 'buy':
                endDialogue();
                openShop();
            case 'talk':
                zoomInToCharacter();
                hidePreShopUI();
                startDialogue(randomTextsArr[randomStartIndex], 0.04, function()
                {
                    zoomOutToCharacter();
                    showPreShopUI();
                });
                randomStartIndex = FlxMath.wrap(randomStartIndex + 1, 0, randomTextsArr.length - 1);
            case 'exit': zoomOutFromShop();
            default: // nothing
        }
    }

    public static var blurShader:BlurShader;
    var blurFilter:ShaderFilter;
    function openShop()
    {
        FlxG.sound.play(Paths.sound('vault/shop/coolHarp'), 0.7);
        FlxG.sound.play(Paths.sound('vault/shop/zoomIn'));

        FlxTween.cancelTweensOf(poloDown);
        FlxTween.tween(poloDown, {y: FlxG.height}, 0.45, {ease: FlxEase.quintOut});

        zoomInToCharacter();

        hidePreShopUI();
        if(blurShaderTween != null) blurShaderTween.cancel();
        blurShaderTween = FlxTween.num(0, 5, 1, {ease: FlxEase.quartOut, onComplete: (_) -> blurShaderTween = null}, function(v:Float)
        {
            blurShader.radius.value[0] = v;
        });

        persistentUpdate = true;
        
        var shop = new ShopSubState();
        shop.cameras = [camHUD];
        openSubState(shop);
    }

    function zoomInToCharacter()
    {
        FlxTween.cancelTweensOf(FlxG.camera);
        FlxTween.tween(FlxG.camera, {zoom: 1.25, "scroll.x": 100}, 0.7, {ease: FlxEase.quartOut});
    }

    function zoomOutToCharacter()
    {
        FlxTween.cancelTweensOf(FlxG.camera);
        FlxTween.tween(FlxG.camera, {zoom: 1.15, "scroll.x": 70}, 0.7, {ease: FlxEase.quartOut});
    }

    public static var blurShaderTween:FlxTween;
    override function closeSubState()
    {
        super.closeSubState();

        if(isOnCollectionables)
        {
            isOnCollectionables = false;
            //FlxG.sound.play(Paths.sound('vault/shop/zoomOut'));
        }

        if(isOnPreShop)
        {
            FlxG.sound.play(Paths.sound('vault/shop/zoomOut'));
            if(FlxG.cameras.list.contains(ShopSubState.cursorCamera)) FlxG.cameras.remove(ShopSubState.cursorCamera);
            if(FlxG.cameras.list.contains(ShopSubState.itemsCamera)) FlxG.cameras.remove(ShopSubState.itemsCamera);

            FlxTween.cancelTweensOf(poloDown);
            FlxTween.tween(poloDown, {y: FlxG.height - poloDown.height}, 0.45, {ease: FlxEase.quintOut});

            zoomOutToCharacter();

            showPreShopUI();
            if(blurShaderTween != null) blurShaderTween.cancel();
            blurShaderTween = FlxTween.num(5, 0, 1, {ease: FlxEase.quartOut, onComplete: (_) -> blurShaderTween = null}, function(v:Float)
            {
                blurShader.radius.value[0] = v;
            });
        }
    }

    function zoomOutFromShop()
    {
        FlxG.sound.play(Paths.sound('vault/zoomOut'));
        hidePreShopUI();

        isOnPreShop = false;
        updateScroll = true;

        madreaCharacter.animation.play('idle', true);
        heroSpawnTimer.active = true;

        FlxTween.cancelTweensOf(heroCharacter);
        FlxTween.cancelTweensOf(FlxG.camera);
        FlxTween.cancelTweensOf(blackShopBackground);

        FlxTween.tween(heroCharacter, {x: rightSpawnHero ? -heroCharacter.width : FlxG.width + 30}, 2);
        FlxTween.color(heroCharacter, 2, heroCharacter.color, 0xFFFFFFFF);
        FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.quartOut});
        FlxTween.tween(blackShopBackground, {alpha: 0}, 0.8);
    }
}