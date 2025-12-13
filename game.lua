local maze = require("maze")
local graphics = require("graphics")
local characters = require("characters")
local constants = require("constants")
local fruits = require("fruits")
local logic = require("logic")
local mode = require("mode")
local levels = require("levels")

local game = {
    name = "game"
}

-- Game state variables
local fc = 0

-- Helper function to update frightened state
local updateFrightenedState = function()
    if g.frightened then
        g.frightened = g.frightened - 1
        if g.frightened == 0 then
            g.frightened = false
            g.chars.pac.speed = g.level.pacSpeed
            for _, c in pairs(g.chars) do
                if c.target and c.frightened then
                    c.speed = logic.getGhostSpeed(c)
                    c.frightened = false
                end
            end
        end
    end
end

-- Helper function to handle mode switching
local handleModeSwitching = function()
    if not g.frightened then
        g.level.timer = g.level.timer + 1
        for _, switchTime in ipairs(g.level.switch) do
            if g.level.timer == switchTime then
                g.level.chase = not g.level.chase
                for _, c in pairs(g.chars) do
                    if c.target then
                        if c.housing then
                            c.leaveRight = 2 -- total hack, gimme a break
                        end
                        if not c.housing and not c.leaving and not c.entering and not c.dead then
                            c.dir = (c.dir + 2) % 4
                            c:target()
                        end
                    end
                end
                break
            end
        end
    end
end

-- Helper function to handle player input
local handlePlayerInput = function()
    g.chars.pac.iDir = false
    for joyDir, dir in pairs(constants.joyDirs) do
        if love.keyboard.isDown(joyDir) then g.chars.pac.iDir = dir end
    end
end

-- Helper function to handle character movement
local updateCharacterMovement = function(char)
    char.moved = false
    logic.move(char)
end

-- Helper function to activate frightened mode
local activateFrightenedMode = function()
    g.frightened = g.level.frightened
    g.ghostScore = false
    g.chars.pac.speed = g.level.pacFrightenedSpeed
    for name, char in pairs(g.chars) do
        if char.target and not char.dead then
            char.frightened = true
            char.speed = logic.getGhostSpeed(char)
            if not char.housing and not char.leaving and not char.entering then
                char.dir = (char.dir + 2) % 4
                char:target()
            end
        end
    end
end

-- Helper function to check and handle collisions with collectibles
local checkCollisions = function(collectibles, xTile, yTile, power)
    for i = #collectibles, 1, -1 do
        local item = collectibles[i]
        if xTile == item.x and yTile == item.y then
            g.score = g.score + item.score
            g.chars.pac.skipCounter = item.skipCounter
            if power then
                activateFrightenedMode()
            end
            table.remove(collectibles, i)
        end
    end
end

-- Helper function to draw debug information
local drawDebugInfo = function()
    if (g.chars) then
        local xTile, xOff, yTile, yOff = maze.getLoc(g.chars.pac)
        love.graphics.print("PAC X/Y:      " .. g.chars.pac.x .. '/' .. g.chars.pac.y, 50, 50)
        love.graphics.print('PAC TILE X/Y: ' .. xTile .. "/" .. yTile, 50, 60)
        love.graphics.print('PAC OFF X/Y:  ' .. xOff .. "/" .. yOff, 50, 70)
        love.graphics.print("DIR/IDIR: " .. g.chars.pac.dir .. "/" .. (g.chars.pac.iDir or 'X'), 50, 100)

        xTile, xOff, yTile, yOff = maze.getLoc(g.chars.blinky)
        love.graphics.print("PINKY X/Y:      " .. g.chars.blinky.x .. '/' .. g.chars.blinky.y, 50, 120)
        love.graphics.print('BLINKY TILE X/Y: ' .. xTile .. "/" .. yTile, 50, 130)
        if (g.chars.blinky.targetX) then love.graphics.print('BLINKY TARGET X/Y: ' .. g.chars.blinky.targetX .. "/" .. g.chars.blinky.targetY, 50, 200) end
        love.graphics.print('BLINKY OFF X/Y:  ' .. xOff .. "/" .. yOff, 50, 140)
        love.graphics.print("DIR/IDIR: " .. g.chars.blinky.dir .. "/" .. (g.chars.blinky.iDir or 'X'), 50, 150)
    end
end

function game.start()

    g.scenery = {}
    mode.setMode("playerUp")
    g.lives = 3
    g.score = 0
    local powers = maze.getPowers()
    local dots = maze.getDots()
    g.powers = {}
    g.dots = {}
    for _, p in ipairs(powers) do
        table.insert(g.powers, {
            x = p.x, y = p.y, score = 50, skipCounter = 3, animator = function() return graphics.animations.power end
        })
    end
    for _, d in ipairs(dots) do
        table.insert(g.dots, {
            x = d.x, y = d.y, score = 10, skipCounter = 1, animator = function() return graphics.animations.dot end
        })
    end    

    g.level = levels.getLevel()

end

function game.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    mode.handle()

    if g.state.running then
        updateFrightenedState()
        handleModeSwitching()
        handlePlayerInput()
        
        logic.turn(g.chars.pac)
        -- Update all characters
        for name, char in pairs(g.chars) do
            updateCharacterMovement(char)
        end

        -- Check collisions with collectibles (reuse pac location from movement update)
        local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
        checkCollisions(g.powers, pacXTile, pacYTile, true)
        checkCollisions(g.dots, pacXTile, pacYTile)

        -- Check ghost collisions (reuse pac location)
        for name, char in pairs(g.chars) do
            if char.target then
                local ghostXTile, ghostXOff, ghostYTile, ghostYOff = maze.getLoc(char)
                if pacXTile == ghostXTile and pacYTile == ghostYTile then
                    if char.frightened then
                        char.dead = true-- ate a ghost
                        char.frightened = false
                        char.speed = logic.getGhostSpeed(char)
                        char:target()
                        char.hidden = true
                        mode.setMode("ateGhost")
                        if g.ghostScore then g.ghostScore = g.ghostScore * 2 else g.ghostScore = 200 end
                        g.score = g.score + g.ghostScore
                    elseif not char.dead then
                        mode.setMode("caught")
                    end
                end
            end
        end

            -- Update animation
        if g.chars.pac.moved then
            graphics.updateAnimation(g.chars.pac, fc)
        end
    end

    -- hack, they animate while you're dying but not while setting up
    if g.chars and g.mode ~= "ready" then
        -- Update scenery animations
        for name, power in pairs(g.powers) do
            graphics.updateAnimation(power, fc)
        end
        for _, c in pairs(g.chars) do
            -- Update animation
            if c.target then
                graphics.updateAnimation(c, fc)
            end
        end
    end
    
    -- Update high score
    if (not g.highScore or g.score > g.highScore) and g.score > 0 then
        g.highScore = g.score
    end
end

function game.draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    -- Draw mode messages
    if g.mode == "playerUp" then
        graphics.print("player one", 9, 14, 3)
        graphics.print("ready!", 11, 20, 6)
    elseif g.state.showReady then
        graphics.print("ready!", 11, 20, 6)
    end

    -- Draw scenery (use ipairs for arrays)
    for _, scenery in ipairs(g.dots) do
        graphics.drawScenery(scenery, scenery.x, scenery.y)
    end
    for _, scenery in ipairs(g.powers) do
        graphics.drawScenery(scenery, scenery.x, scenery.y)
    end

    -- Draw score
    if fc % 32 < 16 then graphics.print("1up", 3, 0) end
    graphics.print("high score", 9, 0)
    graphics.print(formatScore(g.score or 0), 0, 1, 0)
    if g.highScore then
        graphics.print(formatScore(g.highScore), 10, 1)
    end

    maze.draw()

    -- Draw characters (ghosts last)
    if g.state.showPac then
        graphics.drawChar(g.chars.pac, g.chars.pac.x, g.chars.pac.y)
    end
    if g.state.showGhosts then
        for name, char in pairs(g.chars) do
            if char.target and not char.hidden then graphics.drawChar(char, char.x, char.y) end
        end
    end
    
    if g.mode == "ateGhost" then
        pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
        graphics.print(g.ghostScore, pacXTile - 1, pacYTile, 3)
    end

    -- Draw fruit and lives
    graphics.drawSpriteAtTile(fruits.cherry.sheet, fruits.cherry.quad, 24, 34)
    for i = 1, g.lives do
        graphics.drawSpriteAtTile("spr16", 61, i*2, 34)
    end
    
    if g.mode == "dying" then
        if g.modeTimer > 180 then
            graphics.drawSprite("spr16", 50, g.chars.pac.x - 8, g.chars.pac.y - 8)
        elseif g.modeTimer > 100 then
            local dFrame = 180 - g.modeTimer
            graphics.drawSprite("spr16", 50 + math.floor(dFrame / 8), g.chars.pac.x - 8, g.chars.pac.y - 8)
        elseif g.modeTimer > 70 then
            graphics.drawSprite("spr16", 60, g.chars.pac.x - 8, g.chars.pac.y - 8)
        end
    end

    if g.mode == "gameover" then
        graphics.print("game  over", 9, 20, 1)
    end

    love.graphics.setCanvas()

    -- Draw debug info
    drawDebugInfo()
end

return game

