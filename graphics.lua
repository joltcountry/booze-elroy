-- Graphics utility functions

local constants = require("constants")

local graphics = {}
local sprites = {}

local textChars = 'ABCDEFGHIJKLMNO PQRSTUVWXYZ!©##0123456789/-"'
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local ghostScores = {
    [200] = 106,
    [400] = 107,
    [800] = 108,
    [1600] = 109,
    [3200] = 110,
    [6400] = 111,
    [12800] = 112,
    [25600] = 113,
}

local fruitScores = {
    [100] = 114,
    [300] = 117,
    [500] = 120,
    [700] = 123,
    [1000] = 126,
    [2000] = 129,
    [3000] = 132,
    [5000] = 135,
}

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

function graphics.drawGhostScore(score, x, y)
    local quad = ghostScores[score]
    love.graphics.draw(sprites.spr16.sheet, sprites.spr16.quads[quad], x, y)
end

function graphics.drawFruitScore(score, x, y)
    local quad = fruitScores[score]
    for i = 0, 2 do
        love.graphics.draw(sprites.spr16.sheet, sprites.spr16.quads[quad + i], x + 16 * (i-1), y)
    end
end

function graphics.spriteChart()

    for i, quad in ipairs(sprites.spr16.quads) do
        -- Arrange sprites in a grid, e.g., 10 per row
        local spritesPerRow = 10
        local x = (love.graphics.getWidth() / 6) * 5 + ((i - 1) % spritesPerRow) * 24  -- 16px + margin
        local y = 30 + math.floor((i - 1) / spritesPerRow) * 32
        love.graphics.draw(sprites.spr16.sheet, quad, x, y)
        love.graphics.print(i, x, y + 18)
    end

    -- for i, quad in ipairs(sprites.spr8.quads) do
    --     -- Arrange sprites in a grid, e.g., 10 per row
    --     local spritesPerRow = 10
    --     local x = 300 + ((i - 1) % spritesPerRow) * 24  -- 16px + margin
    --     local y = 300 + math.floor((i - 1) / spritesPerRow) * 40
    --     love.graphics.draw(sprites.spr8.sheet, quad, x, y)
    --     local c = i
    --     if c > 3 and c < 13 then c = c - 3 end
    --     if c > 12 then c = string.sub(alphabet, c-12, c-12) end
    --     love.graphics.print(c, x, y + 10)
    -- end

end

graphics.animations = require("animations")

graphics.drawChar = function(o, x, y, phased)
    local a = o:animator()
    if not a or not a.frames then
        return  -- Safety check: animation not available
    end
    o.frame = o.frame or 1
    local frameIndex = a.frames[o.frame]
    if not frameIndex then
        o.frame = 1  -- Reset to first frame if out of bounds
        frameIndex = a.frames[1]
    end
    if not frameIndex or not sprites[a.spr] or not sprites[a.spr].quads[frameIndex] then
        return  -- Safety check: quad not available
    end
    if phased then
        if phased >= 0 then love.graphics.setColor(math.random(), math.random(), math.random())
        else love.graphics.setColor(.2 + math.abs(phased) / 60 * .8, math.abs(phased) / 60, 0) end
    end
    love.graphics.draw(sprites[a.spr].sheet, sprites[a.spr].quads[frameIndex], x - 8, y - 8)
    if phased then love.graphics.setColor(1, 1, 1) end
end

graphics.drawScenery = function(o, x, y)
    local a = o:animator()
    o.frame = o.frame or 1
    graphics.drawSpriteAtTile(a.spr, a.frames[o.frame], x, y)
end

graphics.drawSprite = function(s, i, x, y)
    love.graphics.draw(sprites[s].sheet, sprites[s].quads[i], x, y)
end

graphics.print = function(s, x, y, o)
    o = o or 0
    local str = string.upper(s)
    for i = 1, #str do
        local c = string.sub(str, i, i)
        local index = string.find(textChars, c, 1, true)
        love.graphics.draw(sprites.text8.sheet, sprites.text8.quads[(o * 64) + index], x * constants.tileSize, y * constants.tileSize)
        x = x + 1
    end
end

graphics.drawSpriteAtTile = function(s, i, x, y)
    local quad = sprites[s].quads[i]
    if quad then
        love.graphics.draw(sprites[s].sheet, sprites[s].quads[i], x * constants.tileSize, y * constants.tileSize)
    end
end

graphics.updateAnimation = function(o, frameCounter)
    local a = o:animator()
    if not a then return end
    o.frame = o.frame or 1 
    if a.speed and frameCounter % a.speed == 0 then
        o.frame = (o.frame % #a.frames) + 1
    end
end

-- Particle system
g.particles = {}

function graphics.initParticles()
    g.particles = {}
end

function graphics.createParticleExplosion(x, y)
    -- Create random particles like fireworks
    for i = 1, 50 do
        local angle = math.random() * math.pi * 2  -- Completely random angle
        local speed = math.random() * 1.5
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        table.insert(g.particles, {
            x = x + (math.random() - 0.5) * 4,  -- Slight random offset for spread
            y = y + (math.random() - 0.5) * 4,
            vx = vx,
            vy = vy,
            life = 60,  -- frames to live
            maxLife = 60,
            size = 0.5 + math.random(),
            colors = {
                -- Pick either yellow (#ffff00) or purple (#B000ff) at random
                (function()
                    if math.random() < 0.5 then
                        -- yellow: 1, 1, 0
                        return {1, 1, 0}
                    else
                        -- purple: 176/255, 0, 1
                        return {176/255, 0, 1}
                    end
                end)()
            }
        })
    end
end

function graphics.emitBlinkyBubbles(x, y)
    -- Emit bubbles from Blinky's head position
    -- Bubbles drift upward and outward, creating a wake effect
    local numBubbles = math.random(0, 1)  -- Emit 0-1 bubbles per frame
    for i = 1, numBubbles do
        -- Position bubbles around head area (slightly above center)
        local offsetX = (math.random() - 0.5) * 8
        local offsetY = -4 + (math.random() - 0.5) * 4
        
        -- Bubbles move in a completely random direction
        local angle = math.random() * math.pi * 2  -- Any random angle
        local speed = 1 + math.random() * 0.2
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        
        table.insert(g.particles, {
            x = x + offsetX,
            y = y + offsetY,
            vx = vx,
            vy = vy,
            life = 20,  -- frames to live
            maxLife = 20,
            size = 1.5 + math.random() * 1.5,
            colors = {
                .5,
                .5,
                1.0
            },
            alpha = 0.6  -- Start with some transparency
        })
    end
end

function graphics.updateParticles()
    for i = #g.particles, 1, -1 do
        local p = g.particles[i]
        p.x = p.x + p.vx
        p.y = p.y + p.vy
        p.vx = p.vx * 0.97  -- friction
        p.vy = p.vy * 0.97
        p.life = p.life - 1
        
        -- Update alpha for bubbles (fade out over time)
        if p.alpha then
            p.alpha = (p.life / p.maxLife) * 0.6
        end
        
        if p.life <= 0 then
            table.remove(g.particles, i)
        end
    end
end

function graphics.drawParticles()
    for _, p in ipairs(g.particles) do
        local alpha = p.alpha or 1  -- Use particle's alpha if it exists, otherwise fully opaque
        love.graphics.setColor(p.colors[1], p.colors[2], p.colors[3], alpha)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    love.graphics.setColor(1, 1, 1)  -- Reset color
end

return graphics

