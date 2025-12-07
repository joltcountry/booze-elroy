-- Love2D Application
-- Main entry point
-- Global stuff
g = {
    scale  = 2
}
g.state = {
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
    local gw, gh = 224, 288

    g.scale = love.graphics.getHeight() / gh

    gameCanvas = love.graphics.newCanvas(gw, gh)
    crtCanvas  = love.graphics.newCanvas(gw * g.scale, gh * g.scale)
    love.graphics.setDefaultFilter("nearest", "nearest")
    effect = moonshine(moonshine.effects.crt)
    .chain(moonshine.effects.scanlines)
    .chain(moonshine.effects.glow)
    .chain(moonshine.effects.colorgradesimple)
    --.chain(moonshine.effects.godsray)
    --.chain(moonshine.effects.chromasep)
    effect.crt.distortionFactor = {1.03, 1.04}  -- horizontal/vertical bulge
    effect.crt.feather = 0.03                    -- soften edges
    -- tweak scanlines
    effect.glow.strength = 5
    effect.glow.min_luma = .7
    effect.scanlines.opacity = 0.4
    effect.scanlines.thickness = 1.0
    -- brighten things up (values > 1.0 brighten, < 1.0 darken)
    effect.colorgradesimple.factors = {1.1, 1.1, 1.1}  -- 30% brighter
    effect.resize(gw * g.scale, gh * g.scale)
    love.window.setTitle("Booze Elroy")
    love.graphics.setBackgroundColor(.1,.3, .2)
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
    love.graphics.setCanvas(crtCanvas)
    love.graphics.clear(0,0,0,1)
    love.graphics.origin()

    effect(function()
        love.graphics.push()
        love.graphics.scale(g.scale, g.scale)
        love.graphics.translate(0, 1)
        love.graphics.draw(gameCanvas, 0, 0)
        love.graphics.pop()
    end)

    love.graphics.setCanvas()

    local gw, gh = crtCanvas:getWidth(), crtCanvas:getHeight()
    local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()

    effect.resize(gw, gh)

    love.graphics.push()
    love.graphics.draw(crtCanvas, ww / 2 - gw / 2, 0)
    love.graphics.pop()

    graphics.spriteChart()

end

function love.keypressed(key)
    -- Handle key presses
    if key == "escape" then
        love.event.quit()
    end
end

