local graphics = require("graphics")
local indexes = '123456789ABCDEFGHIJKLMNOPQRSTUVWX'

maze = {}

local map = {
    -- 28 columns each
    "1222222222222342222222222225", --  1
    "6............78............9", --  2
    "6.ABBC.ABBBC.78.ABBBC.ABBC.9", --  3
    "6o7  8.7   8.78.7   8.7  8o9", --  4
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
    "      .   9      6   .      ", -- 15 (center row; gate ==)
    "JJJJJC.AC 9      6 AC.AJJJJJ", -- 16
    "     6.78 S222222T 78.9     ", -- 17
    "     6.78          78.9     ", -- 18
    "     6.78 ABBBBBBC 78.9     ", -- 19
    "12222F.DF DEEGHEEF DF.D22225", -- 20
    "6............78............9", -- 21
    "6.ABBC.ABBBC.78.ABBBC.ABBC.9", -- 22
    "6.DEG8.DEEEF.DF.DEEEF.7HEF.9", -- 23
    "6o..78.......  .......78..o9", -- 24 (^^ above house: no-ghost tiles)
    "XBC.78.AC.ABBBBBBC.AC.78.ABV", -- 25
    "WEF.DF.78.DEEGHEEF.78.DF.DEU", -- 26
    "6......78....78....78......9", -- 27
    "6.ABBBBLKBBC.78.ABBLKBBBBC.9", -- 28
    "6.DEEEEEEEEF.DF.DEEEEEEEEF.9", -- 29
    "6..........................9", -- 30
    "IJJJJJJJJJJJJJJJJJJJJJJJJJJM", -- 31 (bottom “void” row; often unused)
}
maze.init = function()



end

maze.getPowers = function()
    local powers = {};
    for y = 1, #map do
        for x = 1, #map[1] do
            local c = string.sub(map[y], x, x)
            if (c == 'o') then table.insert(powers, {x= (x - 1) *8, y=24 + (y - 1)*8}) end
        end
    end
    return powers
end

maze.getDots = function()
    local dots = {};
    for y = 1, #map do
        for x = 1, #map[1] do
            local c = string.sub(map[y], x, x)
            if (c == '.') then table.insert(dots, {x= (x-1)*8, y=24 +(y-1)*8}) end
        end
    end
    return dots
end

maze.draw = function()
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
            if spriteNum then
                graphics.drawSprite("spr8", spriteNum + 3, (x-1) * 8,24 + (y-1) * 8)
            end
        end
    end
end

return maze