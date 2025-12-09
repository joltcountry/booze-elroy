local graphics = require("graphics")
local chars = {}

chars.pac = {
    x = (8 * 14),
    y = (8 * 26) + 4,
    dir = 2, -- 0 = right, 1 down, 2 left, 3 right
    speed = .8,
    turnWindow = 3
}
chars.pac.animator = function()
   return graphics.animations.pac[g.chars.pac.dir]
end

-- chars.blinky = {
--     x = 70,
--     y = 120,
--     dir = 1,
--     speed = .85
-- }
-- chars.blinky.animator = function()
--     return graphics.animations.blinky[g.chars.blinky.dir]
-- end

-- chars.pinky = {
--     x = 90,
--     y = 120,
--     dir = 2,
--     speed = .75
-- }
-- chars.pinky.animator = function()
--     return graphics.animations.pinky[g.chars.pinky.dir]
-- end

-- chars.inky = {
--     x = 20,
--     y = 120,
--     dir = 3,
--     speed = .75
-- }
-- chars.inky.animator = function()
--     return graphics.animations.inky[g.chars.inky.dir]
-- end

-- chars.clyde = {
--     x = 55,
--     y = 120,
--     dir = 0,
--     speed = .75
-- }
-- chars.clyde.animator = function()
--     return graphics.animations.clyde[g.chars.clyde.dir]
-- end

return chars