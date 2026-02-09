package options;

import flixel.util.FlxSave;
import flixel.addons.display.FlxBackdrop;

class SaveFilesMenu extends MusicBeatState
{
    var saveFilesAmount:Int = 3;
    var saveFilesSprGrp:FlxTypedGroup<FlxSprite>;
    var saveFilesTxtGrp:FlxTypedGroup<FlxText>;
    var saveFilesPlayedTimeTxtGrp:FlxTypedGroup<FlxText>;
    var saveFilesDataArr:Array<Dynamic> = [];
    override function create()
    {
        super.create();

        FlxG.mouse.visible = true;

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

            platiniumAchievement.color = Achievements.checkPlatiniumAchievement() ? 0xFFFFFFFF : 0xFF000000;
        }

        // tiny offset lmao so always centered
        //saveFilesGrp.members[1].screenCenter();
        //saveFilesGrp.members[0].y = saveFilesGrp.members[1].y - 120;
        //saveFilesGrp.members[2].y = saveFilesGrp.members[1].y + 120; 
    }

    var curSelected:Int = 0;
    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE)
        {
            MusicBeatState.switchState(new OptionsState());
        }

        saveFilesSprGrp.forEach(function(spr:FlxSprite)
        {
            if(FlxG.mouse.overlaps(spr))
            {
                // code here...
                spr.color = FlxColor.YELLOW;
                curSelected = spr.ID;
                if(FlxG.mouse.justPressed)
                {
                    Saves.loadSlot(curSelected);
                    Sys.exit(0);
                }
            }
            else
            {
                spr.color = FlxColor.WHITE;
            }
        });
    }
}