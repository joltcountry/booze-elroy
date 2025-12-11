logic = {}

local constants = require("constants")
local maze = require("maze")
local speedFactor = 20/16 -- 1.25

logic.advance = function(c, xOff, yOff)
    -- CLEAN THIS UP TOMORROW
    c.x = c.x + constants.deltas[c.dir].x
    c.y = c.y + constants.deltas[c.dir].y

    if not c.housing then
        if c.dir % 2 == 0 then -- left/right, correct yOff
            if yOff > constants.centerLine then c.y = c.y - 1 end
            if yOff < constants.centerLine then c.y = c.y + 1 end
        else
            if xOff < constants.centerLine then c.x = c.x + 1 end
            if xOff > constants.centerLine then c.x = c.x - 1 end
        end

        -- check for wraparound
        xTile, xOff, yTile, yOff = maze.getLoc(c)
        if xTile == maze.w + 2 then
            c.x = -2 * constants.tileSize + xOff
        elseif xTile == -3 then
            c.x = (maze.w + 1) * constants.tileSize + xOff
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
        xTile, xOff, yTile, yOff = maze.getLoc(c)
        c.accum16 = c.accum16 - 16;

        if not maze.isBlocked(c, c.dir) or 
            (c.dir == 2 and xOff > constants.centerLine) or
            (c.dir == 3 and yOff > constants.centerLine) or
            (c.dir == 0 and xOff < constants.centerLine) or
            (c.dir == 1 and yOff < constants.centerLine) then 
            logic.advance(c, xOff, yOff)
        else 
            if c.iDir and not maze.isBlocked(c, c.dir) then
                c.dir = c.iDir
                logic.advance(c, xOff, yOff)
            end
        end
    end

end

logic.turn = function(c)

    local xTile, xOff, yTile, yOff = maze.getLoc(c)

    if c.housing then
        if yOff == 0 then c.dir = 1 end
        if yOff == 7 then c.dir = 3 end
    elseif c.iDir then
        -- can always turn around
        if math.abs(c.dir - c.iDir) == 2 then
            c.dir = c.iDir
        end

        -- if perpendicular turn
        if (c.dir - c.iDir) % 2 == 1 and xTile > 0 and xTile < maze.w then -- the xTile check is so he can't leave tunnel
            local turnWindow = c.turnWindow or 0
            if c.dir % 2 == 0 then -- left or right
                if not maze.isBlocked(c, c.iDir) and math.abs(xOff - constants.centerLine) <= turnWindow then -- moving up or down
                    c.dir = c.iDir
                end
            elseif not maze.isBlocked(c, c.iDir) and math.abs(yOff - constants.centerLine) <= turnWindow then
                c.dir = c.iDir
            end
        end
    end

end

logic.getGhostSpeed = function(c)
    if c.elroy then
        if #g.dots <= g.level.elroy2 then
            return g.level.elroy2Speed
        elseif #g.dots <= g.level.elroy1 then
            return g.level.elroy1Speed
        end
    end
    return g.level.ghostSpeed
end

return logic