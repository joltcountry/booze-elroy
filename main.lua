-- Love2D Application
-- Main entry point
-- Global stuff
g = {}
g.state = {
    xOffset = 0, yOffset = 24
}

local game = require("game")
local graphics = require("graphics")
local moonshine = require("moonshine")

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

function love.load()

    gameCanvas = love.graphics.newCanvas(224, 288)
    love.graphics.setDefaultFilter("nearest", "nearest")
    effect = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.scanlines)
    effect.crt.distortionFactor = {1.06, 1.065}  -- horizontal/vertical bulge
    effect.crt.feather = 0.03                    -- soften edges
  
    -- tweak scanlines
    effect.scanlines.opacity = 0.4
    effect.scanlines.thickness = 1.0


    love.window.setTitle("Booze Elroy")
    love.graphics.setBackgroundColor(.02,.1, .08)
    love.graphics.setDefaultFilter("nearest", "nearest")
    graphics.init()
    game.start()

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
    game.draw()
    effect(function()
        local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()
        local gw, gh = gameCanvas:getWidth(), gameCanvas:getHeight()
        local scale = math.min(ww / gw, wh / gh)

        love.graphics.push()
        love.graphics.translate((ww - gw * scale) / 2, (wh - gh * scale) / 2)
        love.graphics.scale(scale, scale)
        love.graphics.draw(gameCanvas, 0, 0)
        love.graphics.pop()
    end)
    graphics.spriteChart()

end

function love.keypressed(key)
    -- Handle key presses
    if key == "escape" then
        love.event.quit()
    end
end

