animations = {}

animations.pac = {
    frames = {1, 2, 3, 2},
    frame = 1,
    speed = 3,
}

animations.animate = function(a)

end

animations.update = function(a, frameCounter)
    if frameCounter % a.speed == 0 then
        a.frame = (a.frame % #a.frames) + 1
    end
end

return animations