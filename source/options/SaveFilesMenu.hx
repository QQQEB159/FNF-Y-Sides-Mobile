package options;

import flixel.util.FlxSave;
import flixel.addons.display.FlxBackdrop;
import shaders.BlurShader;
import openfl.filters.ShaderFilter;

class SaveFilesMenu extends MusicBeatState
{
    var saveFilesAmount:Int = 3;
    var saveFilesSprGrp:FlxTypedGroup<FlxSprite>;
    var saveFilesTxtGrp:FlxTypedGroup<FlxText>;
    var saveFilesPlayedTimeTxtGrp:FlxTypedGroup<FlxText>;
    var saveFilesDataArr:Array<Dynamic> = [];

    var alreadySelectedSlot:FlxText;

    public static var canInteract:Bool = true;
    public static var blurShader:BlurShader;
    var blurFilter:ShaderFilter;

    var camNormal:FlxCamera;
    var camPrompt:FlxCamera;

    override function create()
    {
        super.create();

        FlxG.mouse.visible = true;

        camNormal = initPsychCamera();

        camPrompt = new FlxCamera();
        camPrompt.bgColor.alpha = 0;
        add(camPrompt);

		FlxG.cameras.add(camPrompt, false);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

        saveFilesSprGrp = new FlxTypedGroup<FlxSprite>();
        add(saveFilesSprGrp);

        saveFilesTxtGrp = new FlxTypedGroup<FlxText>();
        add(saveFilesTxtGrp);

        saveFilesPlayedTimeTxtGrp = new FlxTypedGroup<FlxText>();
        add(saveFilesPlayedTimeTxtGrp);

        var triangleTop:FlxBackdrop = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/lettaBoxDark'), X, 0, 0);
        triangleTop.velocity.set(10, 0);
        triangleTop.angle = 180;
        add(triangleTop);

        var triangleBottom:FlxBackdrop = new FlxBackdrop(Paths.image('resultsScreen/newResultsScreen/lettaBoxDark'), X, 0, 0);
        triangleBottom.velocity.set(-10, 0);
        triangleBottom.y = FlxG.height - triangleBottom.height;
        add(triangleBottom);

        for(i in 0...saveFilesAmount)
        {
            var spr = new FlxSprite();
            spr.makeGraphic(700, 100, 0xFFFFFFFF);
            spr.ID = i;
            spr.screenCenter(X);
            spr.y = 200 + (i * 120);
            spr.updateHitbox();
            //spr.y = triangleTop.y + triangleTop.height + 10 + (i * 120);
            saveFilesSprGrp.add(spr);

            var txt = new FlxText(0, 0, spr.width, 'Save file ${i+1}');
            txt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 20, 0xFF000000);
            txt.x = spr.x + 10;
            txt.y = spr.y + 10;
            txt.ID = i;
            txt.antialiasing = ClientPrefs.data.antialiasing;
            saveFilesTxtGrp.add(txt);

            var save = new FlxSave();
            save.bind('funkin$i', CoolUtil.getSavePath());
            saveFilesDataArr.push(save.data);

            var playedTime:Float = 0;
            playedTime = save.data.playedTime;
            var hours = FlxMath.roundDecimal(playedTime / 3600, 2);

            var playedTimeTxt = new FlxText(0, 0, spr.width, '');
            playedTimeTxt.setFormat(Paths.font('FredokaOne-Regular.ttf'), 18, 0xFF000000);
            playedTimeTxt.text = '$hours hours';
            playedTimeTxt.x = spr.x + 10;
            playedTimeTxt.y = txt.y + txt.height + 10;
            playedTimeTxt.ID = i;
            playedTimeTxt.antialiasing = ClientPrefs.data.antialiasing;
            saveFilesPlayedTimeTxtGrp.add(playedTimeTxt);

		    var platiniumAchievement = new FlxSprite();
		    platiniumAchievement.loadGraphic(Paths.image('achievements/platiniumTrophie'));
		    platiniumAchievement.scrollFactor.set(0, 0);
		    //platiniumAchievement.scale.set(0.35, 0.35);
            platiniumAchievement.setGraphicSize(40, 40);
		    platiniumAchievement.updateHitbox();
		    platiniumAchievement.antialiasing = ClientPrefs.data.antialiasing;
		    platiniumAchievement.x = spr.x + spr.width - platiniumAchievement.width - 10;
		    platiniumAchievement.y = spr.y + 10;
		    add(platiniumAchievement);

            platiniumAchievement.color = Achievements.checkPlatiniumAchievementFromSave(i) ? 0xFFFFFFFF : 0xFF000000;
        }

        alreadySelectedSlot = new FlxText(0, 0, FlxG.width, 'You are currently on this save file!');
        alreadySelectedSlot.setFormat(Paths.font('FredokaOne-Regular.ttf'), 20, FlxColor.RED, CENTER);
        alreadySelectedSlot.y = FlxG.height - alreadySelectedSlot.height - 140;
        alreadySelectedSlot.alpha = 0;
        add(alreadySelectedSlot);

        // tiny offset lmao so always centered
        //saveFilesGrp.members[1].screenCenter();
        //saveFilesGrp.members[0].y = saveFilesGrp.members[1].y - 120;
        //saveFilesGrp.members[2].y = saveFilesGrp.members[1].y + 120; 

        blurShader = new BlurShader();
        blurShader.radius.value = [0];

        blurFilter = new ShaderFilter(blurShader);
        FlxG.camera.filters = [blurFilter];
    }

    var curSelected:Int = 0;
    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE)
        {
            if(!canInteract) return;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new OptionsState(true));
        }

        saveFilesSprGrp.forEach(function(spr:FlxSprite)
        {
            if(!canInteract) return;

            if(FlxG.mouse.overlaps(spr))
            {
                // code here...
                spr.color = FlxColor.YELLOW;
                curSelected = spr.ID;
                if(FlxG.mouse.justPressed)
                {
                    if(Saves.currentSaveSlot == curSelected)
                    {
                        FlxTween.cancelTweensOf(alreadySelectedSlot);

                        alreadySelectedSlot.alpha = 1;
                        FlxTween.tween(alreadySelectedSlot, {alpha: 0}, 1, {ease: FlxEase.circOut});
                    }
                    else
                    {
                        var prompt = new SaveFilePrompt(curSelected);
                        prompt.cameras = [camPrompt];
                        openSubState(prompt);

                        FlxTween.num(0, 7, 0.5, {ease: FlxEase.linear}, function(v:Float)
                        {
                            blurShader.radius.value[0] = v;
                        });

                        persistentDraw = true;
                        persistentUpdate = true;

                        //Saves.loadSlot(curSelected);
                        //Sys.exit(0);
                    }
                }
            }
            else
            {
                spr.color = FlxColor.WHITE;
            }
        });
    }
}

class SaveFilePrompt extends MusicBeatSubstate
{
    var blackBackground:FlxSprite;
    var promptObject:PromptObject;
    public static var blackBackgroundOver:FlxSprite;

    public function new(curSlot:Int)
    {
        super();

        blackBackground = new FlxSprite();
        blackBackground.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        blackBackground.alpha = 0;
        add(blackBackground);

        FlxTween.tween(blackBackground, {alpha: 0.55}, 1);

        var promptY:Float = 0;
        promptObject = new PromptObject(0, 0, curSlot);
        promptObject.screenCenter();
        promptObject.closePromptCallback = closePrompt;
        promptY = promptObject.y;
        add(promptObject);

        promptObject.y = -400;
        FlxTween.tween(promptObject, {y: promptY}, 1, {ease: FlxEase.quartOut});

        SaveFilesMenu.canInteract = false;

        blackBackgroundOver = new FlxSprite();
        blackBackgroundOver.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        blackBackgroundOver.alpha = 0;
        add(blackBackgroundOver);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.keys.justPressed.ESCAPE)
        {
            closePrompt();
        }
    }

    public function closePrompt()
    {
        FlxTween.num(7, 0, 0.5, {ease: FlxEase.linear}, function(v:Float)
        {
            if (SaveFilesMenu.blurShader != null && SaveFilesMenu.blurShader.radius != null)
                SaveFilesMenu.blurShader.radius.value[0] = v;
        });
        FlxTween.tween(blackBackground, {alpha: 0}, 0.5, {onComplete: function(twn:FlxTween)
        {
            close();
            SaveFilesMenu.canInteract = true;
        }});
        FlxTween.cancelTweensOf(promptObject);
        FlxTween.tween(promptObject, {y: FlxG.height + 100}, 0.5, {ease: FlxEase.quartOut});
    }
}

class PromptObject extends FlxSpriteGroup
{
    public var closePromptCallback:Void->Void;
    var yesText:Alphabet;
    var noText:Alphabet;
    var curSlot:Int;

    public function new(x:Float = 0, y:Float = 0, _curSlot:Int)
    {
        super(x, y);

        curSlot = _curSlot;

        var spr = new FlxSprite();
        //spr.makeGraphic(650, 260, 0xFFFFFFFF);
        spr.loadGraphic(Paths.image('saveFileMenu/prompt'));
        add(spr);

        var warningText = new Alphabet(0, 0, 'Warning!');
		warningText.color = 0xFFFF877E;
        warningText.setScale(0.7, 0.7);
        warningText.x = spr.width / 2 - warningText.width / 2;
        warningText.y = spr.y + 10;
        add(warningText);

        var infoText = new Alphabet(0, 0, 'This action will load the selected save file');
        infoText.setScale(0.35, 0.35);
        infoText.x = spr.width / 2 - infoText.width / 2;
        infoText.y = spr.y + warningText.height + 10;
        add(infoText);

        var infoText2 = new Alphabet(0, 0, 'and CLOSE the game');
        infoText2.setScale(0.35, 0.35);
        infoText2.x = spr.width / 2 - infoText2.width / 2;
        infoText2.y = infoText.y + infoText.height + 10;
        add(infoText2);

        var infoText3 = new Alphabet(0, 0, 'Are you sure?');
        infoText3.setScale(0.35, 0.35);
        infoText3.x = spr.width / 2 - infoText3.width / 2;
        infoText3.y = infoText2.y + infoText2.height + 10;
        add(infoText3);

        yesText = new Alphabet(0, 0, 'Yes', true);
        yesText.setScale(0.65, 0.65);
        yesText.x = spr.width / 2 - yesText.width / 2 - 250;
        yesText.y = spr.height - yesText.height - 20;
        add(yesText);

        noText = new Alphabet(0, 0, 'No', true);
        noText.setScale(0.65, 0.65);
        noText.x = spr.width / 2 - noText.width / 2 + 250;
        noText.y = spr.height - noText.height - 20;
        add(noText);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(FlxG.mouse.overlaps(yesText))
        {
            yesText.color = 0xFF7EFFAD;
            if(FlxG.mouse.justPressed)
            {
                FlxTween.tween(SaveFilePrompt.blackBackgroundOver, {alpha: 1}, 1, {onComplete: function(twn:FlxTween)
                {
                    Saves.loadSlot(curSlot);
                    Sys.exit(0);
                }});
            }
        }
        else
        {
            yesText.color = 0xFFFFFFFF;
        }
        
        if(FlxG.mouse.overlaps(noText))
        {
            noText.color = 0xFFFF877E;
            if(FlxG.mouse.justPressed)
            {
                //SaveFilePrompt.closePrompt();
                if(closePromptCallback != null) closePromptCallback();
            }
        }
        else
        {
            noText.color = 0xFFFFFFFF;
        }
    }
}