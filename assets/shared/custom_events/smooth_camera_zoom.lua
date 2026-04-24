function onEvent(name, value1, value2, strumTime)
    if name == 'smooth_camera_zoom' then
        local value_2 = stringSplit(value2, ",")
        if value_2[2] == 'instant' then
            setProperty('camGame.zoom', value1)
        else
            doTweenZoom('zoomTween', 'game', value1, value_2[1], value_2[2]);
        end
            
        setProperty('defaultCamZoom', value1)
    end
end