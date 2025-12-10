local attract = {}

local graphics = require("graphics")
local characters = require("characters")
local constants = require("constants")
local fruits = require("fruits")
local game = require("game")
local maze = require("maze")
local animations = require("animations")

-- Game state variables
local fc = 0
local speedFactor = 20/16 -- 1.25

local state = {}

local booze = {
    x = 0,
    y = 120,
    dir = 0,
    speed = .75,
    animator = function() return animations.booze end
}

local modes = {
    startup = {
        frames = 60,
        state = {},
        nextMode = "hideGame",
        startFunc = function() 
            booze.x = 0 
        end
    },
    hideGame = {
        frames = 180,
        state = { showHelperText = true, showGameName = false },
        nextMode = "restart"
    },
    restart = {
        frames = 600,
        state = { showHelperText = true, showGameName = true, showBooze = true },
        nextMode = "startup"
    }
}

function attract.start()
    g.mode = "startup"
end

function attract.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    if g.mode and modes[g.mode] then
        local mode = modes[g.mode]
        if not mode.started then
            g.modeTimer = mode.frames
            if mode.state then state = mode.state end
            if mode.startFunc then mode.startFunc() end
            mode.started = true
        end
        g.modeTimer = g.modeTimer - 1
        if g.modeTimer == 0 then
            if mode.endFunc then mode.endFunc() end
            if mode.nextMode then g.mode = mode.nextMode else g.mode = false end
            mode.started = false
        end
    end

    if (state.showBooze) then
        booze.x = booze.x + 1
        if booze.x > 224 then booze.x = 0 end
        graphics.updateAnimation(booze, fc)
    end

end

function attract.keypressed(key)
    if key == "z" then
        g.scene = game
        g.scene.start()
    end
end

function attract.draw()

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    local msg1 = "jolt country games"
    local msg2 = "presents"
    local msg3 = "booze elroy"
    local msg4 = "press \"Z\" to start"
    local msg5 = "a completely new game idea"

    if state.showHelperText then
        graphics.print(msg1, 14 - string.len(msg1) / 2, 5)
        graphics.print(msg2, 14 - string.len(msg2) / 2, 7)
        graphics.print(msg4, 14 - string.len(msg4) / 2, 32, 4)
    end
    if state.showGameName then
        graphics.print(msg3, 14 - string.len(msg3) / 2, 17, math.random(0,6))
        graphics.print(msg5, 14 - string.len(msg5) / 2, 19)
    end
    if state.showBooze then
        graphics.drawChar(booze, booze.x, booze.y)
    end
    love.graphics.setCanvas()

end

return attract

