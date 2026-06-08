package states;

import objects.VideoSprite;

class HaxeflixelIntroState extends MusicBeatState
{
    var videoCutscene:VideoSprite;

    override function create()
    {
        super.create();
        
		var bgcolor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF120125);
		add(bgcolor);

        videoCutscene = new VideoSprite(Paths.video('haxeflixelIntro'), false, false, false);
        videoCutscene.play();
        add(videoCutscene);

        videoCutscene.finishCallback = function()
        {
            MusicBeatState.switchState(new TitleState());
            videoCutscene = null;
        }
    }
}