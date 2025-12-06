-- Graphics utility functions

local graphics = {}
local sprites = {}

-- Split spritesheet images into 1D arrays (tables of subimages/quads)
function graphics.splitSpritesheet(image, frameWidth, frameHeight)
    local quads = {}
    local imgWidth = image:getWidth()
    local imgHeight = image:getHeight()
    local cols = math.floor(imgWidth / frameWidth)
    local rows = math.floor(imgHeight / frameHeight)
    local i = 1
    for y = 0, rows - 1 do
        for x = 0, cols - 1 do
            quads[i] = love.graphics.newQuad(
                x * frameWidth, y * frameHeight,
                frameWidth, frameHeight,
                imgWidth, imgHeight
            )
            i = i + 1
        end
    end
    return quads
end

function graphics.init()
    
    local spritesheet16 = love.graphics.newImage("sprites/spr16.png")
    local spritesheet8 = love.graphics.newImage("sprites/spr8.png")
    local spritesheetText8 = love.graphics.newImage("sprites/text8.png")

    -- Split spritesheet images into 1D arrays (tables of subimages/quads)
    local sprites16 = graphics.splitSpritesheet(spritesheet16, 16, 16)
    local sprites8 = graphics.splitSpritesheet(spritesheet8, 8, 8)
    local text8 = graphics.splitSpritesheet(spritesheetText8, 8, 8)

    sprites.spr16 = { sheet = spritesheet16, quads = sprites16 }
    sprites.spr8 = { sheet = spritesheet8, quads = sprites8 }
    sprites.text8 = { sheet = spritesheetText8, quads = text8 }

end

function graphics.spriteChart()
    love.graphics.push()
    love.graphics.scale(2, 2)

    for i, quad in ipairs(sprites.spr16.quads) do
        -- Arrange sprites in a grid, e.g., 10 per row
        local spritesPerRow = 10
        local x = 700 + ((i - 1) % spritesPerRow) * 24  -- 16px + margin
        local y = 0 + math.floor((i - 1) / spritesPerRow) * 32
        love.graphics.draw(sprites.spr16.sheet, quad, x, y)
        love.graphics.print(i, x, y + 18)
    end

    for i, quad in ipairs(sprites.spr8.quads) do
        -- Arrange sprites in a grid, e.g., 10 per row
        local spritesPerRow = 10
        local x = 700 + ((i - 1) % spritesPerRow) * 24  -- 16px + margin
        local y = 300 + math.floor((i - 1) / spritesPerRow) * 32
        love.graphics.draw(sprites.spr8.sheet, quad, x, y)
        love.graphics.print(i, x, y + 18)
    end
    love.graphics.pop()


end

graphics.animations = require("animations")

graphics.draw = function(o, x, y)
    local a = o.animator()
    a.frame = a.frame or 1
    love.graphics.draw(sprites[a.spr].sheet, sprites[a.spr].quads[a.frames[a.frame]], x, y)
end

graphics.updateAnimation = function(o, frameCounter)
    local a = o.animator()
    if frameCounter % a.speed == 0 then
        a.frame = (a.frame % #a.frames) + 1
    end
end

return graphics

