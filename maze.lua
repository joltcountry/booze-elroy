local graphics = require("graphics")
local constants = require("constants")
local handlers = require("handlers")
local maps = require("maps")
local indexes = '123456789ABCDEFGHIJKLMNOPQRSTUVWXY'
local afterDark = 'ABC7Y8DEFGHKL'

-- Module-level constant
local MAX_COLORS = 18

local upperCase = function(c)
    local upper = string.upper(c)
    if c == "&" then upper = "7" end
    if c == "*" then upper = "8" end
    return upper
end

-- Maze constructor
local function Maze(map)
    map = map or maps.defaultMap
    local self = {}
    
    -- Instance properties
    self.map = map
    self.w = #map[1]
    self.h = #map
    
    -- Instance methods
    self.getLoc = function(c)
        local xTile = math.floor(c.x / constants.tileSize)
        local yTile = math.floor(c.y / constants.tileSize)
        local xOff = c.x % constants.tileSize
        local yOff = c.y % constants.tileSize

        return xTile, xOff, yTile, yOff
    end

    self.getChar = function(x, y)
        if x < 0 or x >= #self.map[1] or y < 0 or y >= #self.map then
            return false
        end

        local c = string.sub(self.map[y+1], x+1, x+1)
        return c
    end

    self.isWall = function(x, y)
        if x < 0 or x >= #self.map[1] or y < 3 or y >= #self.map - 1 then
            return false
        end

        local c = upperCase(string.sub(self.map[y+1], x+1, x+1))
        return string.find(indexes, c, 1, true) ~= nil
    end

    self.isTunnel = function(x, y)
        if x < 0 or x >= #self.map[1] or y < 3 or y >= #self.map - 1 then
            return false
        end

        local c = string.sub(self.map[y+1], x+1, x+1)
        return (c == "_")
    end

    self.isDisallowed = function(x, y)
        if x < 0 or x >= #self.map[1] or y < 3 or y >= #self.map - 1 or g.config.freeGhost then
            return false
        end

        local c = string.sub(self.map[y+1], x+1, x+1)
        return (c == ";" or c == ":")
    end

    self.isBlocked = function(c, dir)
        local xTile, xOff, yTile, yOff = self.getLoc(c)
        return self.isWall(xTile + constants.deltas[dir].x, yTile + constants.deltas[dir].y)
    end

    self.getPowers = function()
        local powers = {};
        for y = 1, #self.map do
            for x = 1, #self.map[1] do
                local c = string.sub(self.map[y], x, x)
                if (c == '`') then table.insert(powers, {x= (x - 1), y=(y - 1)}) end
            end
        end
        return powers
    end

    self.getDots = function()
        local dots = {};
        for y = 1, #self.map do
            for x = 1, #self.map[1] do
                local c = string.sub(self.map[y], x, x)
                if (c == '.' or c == ':') then table.insert(dots, {x= (x-1), y=(y-1)}) end
            end
        end
        --print(#dots)
        return dots
    end

    self.init = function()
        local powers = self.getPowers()
        local dots = self.getDots()
        g.powers = {}
        g.dots = {}
        for _, p in ipairs(powers) do
            table.insert(g.powers, {
                x = p.x, y = p.y, score = 50, skipCounter = 3, action = handlers.handlePowerEaten, animator = function() return graphics.animations.power end
            })
        end
        for _, d in ipairs(dots) do
            table.insert(g.dots, {
                x = d.x, y = d.y, score = 10, skipCounter = 1, action = handlers.handleDotEaten, animator = function() return graphics.animations.dot end
            })
        end    
    end

    self.draw = function(color)
        local showMaze = not g.config.afterDark or g.config.afterDark == 2
        color = color or 1
        color = color - 1
        for y = 1, #self.map do
            for x = 1, #self.map[1] do
                local c = string.sub(self.map[y], x, x)
                if showMaze then c = upperCase(c) end
                local spriteNum
                for i = 1, #indexes do
                    if c == string.sub(indexes, i, i) then
                        spriteNum = i
                        break
                    end
                end
                if spriteNum and (g.mode ~= "levelAnimation" or c ~= "P") then
                    graphics.drawSprite("spr8", (spriteNum - 1) * MAX_COLORS + 3 + color, (x-1) * constants.tileSize,(y-1) * constants.tileSize)
                    --graphics.print(c, x-1, y-1,0)
                end
            end
        end
        if self.decorate then
            self.decorate()
        end
    end

    return self
end

-- Maze registry
local instances = {}

-- Create "pac" maze instance
instances.pac = Maze(maps.pac)
instances.pac.maxColors = MAX_COLORS
instances.pac.sirenTriggers = { 20, 40, 100, 150 }
instances.pac.fruitTriggers = { 170, 70 }
instances.pac.fruitLoc = { x = 14 * 8, y = 20 * 8 + 4 }
instances.pac.houseCenter = { x = 14, y = 17 }
instances.pac.pacStart = { x = 14, y = 26 }
instances.pac.punkyStart = { x = 14, y = 8 }
instances.pac.gunkyStart = { x = 14, y = 32 }
instances.pac.gronkyStart = { x = -2, y = 17 }
instances.pac.scatterTiles = {
    { x = 25, y = -1 },
    { x = 2, y = -1 },
    { x = 27, y = 33 },
    { x = 0, y = 33 },
}
instances.pac.scatterPositions = {
    blinky = { x = 25, y = -1 },
    pinky = { x = 2, y = -1 },
    inky = { x = 27, y = 33 },
    clyde = { x = 0, y = 33 },
}
instances.pac.decorate = function()
    -- Draw mode messages
    if g.mode == "playerUp" then
        graphics.print("player one", 9, 14, 3)
        graphics.print("ready!", 11, 20, 6)
    elseif g.state.showReady then
        graphics.print("ready!", 11, 20, 6)
    end

    graphics.print("BO", 3, 6, 3)
    graphics.print("OZE", 8, 6, 3)
    graphics.print("ELR", 17, 6, 3)
    graphics.print("OY", 23, 6, 3)
end
instances.pac.playerone = 14
instances.pac.ready = 20

instances.pac.defaultColor = 1

-- Create "pac" maze instance
instances.mspac1 = Maze(maps.mspac1)
instances.mspac1.maxColors = MAX_COLORS
instances.mspac1.sirenTriggers = { 20, 40, 90, 140 }
instances.mspac1.fruitTriggers = { 150, 60 }
instances.mspac1.fruitLoc = { x = 14 * 8, y = 20 * 8 + 4 }
instances.mspac1.houseCenter = { x = 14, y = 17 }
instances.mspac1.pacStart = { x = 14, y = 26 }
instances.mspac1.punkyStart = { x = 14, y = 7 }
instances.mspac1.gunkyStart = { x = 14, y = 32 }
instances.mspac1.gronkyStart = { x = -2, y = 11 }
instances.mspac1.scatterTiles = {
    { x = 25, y = -1 },
    { x = 2, y = -1 },
    { x = 27, y = 33 },
    { x = 0, y = 33 },
}
instances.mspac1.scatterPositions = {
    blinky = { x = 25, y = -1 },
    pinky = { x = 2, y = -1 },
    inky = { x = 27, y = 33 },
    clyde = { x = 0, y = 33 },
}
instances.mspac1.playerone = 14
instances.mspac1.ready = 20

instances.mspac1.defaultColor = 12


-- Create "pac" maze instance
instances.mspac2 = Maze(maps.mspac2)
instances.mspac2.maxColors = MAX_COLORS
instances.mspac2.sirenTriggers = { 20, 40, 100, 150 }
instances.mspac2.fruitTriggers = { 170, 70 }
instances.mspac2.fruitLoc = { x = 14 * 8, y = 20 * 8 + 4 }
instances.mspac2.houseCenter = { x = 14, y = 17 }
instances.mspac2.pacStart = { x = 14, y = 26 }
instances.mspac2.punkyStart = { x = 14, y = 4 }
instances.mspac2.gunkyStart = { x = 14, y = 32 }
instances.mspac2.gronkyStart = { x = -2, y = 4 }
instances.mspac2.scatterTiles = {
    { x = 25, y = -1 },
    { x = 2, y = -1 },
    { x = 27, y = 33 },
    { x = 0, y = 33 },
}
instances.mspac2.scatterPositions = {
    blinky = { x = 25, y = -1 },
    pinky = { x = 2, y = -1 },
    inky = { x = 27, y = 33 },
    clyde = { x = 0, y = 33 },
}
instances.mspac2.playerone = 14
instances.mspac2.ready = 20

instances.mspac2.defaultColor = 13

-- Create "pac" maze instance
instances.mspac3 = Maze(maps.mspac3)
instances.mspac3.maxColors = MAX_COLORS
instances.mspac3.sirenTriggers = { 20, 40, 100, 150 }
instances.mspac3.fruitTriggers = { 170, 70 }
instances.mspac3.fruitLoc = { x = 14 * 8, y = 20 * 8 + 4 }
instances.mspac3.houseCenter = { x = 14, y = 17 }
instances.mspac3.pacStart = { x = 14, y = 26 }
instances.mspac3.punkyStart = { x = 14, y = 4 }
instances.mspac3.gunkyStart = { x = 14, y = 32 }
instances.mspac3.gronkyStart = { x = -2, y = 12 }
instances.mspac3.scatterTiles = {
    { x = 25, y = -1 },
    { x = 2, y = -1 },
    { x = 27, y = 33 },
    { x = 0, y = 33 },
}
instances.mspac3.scatterPositions = {
    blinky = { x = 25, y = -1 },
    pinky = { x = 2, y = -1 },
    inky = { x = 27, y = 33 },
    clyde = { x = 0, y = 33 },
}
instances.mspac3.playerone = 14
instances.mspac3.ready = 20

instances.mspac3.defaultColor = 14

-- Create "pac" maze instance
instances.mspac4 = Maze(maps.mspac4)
instances.mspac4.maxColors = MAX_COLORS
instances.mspac4.sirenTriggers = { 20, 40, 100, 150 }
instances.mspac4.fruitTriggers = { 170, 70 }
instances.mspac4.fruitLoc = { x = 14 * 8, y = 20 * 8 + 4 }
instances.mspac4.houseCenter = { x = 14, y = 17 }
instances.mspac4.pacStart = { x = 14, y = 26 }
instances.mspac4.punkyStart = { x = 14, y = 4 }
instances.mspac4.gunkyStart = { x = 14, y = 29 }
instances.mspac4.gronkyStart = { x = -2, y = 16 }
instances.mspac4.scatterTiles = {
    { x = 25, y = -1 },
    { x = 2, y = -1 },
    { x = 27, y = 33 },
    { x = 0, y = 33 },
}
instances.mspac4.scatterPositions = {
    blinky = { x = 25, y = -1 },
    pinky = { x = 2, y = -1 },
    inky = { x = 27, y = 33 },
    clyde = { x = 0, y = 33 },
}
instances.mspac4.playerone = 14
instances.mspac4.ready = 20

instances.mspac4.defaultColor = 11

-- Create "pac" maze instance
instances.booze1 = Maze(maps.booze1)
instances.booze1.maxColors = MAX_COLORS
instances.booze1.sirenTriggers = { 20, 40, 90, 140 }
instances.booze1.fruitTriggers = { 150, 60 }
instances.booze1.fruitLoc = { x = 14 * 8, y = 21 * 8 + 4 }
instances.booze1.houseCenter = { x = 14, y = 27 }
instances.booze1.pacStart = { x = 14, y = 9 }
instances.booze1.punkyStart = { x = 14, y = 21 }
instances.booze1.gunkyStart = { x = 14, y = 30 }
instances.booze1.gronkyStart = { x = -2, y = 24 }
instances.booze1.scatterTiles = {
    { x = 25, y = 10 },
    { x = 5, y = 10 },
    { x = 27, y = 33 },
    { x = 0, y = 33 },
}
instances.booze1.scatterPositions = {
    blinky = { x = 25, y = 10 },
    pinky = { x = 5, y = 10 },
    inky = { x = 27, y = 33 },
    clyde = { x = 0, y = 33 },
}
instances.booze1.playerone = 24
instances.booze1.ready = 30

instances.booze1.defaultColor = 10

-- Module table
local maze = {}

-- Get a maze instance by name
maze.getMaze = function(name)
    return instances[name]
end

-- Constructor for creating new maze instances
maze.new = Maze

-- Module-level constant
maze.maxColors = MAX_COLORS

return maze
