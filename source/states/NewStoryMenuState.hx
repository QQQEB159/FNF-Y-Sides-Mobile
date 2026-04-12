package states;

class NewStoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var backFromStoryMode:Bool = false;

    override function create()
    {
        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.BACK)
        {
            MusicBeatState.switchState(new MainMenuState());
        }
    }
}