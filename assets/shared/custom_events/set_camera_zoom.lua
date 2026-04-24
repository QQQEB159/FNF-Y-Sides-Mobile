function onEvent(name, value1, value2, strumTime)
    if name == 'set_camera_zoom' then
        setProperty('camGame.zoom', value1)
        setProperty('defaultCamZoom', value1)
    end
end