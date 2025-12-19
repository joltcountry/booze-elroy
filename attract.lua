local attract = {
    name = "attract"
}

local graphics = require("graphics")
local characters = require("characters")
local constants = require("constants")
local fruits = require("fruits")
local game = require("game")
local maze = require("maze")
local animations = require("animations")
local mode = require("mode")
local menus = require("menus")

-- Game state variables
local fc = 0
local speedFactor = 20/16 -- 1.25

local state = {}

g.booze = {
    x = 0,
    y = 100,
    dir = 0,
    speed = .75,
    animator = function() return animations.booze end
}

local menu = menus.main

function attract.start()
    mode.setMode("startup")
    menu.selectedItem = 1
    stopSiren()
    if g.originalVolume then
        g.config.volume = g.originalVolume
    end
    g.attract = false
    applyVolume()
    for _, snd in pairs(g.sounds) do
        if type(snd.stop) == "function" then snd:stop() end
    end
end

function attract.update(dt)
    -- Called every fixed timestep (60 FPS) / frame
    fc = fc + 1

    mode.handle()

    if (g.state.showBooze) then
        g.booze.x = g.booze.x + 1
        if g.booze.x > 224 then g.booze.x = 0 end
        graphics.updateAnimation(g.booze, fc)
    end

end

function attract.keypressed(key)
    menus.keypressed(menu, key)
end

function attract.gamepadpressed(joystick, button)
    menus.gamepadpressed(menu, button)
end

function attract.draw()

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    if not g.currentBackground then g.currentBackground = g.config.background end
    if g.backgrounds[g.currentBackground] then
        love.graphics.setColor(.4, .4, .4)
        love.graphics.draw(g.backgrounds[g.currentBackground], 0, 0, 0, 224 / g.backgrounds[g.currentBackground]:getWidth(), 288  / g.backgrounds[g.currentBackground]:getHeight())
        love.graphics.setColor(1, 1, 1)
    end

    local msg1 = "jolt country games"
    local msg2 = "presents"
    local msg3 = "booze elroy"
    local msg4 = "press \"Z\" to start"
    local msg5 = "a completely new game idea"
    local msg6 = "Alpha4 2025-12-19"

    -- Draw score
    graphics.print("1up", 3, 0)
    graphics.print("high score", 9, 0)
    graphics.print(formatScore(g.score or 0), 0, 1, 0)
    if g.highScore then
        graphics.print(formatScore(g.highScore), 10, 1)
    end

        
    if g.state.showHelperText then
        graphics.print(msg1, 14 - string.len(msg1) / 2, 5)
        graphics.print(msg2, 14 - string.len(msg2) / 2, 7)
        
        menus.draw(menus.main, 6, 23, 1)
    end
    if g.state.showGameName then
        graphics.print(msg3, 14 - string.len(msg3) / 2, 15, math.random(0,6))
        graphics.print(msg5, 14 - string.len(msg5) / 2, 17, 3)
        graphics.print(msg6, 14 - string.len(msg6) / 2, 19, 2)
    end
    if g.state.showBooze then
        graphics.drawChar(g.booze, g.booze.x, g.booze.y)
    end


    love.graphics.setCanvas()

end

return attract

