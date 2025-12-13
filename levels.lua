local levels = {}
local fruits = require("fruits")

levels.getLevel = function()
    return {
        pacSpeed = .8,
        pacFrightenedSpeed = .9,
        tunnelSpeed = .4,
        ghostSpeed = .75,
        frightened = 6 * 60,
        frightenedSpeed = .5,
        elroy1 = 20,
        elroy1Speed = .8,
        elroy2 = 10,
        elroy2Speed = .85,
        timer = 0,
        switch = {7*60, 27*60, 34*60, 54*60, 59*60, 79*60, 84*50},
        fruit = fruits.galaxian,
        levelDisplay = {fruits.strawberry, fruits.peach, fruits.apple, fruits.apple, fruits.melon, fruits.melon, fruits.galaxian },
        starvation = 4 * 60
    }
end

return levels