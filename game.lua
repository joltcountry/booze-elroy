local maze = require("maze")
local graphics = require("graphics")
local characters = require("characters")
local constants = require("constants")
local game = {}

local fruits = require("fruits")

-- Game state variables
local fc = 0
local speedFactor = 20/16 -- 1.25

local joyDirs = {
    right = 0,
    down = 1,
    left = 2,
    up = 3
}

local advance = function(c, xOff, yOff)
    -- CLEAN THIS UP TOMORROW
    c.x = c.x + constants.deltas[c.dir].x
    c.y = c.y + constants.deltas[c.dir].y

    if c.dir % 2 == 0 then -- left/right, correct yOff
        if yOff > constants.centerLine then c.y = c.y - 1 end
        if yOff < constants.centerLine then c.y = c.y + 1 end
    else
        if xOff < constants.centerLine then c.x = c.x + 1 end
        if xOff > constants.centerLine then c.x = c.x - 1 end
    end

    -- check for wraparound
    xTile, xOff, yTile, yOff = maze.getLoc(c)
    if xTile == maze.w + 2 then
        c.x = -2 * constants.tileSize + xOff
    elseif xTile == -3 then
        c.x = (maze.w + 1) * constants.tileSize + xOff
    end
    c.moved = true
end

local move = function(c)

    if c.skipCounter and c.skipCounter > 0 then
        c.skipCounter = c.skipCounter - 1
        return
    end

-- add iDir -- ghost should set iDir each tile, pac's iDir is set by joystick
    c.accum16 = c.accum16 or 0
    local speed16 = c.speed * speedFactor * 16
    c.accum16 = c.accum16 + speed16;
    while c.accum16 >= 16 do
        xTile, xOff, yTile, yOff = maze.getLoc(c)
        c.accum16 = c.accum16 - 16;

        if not maze.isBlocked(c, c.dir) or 
            (c.dir == 2 and xOff > constants.centerLine) or
            (c.dir == 3 and yOff > constants.centerLine) or
            (c.dir == 0 and xOff < constants.centerLine) or
            (c.dir == 1 and yOff < constants.centerLine) then 
            advance(c, xOff, yOff)
        else 
            if c.iDir and not maze.isBlocked(c, c.dir) then
                c.dir = c.iDir
                advance(c, xOff, yOff)
            end
        end
    end


end

function game.start()

    g.chars = require("characters")
    g.scenery = {}
    g.score = 0
    local powers = maze.getPowers()
    local dots = maze.getDots()
    for _, p in ipairs(powers) do
        table.insert(g.scenery, {
            x = p.x, y = p.y, score = 50, skipCounter = 3, animator = function() return graphics.animations.power end
        })
    end
    for _, d in ipairs(dots) do
        table.insert(g.scenery, {
            x = d.x, y = d.y, score = 10, skipCounter = 1, animator = function() return graphics.animations.dot end
        })
    end    

end

function game.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    -- Check for directional input
    g.chars.pac.iDir = false
    for joyDir, dir in pairs(joyDirs) do
        if love.keyboard.isDown(joyDir) then g.chars.pac.iDir = dir end
    end

    -- decide whether to turn or not
    for name, c in pairs(g.chars) do
        xTile, xOff, yTile, yOff = maze.getLoc(c)

        if c.iDir then
            -- can always turn around
            if math.abs(c.dir - c.iDir) == 2 then
                c.dir = c.iDir
            end

            -- if perpendicular turn
            if (c.dir - c.iDir) % 2 == 1 and xTile > 0 and xTile < maze.w then -- the xTile check is so he can't leave tunnel
                local turnWindow = c.turnWindow or 0
                if c.dir % 2 == 0 then -- left or right
                    if not maze.isBlocked(c, c.iDir) and math.abs(xOff - constants.centerLine) <= turnWindow then -- moving up or down
                        c.dir = c.iDir
                    end
                elseif not maze.isBlocked(c, c.iDir) and math.abs(xOff - constants.centerLine) <= turnWindow then
                    c.dir = c.iDir
                end
            end
        end

    end

    -- Move all characters if able
    for name, char in pairs(g.chars) do
        char.moved = false
        move(char)
        if (char.moved) then
            graphics.updateAnimation(char, fc)
        end
    end

    -- update scenery animation
    for name, scenery in pairs(g.scenery) do
        graphics.updateAnimation(scenery, fc)
    end

    -- check for ate dots/pellets
    local xTile, xOff, yTile, yOff = maze.getLoc(g.chars.pac)
    for _, s in ipairs(g.scenery) do
        if xTile == s.x and yTile == s.y then
            g.score = g.score + s.score
            g.chars.pac.skipCounter = s.skipCounter
            table.remove(g.scenery, _)
        end
    end
end

function game.draw()

    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    for name, char in pairs(g.chars) do
        graphics.drawChar(char, char.x, char.y)
    end

    for name, scenery in pairs(g.scenery) do
        graphics.drawScenery(scenery, scenery.x, scenery.y)
    end

    graphics.print("1up   booze elroy! 2up", 3, 0, 0)
    local score = g.score or 0
    local scoreText
    if score == 0 then
        scoreText = "     00"
    else
        scoreText = string.rep(" ", 7 - tostring(score):len()) .. tostring(score)
    end
    graphics.print(scoreText, 0, 1, 0)

    maze.draw()

    graphics.drawSpriteAtTile(fruits.cherry.sheet, fruits.cherry.quad, 24,34)
    graphics.drawSpriteAtTile("spr16", 61, 2, 34)
    graphics.drawSpriteAtTile("spr16", 61, 4, 34)
    love.graphics.setCanvas()

    xTile, xOff, yTile, yOff = maze.getLoc(g.chars.pac);
    love.graphics.print("PAC X/Y:      " .. g.chars.pac.x .. '/' .. g.chars.pac.y, 50, 50)
    love.graphics.print('PAC TILE X/Y: ' .. xTile .. "/" .. yTile, 50, 60)
    love.graphics.print('PAC OFF X/Y:  ' .. xOff .. "/" .. yOff, 50, 70)
    love.graphics.print("DIR/IDIR: " .. g.chars.pac.dir .. "/" .. (g.chars.pac.iDir or 'X'), 50, 100)
end

return game

