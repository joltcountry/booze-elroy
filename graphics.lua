-- Graphics utility functions

local graphics = {}

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

return graphics

