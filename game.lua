local maze = require("maze")
local graphics = require("graphics")
local characters = require("characters")

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

function game.start()

    g.chars = require("characters")
    local powers = maze.getPowers()
    local dots = maze.getDots()
    for _, p in ipairs(powers) do
        table.insert(g.chars, {
            x = p.x, y = p.y, animator = function() return graphics.animations.power end
        })
    end
    for _, d in ipairs(dots) do
        table.insert(g.chars, {
            x = d.x, y = d.y, animator = function() return graphics.animations.dot end
        })
    end    

end

function game.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    for name, char in pairs(g.chars) do
        if char.speed then 
            move(char)
        end
        graphics.updateAnimation(char, fc)

    end
    
end

function game.draw()

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    for name, char in pairs(g.chars) do
        graphics.draw(char, char.x, char.y)
    end

    graphics.print("1up   booze elroy!", (2 * 8), 1, 0)
    graphics.print("  00", (2 * 9), 9, 0)


    maze.draw()
    love.graphics.setCanvas()
end

return game

