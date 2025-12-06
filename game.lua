local maze = require("maze")
local graphics = require("graphics")

local game = {}

-- Game state variables
local fc = 0
local speedFactor = 20/16 -- 1.25
local deltas = {
    [0] = { x = 1, y = 0},
    [1] = { x = 0, y = 1},
    [2] = { x = -1, y = 0},
    [3] = { x = 0, y = -1}
}

local move = function(c)

    c.accum16 = c.accum16 or 0
    local speed16 = c.speed * speedFactor * 16
    c.accum16 = c.accum16 + speed16;
    while c.accum16 >= 16 do
        c.accum16 = c.accum16 - 16;
        c.x = c.x + deltas[c.dir].x * (c.speed * speedFactor)
        c.y = c.y + deltas[c.dir].y * (c.speed * speedFactor)
    end


end

function game.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    for name, char in pairs(g.chars) do
        move(char)
        graphics.updateAnimation(char, fc)
        if fc % 50 == 0 then
            char.dir = (char.dir + 1) % 4
            char.accum16 = 0
        end

    end
    
    graphics.updateAnimation(g.power, fc)
end

function game.draw()
    love.graphics.push()
    love.graphics.scale(3,3)
    for name, char in pairs(g.chars) do
        graphics.draw(char, char.x, char.y)
    end
    graphics.draw(g.power, g.power.x, g.power.y)

    graphics.print("welcome to", 16, 15, 0)
    graphics.print("booze elroy!", 104, 15, 6)


    maze.draw()

    love.graphics.pop()
end

return game

