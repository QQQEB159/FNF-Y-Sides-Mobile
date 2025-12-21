package backend;

import flixel.util.FlxSave;

class PlayedTime
{
    /**
     * The save file where played time is saved
    **/
    public static var timeSave:FlxSave;
    /**
     * Total time you have been playing the game (in seconds)
    **/
    public static var time:Int = 0;

    public static function loadPlayedTime():Void
    {
        FlxG.save.data.playedTime = FlxG.save.data.playedTime == null ? 0 : FlxG.save.data.playedTime;
        time = FlxG.save.data.playedTime;

        #if debug 
        trace('Loaded play time (current played time is $time seconds)');
        #end
    }

    public static function updateTime():Void
    {
        // avoid crash (just in case)
        if(FlxG.save == null) return;

        time++;
        FlxG.save.data.playedTime = time;
        FlxG.save.flush();
        
        #if debug 
        trace('You have played for $time seconds! (${time/60} minutes) (${time/3600} hours)');
        #end
    }
}