local graphics = require("graphics")
local maze = require("maze")
local constants = require("constants")
local chars = {}

chars.pac = {
    x = (8 * 14),
    y = (8 * 26) + 4,
    dir = 2, -- 0 = right, 1 down, 2 left, 3 right
    speed = .8,
    turnWindow = 3
}
chars.pac.animator = function()
   return graphics.animations.pac[g.chars.pac.dir]
end

local getRandomFrightenedDir = function()
    local r = math.random()
    if r < 0.252 then
        return 0
    elseif r < 0.252 + 0.285 then
        return 1
    elseif r < 0.252 + 0.285 + 0.299 then
        return 2
    else
        return 3
    end
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
local findBestDirection = function(self, xTile, yTile, targetX, targetY, candidates)
    local shortest = math.huge
    for _, dir in ipairs(candidates) do
        local newXTile = xTile + constants.deltas[dir].x
        local newYTile = yTile + constants.deltas[dir].y
        if not maze.isDisallowed(newXTile, newYTile) then 
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
    return function()
        if g.frightened then
            if g.frightened < 120 and math.floor(g.frightened / 14) % 2 == 0 then
                return graphics.animations.scaredWhite
            else
                return graphics.animations.scaredBlue
            end
        elseif elroyCheck and #g.dots <= g.level.elroy1 then
            return graphics.animations.booze
        else
            return graphics.animations[ghostName][g.chars[ghostName].dir]
        end
    end
end

chars.blinky = {
    x = (8 * 14),
    y = (8 * 14) + 4,
    dir = 2,
    speed = .7,
    scatterX = 25, scatterY = 0,
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
                if g.level.chase or #g.dots <= g.level.elroy1 then
                    local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                    targetX, targetY = pacXTile, pacYTile
                else
                    targetX, targetY = self.scatterX, self.scatterY
                end
                findBestDirection(self, xTile, yTile, targetX, targetY, candidates)
            end
        end
    end

}
chars.blinky.animator = createGhostAnimator("blinky", true)

chars.pinky = {
    x = (8 * 14),
    y = (8 * 17) + 4,
    dir = 1,
    speed = .35,
    leaving = true,
    scatterX = 2, scatterY = 0,
    houseX = 14, houseY = 17,
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
                if g.level.chase then
                    local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                    targetX = pacXTile + constants.deltas[g.chars.pac.dir].x * 4
                    targetY = pacYTile + constants.deltas[g.chars.pac.dir].y * 4
                    -- Pinky bug
                    if g.chars.pac.dir == 3 then targetX = pacXTile - 4 end
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
    speed = .35,
    leaving = true,
    scatterX = 27, scatterY = 33,
    houseX = 12, houseY = 17,
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
                if g.level.chase then
                    local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
                    local bXTile, bXOff, bYTile, bYOff = maze.getLoc(g.chars.blinky)

                    local midX = pacXTile + constants.deltas[g.chars.pac.dir].x * 2
                    local midY = pacYTile + constants.deltas[g.chars.pac.dir].y * 2

                    -- Pinky bug
                    if g.chars.pac.dir == 3 then midX = pacXTile - 2 end

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
    speed = .35,
    leaving = true,
    scatterX = 0, scatterY = 33,
    houseX = 16, houseY = 17,
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
                if g.level.chase then
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

return chars