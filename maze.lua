local graphics = require("graphics")
local constants = require("constants")
local utils = require("utils")
local indexes = '123456789ABCDEFGHIJKLMNOPQRSTUVWXY'
local afterDark = 'ABC7Y8DEFGHKL'
maze = {}

maze.maxColors = 14

local map = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "1222222222222342222222222225", --  1
    "6............78............9", --  2
    "6.ABBC.ABBBC.78.ABBBC.ABBC.9", --  3
    "6o7YY8.7YYY8.78.7YYY8.7YY8o9", --  4
    "6.DEEF.DEEEF.DF.DEEEF.DEEF.9", --  5
    "6..........................9", --  6
    "6.ABBC.AC.ABBBBBBC.AC.ABBC.9", --  7
    "6.DEEF.78.DEEGHEEF.78.DEEF.9", --  8
    "6......78....78....78......9", --  9
    "IJJJJC.7KBBC 78 ABBL8.AJJJJM", -- 10
    "     6.7HEEFxDFxDEEG8.9     ", -- 11 (warp tunnels row; spaces = void)
    "     6.78          78.9     ", -- 12 (entrance to house row)
    "     6.78 NJOPPQJR 78.9     ", -- 13
    "22222F.DF 9      6 DF.D22222", -- 14
    "_____ .   9      6   . _____", -- 15 (center row; gate ==)
    "JJJJJC.AC 9      6 AC.AJJJJJ", -- 16
    "     6.78 S222222T 78.9     ", -- 17
    "     6.78          78.9     ", -- 18
    "     6.78 ABBBBBBC 78.9     ", -- 19
    "12222F.DF DEEGHEEF DF.D22225", -- 20
    "6............78............9", -- 21
    "6.ABBC.ABBBC.78.ABBBC.ABBC.9", -- 22
    "6.DEG8.DEEEFyDFyDEEEF.7HEF.9", -- 23
    "6o..78.......  .......78..o9", -- 24 (^^ above house: no-ghost tiles)
    "XBC.78.AC.ABBBBBBC.AC.78.ABV", -- 25
    "WEF.DF.78.DEEGHEEF.78.DF.DEU", -- 26
    "6......78....78....78......9", -- 27
    "6.ABBBBLKBBC.78.ABBLKBBBBC.9", -- 28
    "6.DEEEEEEEEF.DF.DEEEEEEEEF.9", -- 29
    "6..........................9", -- 30
    "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom “void” row; often unused)
    "                            ",
}

-- local map = {
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
--     "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom “void” row; often unused)
--     "                            ",
-- }

local afterDark = {
    -- 28 columns each
    "                            ",
    "                            ",
    "                            ",
    "                            ", --  1
    "                            ", --  2
    "  XXXX XXXXX    XXXXX XXXX  ", --  3
    "  XXXX XXXXX    XXXXX XXXX  ", --  4
    "  XXXX XXXXX    XXXXX XXXX  ", --  5
    "                            ", --  6
    "  XXXX XX XXXXXXXX XX XXXX  ", --  7
    "  XXXX XX XXXXXXXX XX XXXX  ", --  8
    "       XX    XX    XX       ", --  9
    "       XXXXX XX XXXXX       ", -- 10
    "       XXXXX XX XXXXX       ", -- 11 (warp tunnels row; spaces = void)
    "       XX          XX       ", -- 12 (entrance to house row)
    "       XX          XX       ", -- 13
    "       XX          XX       ", -- 14
    "                            ", -- 15 (center row; gate ==)
    "       XX          XX       ", -- 16
    "       XX          XX       ", -- 17
    "       XX          XX       ", -- 18
    "       XX XXXXXXXX XX       ", -- 19
    "       XX XXXXXXXX XX       ", -- 20
    "             XX             ", -- 21
    "  XXXX XXXXX XX XXXXX XXXX  ", -- 22
    "  XXXX XXXXX XX XXXXX XXXX  ", -- 23
    "    XX                XX    ", -- 24 (^^ above house: no-ghost tiles)
    "    XX XX XXXXXXXX XX XX    ", -- 25
    "    XX XX XXXXXXXX XX XX    ", -- 26
    "       XX    XX    XX       ", -- 27
    "  XXXXXXXXXX XX XXXXXXXXXX  ", -- 28
    "  XXXXXXXXXX XX XXXXXXXXXX  ", -- 29
    "                            ", -- 30
    "                            ", -- 31 (bottom “void” row; often unused)
    "                            ",
}

local xPixels = #map[1]*constants.tileSize
local yPixels = #map*constants.tileSize

maze.w = #map[1]
maze.h = #map

local handleDotEaten = function()
    if g.wakka then
        g.sounds.wakka2:play()
        g.wakka = false
    else
        g.sounds.wakka1:play()
        g.wakka = true
    end

    local found = false
    for i, v in ipairs(g.sirenTriggers) do
        if v == #g.dots then
            found = true
            break
        end
    end
    if found and not g.sounds.dead:isPlaying() and not g.sounds.scared:isPlaying() then
        stopSiren()
        playSiren()
    end

    if #g.dots == 170 or #g.dots == 70 then
        g.fruitTimer = 9 * 60 + math.random(0, 60)
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

local handlePowerEaten = function(xTile, yTile)
    if g.wakka then
        g.sounds.wakka2:play()
        g.wakka = false
    else
        g.sounds.wakka1:play()
        g.wakka = true
    end

    utils.activateFrightenedMode()
    
    -- -- Create particle explosion at power pellet location
    -- if g.createParticleExplosion then
    --     local x = xTile * constants.tileSize + constants.tileSize / 2
    --     local y = yTile * constants.tileSize + constants.tileSize / 2
    --     g.createParticleExplosion(x, y)
    -- end
end


maze.getLoc = function(c)
    local xTile = math.floor(c.x / constants.tileSize)
    local yTile = math.floor(c.y / constants.tileSize)
    local xOff = c.x % constants.tileSize
    local yOff = c.y % constants.tileSize

    return xTile, xOff, yTile, yOff
end

maze.init = function()

    local powers = maze.getPowers()
    local dots = maze.getDots()
    g.powers = {}
    g.dots = {}
    for _, p in ipairs(powers) do
        table.insert(g.powers, {
            x = p.x, y = p.y, score = 50, skipCounter = 3, action = handlePowerEaten, animator = function() return graphics.animations.power end
        })
    end
    for _, d in ipairs(dots) do
        table.insert(g.dots, {
            x = d.x, y = d.y, score = 10, skipCounter = 1, action = handleDotEaten, animator = function() return graphics.animations.dot end
        })
    end    

end

maze.getChar = function(x,y)
    if x < 0 or x >= #map[1] or y < 0 or y >= #map then
        return false
    end

    local c = string.sub(map[y+1], x+1, x+1)
    return c
end

maze.isWall = function(x,y)
    if x < 0 or x >= #map[1] then
        return false
    end

    local c = string.sub(map[y+1], x+1, x+1)
    return string.find(indexes, c, 1, true) ~= nil
end

maze.isTunnel = function(x,y)
    if x < 0 or x >= #map[1] then
        return false
    end

    local c = string.sub(map[y+1], x+1, x+1)
    return (c == "_")
end

maze.isDisallowed = function(x, y)
    if x < 0 or x >= #map[1] or g.config.freeGhost then
        return false
    end

    local c = string.sub(map[y+1], x+1, x+1)
    return (c == "x" or c == "y")
end

maze.isBlocked = function(c, dir)
    local xTile, xOff, yTile, yOff = maze.getLoc(c)
    return maze.isWall(xTile + constants.deltas[dir].x, yTile + constants.deltas[dir].y)
end

maze.getPowers = function()
    local powers = {};
    for y = 1, #map do
        for x = 1, #map[1] do
            local c = string.sub(map[y], x, x)
            if (c == 'o') then table.insert(powers, {x= (x - 1), y=(y - 1)}) end
        end
    end
    return powers
end

maze.getDots = function()
    local dots = {};
    for y = 1, #map do
        for x = 1, #map[1] do
            local c = string.sub(map[y], x, x)
            if (c == '.' or c == 'y') then table.insert(dots, {x= (x-1), y=(y-1)}) end
        end
    end
    return dots
end

maze.draw = function(color)
    color = color or 1
    color = color - 1
    for y = 1, #map do
        for x = 1, #map[1] do
            local c = string.sub(map[y], x, x)
            local spriteNum
            for i = 1, #indexes do
                if c == string.sub(indexes, i, i) then
                    spriteNum = i
                    break
                end
            end
            if spriteNum and (g.mode ~= "levelAnimation" or c ~= "P") and (not g.config.afterDark or g.config.afterDark == 2 or string.sub(afterDark[y], x, x) ~= "X") then
                graphics.drawSprite("spr8", (spriteNum - 1) * maze.maxColors + 3 + color, (x-1) * constants.tileSize,(y-1) * constants.tileSize)
            end
        end
    end
    graphics.print("BO", 3, 6, 3)
    graphics.print("OZE", 8, 6, 3)
    graphics.print("ELR", 17, 6, 3)
    graphics.print("OY", 23, 6, 3)
end

return maze