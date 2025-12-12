local chars = require("characters")
local levels = require("levels")

-- local game = require("game")
-- local attract = require("attract")

local mode = {}

local modes = {
    attract = {
        startup = {
            frames = 60,
            state = {},
            nextMode = "hideGame",
            startFunc = function() 
                g.booze.x = 0 
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
    },
    game = {
        playerUp = {
            frames = 120,
            state = { running = false, showPac = false, showGhosts = false },
            nextMode = "ready",
        },
        ready = {
            frames = 120,
            nextMode = "normal",
            startFunc = function()
                g.lives = g.lives - 1
                if g.lives < 0 then
                    mode.setMode("gameover")
                    g.state = {}
                else
                    g.state = { showPac = true, showGhosts = true, showReady = true }
                    chars.initialize()
                    g.level = levels.getLevel()
                end 
            end
        },
        normal = {
            state = { running = true, showPac = true, showGhosts = true },
        },
        caught = {
            state = { running = false, showPac = true, showGhosts = true },
            frames = 60,
            nextMode = "dying",
        },
        dying = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 210,
            nextMode = "ready"
        },
        gameover = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 120,
            endFunc = function()
                g.state = {}
                setScene("attract")
            end
        }
        
    }
}

mode.setMode = function(mode)
    if modes[g.scene.name][mode] then
        g.mode = mode
        modes[g.scene.name][mode].started = false
    end
end


mode.handle = function()
    
    if g.mode and modes[g.scene.name][g.mode] then
        local currMode = modes[g.scene.name][g.mode]
        if not currMode.started then
            if currMode.frames then
                g.modeTimer = currMode.frames
                currMode.started = true
            end
            if currMode.startFunc then currMode.startFunc() end
            if currMode.state then g.state = currMode.state end
        end
        if currMode.frames then
            g.modeTimer = g.modeTimer - 1
            if g.modeTimer == 0 then
                if currMode.nextMode then mode.setMode(currMode.nextMode) end
                if currMode.endFunc then currMode.endFunc() end
                currMode.started = false
            end
        end
    end

end

return mode
