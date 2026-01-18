package options;

import flixel.addons.display.FlxBackdrop;

class SaveFilesMenu extends MusicBeatState
{
    var saveFilesAmount:Int = 3;
    var saveFilesGrp:FlxTypedGroup<FlxSprite>;
    override function create()
    {
        super.create();

        FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFFBFB4F1);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

        saveFilesGrp = new FlxTypedGroup<FlxSprite>();
        add(saveFilesGrp);

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
            spr.makeGraphic(700, 100, 0xFF000000);
            spr.screenCenter(X);
            spr.y = 200 + (i * 120);
            //spr.y = triangleTop.y + triangleTop.height + 10 + (i * 120);
            saveFilesGrp.add(spr);
        }

        // tiny offset lmao so always centered
        //saveFilesGrp.members[1].screenCenter();
        //saveFilesGrp.members[0].y = saveFilesGrp.members[1].y - 120;
        //saveFilesGrp.members[2].y = saveFilesGrp.members[1].y + 120; 
    }

    override function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE)
        {
            MusicBeatState.switchState(new OptionsState());
        }

        saveFilesGrp.forEach(function(spr:FlxSprite)
        {
            if(FlxG.mouse.overlaps(spr))
            {
                // code here...
            }
        });
    }
}