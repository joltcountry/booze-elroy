-- Love2D Application
-- Main entry point
-- Global stuff
g = {
    scale  = 2
}

-- SCENES
local game = require("game")
local attract = require("attract")


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
    -- Set filter FIRST, before creating any canvases or loading images
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    local gw, gh = 224, 288

    g.scale = love.graphics.getHeight() / gh

    gameCanvas = love.graphics.newCanvas(gw, gh)
    crtCanvas  = love.graphics.newCanvas(gw * g.scale, gh * g.scale)
    
    -- Explicitly set filter on canvases (they don't inherit default filter)
    gameCanvas:setFilter("nearest", "nearest")
    crtCanvas:setFilter("nearest", "nearest")
    effect = moonshine(moonshine.effects.crt)
    --.chain(moonshine.effects.colorgradesimple)
    .chain(moonshine.effects.glow)
    .chain(moonshine.effects.gaussianblur)
    .chain(moonshine.effects.scanlines)
    --.chain(moonshine.effects.godsray)
    --.chain(moonshine.effects.chromasep)
    effect.crt.distortionFactor = {1.03, 1.04}  -- horizontal/vertical bulge
    effect.crt.feather = 0.03                    -- soften edges
    -- -- tweak scanlines
    effect.glow.strength = 5
    effect.glow.min_luma = .2
    effect.scanlines.opacity = 0.3
    effect.scanlines.thickness = .3
    -- -- brighten things up (values > 1.0 brighten, < 1.0 darken)
    --effect.colorgradesimple.factors = {1.1, 1.1, 1.1}  -- 30% brighter

    effect.resize(gw * g.scale, gh * g.scale)
    love.window.setTitle("Booze Elroy")
    love.graphics.setBackgroundColor(.05,.12,.12)
    graphics.init()
    g.scene = attract
    g.scene.start()

end

function love.update(dt)
    -- Called every frame, dt is the time since last frame
    t = t + dt
    accumulator = accumulator + dt
    while accumulator >= fixed_dt do
        frameCounter = frameCounter + 1
        g.scene.update(fixed_dt)
        accumulator = accumulator - fixed_dt
    end

end

function love.draw()
    g.scene.draw()
    love.graphics.setCanvas(crtCanvas)
    love.graphics.clear(0,0,0,1)
    love.graphics.origin()

    effect(function()
        love.graphics.push()
        love.graphics.scale(g.scale, g.scale)
        love.graphics.translate(1, 1)
        love.graphics.draw(gameCanvas, 0, 0)
        love.graphics.pop()
    end)

    love.graphics.setCanvas()

    local gw, gh = crtCanvas:getWidth(), crtCanvas:getHeight()
    local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()

    love.graphics.push()
    love.graphics.draw(crtCanvas, ww / 2 - gw / 2, 0)
    love.graphics.pop()

    graphics.spriteChart()

end

function love.keypressed(key)
    -- global
    if key == "escape" then
        love.event.quit()
    end

    if g.scene.keypressed then g.scene.keypressed(key) end
end

