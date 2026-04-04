package states.gallery;

import sys.thread.Thread;
import sys.thread.Mutex;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import flixel.sound.FlxSound;

class GalleryPreload
{
    // Music preloading
    public static var hasPreloadedMusic:Bool = false;
    public static var musicPreloadProgress:Int = 0;
    public static var totalMusicItems:Int = 0;
    
    // Image preloading
    public static var hasPreloadedImages:Bool = false;
    public static var imagePreloadProgress:Int = 0;
    public static var totalImageItems:Int = 0;
    
    // Storage maps
    static var preloadedInstMap:Map<String, FlxSound> = new Map<String, FlxSound>();
    static var preloadedImages:Map<String, GalleryObject> = new Map<String, GalleryObject>();
    
    // Mutexes for thread safety
    static var musicMutex:Mutex = new Mutex();
    static var imageMutex:Mutex = new Mutex();
    
    /**
     * Preload music files in a background thread
     */
    public static function preloadMusic():Void
    {
        Thread.create(() -> {
            totalMusicItems = NewGalleryState.musicSongsArrayFull.length;
            
            for (i in 0...NewGalleryState.musicSongsArrayFull.length)
            {
                var song = NewGalleryState.musicSongsArrayFull[i];
                var instPath = 'assets/songs/$song/Inst.ogg';
                
                if (!FileSystem.exists(instPath)) 
                {
                    trace('Skipping $song - Inst.ogg not found');
                    musicMutex.acquire();
                    musicPreloadProgress++;
                    musicMutex.release();
                    continue;
                }
                
                try 
                {
                    var embedInst = new FlxSound();
                    embedInst.loadEmbedded(instPath);
                    
                    // Thread-safe write to the map
                    musicMutex.acquire();
                    preloadedInstMap.set(song, embedInst);
                    musicPreloadProgress++;
                    trace('Loaded $song (INST) - Progress: $musicPreloadProgress/$totalMusicItems');
                    musicMutex.release();
                }
                catch (e:Dynamic)
                {
                    trace('Error loading $song: $e');
                    musicMutex.acquire();
                    musicPreloadProgress++;
                    musicMutex.release();
                }
            }
            
            // Mark as complete
            musicMutex.acquire();
            hasPreloadedMusic = true;
            trace('Music preloading complete!');
            musicMutex.release();
        });
    }
    
    /**
     * Preload gallery images in a background thread
     */
    public static function preloadImages(galleryDirectory:String):Void
    {
        Thread.create(() -> {
            var galleryPath = 'assets/shared/images/gallery/$galleryDirectory';
            
            if (!FileSystem.exists(galleryPath))
            {
                trace('Gallery directory not found: $galleryPath');
                return;
            }
            
            var imagesOnFolder = FileSystem.readDirectory(galleryPath);
            
            // Filter to only PNG images
            var imageFiles = imagesOnFolder.filter(function(file) {
                return StringTools.endsWith(file.toLowerCase(), '.png');
            });
            
            totalImageItems = imageFiles.length;
            
            for (num in 0...imageFiles.length)
            {
                var image = imageFiles[num];
                var imageName = StringTools.replace(image, '.png', '');
                var jsonPath = '$galleryPath/$imageName.json';
                
                try 
                {
                    // Load metadata if available
                    if (FileSystem.exists(jsonPath))
                    {
                        var content = File.getContent(jsonPath);
                        var imageData = Json.parse(content);
                        trace('Preloaded metadata: ${imageData.name} at index $num');
                    }
                    else
                    {
                        #if debug 
                        trace('No JSON metadata for $imageName (index $num)'); 
                        #end
                    }
                    
                    // Load the image
                    var spr = new GalleryObject();
                    spr.loadGraphic(Paths.image('gallery/$galleryDirectory/$imageName'));
                    
                    // Thread-safe write to the map
                    imageMutex.acquire();
                    preloadedImages.set(imageName, spr);
                    imagePreloadProgress++;
                    trace('Loaded image $imageName - Progress: $imagePreloadProgress/$totalImageItems');
                    imageMutex.release();
                }
                catch (e:Dynamic)
                {
                    trace('Error loading image $imageName: $e');
                    imageMutex.acquire();
                    imagePreloadProgress++;
                    imageMutex.release();
                }
            }
            
            // Mark as complete
            imageMutex.acquire();
            hasPreloadedImages = true;
            trace('Image preloading complete!');
            imageMutex.release();
        });
    }
    
    /**
     * Get preloaded music (thread-safe)
     */
    public static function getMusic(songName:String):FlxSound
    {
        musicMutex.acquire();
        var sound = preloadedInstMap.get(songName);
        musicMutex.release();
        return sound;
    }
    
    /**
     * Get preloaded image (thread-safe)
     */
    public static function getImage(imageName:String):GalleryObject
    {
        imageMutex.acquire();
        var image = preloadedImages.get(imageName);
        imageMutex.release();
        return image;
    }
    
    /**
     * Get music preload progress as percentage (thread-safe)
     */
    public static function getMusicProgressPercent():Float
    {
        if (totalMusicItems == 0) return 0;
        
        musicMutex.acquire();
        var progress = (musicPreloadProgress / totalMusicItems) * 100;
        musicMutex.release();
        
        return progress;
    }
    
    /**
     * Get image preload progress as percentage (thread-safe)
     */
    public static function getImageProgressPercent():Float
    {
        if (totalImageItems == 0) return 0;
        
        imageMutex.acquire();
        var progress = (imagePreloadProgress / totalImageItems) * 100;
        imageMutex.release();
        
        return progress;
    }
    
    /**
     * Clean up resources
     */
    public static function cleanup():Void
    {
        musicMutex.acquire();
        for (sound in preloadedInstMap)
        {
            if (sound != null) sound.destroy();
        }
        preloadedInstMap.clear();
        musicMutex.release();
        
        imageMutex.acquire();
        for (image in preloadedImages)
        {
            if (image != null) image.destroy();
        }
        preloadedImages.clear();
        imageMutex.release();
        
        hasPreloadedMusic = false;
        hasPreloadedImages = false;
        musicPreloadProgress = 0;
        imagePreloadProgress = 0;
    }
}