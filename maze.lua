local graphics = require("graphics")
local constants = require("constants")
local handlers = require("handlers")
local maps = require("maps")
local indexes = '123456789ABCDEFGHIJKLMNOPQRSTUVWXY'
local afterDark = 'ABC7Y8DEFGHKL'

-- Module-level constant
local MAX_COLORS = 15

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
        if x < 0 or x >= #self.map[1] then
            return false
        end

        local c = upperCase(string.sub(self.map[y+1], x+1, x+1))
        return string.find(indexes, c, 1, true) ~= nil
    end

    self.isTunnel = function(x, y)
        if x < 0 or x >= #self.map[1] then
            return false
        end

        local c = string.sub(self.map[y+1], x+1, x+1)
        return (c == "_")
    end

    self.isDisallowed = function(x, y)
        if x < 0 or x >= #self.map[1] or g.config.freeGhost then
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
                end
            end
        end
        graphics.print("BO", 3, 6, 3)
        graphics.print("OZE", 8, 6, 3)
        graphics.print("ELR", 17, 6, 3)
        graphics.print("OY", 23, 6, 3)
    end

    return self
end

-- Maze registry
local instances = {}

-- Create "pac" maze instance
instances.pac = Maze(maps.defaultMap)
instances.pac.maxColors = MAX_COLORS
instances.pac.sirenTriggers = { 20, 40, 100, 150 }
instances.pac.fruitTriggers = { 170, 70 }
instances.pac.fruitLoc = { x = 14 * 8, y = 20 * 8 + 4 }

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
