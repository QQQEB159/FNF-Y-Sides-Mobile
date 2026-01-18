package states.gallery;

import sys.thread.Thread;
import haxe.Json;

class GalleryPreload
{
    public static var hasPreloadedMusic:Bool = false;
    public static var preloadProgress:Int = 0;
    static var preloadedInstMap:Map<String, FlxSound> = new Map<String, FlxSound>();

    public static function preloadMusic()
    {
        Thread.create(() -> {
            for(song in GalleryStateMusic.musicSongsArrayFull)
            {
                if(!FileSystem.exists('assets/songs/$song/Inst.ogg')) continue;

                var embedInst = new FlxSound();
                embedInst.loadEmbedded('assets/songs/$song/Inst.ogg');
                preloadedInstMap.set(song, embedInst);

                trace('Loaded $song (INST)!');
                preloadProgress++;

                if(song == GalleryStateMusic.musicSongsArrayFull[GalleryStateMusic.musicSongsArrayFull.length-1]) //last song
                {
                    hasPreloadedMusic = true;
                }
            }
        });
    }

    static var preloadedImages:Map<String, GalleryObject> = new Map<String, GalleryObject>();
    public static function preloadImages(galleryDirectory:String)
    {
        Thread.create(() -> {
            var imagesOnFolder = FileSystem.readDirectory('assets/shared/images/gallery/$galleryDirectory');

            // remove objects that aren't IMAGES (like .jsons which contain metadata)
            for(obj in imagesOnFolder)
            {
                if(StringTools.endsWith(obj, '.json'))
                {
                    imagesOnFolder.remove(obj);
                }
            }

            for(num => image in imagesOnFolder)
            {
                // remove extension
                var imageName = StringTools.replace(image, '.png', '');

                try {
                    var content = File.getContent('assets/shared/images/gallery/$galleryDirectory/$imageName.json');
                    var imageData = Json.parse(content);

                    trace('Preloaded ${imageData.name} at index $num');
                } 
                catch(exc)
                {
                    #if debug trace('No json has been found for the image with ID $num'); #end
                }

                var spr = new GalleryObject();
                spr.loadGraphic(Paths.image('gallery/$galleryDirectory/$imageName'));
                preloadedImages.set(imageName, spr);
            }
        });
    }
}