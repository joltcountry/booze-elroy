local handlers = {}

handlers.activateFrightenedMode = function(byFruit)
    byFruit = byFruit or false
    if not byFruit then
        g.fruitFrightened = false
        g.mazeFrightened = false
    end

    local logic = require("logic")
    g.frightened = g.level.frightened
    g.ghostScore = false
    if not g.config.fastPac then g.chars.pac.speed = g.level.pacFrightenedSpeed end
    if not g.sounds.scared:isPlaying( ) then
		love.audio.play( g.sounds.scared )
        stopSiren()
	end
    -- PLUS MODE

    local immuneChar

    if g.config.plusMode and not byFruit then -- these are the real power pellet shit
        
        -- determine if one ghost is immune
        local coinflip = math.random() < 0.5
        if coinflip then
            local candidates = {}
            for name, char in pairs(g.chars) do
                if char.target and not char.dead then
                    table.insert(candidates, char)
                end
            end
            immuneChar = candidates[math.random(1, #candidates)]
        end

        if g.levelNumber > 2 then
            coinflip = math.random() < 0.5
            if coinflip then
                g.mazeFrightened = true
            end
        end

    end

    for name, char in pairs(g.chars) do
        if char.target and not char.dead then
            if char ~= immuneChar then
                char.frightened = true
                char.speed = logic.getGhostSpeed(char)
            end
            if not char.housing and not char.leaving and not char.entering then
                char.dir = (char.dir + 2) % 4
                char:target()
            end
        end
    end
end

handlers.handleDotEaten = function()
    if g.wakka then
        g.sounds.wakka2:play()
        g.wakka = false
    else
        g.sounds.wakka1:play()
        g.wakka = true
    end

    local maze = require("maze")
    local currentMaze = maze.getMaze(g.currentMaze or g.config.maze)
    local sirenTriggers = currentMaze.sirenTriggers
    local found = false
    for i, v in ipairs(sirenTriggers) do
        if v == #g.dots then
            found = true
            break
        end
    end
    if found and not g.sounds.dead:isPlaying() and not g.sounds.scared:isPlaying() then
        stopSiren()
        playSiren()
    end

    local fruitTriggers = currentMaze.fruitTriggers
    for i, v in ipairs(fruitTriggers) do
        if #g.dots == v then
            g.fruitTimer = 9 * 60 + math.random(0, 60)
            break
        end
    end
    g.starvation = 0

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

    if g.globalCounter then 
        g.globalCounter = g.globalCounter + 1
    else
        for i = 1, #leavingChars do
            local char = leavingChars[i]
            if char.dotCounter > 0 then
                char.dotCounter = char.dotCounter - 1
                break
            end
        end
    end

end

handlers.handlePowerEaten = function(xTile, yTile)
    if g.wakka then
        g.sounds.wakka2:play()
        g.wakka = false
    else
        g.sounds.wakka1:play()
        g.wakka = true
    end

    handlers.activateFrightenedMode()
    
    -- -- Create particle explosion at power pellet location
    -- if g.createParticleExplosion then
    --     local x = xTile * constants.tileSize + constants.tileSize / 2
    --     local y = yTile * constants.tileSize + constants.tileSize / 2
    --     g.createParticleExplosion(x, y)
    -- end
end

return handlers
