function onCreate()
    makeLuaSprite('stagel2', 'stages/returnyStage/gronxdl2', 3600, -680)
    scaleObject('stagel2', 1.1, 1.1)
    setBlendMode('stagel2', 'add')
    setProperty('stagel2.visible', true)
    setProperty('stagel2.alpha', 1)

    makeLuaSprite('stagel', 'stages/returnyStage/gronxdl', 3600, -80)
    scaleObject('stagel', 1.1, 1.1)
    setBlendMode('stagel', 'multiply')
    setProperty('stagel.visible', true)
    setProperty('stagel.alpha', 1)


	makeLuaSprite('stageback', 'stages/returnyStage/gronxd', 2900, -650);
	setScrollFactor('stageback', 1, 1);
    scaleObject('stageback', 1.1, 1.1);

	makeLuaSprite('stagen', 'stages/returnyStage/gronxdstuff', 3050, 200);
	setScrollFactor('stagen', 1.2, 1.2);
    scaleObject('stagen', 1.2, 1.2);

    addLuaSprite('stagel', true)  
    addLuaSprite('stagel2', true)  
    addLuaSprite('stageback', false);
    addLuaSprite('stagen', true);    

    runTimer('flicker', 0.2)  
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'flicker' then
        local chance = math.random(1,10)
        if chance <= 3 then
            doTweenAlpha('fadestagel2', 'stagel2', 0.2, 0.05, 'linear')
        else
            doTweenAlpha('fadestagel2', 'stagel2', 0.6, 0.1, 'linear')
        end
 
        runTimer('flicker', getRandomFloat(0.05, 0.4))
    end
end
