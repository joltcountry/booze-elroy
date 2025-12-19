local graphics = require("graphics")
local maze = require("maze")
local constants = require("constants")
local levels = require("levels")

local characters = {}
local getRandomFrightenedDir = function()
    local r = math.random()
    -- Probabilities: 0=25.2%, 1=28.5%, 2=29.9%, 3=16.4%
    -- Verify: 0.252 + 0.285 + 0.299 = 0.836, remaining = 0.164
    local result
    if r < 0.252 then
        result = 0
    elseif r < 0.537 then  -- 0.252 + 0.285
        result = 1
    elseif r < 0.836 then  -- 0.252 + 0.285 + 0.299
        result = 2
    else
        result = 3
    end
    return result
end

-- Helper function to get valid direction candidates
local getCandidates = function(self)
    local candidates = {}
    for i = 0, 3 do
        if not maze.isBlocked(self, i) and math.abs(i - self.dir) ~= 2 then
            table.insert(candidates, i)
        end
    end
    return candidates
end

-- Helper function to handle frightened mode direction selection
-- The red guy never goes down when you eat it upper right corner, something is wrong here
local handleFrightenedDirection = function(self, candidates)
    local frightenedDir = getRandomFrightenedDir()
    local nextDir = frightenedDir
    local checked = 0
    local found = false
    while checked < 4 do
        for _, dir in ipairs(candidates) do
            if dir == nextDir then
                self.iDir = nextDir
                found = true
                break
            end
        end
        if found then break end
        nextDir = (nextDir + 1) % 4
        checked = checked + 1
    end
end

-- Helper function to find best direction based on distance to target
findBestDirection = function(self, xTile, yTile, targetX, targetY, candidates)
    local shortest = math.huge
    local isGhost = self.target ~= nil  -- Pac-man doesn't have a target function
    for _, dir in ipairs(candidates) do
        local newXTile = xTile + constants.deltas[dir].x
        local newYTile = yTile + constants.deltas[dir].y
        -- Dead ghosts can pass through disallowed tiles (x/y markers) to return to house
        -- Pac-man should never be blocked by disallowed tiles (only ghosts are)
        if not isGhost or g.config.freeGhost or not maze.isDisallowed(newXTile, newYTile) then 
            local dist = (newXTile - targetX) ^ 2 + (newYTile - targetY) ^ 2
            if dist <= shortest then 
                shortest = dist
                self.iDir = dir
            end
        end
    end
end

-- Helper function to create ghost animator
local createGhostAnimator = function(ghostName, elroyCheck)
    return function(self)
        if self.dead then
            return graphics.animations.dead[self.dir]
        elseif self.frightened then
            if g.frightened < 120 and math.floor(g.frightened / 14) % 2 == 0 then
                return graphics.animations.scaredWhite
            else
                return graphics.animations.scaredBlue
            end
        elseif elroyCheck and #g.dots <= g.level.elroy1 and not g.suspendElroy then
            return graphics.animations.booze
        else
            if self.iDir and not self.leaving and not self.housing then -- hack
                return graphics.animations[ghostName][self.iDir]
            else
                return graphics.animations[ghostName][self.dir]
            end
        end
    end
end

local scatterTiles = {
    { x = 25, y = -1 },
    { x = 2, y = -1 },
    { x = 27, y = 33 },
    { x = 0, y = 33 },
}

characters.initialize = function()
    local level = levels.getLevel(g.levelNumber)
    local chars = {}
    chars.pac = {
        x = (8 * 14),
        y = (8 * 26) + 4,
        dir = 2, -- 0 = right, 1 down, 2 left, 3 right
        turnWindow = 3
    }
    chars.pac.animator = function()
        return graphics.animations.pac[g.chars.pac.dir]
    end

    chars.blinky = {
        x = (8 * 14),
        y = (8 * 14) + 4,
        dir = 2,
        scatterX = 25, scatterY = -1,
        houseX = 14, houseY = 17,
        elroy = true,
        target = function(self)
            if not self.iDir then
                self.iDir = self.dir
                return
            end

            local xTile, xOff, yTile, yOff = maze.getLoc(self)
            local candidates = getCandidates(self)

            if #candidates == 1 then 
                self.iDir = candidates[1]
            else
                if self.frightened then
                    handleFrightenedDirection(self, candidates)
                else
                    local targetX, targetY
                    if self.dead then
                        targetX, targetY = 13, 14
                    elseif g.level.chase or (#g.dots <= g.level.elroy1 and not g.suspendElroy) then
                        local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                        targetX, targetY = pacXTile, pacYTile
                    else
                        targetX, targetY = self.scatterX, self.scatterY
                    end
                    findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
                    self.targetX = targetX
                    self.targetY = targetY
                end
            end
        end

    }
    chars.blinky.animator = createGhostAnimator("blinky", true)

    chars.pinky = {
        x = (8 * 14),
        y = (8 * 17) + 4,
        dir = 1,
        housing = true,
        scatterX = 2, scatterY = -1,
        houseX = 14, houseY = 17,
        leavingPreference = 0,
        dotCounter = level.pinkyCounter,
        globalCounter = 7,
        target = function(self)
            if not self.iDir then
                self.iDir = self.dir
                return
            end

            local xTile, xOff, yTile, yOff = maze.getLoc(self)
            local candidates = getCandidates(self)

            if #candidates == 1 then 
                self.iDir = candidates[1]
            else
                if self.frightened then
                    handleFrightenedDirection(self, candidates)
                else
                    local targetX, targetY
                    if self.dead then
                        targetX, targetY = 13, 14
                    elseif g.level.chase then
                        local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                        targetX = pacXTile + constants.deltas[g.chars.pac.dir].x * 4
                        targetY = pacYTile + constants.deltas[g.chars.pac.dir].y * 4
                        -- Pinky bug
                        if g.config.pinkyBug and g.chars.pac.dir == 3 then targetX = pacXTile - 4 end
                    else
                        targetX, targetY = self.scatterX, self.scatterY
                    end
                    findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
                end
            end
        end

    }

    chars.pinky.animator = createGhostAnimator("pinky", false)

    chars.inky = {
        x = (8 * 12),
        y = (8 * 17) + 4,
        dir = 3,
        housing = true,
        scatterX = 27, scatterY = 33,
        houseX = 12, houseY = 17,
        leavingPreference = 1,
        globalCounter = 17,
        dotCounter = level.inkyCounter,
        target = function(self)
            if not self.iDir then
                self.iDir = self.dir
                return
            end

            local xTile, xOff, yTile, yOff = maze.getLoc(self)
            local candidates = getCandidates(self)

            if #candidates == 1 then 
                self.iDir = candidates[1]
            else
                if self.frightened then
                    handleFrightenedDirection(self, candidates)
                else
                    local targetX, targetY
                    if self.dead then
                        targetX, targetY = 13, 14
                    elseif g.level.chase then
                        local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                        local bXTile, bXOff, bYTile, bYOff = maze.getLoc(g.chars.blinky)

                        local midX = pacXTile + constants.deltas[g.chars.pac.dir].x * 2
                        local midY = pacYTile + constants.deltas[g.chars.pac.dir].y * 2

                        -- Pinky bug
                        if g.config.pinkyBug and g.chars.pac.dir == 3 then midX = pacXTile - 2 end

                        local bx = midX - bXTile
                        local by = midY - bYTile
                        
                        targetX = bXTile + bx * 2
                        targetY = bYTile + by * 2
                    else
                        targetX, targetY = self.scatterX, self.scatterY
                    end
                    findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
                end
            end
        end
    }
    chars.inky.animator = createGhostAnimator("inky", false)

    chars.clyde = {
        x = (8 * 16),
        y = (8 * 17) + 4,
        dir = 3,
        housing = true,
        scatterX = 0, scatterY = 33,
        houseX = 16, houseY = 17,
        leavingPreference = 2,
        dotCounter = level.clydeCounter,
        globalCounter = 32,
        target = function(self)
            if not self.iDir then
                self.iDir = self.dir
                return
            end

            local xTile, xOff, yTile, yOff = maze.getLoc(self)
            local candidates = getCandidates(self)

            if #candidates == 1 then 
                self.iDir = candidates[1]
            else
                if self.frightened then
                    handleFrightenedDirection(self, candidates)
                else
                    local targetX, targetY
                    if self.dead then
                        targetX, targetY = 13, 14
                    elseif g.level.chase then
                        local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                        if ((xTile - pacXTile) ^ 2 + (yTile - pacYTile) ^ 2) > 64 then
                            targetX = pacXTile
                            targetY = pacYTile
                        else
                            targetX = self.scatterX
                            targetY = self.scatterY
                        end
                    else
                        targetX, targetY = self.scatterX, self.scatterY
                    end
                    findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
                end
            end
        end
    }
    chars.clyde.animator = createGhostAnimator("clyde", false)

    if g.config.extraGhosts >= 1 then
        chars.punky = {
            x = (8 * 14),
            y = (8 * 8) + 4,
            dir = 0,
            houseX = 14, houseY = 17,
            leavesRight = true,
            target = function(self)
                if not self.iDir then
                    self.iDir = self.dir
                    return
                end
    
                local xTile, xOff, yTile, yOff = maze.getLoc(self)
                local candidates = getCandidates(self)
    
                if #candidates == 1 then 
                    self.iDir = candidates[1]
                else
                    if self.frightened then
                        handleFrightenedDirection(self, candidates)
                    else
                        local targetX, targetY
                        if self.dead then
                            targetX, targetY = 13, 14
                        else -- never scatters
                            local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                            targetX = pacXTile + constants.deltas[g.chars.pac.dir].y * (math.random(0, 8) - 4)
                            targetY = pacYTile + constants.deltas[g.chars.pac.dir].x * (math.random(0, 8) - 4)
                        end
                        findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
                    end
                end
            end
        }
        chars.punky.animator = createGhostAnimator("punky", false)
    end

    if g.config.extraGhosts >= 2 then
        chars.gunky = {
            x = (8 * 14),
            y = (8 * 32) + 4,
            dir = 0,
            houseX = 14, houseY = 17,
            leavesRight = false,
            target = function(self)
                if not self.iDir then
                    self.iDir = self.dir
                    return
                end
    
                local xTile, xOff, yTile, yOff = maze.getLoc(self)
                local candidates = getCandidates(self)
    
                if #candidates == 1 then 
                    self.iDir = candidates[1]
                else
                    if self.frightened then
                        handleFrightenedDirection(self, candidates)
                    else
                        local targetX, targetY
                        if self.dead then
                            targetX, targetY = 13, 14
                        else -- never scatters
                            local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                            local midXTile = maze.w / 2
                            local midYTile = maze.h / 2
    
                            local px = midXTile - pacXTile
                            local py = midYTile - pacYTile
                            
                            targetX = pacXTile + px * 2
                            targetY = pacYTile + py * 2
                        end
                        findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
                    end
                end
            end
        }
        chars.gunky.animator = createGhostAnimator("gunky", false)
    end

    if g.config.extraGhosts >= 3 then
        chars.gronky = {
            x = -2 * 8,
            y = (8 * 17) + 4,
            dir = math.random(0,1) * 2,
            houseX = 14, houseY = 17,
            leavesRight = math.random(0, 1) == 1,
            target = function(self)
                if not self.iDir then
                    self.iDir = self.dir
                    return
                end
    
                local xTile, xOff, yTile, yOff = maze.getLoc(self)
                local candidates = getCandidates(self)
    
                if #candidates == 1 then 
                    self.iDir = candidates[1]
                else
                    if self.frightened then
                        handleFrightenedDirection(self, candidates)
                    else
                        local targetX, targetY
                        if self.dead then
                            targetX, targetY = 13, 14
                        else -- never scatters
                            local myXTile, myXOff, myYTile, myYOff = maze.getLoc(self)

                            targetX = myXTile + constants.deltas[math.random(0, 3)].x
                            targetY = myYTile + constants.deltas[math.random(0, 3)].y
                        end
                        findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
                    end
                end
            end
        }
        chars.gronky.animator = createGhostAnimator("gronky", false)
    end

    g.chars = chars
end

characters.reset = function()
    g.chars.blinky.frame = 1
    g.chars.blinky.x = (8 * 14)
    g.chars.blinky.y = (8 * 14) + 4
    g.chars.blinky.dir = 2
    g.chars.blinky.iDir = nil
    g.chars.blinky.entering = false
    g.chars.blinky.leaving = false
    g.chars.blinky.dead = false
    g.chars.blinky.frightened = false
    g.chars.blinky.leaveRight = false
    g.chars.blinky.speed = logic.getGhostSpeed(g.chars.blinky)
    if g.config.scatterOption == 1 then
        local randomScatter = scatterTiles[math.random(1, 4)]
        g.chars.blinky.scatterX = randomScatter.x
        g.chars.blinky.scatterY = randomScatter.y
    end

    g.chars.pinky.x = (8 * 14)
    g.chars.pinky.y = (8 * 17) + 4
    g.chars.pinky.frame = 1
    g.chars.pinky.housing = true
    g.chars.pinky.entering = false
    g.chars.pinky.leaving = false
    g.chars.pinky.dead = false
    g.chars.pinky.frightened = false
    g.chars.pinky.leaveRight = false
    g.chars.pinky.dir = 1
    g.chars.pinky.iDir = nil
    g.chars.pinky.speed = logic.getGhostSpeed(g.chars.pinky)
    if g.config.scatterOption == 1 then
        local randomScatter = scatterTiles[math.random(1, 4)]
        g.chars.pinky.scatterX = randomScatter.x
        g.chars.pinky.scatterY = randomScatter.y
    end

    g.chars.inky.x = (8 * 12)
    g.chars.inky.y = (8 * 17) + 4
    g.chars.inky.frame = 1
    g.chars.inky.housing = true
    g.chars.inky.entering = false
    g.chars.inky.leaving = false
    g.chars.inky.dead = false
    g.chars.inky.frightened = false
    g.chars.inky.leaveRight = false
    g.chars.inky.dir = 3
    g.chars.inky.iDir = nil
    g.chars.inky.speed = logic.getGhostSpeed(g.chars.inky)
    if g.config.scatterOption == 1 then
        local randomScatter = scatterTiles[math.random(1, 4)]
        g.chars.inky.scatterX = randomScatter.x
        g.chars.inky.scatterY = randomScatter.y
    end

    g.chars.clyde.x = (8 * 16)
    g.chars.clyde.y = (8 * 17) + 4
    g.chars.clyde.frame = 1
    g.chars.clyde.housing = true    
    g.chars.clyde.entering = false
    g.chars.clyde.leaving = false
    g.chars.clyde.dead = false
    g.chars.clyde.frightened = false
    g.chars.clyde.leaveRight = false
    g.chars.clyde.dir = 3
    g.chars.clyde.iDir = nil
    g.chars.clyde.speed = logic.getGhostSpeed(g.chars.clyde)
    if g.config.scatterOption == 1 then
        local randomScatter = scatterTiles[math.random(1, 4)]
        g.chars.clyde.scatterX = randomScatter.x
        g.chars.clyde.scatterY = randomScatter.y
    end

    if g.config.extraGhosts >= 1 then
        g.chars.punky.frame = 1
        g.chars.punky.x = (8 * 14)
        g.chars.punky.y = (8 * 8) + 4
        g.chars.punky.dir = 0
        g.chars.punky.iDir = nil
        g.chars.punky.entering = false
        g.chars.punky.leaving = false
        g.chars.punky.dead = false
        g.chars.punky.frightened = false
        g.chars.punky.leaveRight = false
        g.chars.punky.speed = logic.getGhostSpeed(g.chars.punky)
    end

    if g.config.extraGhosts >= 2 then
        g.chars.gunky.frame = 1
        g.chars.gunky.x = (8 * 14)
        g.chars.gunky.y = (8 * 32) + 4
        g.chars.gunky.dir = 0
        g.chars.gunky.iDir = nil
        g.chars.gunky.entering = false
        g.chars.gunky.leaving = false
        g.chars.gunky.dead = false
        g.chars.gunky.frightened = false
        g.chars.gunky.leaveRight = false
        g.chars.gunky.speed = logic.getGhostSpeed(g.chars.gunky)
    end 

    if g.config.extraGhosts >= 3 then
        g.chars.gronky.frame = 1
        g.chars.gronky.x = (8 * -2)
        g.chars.gronky.y = (8 * 17) + 4
        g.chars.gunky.dir = math.random(0,1) * 2
        g.chars.gronky.iDir = nil
        g.chars.gronky.leavesRight = math.random(0, 1) == 1
        g.chars.gronky.entering = false
        g.chars.gronky.leaving = false
        g.chars.gronky.dead = false
        g.chars.gronky.frightened = false
        g.chars.gronky.leaveRight = false
        g.chars.gronky.speed = logic.getGhostSpeed(g.chars.gronky)
    end 

    g.chars.pac.x = (8 * 14)
    g.chars.pac.y = (8 * 26) + 4
    g.chars.pac.dir = 2
    g.chars.pac.phased = false
    if g.config.fastPac then g.chars.pac.speed = 1.6 else
        g.chars.pac.speed = g.level.pacSpeed
    end

end


return characters