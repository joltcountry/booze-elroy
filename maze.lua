local graphics = require("graphics")
local constants = require("constants")
local handlers = require("handlers")
local indexes = '123456789ABCDEFGHIJKLMNOPQRSTUVWXY'
local afterDark = 'ABC7Y8DEFGHKL'

-- Default map for backward compatibility
local defaultMap = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "1222222222222342222222222225", --  1
    "6............78............9", --  2
    "6.abbc.abbbc.78.abbbc.abbc.9", --  3
    "6`&yy*.&yyy*.78.&yyy*.&yy*`9", --  4
    "6.deef.deeef.DF.deeef.deef.9", --  5
    "6..........................9", --  6
    "6.abbc.ac.abbbbbbc.ac.abbc.9", --  7
    "6.deef.&*.deegheef.&*.deef.9", --  8
    "6......&*....&*....&*......9", --  9
    "IJJJJC.&kbbc &* abbl*.AJJJJM", -- 10
    "     6.&heef;df;deeg*.9     ", -- 11 (warp tunnels row; spaces = void)
    "     6.&*          &*.9     ", -- 12 (entrance to house row)
    "     6.&* NJOPPQJR &*.9     ", -- 13
    "22222F.df 9      6 df.D22222", -- 14
    "_____ .   9      6   . _____", -- 15 (center row; gate ==)
    "JJJJJC.ac 9      6 ac.AJJJJJ", -- 16
    "     6.&* S222222T &*.9     ", -- 17
    "     6.&*          &*.9     ", -- 18
    "     6.&* abbbbbbc &*.9     ", -- 19
    "12222F.df deegheef df.D22225", -- 20
    "6............&*............9", -- 21
    "6.abbc.abbbc.&*.abbbc.abbc.9", -- 22
    "6.deg*.deeef:df:deeef.&hef.9", -- 23
    "6`..&*.......  .......&*..`9", -- 24 (^^ above house: no-ghost tiles)
    "XBC.&*.ac.abbbbbbc.ac.&*.ABV", -- 25
    "WEF.df.&*.deegheef.&*.df.DEU", -- 26
    "6......&*....&*....&*......9", -- 27
    "6.abbbblkbbc.&*.abblkbbbbc.9", -- 28
    "6.deeeeeeeef.df.deeeeeeeef.9", -- 29
    "6..........................9", -- 30
    "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
    "                            ",
}

-- local defaultMap = {
--     -- 28 columns each
--     "                            ",
--     "                            ",
--     "                            ",
--     "1222222222222342222222222225", --  1
--     "6            78            9", --  2
--     "6 ABBC ABBBC 78 ABBBC ABBC 9", --  3
--     "6 7YY8 7YYY8 78 7YYY8 7YY8 9", --  4
--     "6 DEEF DEEEF DF DEEEF DEEF 9", --  5
--     "6                          9", --  6
--     "6 ABBC AC ABBBBBBC AC ABBC 9", --  7
--     "6 DEEF 78 DEEGHEEF 78 DEEF 9", --  8
--     "6      78    78    78      9", --  9
--     "IJJJJC 7KBBC 78 ABBL8 AJJJJM", -- 10
--     "     6 7HEEFxDFxDEEG8 9     ", -- 11 (warp tunnels row; spaces = void)
--     "     6 78          78 9     ", -- 12 (entrance to house row)
--     "     6 78 NJOPPQJR 78 9     ", -- 13
--     "22222F DF 9      6 DF D22222", -- 14
--     "_____     9      6     _____", -- 15 (center row; gate ==)
--     "JJJJJC AC 9      6 AC AJJJJJ", -- 16
--     "     6 78 S222222T 78 9     ", -- 17
--     "     6 78          78 9     ", -- 18
--     "     6 78 ABBBBBBC 78 9     ", -- 19
--     "12222F DF DEEGHEEF DF D22225", -- 20
--     "6            78            9", -- 21
--     "6.ABBC ABBBC 78 ABBBC ABBC 9", -- 22
--     "6.DEG8 DEEEF DF DEEEF 7HEF 9", -- 23
--     "6o..78                78   9", -- 24 (^^ above house: no-ghost tiles)
--     "XBC 78 AC ABBBBBBC AC 78 ABV", -- 25
--     "WEF DF 78 DEEGHEEF 78 DF DEU", -- 26
--     "6      78    78    78      9", -- 27
--     "6 ABBBBLKBBC 78 ABBLKBBBBC 9", -- 28
--     "6 DEEEEEEEEF DF DEEEEEEEEF 9", -- 29
--     "6                          9", -- 30
--     "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom "void" row; often unused)
--     "                            ",
-- }

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
    map = map or defaultMap
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

-- Create default maze instance for backward compatibility
local maze = Maze(defaultMap)

-- Add maxColors property to default instance for backward compatibility
maze.maxColors = MAX_COLORS

-- Add constructor method to default instance so users can create new mazes
maze.new = Maze

return maze
