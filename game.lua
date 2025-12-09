local maze = require("maze")
local graphics = require("graphics")
local characters = require("characters")

local game = {}

local fruits = require("fruits")

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

    xTile, xOff, yTile, yOff = maze.getLoc(c)
    c.accum16 = c.accum16 or 0
    local speed16 = c.speed * speedFactor * 16
    c.accum16 = c.accum16 + speed16;
    while c.accum16 >= 16 do
        c.accum16 = c.accum16 - 16;
        if not maze.isBlocked(c, c.dir) or
            (c.dir == 2 and xOff > 4) or
            (c.dir == 3 and yOff > 4) or
            (c.dir == 0 and xOff < 4) or
            (c.dir == 1 and yOff < 4)
            then 
            -- CLEAN THIS UP TOMORROW
            c.x = c.x + deltas[c.dir].x
            c.y = c.y + deltas[c.dir].y
        end
    end


end

function game.start()

    g.chars = require("characters")
    local powers = maze.getPowers()
    local dots = maze.getDots()
    -- for _, p in ipairs(powers) do
    --     table.insert(g.chars, {
    --         x = p.x, y = p.y, animator = function() return graphics.animations.power end
    --     })
    -- end
    -- for _, d in ipairs(dots) do
    --     table.insert(g.chars, {
    --         x = d.x, y = d.y, animator = function() return graphics.animations.dot end
    --     })
    -- end    

end

function game.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    xTile, xOff, yTile, yOff = maze.getLoc(g.chars.pac)

    if (love.keyboard.isDown('up') and xOff == 4 and not maze.isBlocked(g.chars.pac, 3)) then
        g.chars.pac.dir=3
    elseif (love.keyboard.isDown('right') and yOff == 4 and not maze.isBlocked(g.chars.pac, 0)) then
        g.chars.pac.dir=0
    elseif (love.keyboard.isDown('down') and xOff == 4 and not maze.isBlocked(g.chars.pac, 1)) then
        g.chars.pac.dir=1
    elseif (love.keyboard.isDown('left') and yOff == 4 and not maze.isBlocked(g.chars.pac, 2)) then
        g.chars.pac.dir=2
    end

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

    graphics.print("1up   booze elroy! 2up", 3, 0, 0)
    graphics.print("  00", 3, 1, 0)

    maze.draw()

    graphics.drawSpriteAtTile(fruits.cherry.sheet, fruits.cherry.quad, 24,34)
    graphics.drawSpriteAtTile("spr16", 61, 2, 34)
    graphics.drawSpriteAtTile("spr16", 61, 4, 34)
    love.graphics.setCanvas()

    xTile, xOff, yTile, yOff = maze.getLoc(g.chars.pac);
    love.graphics.print("PAC X/Y:      " .. g.chars.pac.x .. '/' .. g.chars.pac.y, 50, 50)
    love.graphics.print('PAC TILE X/Y: ' .. xTile .. "/" .. yTile, 50, 0)
    love.graphics.print('PAC OFF X/Y:  ' .. xOff .. "/" .. yOff, 50, 70)
end

return game

