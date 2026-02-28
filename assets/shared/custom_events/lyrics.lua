function onEvent(name, value1, value2)
    if name == 'lyrics' then

        local value_2 = stringSplit(value2, ",")

        makeLuaText('lyricsText', value1 or '', 0, 0, getProperty('healthBar.y') - 80)
        setObjectCamera('lyricsText', 'hud')
        setTextSize('lyricsText', value_2[1] or 32)
        setTextColor('lyricsText', value_2[2] or 'FFFFFF')
        setTextAlignment('lyricsText', 'center')   
        screenCenter('lyricsText', 'x') 
        addLuaText('lyricsText')

        makeLuaSprite('lyricsBG', '', 0, 0)
        makeGraphic('lyricsBG', getProperty('lyricsText.width') + 10, 40, '000000')
        setObjectCamera('lyricsBG', 'hud')
        if value1 == nil or value1 == '' then 
            setProperty('lyricsBG.alpha', 0)
        else
            setProperty('lyricsBG.alpha', 0.5)
        end
        addLuaSprite('lyricsBG')
        setObjectOrder('lyricsBG', getObjectOrder('lyricsText') - 1)

        if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') then
            setProperty('lyricsText.y', getProperty('healthBar.y') + getProperty('healthBar.height') + 80)
        end

        setProperty('lyricsBG.x', getProperty('lyricsText.x') + (getProperty('lyricsText.width') / 2) - (getProperty('lyricsBG.width') / 2))
        setProperty('lyricsBG.y', getProperty('lyricsText.y') + (getProperty('lyricsText.height') / 2) - (getProperty('lyricsBG.height') / 2))

        setProperty('lyricsText.antialiasing', getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing', false, false))
    end
end
