local graphics = require("graphics")
local indexes = '123456789ABCDEFGHIJKLMNOPQRSTUVWX'

maze = {}

local logicMap = {

}

local spriteMap = {
    -- 28 columns each
    "1222222222222342222222222225", --  1
    "6            78            9", --  2
    "6 ABBC ABBBC 78 ABBBC ABBC 9", --  3
    "6 7  8 7   8 78 7   8 7  8 9", --  4
    "6 DEEF DEEEF DF DEEEF DEEF 9", --  5
    "#..........................#", --  6
    "#.####.##.########.##.####.#", --  7
    "#.####.##.########.##.####.#", --  8
    "#......##....##....##......#", --  9
    "######.##### ## #####.######", -- 10
    "     #.##### ## #####.#     ", -- 11 (warp tunnels row; spaces = void)
    "     #.##          ##.#     ", -- 12 (entrance to house row)
    "     #.## ###HH### ##.#     ", -- 13
    "######.## #HHHHHH# ##.######", -- 14
    "      .   #HH==HH#   .      ", -- 15 (center row; gate ==)
    "######.## #HHHHHH# ##.######", -- 16
    "     #.## ######## ##.#     ", -- 17
    "     #.##          ##.#     ", -- 18
    "     #.## ######## ##.#     ", -- 19
    "######.## ######## ##.######", -- 20
    "#............##............#", -- 21
    "#.####.#####.##.#####.####.#", -- 22
    "#.####.#####.##.#####.####.#", -- 23
    "#o..##.......^^.......##..o#", -- 24 (^^ above house: no-ghost tiles)
    "###.##.##.########.##.##.###", -- 25
    "#......##....##....##......#", -- 26
    "#.##########.##.##########.#", -- 27
    "#.##########.##.##########.#", -- 28
    "#..........................#", -- 29
    "############################", -- 30
    "                            ", -- 31 (bottom “void” row; often unused)
}
maze.init = function()



end

maze.draw = function()

    for y = 1, #spriteMap do
        for x = 1, #spriteMap[1] do
            local c = string.sub(spriteMap[y], x, x)
            local spriteNum
            for i = 1, #indexes do
                if c == string.sub(indexes, i, i) then
                    spriteNum = i
                    break
                end
            end
            if spriteNum then
                graphics.drawSprite("spr8", spriteNum + 3, 5 + x * 8, 25 + y * 8)
            end
        end
    end
end

return maze