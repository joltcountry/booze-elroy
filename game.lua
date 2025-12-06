local graphics = require("graphics")
local game = {}

-- Game state variables
local fc = 0
local speedFactor = 1.26262626 -- trust the Dossier!
local deltas = {
    [0] = { x = 1, y = 0},
    [1] = { x = 0, y = 1},
    [2] = { x = -1, y = 0},
    [3] = { x = 0, y = -1}
}

local move = function(c)

    c.x = c.x + deltas[c.dir].x * (c.speed * speedFactor)
    c.y = c.y + deltas[c.dir].y * (c.speed * speedFactor)

end

function game.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    for name, char in pairs(g.chars) do
        move(char)
        graphics.updateAnimation(char, fc)
        if fc % 50 == 0 then
            char.dir = (char.dir + 1) % 4
        end

    end
    
end

function game.draw()
    love.graphics.push()
    love.graphics.scale(6,6)
    for name, char in pairs(g.chars) do
        graphics.draw(char, char.x, char.y)
    end
    love.graphics.pop()
end

return game

