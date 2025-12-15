-- Love2D Application
-- Main entry point
-- Global stuff
g = {
    scaleOption = 3,
    state = {},
    score = 0,
}

g.config = {
    spicy = false,
    pinkyBug = true,
    fastPac = false,
    background = "none",
}

-- SCENES
local game = require("game")
local attract = require("attract")
local credits = require("credits")
local options = require("options")
local maze = require("maze")

local graphics = require("graphics")
local moonshine = require("moonshine")

love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption)

-- Game state
local t = 0
local accumulator = 0
local fixed_dt = 1/60
local frameCounter = 0;

-- Spritesheets (loaded in love.load)
local spritesheet16
local spritesheet8
local spritesheetText8

g.sounds = {
    opening = love.audio.newSource("sounds/opening.wav", "static"),
    wakka1 = love.audio.newSource("sounds/wakka1.wav", "static"),
    wakka2 = love.audio.newSource("sounds/wakka2.wav", "static"),
    fruit = love.audio.newSource("sounds/fruit.wav", "static"),
    died = love.audio.newSource("sounds/died.wav", "static"),
    scared = love.audio.newSource("sounds/scared.wav", "static"),
    ateGhost = love.audio.newSource("sounds/ateGhost.wav", "static"),
    siren1 = love.audio.newSource("sounds/siren1.wav", "static"),
    siren2 = love.audio.newSource("sounds/siren2.wav", "static"),
    siren3 = love.audio.newSource("sounds/siren3.wav", "static"),
    siren4 = love.audio.newSource("sounds/siren4.wav", "static"),
    siren5 = love.audio.newSource("sounds/siren5.wav", "static"),
    dead = love.audio.newSource("sounds/dead.wav", "static"),
    extrapac = love.audio.newSource("sounds/extrapac.wav", "static"),
    coindrop = love.audio.newSource("sounds/coindrop.wav", "static"),
}
g.sounds.scared:setLooping(true)
g.sounds.siren1:setLooping(true)
g.sounds.siren2:setLooping(true)
g.sounds.siren3:setLooping(true)
g.sounds.siren4:setLooping(true)
g.sounds.siren5:setLooping(true)
g.sounds.dead:setLooping(true)

g.sirenTriggers = { 20, 40, 100, 150 }

g.backgrounds = {
    stars = love.graphics.newImage("backgrounds/stars.jpg"),
    beach = love.graphics.newImage("backgrounds/beach.jpg"),
    arcade = love.graphics.newImage("backgrounds/arcade.jpg"),
}

playSiren = function()
    for i = 1, #g.sirenTriggers do
        if #g.dots < g.sirenTriggers[i] then
            love.audio.play( g.sounds["siren" .. 6-i] )
            return
        end
    end
    love.audio.play( g.sounds.siren1 )
end

stopSiren = function()
    g.sounds.siren5:stop()
    g.sounds.siren4:stop()
    g.sounds.siren3:stop()
    g.sounds.siren2:stop()
    g.sounds.siren1:stop()
end

setScene = function(s)
    if s == "game" then
        g.scene = game
        g.scene.start()
    elseif s == "attract" then
        g.scene = attract
        g.scene.start()
    elseif s == "credits" then
        g.scene = credits
        g.scene.start()
    elseif s == "options" then
        g.scene = options
        g.scene.start()
    end
end

-- Helper function to format score text
formatScore = function(score)
    if score == 0 then
        return "     00"
    else
        return string.rep(" ", 7 - tostring(score):len()) .. tostring(score)
    end
end

score = function(s)
    local oldScore = g.score
    g.score = g.score + s
    if oldScore < 10000 and g.score >= 10000 then
        love.audio.play( g.sounds.extrapac )
        g.lives = g.lives + 1
    end
end

resizeCanvases = function()
    local gw, gh = 224, 288
    
    g.scale = love.graphics.getHeight() / gh
    
    gameCanvas = love.graphics.newCanvas(gw, gh)
    crtCanvas  = love.graphics.newCanvas(gw * g.scale, gh * g.scale)
    
    -- Explicitly set filter on canvases (they don't inherit default filter)
    gameCanvas:setFilter("nearest", "nearest")
    crtCanvas:setFilter("nearest", "nearest")
    
    if effect then
        --effect.gaussianblur.sigma = .3 * g.scale
        effect.resize(gw * g.scale, gh * g.scale)
    end
end

function love.load()
    -- Seed random number generator for proper randomness
    --math.randomseed(os.time())
    
    -- Set filter FIRST, before creating any canvases or loading images
    --love.graphics.setDefaultFilter("nearest", "nearest")
    
    local gw, gh = 224, 288

    resizeCanvases()
    
    effect = moonshine(moonshine.effects.crt)
    --.chain(moonshine.effects.boxblur)
    .chain(moonshine.effects.glow)
    .chain(moonshine.effects.scanlines)
    effect.crt.distortionFactor = {1.03, 1.04}  -- horizontal/vertical bulge
    effect.crt.feather = 0.02                    -- soften edges
    effect.glow.strength = 3
    effect.glow.min_luma = .85
    --effect.gaussianblur.sigma = .3 * g.scale
    effect.scanlines.opacity = 0.3
    effect.scanlines.thickness = .3

    effect.resize(gw * g.scale, gh * g.scale)
    love.window.setTitle("Booze Elroy")
    love.graphics.setBackgroundColor(.05,.12,.12)
    graphics.init()
    setScene("attract")
    joystick = love.joystick.getJoysticks()[1]

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

    --graphics.spriteChart()

end

function love.keypressed(key)
    -- global
    if key == "escape" then
        if g.scene == attract then
            love.event.quit()
        else
            setScene("attract")
        end
        return
    end

    if g.scene.keypressed then g.scene.keypressed(key) end
end

function love.gamepadpressed(joystick, button)
    if g.scene.gamepadpressed then g.scene.gamepadpressed(joystick, button) end
end
