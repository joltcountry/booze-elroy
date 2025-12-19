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

local isScaryMonster = function(xTile, yTile, dir, distance)
    distance = distance or 1
    for _, char in pairs(g.chars) do
        if char.target and not char.dead and not char.frightened and not char.housing then
            local d = constants.deltas[dir]
            local targetX = xTile + (d.x * distance)
            local targetY = yTile + (d.y * distance)
            local charXTile, charXOff, charYTile, charYOff = maze.getLoc(char)
            if charXTile == targetX and charYTile == targetY then
                return true
            end
        end
    end
end

local phasePac = function()
    g.chars.pac.phased = 60
    if g.sounds.phase:isPlaying() then g.sounds.phase:stop() end
    g.sounds.phase:play()
end


-- Helper function to handle player input
local handlePlayerInput = function()
    g.chars.pac.iDir = false

    -- AUTOPLAY AI.  OOF --
    if g.autoplay or g.attract then 
        local xTile, xOff, yTile, yOff = maze.getLoc(g.chars.pac)
        local oneInFront = { xTile = xTile + constants.deltas[g.chars.pac.dir].x, yTile = yTile + constants.deltas[g.chars.pac.dir].y }
        if isScaryMonster(xTile, yTile, g.chars.pac.dir, 1) 
            or isScaryMonster(xTile, yTile, g.chars.pac.dir, 2)
            or isScaryMonster(oneInFront.xTile, oneInFront.yTile, (g.chars.pac.dir - 1) % 4, 1) 
            or isScaryMonster(oneInFront.xTile, oneInFront.yTile, (g.chars.pac.dir + 1) % 4, 1)
        then
            if g.config.phasing and not g.chars.pac.phased then
                phasePac()
            else
                if not g.state.turnaroundCooldown then
                    g.chars.pac.iDir = (g.chars.pac.dir + 2) % 4
                    g.state.turnaroundCooldown = math.ceil(math.min(maze.w, maze.h) / 2)
                    return
                end
            end
        end

        if xOff == constants.centerLine and yOff == constants.centerLine then

            local candidates = {}
            for i = 0, 3 do
                if not maze.isBlocked(g.chars.pac, i) and (g.chars.pac.phased or (not isScaryMonster(xTile, yTile, i, 1) and not isScaryMonster(xTile, yTile, i, 2))) then
                    if math.abs(i - g.chars.pac.dir) == 2 and not g.state.turnaroundCooldown then
                        table.insert(candidates, i)
                    elseif math.abs(i - g.chars.pac.dir) ~= 2 then
                        table.insert(candidates, i)
                    end
                end
            end

            if g.state.turnaroundCooldown and g.state.turnaroundCooldown > 0 then
                g.state.turnaroundCooldown = g.state.turnaroundCooldown - 1
                if g.state.turnaroundCooldown == 0 then
                    g.state.turnaroundCooldown = nil
                end
            end

            if #candidates == 1 then
                g.chars.pac.iDir = candidates[1]
                return
            end

            -- Combine all dot and power positions and choose the closest to Pac-Man's tile
            local positions = {}

            for _, char in pairs(g.chars) do
                if char.target and char.frightened then
                    local charXTile, _, charYTile, _ = maze.getLoc(char)
                    -- INSERT_YOUR_CODE
                    local dx = charXTile - xTile
                    local dy = charYTile - yTile
                    if math.abs(dx) <= 4 and math.abs(dy) <= 4 then
                        table.insert(positions, {x = charXTile, y = charYTile})
                    end
                end
            end
            if #positions == 0 then
            -- INSERT_YOUR_CODE
                if g.fruitTimer then
                    table.insert(positions, {x = fruits.x/8, y = fruits.y/8})
                end
                for _, dot in ipairs(g.dots) do
                    table.insert(positions, {x = dot.x, y = dot.y})
                end
                if not g.frightened then
                    for _, power in ipairs(g.powers) do
                        table.insert(positions, {x = power.x, y = power.y})
                    end
                end
            end

            -- Find closest
            local minDist = nil
            local closest = {}
            for _, pos in ipairs(positions) do
                local dx = pos.x - xTile
                local dy = pos.y - yTile
                local dist = dx * dx + dy * dy -- squared distance
                if not minDist or dist < minDist then
                    minDist = dist
                    closest = {pos}
                elseif dist == minDist then
                    table.insert(closest, pos)
                end
            end

            local bestTarget;
            if #closest > 1 then
                bestTarget = closest[math.random(#closest)]
            else
                bestTarget = closest[1]
            end

            findBestDirection(g.chars.pac, xTile, yTile, bestTarget.x, bestTarget.y, candidates)
            if g.chars.pac.iDir and math.abs(g.chars.pac.iDir - g.chars.pac.dir) == 2 then
                g.state.turnaroundCooldown = math.ceil(math.min(maze.w, maze.h) / 2)
            end
        end
    end

    -- END OF AUTOPLAY AI.  OOF --

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

-- Particle system for power pellet explosions
g.particles = {}

g.createParticleExplosion = function(x, y)
    -- Create random particles like fireworks
    for i = 1, 50 do
        local angle = math.random() * math.pi * 2  -- Completely random angle
        local speed = math.random() * 1.5
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        table.insert(g.particles, {
            x = x + (math.random() - 0.5) * 4,  -- Slight random offset for spread
            y = y + (math.random() - 0.5) * 4,
            vx = vx,
            vy = vy,
            life = 60,  -- frames to live
            maxLife = 60,
            size = 0.5 + math.random(),
            colors = {
                -- Pick either yellow (#ffff00) or purple (#B000ff) at random
                (function()
                    if math.random() < 0.5 then
                        -- yellow: 1, 1, 0
                        return {1, 1, 0}
                    else
                        -- purple: 176/255, 0, 1
                        return {176/255, 0, 1}
                    end
                end)()
            }
        })
    end
end

local updateParticles = function()
    for i = #g.particles, 1, -1 do
        local p = g.particles[i]
        p.x = p.x + p.vx
        p.y = p.y + p.vy
        p.vx = p.vx * 0.97  -- friction
        p.vy = p.vy * 0.97
        p.life = p.life - 1
        if p.life <= 0 then
            table.remove(g.particles, i)
        end
    end
end

local drawParticles = function()
    for _, p in ipairs(g.particles) do
        local alpha = 1
        love.graphics.setColor(p.colors[1], p.colors[2], p.colors[3], alpha)  -- Yellow-white particles
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    love.graphics.setColor(1, 1, 1)  -- Reset color
end

function game.start()

    -- One-time audio-device-sensitive reload of sources when starting the game
    if reloadAudioSources then
        reloadAudioSources()
    end
    
    g.levelNumber = g.config.startingLevel
    g.scenery = {}
    if g.attract then
        mode.setMode("ready")
    else
        mode.setMode("pregame")
    end
    g.lives = g.config.startingLives
    g.score = 0
    g.paused = false
    g.wakka = false
    g.particles = {}  -- Initialize particles

    maze.init()

    g.state = { hideMaze = true}
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

        if g.chars.pac.phased then 
            g.chars.pac.phased = g.chars.pac.phased - 1 
            if g.chars.pac.phased == -60 then
                g.chars.pac.phased = false
            end
        end

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
        
        -- Update particles
        updateParticles()
        
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

    if g.mode == "intermission1" then
        if not g.intermissionBoozes then
            g.intermissionBoozes = {}
            for i = 1, 50 do
                local x = math.random(0, maze.w * 8)
                local y = math.random(0, maze.h * 8)
                local vx = math.random() * 2 - 1
                local vy = math.random() * 2 - 1
                table.insert(g.intermissionBoozes, {spr = math.random(86,95), x = x, y = y, vx = vx, vy = vy})
            end
        end
        for i, booze in ipairs(g.intermissionBoozes) do
            booze.x = booze.x + booze.vx
            booze.y = booze.y + booze.vy

            if booze.x > maze.w * 8 then
                booze.x = 0
            elseif booze.x < 0 then
                booze.x = maze.w * 8
            end

            if booze.y > maze.h * 8 then
                booze.y = 0
            elseif booze.y < 0 then
                booze.y = maze.h * 8
            end
        end
    end


end

function game.draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()
    if not g.currentBackground then g.currentBackground = g.config.background end
    love.graphics.setColor(.4, .4, .4)
    love.graphics.draw(g.backgrounds[g.currentBackground], 0, 0, 0, 224 / g.backgrounds[g.currentBackground]:getWidth(), 288  / g.backgrounds[g.currentBackground]:getHeight())
    love.graphics.setColor(1, 1, 1)

    -- Draw mode messages
    if g.mode == "playerUp" then
        graphics.print("player one", 9, 14, 3)
        graphics.print("ready!", 11, 20, 6)
    elseif g.state.showReady then
        graphics.print("ready!", 11, 20, 6)
    end

    -- Draw score
    if not g.state.hideScore then
        if fc % 32 < 16 then graphics.print("1up", 3, 0) end
        graphics.print("high score", 9, 0)
        graphics.print(formatScore(g.score or 0), 0, 1, 0)
        if g.highScore then
            graphics.print(formatScore(g.highScore), 10, 1)
        end
    end

    if not g.state.hideMaze then
        if g.mode == "levelAnimation" and g.modeTimer % 20 > 10 then
            maze.draw(maze.maxColors)
        elseif g.mode ~= "pause" then
            maze.draw(g.currentMazeColor)
        end
        
        -- Draw scenery (use ipairs for arrays)
        if (not g.config.afterDark or g.config.afterDark == 1) then
            if (g.mode == "playerUp") then
                local a = (135 - g.modeTimer) / 135
                love.graphics.setColor(a, a, a)
            end
            for _, scenery in ipairs(g.dots) do
                graphics.drawScenery(scenery, scenery.x, scenery.y)
            end
            if (g.mode == "playerUp") then
                love.graphics.setColor(1, 1, 1)
            end
        end
        if (not g.config.afterDark or g.config.afterDark < 4) then
            if (g.mode == "playerUp") then
                local a = (135 - g.modeTimer) / 135
                love.graphics.setColor(a, a, a)
            end
            for _, scenery in ipairs(g.powers) do
                graphics.drawScenery(scenery, scenery.x, scenery.y)
            end
            if (g.mode == "playerUp") then
                love.graphics.setColor(1, 1, 1)
            end
        end
        
        -- Draw particle explosions
        drawParticles()
        
        -- Draw lives
        if not g.state.hideLives then
            for i = 1, math.min(5, g.lives) do
                graphics.drawSpriteAtTile("spr16", 85, i*2, 34)
            end        
        end
    end

-- Draw level display
for i = 1, #g.level.levelDisplay do
        graphics.drawSpriteAtTile(g.level.levelDisplay[i].sheet, g.level.levelDisplay[i].quad, 26 - (i*2), 34)
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
        graphics.drawChar(g.chars.pac, g.chars.pac.x, g.chars.pac.y, g.chars.pac.phased)
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
            graphics.drawSprite("spr16", 74, g.chars.pac.x - 8, g.chars.pac.y - 8)
        elseif g.modeTimer > 100 then
            if g.modeTimer <= 180 and not g.diedSoundPlayed then
                g.sounds.died:play()
                g.diedSoundPlayed = true
            end
            local dFrame = 180 - g.modeTimer
            graphics.drawSprite("spr16", 74 + math.floor(dFrame / 8), g.chars.pac.x - 8, g.chars.pac.y - 8)
        elseif g.modeTimer > 70 then
            graphics.drawSprite("spr16", 84, g.chars.pac.x - 8, g.chars.pac.y - 8)
        end
    end

    if g.mode == "gameover" then
        graphics.print("game", 9, 20, 1)
        graphics.print("over", 15, 20, 1)
    end

    if g.mode == "intermission1" then

        if g.modeTimer <= 660 and mode.isStarted("intermission1") then
            if g.modeTimer == 660 then
                g.sounds.intermission1:play()
            end
            for _, booze in ipairs(g.intermissionBoozes) do
                graphics.drawSprite("spr16", booze.spr, booze.x, booze.y)
            end
            graphics.print("pardon our dust!", 6, 15, 6)
            graphics.print("intermission", 8, 19, 3)
            graphics.print("under construction", 5, 21, 3)
        end
    end

    love.graphics.setCanvas()

-- Draw debug info
    --drawDebugInfo()
end

function game.keypressed(key)
    if g.state.running and key == "space" and not g.chars.pac.phased and g.config.phasing then
        phasePac()
    end
    if key == "tab" then
        if not g.paused then
            g.paused = true
            -- INSERT_YOUR_CODE
            g.playingSounds = {}
            for name, sound in pairs(g.sounds) do
                if sound:isPlaying() then
                    table.insert(g.playingSounds, sound)
                    sound:pause()
                end
            end
        else
            g.paused = false
            for _, sound in ipairs(g.playingSounds) do
                sound:play()
            end
            g.playingSounds = {}
        end
    end
end

function game.gamepadpressed(joystick, button)
    if g.state.running and button == "a" and not g.chars.pac.phased and g.config.phasing then
        phasePac()
    end
    if button == "x" then
        if not g.paused then
            g.paused = true
            -- INSERT_YOUR_CODE
            g.playingSounds = {}
            for name, sound in pairs(g.sounds) do
                if sound:isPlaying() then
                    table.insert(g.playingSounds, sound)
                    sound:pause()
                end
            end
        else
            g.paused = false
            for _, sound in ipairs(g.playingSounds) do
                sound:play()
            end
            g.playingSounds = {}
        end
    end
end
return game