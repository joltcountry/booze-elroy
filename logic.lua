logic = {}

local constants = require("constants")
local maze = require("maze")
local speedFactor = 20/16 -- 1.25
local mode = require("mode")
local fruits = require("fruits")
local handlers = require("handlers")

-- Helper to get current maze instance
local function getCurrentMaze()
    if not g.currentMaze then g.currentMaze = g.config.maze end
    return maze.getMaze(g.currentMaze)
end

-- Helper function to check and handle collisions with collectibles
local checkCollisions = function(collectibles, xTile, yTile)
    if g.chars.pac.phased and g.chars.pac.phased >= 0 then return end
    for i = #collectibles, 1, -1 do
        local item = collectibles[i]
        if xTile == item.x and yTile == item.y then
            score(item.score)
            g.chars.pac.skipCounter = item.skipCounter
            table.remove(collectibles, i)
            if item.action then item.action(xTile, yTile) end
        end
    end
end

-- Helper function to handle collision between Pac-Man and a ghost
local handleGhostCollision = function(ghost, pacXTile, pacYTile, ghostXTile, ghostYTile)
    if g.chars.pac.phased and g.chars.pac.phased >= 0 then return false end
    if g.mode == "ateGhost" or g.mode == "caught" then return false end
    if pacXTile == ghostXTile and pacYTile == ghostYTile then
        if ghost.frightened then
            ghost.dead = true -- ate a ghost
            if ghost.leaving then
                ghost.leaving = false
                ghost.entering = true
            end
            ghost.frightened = false
            ghost.speed = logic.getGhostSpeed(ghost)
            ghost:target()
            ghost.hidden = true
            mode.setMode("ateGhost")
            g.sounds.ateGhost:play()
            if g.ghostScore then g.ghostScore = g.ghostScore * 2 else g.ghostScore = g.fruitFrightened and 400 or 200 end
            score(g.ghostScore)
            return true -- collision handled
        elseif not ghost.dead then
            mode.setMode("caught")
            if g.chars.clyde then g.suspendElroy = true end
            g.globalCounter = 0
            return true -- collision handled
        end
    end
    return false -- no collision
end


-- Helper function to update ghost speed based on location and state
local updateGhostSpeed = function(char, xTile, yTile)
    if not char.dead and getCurrentMaze().isTunnel(xTile, yTile) then
        char.speed = g.level.tunnelSpeed
    elseif char.frightened then
        char.speed = g.level.frightenedSpeed
    elseif not char.housing then
        char.speed = logic.getGhostSpeed(char)
    end
end

-- Helper function to handle ghost movement logic
local handleGhostMovement = function(char, oldXTile, oldYTile, newXTile, newYTile, newXOff, newYOff)
    if newXTile ~= oldXTile or newYTile ~= oldYTile then
        if char.leaveRight then
            char.leaveRight = char.leaveRight - 1
            if char.leaveRight == 0 then
                char.leaveRight = false
                char.dir = 0
            end
        else
            -- This is a nod to the OG random number thing, just for fun.
            math.random()

            char:target()
            updateGhostSpeed(char, newXTile, newYTile)
        end
    end
end

logic.advance = function(c, xOff, yOff)
    -- CLEAN THIS UP TOMORROW
    c.x = c.x + constants.deltas[c.dir].x
    c.y = c.y + constants.deltas[c.dir].y

    if not c.housing and not c.leaving and not c.entering then
        if c.dir % 2 == 0 then -- left/right, correct yOff
            if yOff > constants.centerLine then c.y = c.y - 1 end
            if yOff < constants.centerLine then c.y = c.y + 1 end
        else
            if xOff < constants.centerLine then c.x = c.x + 1 end
            if xOff > constants.centerLine then c.x = c.x - 1 end
        end

        -- check for wraparound
        local currentMaze = getCurrentMaze()
        xTile, xOff, yTile, yOff = currentMaze.getLoc(c)
        if xTile == currentMaze.w + 2 then
            c.x = -2 * constants.tileSize + xOff
        elseif xTile == -3 then
            c.x = (currentMaze.w + 1) * constants.tileSize + xOff
        end
        if yTile == currentMaze.h + 1 then
            c.y = 1 * constants.tileSize + yOff
        elseif yTile == 0 then
            c.y = (currentMaze.h) * constants.tileSize + yOff
        end
    end

    c.moved = true
end

logic.move = function(c)

    if c.skipCounter and c.skipCounter > 0 then
        c.skipCounter = c.skipCounter - 1
        return
    end

-- add iDir -- ghost should set iDir each tile, pac's iDir is set by joystick
    c.accum16 = c.accum16 or 0
    local speed16 = c.speed * speedFactor * 16
    c.accum16 = c.accum16 + speed16;
    while c.accum16 >= 16 do
        c.moved = false
        local currentMaze = getCurrentMaze()
        xTile, xOff, yTile, yOff = currentMaze.getLoc(c)
        local oldXTile, oldYTile = xTile, yTile
        c.accum16 = c.accum16 - 16;

        if c.housing or c.leaving or c.entering or not currentMaze.isBlocked(c, c.dir) or 
            (c.dir == 2 and xOff > constants.centerLine) or
            (c.dir == 3 and yOff > constants.centerLine) or
            (c.dir == 0 and xOff < constants.centerLine) or
            (c.dir == 1 and yOff < constants.centerLine) then 
            logic.advance(c, xOff, yOff)
        else 
            if c.iDir and not currentMaze.isBlocked(c, c.iDir) then
                c.dir = c.iDir
                logic.advance(c, xOff, yOff)
            end
        end
            
        if c.moved then
            local newXTile, newXOff, newYTile, newYOff = currentMaze.getLoc(c)
            
            if c.target then
                if not c.leaving and not c.housing then 
                    handleGhostMovement(c, oldXTile, oldYTile, newXTile, newYTile, newXOff, newYOff)
                end

                local houseCenter = getCurrentMaze().houseCenter
                if c.dead and newYTile == c.houseY - 3 and newXTile == houseCenter.x and newXOff == 0 then
                    c.dir = 1
                    c.iDir = false
                    c.entering = true
                    c.speed = logic.getGhostSpeed(c)
                end

                if c.entering and newYTile == c.houseY and newXTile == c.houseX and newXOff == 0 then
                    c.dir = 3
                    c.iDir = false
                    c.dead = false
                    local anyDead = false
                    for _, char in pairs(g.chars) do
                        if char.dead then
                            anyDead = true
                            break
                        end
                    end
                    if not anyDead then
                        g.sounds.dead:stop()
                        if g.frightened then
                            g.sounds.scared:play()
                        else
                            playSiren()
                        end
                    end
                    c.entering = false
                    if not c.leavingPreference then
                        c.leaving = true
                    else
                        c.housing = true
                    end
                    c.speed = logic.getGhostSpeed(c)
                end
                -- Handle leaving house logic
                if c.leaving and newYTile == c.houseY - 3 and newYOff == constants.centerLine then
                    c.dir = c.leavesRight and 0 or 2
                    c.iDir = false
                    c.leaving = false
                    c.speed = logic.getGhostSpeed(c)
                    if not c.leaveRight then
                        c:target()
                    end
                end

                -- Check collision with Pac-Man when ghost moves
                if g.mode ~= "ateGhost" then
                    local pacXTile, pacXOff, pacYTile, pacYOff = currentMaze.getLoc(g.chars.pac)
                    local ghostXTile, ghostXOff, ghostYTile, ghostYOff = currentMaze.getLoc(c)
                    if handleGhostCollision(c, pacXTile, pacYTile, ghostXTile, ghostYTile) then
                        break
                    end
                end
            else
                -- Check collisions with collectibles (reuse pac location from movement update)
                local pacXTile, pacXOff, pacYTile, pacYOff = currentMaze.getLoc(g.chars.pac)
                checkCollisions(g.powers, pacXTile, pacYTile, true)
                checkCollisions(g.dots, pacXTile, pacYTile)

                -- Check ghost collisions (reuse pac location)
                for name, char in pairs(g.chars) do
                    if char.target then
                        local ghostXTile, ghostXOff, ghostYTile, ghostYOff = currentMaze.getLoc(char)
                        if handleGhostCollision(char, pacXTile, pacYTile, ghostXTile, ghostYTile) then
                            break
                        end
                    end
                end
            end

            logic.turn(c)

            local fruitLoc = getCurrentMaze().fruitLoc
            if g.fruitTimer and g.chars.pac.x == fruitLoc.x and g.chars.pac.y == fruitLoc.y and (not g.chars.pac.phased or g.chars.pac.phased <= 0) then
                score(g.level.fruit.score)
                g.fruitTimer = false
                mode.setMode("ateFruit")
                g.sounds.fruit:play()
                if g.config.plusMode then
                    g.fruitFrightened = true
                    handlers.activateFrightenedMode(true)
                end
            end

        end

    end

end

logic.turn = function(c)
    local currentMaze = getCurrentMaze()
    local xTile, xOff, yTile, yOff = currentMaze.getLoc(c)

    if c.housing then
        if yOff == 0 then c.dir = 1 end
        if yOff == 7 then c.dir = 3 end
    elseif c.leaving then
        local houseCenter = getCurrentMaze().houseCenter
        if xTile < houseCenter.x then c.dir = 0
        elseif xTile > houseCenter.x or xOff > 0 then c.dir = 2
        else c.dir = 3 end
    elseif c.entering then
        if yTile == c.houseY and yOff == constants.centerLine then 
            --and yOff == constants.centerLine then
            if c.houseX < xTile then c.dir = 2
            elseif c.houseX > xTile then c.dir = 0 end
        end
    
    elseif c.iDir then
        -- can always turn around
        if math.abs(c.dir - c.iDir) == 2 then
            c.dir = c.iDir
        end

        -- if perpendicular turn
        -- this line also checks wraparounds
        if (c.dir - c.iDir) % 2 == 1 and yTile > 3 and yTile < currentMaze.h - 1 and xTile > 0 and xTile < currentMaze.w then -- the xTile check is so he can't leave tunnel
            local turnWindow = c.turnWindow or 0
            if c.dir % 2 == 0 then -- left or right
                if not currentMaze.isBlocked(c, c.iDir) and math.abs(xOff - constants.centerLine) <= turnWindow then -- moving up or down
                    c.dir = c.iDir
                end
            elseif not currentMaze.isBlocked(c, c.iDir) and math.abs(yOff - constants.centerLine) <= turnWindow then
                c.dir = c.iDir
            end
        end
    end

end

logic.getGhostSpeed = function(c)
    if c.housing or c.leaving then return .35 end
    if c.dead then return 1.6 end
    if c.elroy and not g.suspendElroy then
        if #g.dots <= g.level.elroy2 then
            return g.level.elroy2Speed
        elseif #g.dots <= g.level.elroy1 then
            return g.level.elroy1Speed
        end
    end
    if c.frightened then
        return g.level.frightenedSpeed
    end
    return g.level.ghostSpeed
end

return logic