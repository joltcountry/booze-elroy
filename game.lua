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
        if g.frightened <= 0 then
            g.sounds.scared:stop()
            local anyDead = false
            for _, char in pairs(g.chars) do
                if char.dead then
                    anyDead = true
                    break
                end
            end
            if not anyDead then
                playSiren()
            end
            g.frightened = false
            if not g.config.fastPac then g.chars.pac.speed = g.level.pacSpeed end
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
    if g.config.scatterOption == 2 then return end
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
    if joystick then
        -- Check d-pad first (has priority)
        if joystick:isGamepadDown("dpright") then g.chars.pac.iDir = 0 end
        if joystick:isGamepadDown("dpdown")  then g.chars.pac.iDir = 1 end
        if joystick:isGamepadDown("dpleft")  then g.chars.pac.iDir = 2 end
        if joystick:isGamepadDown("dpup")    then g.chars.pac.iDir = 3 end
        
        -- If no d-pad input, check analog stick
        if g.chars.pac.iDir == false then
            local deadzone = 0.3  -- Threshold to avoid drift
            local leftX = joystick:getGamepadAxis("leftx")
            local leftY = joystick:getGamepadAxis("lefty")
            
            -- Find the axis with the largest absolute value
            local absX = math.abs(leftX)
            local absY = math.abs(leftY)
            
            if absX > deadzone or absY > deadzone then
                -- Determine direction based on dominant axis
                if absX > absY then
                    -- Horizontal movement
                    if leftX > 0 then
                        g.chars.pac.iDir = 0  -- right
                    else
                        g.chars.pac.iDir = 2  -- left
                    end
                else
                    -- Vertical movement
                    if leftY > 0 then
                        g.chars.pac.iDir = 1  -- down
                    else
                        g.chars.pac.iDir = 3  -- up
                    end
                end
            end
        end
    end
    for joyDir, dir in pairs(constants.joyDirs) do
        if love.keyboard.isDown(joyDir) then g.chars.pac.iDir = dir end
    end
end

-- Helper function to handle character movement
local updateCharacterMovement = function(char)
    char.moved = false
    logic.move(char)
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

    -- i want this removed!  but I need it for testing
    math.randomseed(os.time())

    -- One-time audio-device-sensitive reload of sources when starting the game
    if reloadAudioSources then
        reloadAudioSources()
    end
    
    g.levelNumber = 1
    g.scenery = {}
    mode.setMode("pregame")
    g.lives = g.config.startingLives
    g.score = 0
    g.paused = false
    
    maze.init()

    levels.startLevel(g.levelNumber)
    characters.initialize()
    characters.reset()

end

local forceLeave = function(char)
    char.leaving = true
    char.housing = false
    if char == g.chars.clyde and g.suspendElroy then g.suspendElroy = false end
end

function game.update(dt)

    if g.paused then return end
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    mode.handle()

    if g.state.running then

        g.starvation = g.starvation or 0
        g.starvation = g.starvation + 1

        -- Leaving logic
        local leavingChars = {}
        for name, char in pairs(g.chars) do
            if char.housing and char.leavingPreference ~= nil then
                table.insert(leavingChars, char)
            end
        end
        table.sort(leavingChars, function(a, b)
            return a.leavingPreference < b.leavingPreference
        end)

        for i = 1, #leavingChars do
            local char = leavingChars[i]

            -- starvation timer
            if g.starvation >= g.level.starvation then
                forceLeave(char)
                g.starvation = 0
                break
            end

            if g.globalCounter then 

                if g.globalCounter == char.globalCounter then
                    forceLeave(char)
                    if g.globalCounter == 32 then
                        g.globalCounter = false
                    end
                end

            else -- personal dot counter
                if char.dotCounter == 0 then
                    forceLeave(char)
                    break
                end
            end

        end

        updateFrightenedState()
        handleModeSwitching()
        handlePlayerInput()

        -- Reset ghost eaten flag at start of each frame
        g.ghostEatenThisFrame = false

        logic.turn(g.chars.pac)
        -- Update all characters
        for name, char in pairs(g.chars) do
            if g.mode ~= "caught" and g.mode ~= "ateGhost" then
                updateCharacterMovement(char)
            end
        end
        
        -- Handle fruit
        if g.fruitTimer then
            g.fruitTimer = g.fruitTimer - 1
            if g.fruitTimer == 0 then
                g.fruitTimer = false
            end
        end

        -- level complete
        if #g.dots == 0 and #g.powers == 0 then
            mode.setMode("levelComplete")
        end
        
        -- Update animation
        if g.chars.pac.moved then
            graphics.updateAnimation(g.chars.pac, fc)
        end
    elseif g.mode == "ateGhost" then -- hack to move dead ghosts
        for _, c in pairs(g.chars) do
            if c.dead and not c.hidden then
                updateCharacterMovement(c)
            end
        end
    end

    -- hack, they animate while you're dying but not while setting up
    if g.chars and g.mode ~= "playerUp" and g.mode ~= "ready" and g.mode ~= "levelComplete" then
        -- Update scenery animations
        for name, power in pairs(g.powers) do
            graphics.updateAnimation(power, fc)
        end
        if g.mode ~= "ateGhost" then
            for _, c in pairs(g.chars) do
                -- Update animation
                if c.target then
                    graphics.updateAnimation(c, fc)
                end
            end
        end
    end


end

function game.draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()
    if g.backgrounds[g.config.background] then
        love.graphics.setColor(.5, .5, .5)
        love.graphics.draw(g.backgrounds[g.config.background], 0, 0, 0, 224 / g.backgrounds[g.config.background]:getWidth(), 288  / g.backgrounds[g.config.background]:getHeight())
        love.graphics.setColor(1, 1, 1)
    end
    -- Draw mode messages
    if g.mode == "playerUp" then
        graphics.print("player one", 9, 14, 3)
        graphics.print("ready!", 11, 20, 6)
    elseif g.state.showReady then
        graphics.print("ready!", 11, 20, 6)
    end

    -- Draw score
    if fc % 32 < 16 then graphics.print("1up", 3, 0) end
    graphics.print("high score", 9, 0)
    graphics.print(formatScore(g.score or 0), 0, 1, 0)
    if g.highScore then
        graphics.print(formatScore(g.highScore), 10, 1)
    end

    if not g.state.hideMaze then
        if g.mode == "levelAnimation" and g.modeTimer % 20 > 10 then
            maze.draw(5)
        elseif g.mode ~= "pause" then
            maze.draw(g.config.mazeColor)
        end
        
        -- Draw scenery (use ipairs for arrays)
        for _, scenery in ipairs(g.dots) do
            graphics.drawScenery(scenery, scenery.x, scenery.y)
        end
        for _, scenery in ipairs(g.powers) do
            graphics.drawScenery(scenery, scenery.x, scenery.y)
        end

        -- Draw level display
        for i = 1, #g.level.levelDisplay do
            graphics.drawSpriteAtTile(g.level.levelDisplay[i].sheet, g.level.levelDisplay[i].quad, 26 - (i*2), 34)
        end

        -- Draw lives
        for i = 1, g.lives do
            graphics.drawSpriteAtTile("spr16", 77, i*2, 34)
        end        
    end

    -- Draw fruit
    if g.fruitTimer then
        graphics.drawSprite(g.level.fruit.sheet, g.level.fruit.quad, fruits.x - 8, fruits.y - 8)
    end
  
    if g.mode == "ateFruit" then
        graphics.drawFruitScore(g.level.fruit.score, fruits.x - 8, fruits.y - 8)
    end

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
        graphics.drawGhostScore(g.ghostScore, g.chars.pac.x - 8, g.chars.pac.y - 8)
    end
    
    if g.mode == "dying" then
        if g.modeTimer > 180 then
            graphics.drawSprite("spr16", 66, g.chars.pac.x - 8, g.chars.pac.y - 8)
        elseif g.modeTimer > 100 then
            if g.modeTimer <= 180 and not g.diedSoundPlayed then
                g.sounds.died:play()
                g.diedSoundPlayed = true
            end
            local dFrame = 180 - g.modeTimer
            graphics.drawSprite("spr16", 66 + math.floor(dFrame / 8), g.chars.pac.x - 8, g.chars.pac.y - 8)
        elseif g.modeTimer > 70 then
            graphics.drawSprite("spr16", 76, g.chars.pac.x - 8, g.chars.pac.y - 8)
        end
    end

    if g.mode == "gameover" then
        graphics.print("game", 9, 20, 1)
        graphics.print("over", 15, 20, 1)
    end

    love.graphics.setCanvas()

    -- Draw debug info
    --drawDebugInfo()
end

return game

