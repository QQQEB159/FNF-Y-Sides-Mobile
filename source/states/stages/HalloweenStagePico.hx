package states.stages;

import shaders.Dubswitcher;
import shaders.ColorSwap.ColorSwapShader;
import openfl.filters.ShaderFilter;

class HalloweenStagePico extends BaseStage
{
    var blackBackground:FlxSprite;
	var dubswitcherShader:Dubswitcher;
	var dubswitcherFilter:ShaderFilter;
	var colorSwapShader:ColorSwapShader;
	var colorSwapFilter:ShaderFilter;

	override function create()
	{
		if(!ClientPrefs.data.lowQuality)
		{
            var sky:BGSprite = new BGSprite('stages/halloweenStage/sky', -1248 + 250, -1041, 0, 0);
            add(sky);

            var moon:BGSprite = new BGSprite('stages/halloweenStage/moon', 485, -805, 0.1, 0.1);
            add(moon);

            var clouds:BGSprite = new BGSprite('stages/halloweenStage/clouds', -1286, -1146, 0.2, 0.2);
            add(clouds);
        }
                
        var buildings:BGSprite = new BGSprite('stages/halloweenStage/buildings', -1038, -885, 0.6, 0.6);
        add(buildings);

        var bgmain:BGSprite = new BGSprite('stages/halloweenStage/bgmain', -730, -878, 1, 1);
        add(bgmain);

		if(!ClientPrefs.data.lowQuality)
		{
            var lolas:BGSprite = new BGSprite('stages/halloweenStage/lolas', -17, 263, 1, 1, ['persjnaoi'], true);
            add(lolas);
        }

        blackBackground = new FlxSprite();
        blackBackground.makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
        blackBackground.scrollFactor.set(0, 0);
        blackBackground.screenCenter();
        blackBackground.alpha = 0;
        add(blackBackground);

        if(ClientPrefs.data.shaders)
        {
            dubswitcherShader = new Dubswitcher();
            dubswitcherShader.intensity.value = [0.0];

            dubswitcherFilter = new ShaderFilter(dubswitcherShader);

            colorSwapShader = new ColorSwapShader();
            colorSwapShader.uTime.value = [0, 0, 0];

            colorSwapFilter = new ShaderFilter(colorSwapShader);
            if(ClientPrefs.data.shaders) FlxG.camera.filters = [dubswitcherFilter, colorSwapFilter];
        }
	}

	override function update(elapsed:Float)
	{
		if(dubswitcherShader != null)
			dubswitcherShader.iTime.value[0] += elapsed;
	}

	override function createPost()
	{

	}

    var maxAlpha:Float = 0.25;
	override function stepHit()
	{
        switch(game.curSong)
        {
            case 'South':
                switch(curStep)
                {
                    case 399:
                        FlxTween.tween(blackBackground, {alpha: maxAlpha / 1.3}, 0.15);
                        FlxTween.num(0, 0.015, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            dubswitcherShader.intensity.value[0] = v;
                        });
                        FlxTween.num(0, -0.25, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            colorSwapShader.uTime.value[1] = v;
                        });
                    case 416:
                        blackBackground.alpha = 0;
                        dubswitcherShader.intensity.value[0] = 0;
                        colorSwapShader.uTime.value[1] = 0;
                    case 655:
                        FlxTween.tween(blackBackground, {alpha: maxAlpha / 1.3}, 0.15);
                        FlxTween.num(0, 0.015, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            dubswitcherShader.intensity.value[0] = v;
                        });
                        FlxTween.num(0, -0.25, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            colorSwapShader.uTime.value[1] = v;
                        });
                    case 667:
                        FlxTween.num(0.015, 0, 0.45, {ease: FlxEase.cubeIn}, function(v:Float)
                        {
                            dubswitcherShader.intensity.value[0] = v;
                        });
                        FlxTween.num(-0.25, 0, 0.45, {ease: FlxEase.cubeIn}, function(v:Float)
                        {
                            colorSwapShader.uTime.value[1] = v;
                        });
                    case 672:
                        FlxTween.tween(blackBackground, {alpha: maxAlpha}, 0.35);
                    case 911:
                        FlxTween.tween(blackBackground, {alpha: maxAlpha / 1.3}, 0.15);
                        FlxTween.num(0, 0.02, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            dubswitcherShader.intensity.value[0] = v;
                        });
                        FlxTween.num(0, -0.27, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            colorSwapShader.uTime.value[1] = v;
                        });
                    case 923:
                        FlxTween.num(0.015, 0, 0.45, {ease: FlxEase.cubeIn}, function(v:Float)
                        {
                            dubswitcherShader.intensity.value[0] = v;
                        });
                        FlxTween.num(-0.25, 0, 0.45, {ease: FlxEase.cubeIn}, function(v:Float)
                        {
                            colorSwapShader.uTime.value[1] = v;
                        });
                    case 928:
                        blackBackground.alpha = 0;
                    case 1423:
                        FlxTween.tween(blackBackground, {alpha: maxAlpha / 1.3}, 0.15);
                        FlxTween.num(0, 0.025, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            dubswitcherShader.intensity.value[0] = v;
                        });
                        FlxTween.num(0, -0.3, 0.45, {ease: FlxEase.cubeOut}, function(v:Float)
                        {
                            colorSwapShader.uTime.value[1] = v;
                        });
                    case 1435:
                        FlxTween.num(0.015, 0, 0.45, {ease: FlxEase.cubeIn}, function(v:Float)
                        {
                            dubswitcherShader.intensity.value[0] = v;
                        });
                        FlxTween.num(-0.25, 0, 0.45, {ease: FlxEase.cubeIn}, function(v:Float)
                        {
                            colorSwapShader.uTime.value[1] = v;
                        });
                }
        }
	}
}