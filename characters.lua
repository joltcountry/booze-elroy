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
        
        local candidates = {}
        for i = 0, 3 do
            if not maze.isBlocked(self, i) and math.abs(i - self.dir) ~= 2 then
                table.insert(candidates, i)
            end
        end

        if #candidates == 1 then 
            self.iDir = candidates[1]
        else
            local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
            local targetX, targetY = pacXTile, pacYTile
            local shortest = math.huge
            for _, dir in ipairs(candidates) do
                local newXTile = xTile + constants.deltas[dir].x
                local newYTile = yTile + constants.deltas[dir].y
                if not maze.isDisallowed(newXTile, newYTile) then 
                    local dist = (newXTile - targetX) ^ 2 + (newYTile - targetY) ^ 2
                    -- For now, pick the first available direction
                    if dist <= shortest then 
                        shortest = dist
                        self.iDir = dir
                    end
                end
            end
        end
    end

}
chars.blinky.animator = function()
    if g.frightened then
        if g.frightened < 120 and math.floor(g.frightened / 14) % 2 == 0 then
            return graphics.animations.scaredWhite
        else
            return graphics.animations.scaredBlue
        end
    elseif #g.dots <= g.level.elroy1 then
        return graphics.animations.booze
    else
        return graphics.animations.blinky[g.chars.blinky.dir]
    end
end

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
        
        local candidates = {}
        for i = 0, 3 do
            if not maze.isBlocked(self, i) and math.abs(i - self.dir) ~= 2 then
                table.insert(candidates, i)
            end
        end

        if #candidates == 1 then 
            self.iDir = candidates[1]
        else
            local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)

            local targetX = pacXTile + constants.deltas[g.chars.pac.dir].x * 4
            local targetY = pacYTile + constants.deltas[g.chars.pac.dir].y * 4

            -- Pinky bug
            if g.chars.pac.dir == 3 then targetX = pacXTile - 4 end

            local shortest = math.huge
            for _, dir in ipairs(candidates) do
                local newXTile = xTile + constants.deltas[dir].x
                local newYTile = yTile + constants.deltas[dir].y
                if not maze.isDisallowed(newXTile, newYTile) then 
                    local dist = (newXTile - targetX) ^ 2 + (newYTile - targetY) ^ 2
                    -- For now, pick the first available direction
                    if dist <= shortest then 
                        shortest = dist
                        self.iDir = dir
                    end
                end
            end
        end
    end

}

chars.pinky.animator = function()
    if g.frightened then
        if g.frightened < 120 and math.floor(g.frightened / 14) % 2 == 0 then
            return graphics.animations.scaredWhite
        else
            return graphics.animations.scaredBlue
        end
    else
        return graphics.animations.pinky[g.chars.pinky.dir]
    end
end

chars.inky = {
    x = (8 * 12),
    y = (8 * 17) + 4,
    dir = 3,
    speed = .35,
    housing = true,
    scatterX = 27, scatterY = 33,
    houseX = 12, houseY = 17,
    target = function(self)
    end
}
chars.inky.animator = function()
    if g.frightened then
        if g.frightened < 120 and math.floor(g.frightened / 14) % 2 == 0 then
            return graphics.animations.scaredWhite
        else
            return graphics.animations.scaredBlue
        end
    else
        return graphics.animations.inky[g.chars.inky.dir]
    end
end

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
        
        local candidates = {}
        for i = 0, 3 do
            if not maze.isBlocked(self, i) and math.abs(i - self.dir) ~= 2 then
                table.insert(candidates, i)
            end
        end

        if #candidates == 1 then 
            self.iDir = candidates[1]
        else
            local pacXTile, pacXOff, pacYTile, pacYOff = maze.getLoc(g.chars.pac)
            local targetX, targetY
            if ((xTile - pacXTile) ^ 2 + (yTile - pacYTile) ^ 2) > 64 then
                targetX = pacXTile
                targetY = pacYTile
            else
                targetX = self.scatterX
                targetY = self.scatterY
            end

            local shortest = math.huge
            for _, dir in ipairs(candidates) do
                local newXTile = xTile + constants.deltas[dir].x
                local newYTile = yTile + constants.deltas[dir].y
                if not maze.isDisallowed(newXTile, newYTile) then 
                    local dist = (newXTile - targetX) ^ 2 + (newYTile - targetY) ^ 2
                    -- For now, pick the first available direction
                    if dist <= shortest then 
                        shortest = dist
                        self.iDir = dir
                    end
                end
            end
        end
    end
}
chars.clyde.animator = function()
    if g.frightened then
        if g.frightened < 120 and math.floor(g.frightened / 14) % 2 == 0 then
            return graphics.animations.scaredWhite
        else
            return graphics.animations.scaredBlue
        end
    else
        return graphics.animations.clyde[g.chars.clyde.dir]
    end
end

return chars