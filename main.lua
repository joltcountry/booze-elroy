-- Love2D Application
-- Main entry point

local game = require("game")
local graphics = require("graphics")
local animations = require("animations")

local windowWidth = 1920
local windowHeight = 1080

-- Game state
local t = 0
local accumulator = 0
local fixed_dt = 1/60
local frameCounter = 0;

-- Spritesheets (loaded in love.load)
local spritesheet16
local spritesheet8
local spritesheetText8

local pac = {
    animator = animations.pac
}

function love.load()

    love.window.setTitle("Booze Elroy")
    love.graphics.setBackgroundColor(.1,.4, .3)
    love.graphics.setDefaultFilter("nearest", "nearest")

    spritesheet16 = love.graphics.newImage("sprites/spr16.png")
    spritesheet8 = love.graphics.newImage("sprites/spr8.png")
    spritesheetText8 = love.graphics.newImage("sprites/text8.png")

    -- Split spritesheet images into 1D arrays (tables of subimages/quads)
    sprites16 = graphics.splitSpritesheet(spritesheet16, 16, 16)
    sprites8 = graphics.splitSpritesheet(spritesheet8, 8, 8)
    text8 = graphics.splitSpritesheet(spritesheetText8, 8, 8)
end

function love.update(dt)
    -- Called every frame, dt is the time since last frame
    t = t + dt
    accumulator = accumulator + dt
    while accumulator >= fixed_dt do
        frameCounter = frameCounter + 1
        game.update(fixed_dt)
        accumulator = accumulator - fixed_dt

        animations.update(pac.animator, frameCounter)
    
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(2, 2)

    for i, quad in ipairs(sprites16) do
        -- Arrange sprites in a grid, e.g., 10 per row
        local spritesPerRow = 10
        local x = 700 + ((i - 1) % spritesPerRow) * 24  -- 16px + margin
        local y = 0 + math.floor((i - 1) / spritesPerRow) * 32
        love.graphics.draw(spritesheet16, quad, x, y)
        love.graphics.print(i, x, y + 18)
    end

    for i, quad in ipairs(sprites8) do
        -- Arrange sprites in a grid, e.g., 10 per row
        local spritesPerRow = 10
        local x = 700 + ((i - 1) % spritesPerRow) * 24  -- 16px + margin
        local y = 300 + math.floor((i - 1) / spritesPerRow) * 32
        love.graphics.draw(spritesheet8, quad, x, y)
        love.graphics.print(i, x, y + 18)
    end
    love.graphics.pop()

    love.graphics.push()
    love.graphics.scale(6,6)
    love.graphics.draw(spritesheet16, sprites16[pac.animator.frames[pac.animator.frame]], 30, 30)
    love.graphics.pop()
end

function love.keypressed(key)
    -- Handle key presses
    if key == "escape" then
        love.event.quit()
    end
end

