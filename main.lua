-- Love2D Application
-- Main entry point
-- Global stuff
g = {
    scaleOption = 3,
    state = {},
}

g.config = {
    scatterOption = false,
    pinkyBug = true,
    fastPac = false,
    background = "none",
    volume = 5,
    crtEffect = true,
    mazeColor = 1,
    startingLives = 3,
    freeGuy = 1,
    hardMode = false,
    extraGhosts = 0,
}

-- SCENES
local game = require("game")
local attract = require("attract")
local credits = require("credits")
local options = require("options")
local maze = require("maze")

local graphics = require("graphics")
local moonshine = require("moonshine")

love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption, {resizable = true})

-- Game state
local t = 0
local accumulator = 0
local fixed_dt = 1/60.606061
local frameCounter = 0;
local spritesheet16
local spritesheet8
local spritesheetText8

-- Helper to (re)build the sounds table and apply common settings
local function buildSounds()
    g.sounds = {
        opening = love.audio.newSource("sounds/opening.wav", "static"),
        wakka1  = love.audio.newSource("sounds/wakka1.wav", "static"),
        wakka2  = love.audio.newSource("sounds/wakka2.wav", "static"),
        fruit   = love.audio.newSource("sounds/fruit.wav", "static"),
        died    = love.audio.newSource("sounds/died.wav", "static"),
        scared  = love.audio.newSource("sounds/scared.wav", "static"),
        ateGhost= love.audio.newSource("sounds/ateGhost.wav", "static"),
        siren1  = love.audio.newSource("sounds/siren1.wav", "static"),
        siren2  = love.audio.newSource("sounds/siren2.wav", "static"),
        siren3  = love.audio.newSource("sounds/siren3.wav", "static"),
        siren4  = love.audio.newSource("sounds/siren4.wav", "static"),
        siren5  = love.audio.newSource("sounds/siren5.wav", "static"),
        dead    = love.audio.newSource("sounds/dead.wav", "static"),
        extrapac= love.audio.newSource("sounds/extrapac.wav", "static"),
        coindrop= love.audio.newSource("sounds/coindrop.wav", "static"),
    }

    -- Restore looping properties
    g.sounds.scared:setLooping(true)
    g.sounds.siren1:setLooping(true)
    g.sounds.siren2:setLooping(true)
    g.sounds.siren3:setLooping(true)
    g.sounds.siren4:setLooping(true)
    g.sounds.siren5:setLooping(true)
    g.sounds.dead:setLooping(true)

    -- Reapply volume settings
    if applyVolume then
        applyVolume()
    end
end

-- Initial sound setup
buildSounds()

-- Function to reload audio sources (to pick up new default audio device)
reloadAudioSources = function()
    -- Stop all currently playing sounds
    for _, sound in pairs(g.sounds) do
        if sound:isPlaying() then
            sound:stop()
        end
    end
    
    -- Rebuild all audio sources to use the current default audio device
    buildSounds()
end

-- Function to apply volume to all sounds
applyVolume = function()
    local volume = g.config.volume / 10.0  -- Convert 0-10 to 0.0-1.0
    for _, sound in pairs(g.sounds) do
        sound:setVolume(volume)
    end
end

g.sirenTriggers = { 20, 40, 100, 150 }

g.backgrounds = {
    stars = love.graphics.newImage("backgrounds/stars.jpg"),
    beach = love.graphics.newImage("backgrounds/beach.jpg"),
    arcade = love.graphics.newImage("backgrounds/arcade.jpg"),
    forest = love.graphics.newImage("backgrounds/forest.jpg"),
    abstract = love.graphics.newImage("backgrounds/abstract.jpg"),
    xmas = love.graphics.newImage("backgrounds/xmas.jpg"),
    canyon = love.graphics.newImage("backgrounds/canyon.jpg"),
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

local function encodeScore(score)
    -- Simple XOR encoding with a secret key and base64 conversion
    local key = 0x53A7
    local encoded = ""
    local sc = tostring(score)
    for i = 1, #sc do
        local c = string.byte(sc, i)
        encoded = encoded .. string.char(bit.bxor(c, key % 256))
        key = (key * 3 + 11) % 65536
    end
    return love.data.encode("string", "base64", encoded)
end

local function decodeScore(encoded)
    if not encoded or encoded == "" then return nil end

    -- Base64 decode first
    local ok, decoded = pcall(love.data.decode, "string", "base64", encoded)
    if not ok or not decoded then return nil end

    -- Reverse the XOR with the same key stream
    local key = 0x53A7
    local chars = {}
    for i = 1, #decoded do
        local c = string.byte(decoded, i)
        local orig = bit.bxor(c, key % 256)
        chars[#chars + 1] = string.char(orig)
        key = (key * 3 + 11) % 65536
    end

    local scoreStr = table.concat(chars)
    local n = tonumber(scoreStr)
    return n
end

score = function(s)
    local oldScore = g.score
    g.score = g.score + s
    if (g.config.freeGuy == 1 and oldScore < 10000 and g.score >= 10000)
        or (g.config.freeGuy == 2 and oldScore < 20000 and g.score >= 20000)
        or (g.config.freeGuy == 3 and oldScore % 10000 > g.score % 10000) then
        love.audio.play( g.sounds.extrapac )
        g.lives = g.lives + 1
    end
        
    -- Update high score
    if (not g.highScore or g.score > g.highScore) and g.score > 0 then
        g.highScore = g.score

        -- Encode the high score before saving
        local encoded = encodeScore(g.score)
        love.filesystem.write("player.dat", encoded)
    end
end

resizeCanvases = function()
    local gw, gh = 224, 288
    
    g.scale = love.graphics.getHeight() / gh
    
    gameCanvas = love.graphics.newCanvas(gw, gh)
    -- Add 1 pixel to prevent cutoff due to rounding/translation
    crtCanvas  = love.graphics.newCanvas(math.ceil(gw * g.scale) + 1, math.ceil(gh * g.scale) + 1)
    
    -- Explicitly set filter on canvases (they don't inherit default filter)
    if g.config.crtEffect then
        gameCanvas:setFilter("linear", "linear")
        crtCanvas:setFilter("linear", "linear")
    else
        gameCanvas:setFilter("nearest", "nearest")
        crtCanvas:setFilter("nearest", "nearest")
    end
    
    if effect then
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
    
    effect = moonshine(moonshine.effects.glow)
    .chain(moonshine.effects.colorgradesimple)
    .chain(moonshine.effects.scanlines)
    .chain(moonshine.effects.crt)
    -- .chain(moonshine.effects.gaussianblur)
    -- .chain(moonshine.effects.glow)
    effect.crt.distortionFactor = {1.03, 1.04}  -- horizontal/vertical bulge
    effect.crt.feather = 0.02                    -- soften edges
    effect.glow.strength = 3
    effect.glow.min_luma = .85
    --effect.gaussianblur.sigma = .2 * g.scale
    effect.scanlines.opacity = 0.3
    effect.scanlines.thickness = .3
    effect.colorgradesimple.factors = {1.1, 1.1, 1.1}
    
    effect.resize(gw * g.scale, gh * g.scale)
    love.window.setTitle("Booze Elroy")
    love.graphics.setBackgroundColor(0,0,0)
    graphics.init()

    -- Load and decode persisted high score, if present
    if love.filesystem.getInfo("player.dat") then
        local contents = love.filesystem.read("player.dat")
        local saved = decodeScore(contents)
        if saved and saved > 0 then
            g.highScore = saved
        end
    end

    applyVolume()  -- Set initial volume
    setScene("attract")
    joystick = love.joystick.getJoysticks()[1]

end

function love.update(dt)
    -- Called every frame, dt is the time since last frame
    t = t + dt
    accumulator = accumulator + dt
    if accumulator >= fixed_dt then
        frameCounter = frameCounter + 1
        g.scene.update(fixed_dt)
        accumulator = accumulator - fixed_dt
    end
    -- while accumulator >= fixed_dt do
    --     frameCounter = frameCounter + 1
    --     g.scene.update(fixed_dt)
    --     accumulator = accumulator - fixed_dt
    -- end
end

function love.draw()

    g.scene.draw()
    love.graphics.setCanvas(crtCanvas)
    love.graphics.clear(0,0,0,1)
    love.graphics.origin()

    if g.config.crtEffect then
        effect(function()
            love.graphics.push()
            love.graphics.scale(g.scale, g.scale)
            love.graphics.translate(0, 1)
            love.graphics.draw(gameCanvas, 0, 0)
            love.graphics.pop()
        end)
    else
        love.graphics.push()
        love.graphics.scale(g.scale, g.scale)
        love.graphics.translate(0, 1)
        love.graphics.draw(gameCanvas, 0, 0)
        love.graphics.pop()
    end

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
    if key == "escape" or key == "backspace"then
        if g.scene == attract then
            love.event.quit()
        else
            setScene("attract")
        end
        return
    end

    if key == "space" then
        if not g.paused then
            g.paused = true
            -- INSERT_YOUR_CODE
            g.playingSounds = {}
            for name, sound in pairs(g.sounds) do
                if sound:isPlaying() then
                    table.insert(g.playingSounds, sound)
                    sound:pause()
                end
            end
        else
            g.paused = false
            for _, sound in ipairs(g.playingSounds) do
                sound:play()
            end
            g.playingSounds = {}
        end
    end

    if g.scene.keypressed then g.scene.keypressed(key) end
end

function love.gamepadpressed(joystick, button)
    if g.scene.gamepadpressed then g.scene.gamepadpressed(joystick, button) end
end

function love.resize(w, h)
    -- Resize canvases when window is resized
    resizeCanvases()
end
