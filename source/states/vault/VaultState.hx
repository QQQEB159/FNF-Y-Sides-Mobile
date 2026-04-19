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
    var table:FlxSprite;
    var machine:FlxSprite;

    var madreaCharacter:FlxSprite;

    var poloUp:FlxSprite;
    var poloDown:FlxSprite;

    var camMain:FlxCamera;
    var camHUD:FlxCamera;

    override function create()
    {
        super.create();

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

        machine = new FlxSprite();
        machine.loadGraphic(Paths.image('vault/money'));
        machine.antialiasing = ClientPrefs.data.antialiasing;
        machine.x = table.x + table.width - machine.width - 30;
        machine.y = table.y - machine.height + 20;
        add(machine);

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
            MusicBeatState.switchState(new MainMenuState());
        }
    }
}