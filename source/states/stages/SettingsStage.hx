package states.stages;

import flixel.addons.display.FlxBackdrop;
import shaders.DeflectiveLens;
import openfl.filters.ShaderFilter;
import shaders.BloomShader;
import shaders.ChromaticAberration;
import shaders.GlitchFragmentShader;
import shaders.DropShadowShader;

class SettingsStage extends BaseStage
{
    var icons:FlxBackdrop;
    var floor:FlxSprite;
    var blackTop:FlxSprite;
    override function create()
    {
        var bg = new FlxSprite(-1000, -1000);
        bg.loadGraphic(Paths.image('stages/settingsStage/bg'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        add(bg);

        icons = new FlxBackdrop(Paths.image('mainmenu/icons'));
        icons.antialiasing = ClientPrefs.data.antialiasing;
        icons.velocity.set(-150, -150);
        add(icons);

        floor = new FlxSprite(-280, 300);
        floor.loadGraphic(Paths.image('stages/settingsStage/floor'));
        floor.antialiasing = ClientPrefs.data.antialiasing;
        add(floor);

        blackTop = new FlxSprite(-1000, -1000).makeGraphic(3460, 2160, 0xFF000000);
        blackTop.alpha = 0.76;
        add(blackTop);
    }

	var deflectiveLensShader:DeflectiveLens;
	var deflectiveLensFilter:ShaderFilter;
    var bloomShader:BloomShader;
    var bloomFilter:ShaderFilter;
	var chromaticAberration:ChromaticAberration;
    var chromaticAberrationFilter:ShaderFilter;
    var glitchShader:GlitchFragmentShader;
    var glitchFilter:ShaderFilter;

	var rimBF:DropShadowShader;
	var rimGF:DropShadowShader;
	var rimDad:DropShadowShader;
	var rimPlayer3:DropShadowShader;

    override function createPost()
    {
        if(ClientPrefs.data.shaders)
        {
			deflectiveLensShader = new DeflectiveLens();
			deflectiveLensShader.distortionScale.value = [0.0];
			deflectiveLensFilter = new ShaderFilter(deflectiveLensShader);
			FlxG.camera.filters = [deflectiveLensFilter];

            bloomShader = new BloomShader();
			bloomShader.dim.value = [2.0]; // 1.8
			bloomShader.Directions.value = [20.0]; // 2.0, 100.0 to remove
			bloomShader.Quality.value = [8.0]; // 8.0
			bloomShader.Size.value = [4.0]; // 8.0, 1.0

			bloomFilter = new ShaderFilter(bloomShader);
			FlxG.camera.filters.push(bloomFilter);

			chromaticAberration = new ChromaticAberration();
			chromaticAberration.rOffset.value = [0.001];
			chromaticAberration.gOffset.value = [0.0];
			chromaticAberration.bOffset.value = [-0.001];

			chromaticAberrationFilter = new ShaderFilter(chromaticAberration);
			FlxG.camera.filters.push(chromaticAberrationFilter);

			glitchShader = new GlitchFragmentShader();
			glitchShader.GLITCH_THR.value = [0.0]; // velocity //// 0.01
			glitchShader.GLITCH_RECT_DIVISION.value = [0]; // size (more high, more small) name also say it, """""division""""" //// 5
			glitchShader.GLITCH_RECT_ITR.value = [0]; // its like make it more glitchy ////

			glitchFilter = new ShaderFilter(glitchShader);
			FlxG.camera.filters.push(glitchFilter);

            rimBF = new DropShadowShader();
            rimBF.setAdjustColor(-6, -12, 6, -22);
            rimBF.color = 0x0;
            game.boyfriend.shader = rimBF;
            rimBF.attachedSprite = game.boyfriend;
            rimBF.angle = 90;

            game.boyfriend.animation.callback = function()
            {
                if (game.boyfriend != null)
                {
                    rimBF.updateFrameInfo(game.boyfriend.frame);
                }
            };

            rimGF = new DropShadowShader();
            rimGF.setAdjustColor(-6, -12, 6, -22);
            rimGF.color = 0x0;
            game.gf.shader = rimGF;
            rimGF.attachedSprite = game.gf;
            rimGF.distance = 10;
            rimGF.angle = 90;

            game.gf.animation.callback = function()
            {
                if (game.gf != null)
                {
                    rimGF.updateFrameInfo(game.gf.frame);
                }
            };

            rimDad = new DropShadowShader();
            rimDad.setAdjustColor(-6, -12, 6, -22);
            rimDad.color = 0x0;
            game.dad.shader = rimDad;
            rimDad.attachedSprite = game.dad;
            rimDad.angle = 90;

            game.dad.animation.callback = function()
            {
                if (game.dad != null)
                {
                    rimDad.updateFrameInfo(game.dad.frame);
                }
            };

            if(game.player3 != null)
            {
                rimPlayer3 = new DropShadowShader();
                rimPlayer3.setAdjustColor(-6, -12, 6, -22);
                rimPlayer3.color = 0x0;
                game.player3.shader = rimPlayer3;
                rimPlayer3.attachedSprite = game.player3;
                rimPlayer3.angle = 90;

                game.player3.animation.callback = function()
                {
                    if (game.player3 != null)
                    {
                        rimPlayer3.updateFrameInfo(game.player3.frame);
                    }
                };
            }
        }
    }

    override function update(elapsed:Float)
    {
		if (glitchShader != null) glitchShader.iTime.value[0] += elapsed;
    }

    override function stepHit()
    {
        switch(curStep)
        {
            case 144:
                if(ClientPrefs.data.shaders)
                {
                    deflectiveLensShader.distortionScale.value = [0.5];

                    chromaticAberration.rOffset.value = [0.0015];
                    chromaticAberration.gOffset.value = [0.0];
                    chromaticAberration.bOffset.value = [-0.0015];

                    rimBF.setAdjustColor(0, 0, 0, 0);
                    rimGF.setAdjustColor(0, 0, 0, 0);
                    rimDad.setAdjustColor(0, 0, 0, 0);
                    if(rimPlayer3 != null) rimPlayer3.setAdjustColor(0, 0, 0, 0);

                    blackTop.alpha = 0;

                    FlxTween.num(1.4, 2, 2, {ease: FlxEase.linear}, function(v:Float) { bloomShader.dim.value[0] = v; } );
                    FlxTween.num(2.6, 20, 2, {ease: FlxEase.linear}, function(v:Float) { bloomShader.Directions.value[0] = v; } );
                }
            case 528:
                if(ClientPrefs.data.shaders)
                {
                    deflectiveLensShader.distortionScale.value = [0.67];

                    FlxTween.tween(blackTop, {alpha: 0.35}, 0.9);

                    chromaticAberration.rOffset.value = [0.0025];
                    chromaticAberration.gOffset.value = [0.0];
                    chromaticAberration.bOffset.value = [-0.0025];

                    icons.velocity.set(-250, -250);

                    glitchShader.GLITCH_THR.value = [0.005]; // velocity //// 0.01
                    glitchShader.GLITCH_RECT_DIVISION.value = [7]; // size (more high, more small) name also say it, """""division""""" //// 5
                    glitchShader.GLITCH_RECT_ITR.value = [2]; // its like make it more glitchy ////

                    FlxTween.num(1.4, 2, 2, {ease: FlxEase.linear}, function(v:Float) { bloomShader.dim.value[0] = v; } );
                    FlxTween.num(2.6, 20, 2, {ease: FlxEase.linear}, function(v:Float) { bloomShader.Directions.value[0] = v; } );
                }
            case 656:
                if(ClientPrefs.data.shaders)
                {
                    deflectiveLensShader.distortionScale.value = [0.5];

                    chromaticAberration.rOffset.value = [0.0015];
                    chromaticAberration.gOffset.value = [0.0];
                    chromaticAberration.bOffset.value = [-0.0015];

                    FlxTween.tween(blackTop, {alpha: 0}, 0.7);

                    icons.velocity.set(-150, -150);

                    glitchShader.GLITCH_THR.value = [0.0]; // velocity //// 0.01
                    glitchShader.GLITCH_RECT_DIVISION.value = [0]; // size (more high, more small) name also say it, """""division""""" //// 5
                    glitchShader.GLITCH_RECT_ITR.value = [0]; // its like make it more glitchy ////
                }
        }
    }
}