function onCreate()

    setObjectOrder('dadGroup', getObjectOrder('boyfriendGroup') + 1)

    makeLuaSprite('n', 'stages/returnyStage/neg', 0, 0)
    scaleObject('n', 31, 31)
    addLuaSprite('n', false)  
    setObjectCamera('n', 'camHUD')
    setProperty('n.visible', true)
    setProperty('n.alpha', 0);
    setScrollFactor('n', 0, 0)

    makeLuaSprite('bg', 'stages/returnyStage/gronbgpixel', -7500, -5040)
    scaleObject('bg', 8, 8)
    addLuaSprite('bg', false)  
    setObjectOrder('bg', 1)
    setProperty('bg.visible', true)
    setProperty('bg.antialiasing', false)

    makeLuaSprite('bgn', 'stages/returnyStage/gronbgpixelbar', -600, -350)
    scaleObject('bgn', 1, 1)
    addLuaSprite('bgn', true)  
    setObjectCamera('bgn', 'camHUD')
    setObjectOrder('bgn', 92)  
    setProperty('bgn.alpha', 0.5);
    setProperty('bgn.visible', true)
end

function onUpdate(elapsed)
    if curStep >= 1296 then
        setProperty('dad.angle',
            getProperty('dad.angle') + (-1480 * elapsed))
    end
end

function onStepHit()

    if curStep == 260 then
        -- setProperty('bgn.visible', false)
        doTweenAlpha('bgnTwn', 'bgn', 0, 0.15, 'linear')
    end

    if curStep == 266 then 
        setProperty('bg.visible', false)
    end

    if curStep >= 272 and curStep < 1054 then
        if mustHitSection then
            setProperty("defaultCamZoom", 0.85)
        else
            setProperty("defaultCamZoom", 0.7)
     
        end
    end

    if curStep == 1040 then 
        doTweenAlpha('fadein', 'n', 1, 0.5, 'linear')
    end

    if curStep == 1056 then
        setProperty('bg.visible', true)
        setProperty('bgn.visible', true)
        doTweenAlpha('faden', 'n', 0, 0.5, 'linear')
        setProperty('healthBar.visible', true)
        setProperty('iconP1.visible', true)
        setProperty('iconP2.visible', true)
    end
    if curStep == 1060 then
        setProperty('cameraSpeed', 1)
    end
    if curStep >= 1288 then
        doTweenX('moveDad', 'dad', getProperty('dad.x') - 220, 0.85, 'linear')
    end
    if curStep >= 1296 then
        doTweenX('moveDad', 'dad', getProperty('dad.x') - 300, 0.85, 'linear')
        setProperty('dad.angle', getProperty('dad.angle') + (-1480 * elapsed))
    end
    if curStep == 1312 then
        doTweenAlpha('faden', 'n', 1, 0.1, 'linear')
        setProperty('healthBar.visible', false)
        setProperty('iconP1.visible', false)
        setProperty('iconP2.visible', false)
    end

end


