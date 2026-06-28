package states;

import shaders.BloomShader;
import openfl.filters.ShaderFilter;

class HaxeflixelIntroState extends MusicBeatState
{
    var haxeFlixelLogo:FlxSprite;
    var haxeFlixelLogoSfx:FlxSound;
    var sugarntCrewLogo:FlxSprite;
    var sugarntCrewLogoSfx:FlxSound;
    var bloomShader:BloomShader;
    var bloomFilter:ShaderFilter;

    override function create()
    {
        super.create();

		var bgcolor = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF120125);
		add(bgcolor);

        haxeFlixelLogo = new FlxSprite();
        haxeFlixelLogo.frames = Paths.getSparrowAtlas('intro/haxeFlixelIntro');
        haxeFlixelLogo.animation.addByPrefix('idle', 'haxeFlixelIntro idle', 24, false);
        haxeFlixelLogo.animation.play('idle', true);
        haxeFlixelLogo.alpha = 0.0001;
        haxeFlixelLogo.antialiasing = ClientPrefs.data.antialiasing;
        haxeFlixelLogo.screenCenter();
        add(haxeFlixelLogo);

        sugarntCrewLogo = new FlxSprite();
        sugarntCrewLogo.frames = Paths.getSparrowAtlas('intro/sugarntCrew-logo');
        sugarntCrewLogo.animation.addByPrefix('idle', 'idle', 24, false);
        sugarntCrewLogo.antialiasing = ClientPrefs.data.antialiasing;
        sugarntCrewLogo.screenCenter();
        sugarntCrewLogo.visible = false;
        sugarntCrewLogo.scale.set(1.2, 1.2);
        sugarntCrewLogo.x += -13;
        add(sugarntCrewLogo);

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        sugarntCrewLogoSfx = new FlxSound();
        sugarntCrewLogoSfx.loadEmbedded(Paths.sound('intro/sugarntCrewLogoIntro'));
		FlxG.sound.list.add(sugarntCrewLogoSfx);

        haxeFlixelLogoSfx = new FlxSound();
        haxeFlixelLogoSfx.loadEmbedded(Paths.sound('intro/haxeFlixelLogoIntro'));
		FlxG.sound.list.add(haxeFlixelLogoSfx);

        new FlxTimer().start(0.8, function(tmr:FlxTimer)
        {
            haxeFlixelLogo.alpha = 1;
            haxeFlixelLogo.animation.play('idle', true);
            haxeFlixelLogoSfx.play();
        });

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

        haxeFlixelLogo.animation.finishCallback = function(name:String)
        {
            // MusicBeatState.switchState(new TitleState());

            haxeFlixelLogo.visible = false;
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
        }
    }
}