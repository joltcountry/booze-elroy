-- Love2D Application
-- Main entry point

local game = require("game")
local graphics = require("graphics")

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

-- Global stuff
g = {}
g.chars = require("characters")

function love.load()

    love.window.setTitle("Booze Elroy")
    love.graphics.setBackgroundColor(.1,.4, .3)
    love.graphics.setDefaultFilter("nearest", "nearest")
    graphics.init()

end

function love.update(dt)
    -- Called every frame, dt is the time since last frame
    t = t + dt
    accumulator = accumulator + dt
    while accumulator >= fixed_dt do
        frameCounter = frameCounter + 1
        game.update(fixed_dt)
        accumulator = accumulator - fixed_dt
    end
end

function love.draw()
    graphics.spriteChart()

    game.draw()
end

function love.keypressed(key)
    -- Handle key presses
    if key == "escape" then
        love.event.quit()
    end
end

