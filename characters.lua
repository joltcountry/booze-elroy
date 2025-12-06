local graphics = require("graphics")
local chars = {}

chars.pac = {
    x = 50,
    y = 50,
    dir = 0, -- 0 = right, 1 down, 2 left, 3 right
    speed = 1
}
chars.pac.animator = function()
   return graphics.animations.pac[g.chars.pac.dir]
end

chars.blinky = {
    x = 70,
    y = 70,
    dir = 1,
    speed = 1
}
chars.blinky.animator = function()
    return graphics.animations.blinky[g.chars.blinky.dir]
end

chars.pinky = {
    x = 90,
    y = 80,
    dir = 2,
    speed = 1
}
chars.pinky.animator = function()
    return graphics.animations.pinky[g.chars.pinky.dir]
end

chars.inky = {
    x = 20,
    y = 80,
    dir = 3,
    speed = 1
}
chars.inky.animator = function()
    return graphics.animations.inky[g.chars.inky.dir]
end

chars.clyde = {
    x = 55,
    y = 100,
    dir = 0,
    speed = .8
}
chars.clyde.animator = function()
    return graphics.animations.clyde[g.chars.clyde.dir]
end

return chars