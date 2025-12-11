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
    else
        return graphics.animations.blinky[g.chars.blinky.dir]
    end
end

-- chars.pinky = {
--     x = 90,
--     y = 120,
--     dir = 2,
--     speed = .75
-- }
-- chars.pinky.animator = function()
--     return graphics.animations.pinky[g.chars.pinky.dir]
-- end

-- chars.inky = {
--     x = 20,
--     y = 120,
--     dir = 3,
--     speed = .75
-- }
-- chars.inky.animator = function()
--     return graphics.animations.inky[g.chars.inky.dir]
-- end

-- chars.clyde = {
--     x = 55,
--     y = 120,
--     dir = 0,
--     speed = .75
-- }
-- chars.clyde.animator = function()
--     return graphics.animations.clyde[g.chars.clyde.dir]
-- end

return chars