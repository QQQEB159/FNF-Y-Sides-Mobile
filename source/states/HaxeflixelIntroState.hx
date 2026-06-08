package states;

import objects.VideoSprite;

class HaxeflixelIntroState extends MusicBeatState
{
    var videoCutscene:VideoSprite;

    override function create()
    {
        super.create();

        videoCutscene = new VideoSprite(Paths.video('haxeflixelIntro'), false, false, false);
        videoCutscene.play();

        videoCutscene.finishCallback = function()
        {
            MusicBeatState.switchState(new TitleState());
            videoCutscene = null;
        }
    }
}