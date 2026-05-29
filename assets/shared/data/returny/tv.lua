local shaderName = "crt"
function onCreate()
    shaderCoordFix() -- initialize a fix for textureCoord when resizing game window

    makeLuaSprite("tempShader0")

    runHaxeCode([[
        var shaderName = "]] .. shaderName .. [[";
        
        game.initLuaShader(shaderName);
        
        shader0 = game.createRuntimeShader(shaderName);
        FlxG.game.setFilters([new ShaderFilter(shader0)]);
    ]])
end

function onUpdate()
    runHaxeCode([[
        shader0.setFloat("iTime", ]] .. os.clock() .. [[);
    ]])
end

function shaderCoordFix()
    runHaxeCode([[
        resetCamCache = function(?spr) {
            if (spr == null || spr.filters == null) return;
            spr.__cacheBitmap = null;
            spr.__cacheBitmapData3 = spr.__cacheBitmapData2 = spr.__cacheBitmapData = null;
            spr.__cacheBitmapColorTransform = null;
        }
        
        fixShaderCoordFix = function(?_) {
            resetCamCache(game.camGame.flashSprite);
            resetCamCache(game.camHUD.flashSprite);
            resetCamCache(game.camOther.flashSprite);
        }
    
        FlxG.signals.gameResized.add(fixShaderCoordFix);
        fixShaderCoordFix();
    ]])
    
    local temp = onDestroy
    function onDestroy()
        runHaxeCode([[
            FlxG.signals.gameResized.remove(fixShaderCoordFix);
        ]])
        temp()
    end
end
function onEndSong()
    runHaxeCode('FlxG.game.setFilters([]);')
end

function onGameOver()
    runHaxeCode('FlxG.game.setFilters([]);')
end

function onDestroy()
    runHaxeCode('FlxG.game.setFilters([]);')
end
function onStepHit()
    if curStep == 272 then
        runHaxeCode('FlxG.game.setFilters([]);')
    end
    if curStep == 1056 then
        runHaxeCode([[
            FlxG.game.setFilters([new ShaderFilter(shader0)]);
        ]])
    end
end

function onBeatHit()
end