function onCreatePost()
    makeLuaSprite("black", nil, 0, 0)
    makeGraphic("black", screenWidth * 2, screenHeight * 2, "000000")
    addLuaSprite("black", true)
    setObjectCamera("black", "hud")
end

function onStepHit()
    if curStep == 1 then
        doTweenAlpha("PLEASE", "black", 0, 1, "linear")
    end
end