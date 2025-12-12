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

-- Game state variables
local fc = 0
local speedFactor = 20/16 -- 1.25

local state = {}

g.booze = {
    x = 0,
    y = 120,
    dir = 0,
    speed = .75,
    animator = function() return animations.booze end
}

function attract.start()
    mode.setMode("startup")
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
    if key == "z" then
        setScene("game")
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
        graphics.print(msg4, 14 - string.len(msg4) / 2, 32, 4)
    end
    if g.state.showGameName then
        graphics.print(msg3, 14 - string.len(msg3) / 2, 17, math.random(0,6))
        graphics.print(msg5, 14 - string.len(msg5) / 2, 19)
    end
    if g.state.showBooze then
        graphics.drawChar(g.booze, g.booze.x, g.booze.y)
    end
    love.graphics.setCanvas()

end

return attract

