package states;

import objects.VideoSprite;
import shaders.BloomShader;
import openfl.filters.ShaderFilter;

class HaxeflixelIntroState extends MusicBeatState
{
    var videoCutscene:VideoSprite;
    var sugarntCrewLogo:FlxSprite;
    var sugarntCrewLogoSfx:FlxSound;
    var bloomShader:BloomShader;
    var bloomFilter:ShaderFilter;

    override function create()
    {
        super.create();

		var bgcolor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF120125);
		add(bgcolor);

        videoCutscene = new VideoSprite(Paths.video('haxeflixelIntro'), false, false, false);
        videoCutscene.play();
        add(videoCutscene);

        sugarntCrewLogo = new FlxSprite();
        sugarntCrewLogo.frames = Paths.getSparrowAtlas('intro/sugarntCrew-logo');
        sugarntCrewLogo.animation.addByPrefix('idle', 'idle', 24, false);
        sugarntCrewLogo.antialiasing = ClientPrefs.data.antialiasing;
        sugarntCrewLogo.screenCenter();
        sugarntCrewLogo.visible = false;
        sugarntCrewLogo.scale.set(1.2, 1.2);
        add(sugarntCrewLogo);

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        sugarntCrewLogoSfx = new FlxSound();
        sugarntCrewLogoSfx.loadEmbedded(Paths.sound('intro/sugarntCrewLogoIntro'));
		FlxG.sound.list.add(sugarntCrewLogoSfx);

        if(ClientPrefs.data.shaders && ClientPrefs.data.flashing)
        {
		    bloomShader = new BloomShader();
		    bloomShader.dim.value = [2.0]; // 1.8
		    bloomShader.Directions.value = [20.0]; // 2.0, 100.0 to remove
		    bloomShader.Quality.value = [8.0]; // 8.0
		    bloomShader.Size.value = [0.0]; // 8.0, 1.0

		    bloomFilter = new ShaderFilter(bloomShader);
            //FlxG.camera.filters = [bloomFilter];
            // better no, like, the shader prompt it's the following thing that appears lmao
        }

        videoCutscene.finishCallback = function()
        {
            // MusicBeatState.switchState(new TitleState());

            videoCutscene.visible = false;
            sugarntCrewLogo.visible = true;
            sugarntCrewLogo.animation.play('idle', true);

            sugarntCrewLogoSfx.play();

            sugarntCrewLogo.animation.callback = function(name:String, frame:Int, frameIndex:Int)
            {
                if(name == 'idle' && frame == 36)
                {
                    if(ClientPrefs.data.shaders && ClientPrefs.data.flashing)
                    {
                        bloomShader.dim.value[0] = 1.55;
                        bloomShader.Directions.value[0] = 2.0;
		                bloomShader.Size.value[0] = 4.0; // 8.0, 1.0

                        FlxTween.num(1.75, 2, 2, {ease: FlxEase.quartOut}, function(v:Float)
                        {
                            bloomShader.dim.value[0] = v;
                        });
                        
                        FlxTween.num(2.0, 20.0, 2, {ease: FlxEase.quartOut}, function(v:Float)
                        {
                            bloomShader.Directions.value[0] = v;
                        });

                        FlxTween.num(4.0, 0.0, 2, {ease: FlxEase.quartOut}, function(v:Float)
                        {
                            bloomShader.Size.value[0] = v;
                        });
                    }
                }
            }

            sugarntCrewLogo.animation.finishCallback = function(name:String)
            {
                if(name == 'idle')
                {
                    new FlxTimer().start(1, function(tmr:FlxTimer) 
                    {
                        FlxG.camera.fade(0xFF120125, 1, false, function()
                        {
                            MusicBeatState.switchState(new TitleState());
                        }, true);
                    });
                }
            }

            videoCutscene = null;
        }
    }
}