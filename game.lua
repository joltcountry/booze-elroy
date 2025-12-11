local maze = require("maze")
local graphics = require("graphics")
local characters = require("characters")
local constants = require("constants")
local fruits = require("fruits")
local logic = require("logic")
local mode = require("mode")

local game = {
    name = "game"
}

-- Game state variables
local fc = 0

local joyDirs = {
    right = 0,
    down = 1,
    left = 2,
    up = 3
}

function game.start()

    g.chars = require("characters")
    g.scenery = {}
    g.mode = "playerUp"
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

    level = {
        tunnelSpeed = .4,
        ghostSpeed = .75
    }

end

function game.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    mode.handle()

    if g.state.running then

        -- Check for directional input
        g.chars.pac.iDir = false
        for joyDir, dir in pairs(joyDirs) do
            if love.keyboard.isDown(joyDir) then g.chars.pac.iDir = dir end
        end

        -- decide whether to turn or not
        for name, c in pairs(g.chars) do
            logic.turn(c)
        end

        -- Move all characters if able
        for name, char in pairs(g.chars) do
            local oldXTile, oldXOff, oldYTile, oldYOff = maze.getLoc(char)
            char.moved = false
            logic.move(char)
            if (char.moved) then
                local newXTile, newXOff, newYTile, newYOff = maze.getLoc(char)

                -- if ghost enters new tile:
                if (newXTile ~= oldXTile or newYTile ~= oldYTile) and char.target then
                    char:target()
                    if maze.isTunnel(newXTile, newYTile) then
                        char.speed = level.tunnelSpeed
                    else
                        char.speed = level.ghostSpeed
                    end
                end 

                -- update animation
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
end

function game.draw()

    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    if g.mode == "playerUp" then
        graphics.print("player one", 9, 14, 3)
        graphics.print("ready!", 11, 20, 6)
    end

    if g.mode == "ready" then
        graphics.print("ready!", 11, 20, 6)
    end

    for name, scenery in pairs(g.scenery) do
        graphics.drawScenery(scenery, scenery.x, scenery.y)
    end

    if g.state.showPac then
        for name, char in pairs(g.chars) do
            graphics.drawChar(char, char.x, char.y)
        end
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
    for i = 1, g.lives do
        graphics.drawSpriteAtTile("spr16", 61, i*2, 34)
    end
    love.graphics.setCanvas()

    xTile, xOff, yTile, yOff = maze.getLoc(g.chars.pac);
    love.graphics.print("PAC X/Y:      " .. g.chars.pac.x .. '/' .. g.chars.pac.y, 50, 50)
    love.graphics.print('PAC TILE X/Y: ' .. xTile .. "/" .. yTile, 50, 60)
    love.graphics.print('PAC OFF X/Y:  ' .. xOff .. "/" .. yOff, 50, 70)
    love.graphics.print("DIR/IDIR: " .. g.chars.pac.dir .. "/" .. (g.chars.pac.iDir or 'X'), 50, 100)

    xTile, xOff, yTile, yOff = maze.getLoc(g.chars.blinky);
    love.graphics.print("BLINKY X/Y:      " .. g.chars.blinky.x .. '/' .. g.chars.blinky.y, 50, 120)
    love.graphics.print('BLINKY TILE X/Y: ' .. xTile .. "/" .. yTile, 50, 130)
    love.graphics.print('BLINKY OFF X/Y:  ' .. xOff .. "/" .. yOff, 50, 140)
    love.graphics.print("DIR/IDIR: " .. g.chars.blinky.dir .. "/" .. (g.chars.blinky.iDir or 'X'), 50, 150)

end

return game

