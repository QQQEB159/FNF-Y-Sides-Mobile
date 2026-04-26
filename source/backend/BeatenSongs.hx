package backend;

class BeatenSongs
{
    public static var beatenSongs:Map<String, Bool> = new Map<String, Bool>();

    public static function init()
    {
		if(FlxG.save.data.beatenSongs != null)
			beatenSongs = FlxG.save.data.beatenSongs;
        else
        {
            // Load bf songs
            for (i in 0...WeekData.weeksList.length)
            {
			    var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			    for (song in leWeek.songs)
			    {
                    if(!beatenSongs.exists('${song[0].toLowerCase()}-bf')) beatenSongs.set('${song[0].toLowerCase()}-bf', false);
                }
            }

            // Load pico songs
            for (i in 0...WeekData.weeksList.length)
            {
			    var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			    for (song in leWeek.songs)
			    {
					if(!song[3]) continue;
                    if(!beatenSongs.exists('${song[0].toLowerCase()}-pico')) beatenSongs.set('${song[0].toLowerCase()}-pico', false);
                }
            }

            FlxG.save.data.beatenSongs = beatenSongs;
            FlxG.save.flush();
        }

        trace(FlxG.save.data.beatenSongs);
    }

    public static function beatSong(name:String)
    {
        if(beatenSongs.exists(name)) beatenSongs.set(name, true);
        
        trace('Setting $name to true');
        FlxG.save.data.beatenSongs = beatenSongs;
        FlxG.save.flush();
    }

    public static function isSongBeaten(name:String):Bool
    {
        if(!beatenSongs.exists(name)) return false;
        trace('Song beaten? ($name -> ${beatenSongs.get(name)})');
        if(beatenSongs.get(name)) return true;
        return false;
    }

    // method used to only make actual new songs to have the "is new" flag
    public static function isSongNew(name:String):Bool
    {
        // yes, hardcoded, kill me if you want :)
        var songsWithNewFlag:Array<String> = [
            'south-pico',
            'satin-panties-bf',
            'high-bf',
            'high-pico',
            'milf-bf',
            'milf-pico',
            'cocoa-bf',
            'eggnog-bf',
            'winter-horrorland-bf',
            'madness-bf'
        ];

        if(songsWithNewFlag.contains(name)) return true;
        return false;
    }
}