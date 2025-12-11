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
            endFunc = function() 
                g.lives = g.lives - 1
            end
        },
        ready = {
            frames = 120,
            state = { showPac = true, showGhosts = true },
            nextMode = "normal"
        },
        normal = {
            state = { running = true, showPac = true, showGhosts = true },
        },
    }
}

mode.handle = function()
    
    if g.mode and modes[g.scene.name][g.mode] then
        local mode = modes[g.scene.name][g.mode]
        if not mode.started then
            if mode.frames then
                g.modeTimer = mode.frames
                mode.started = true
            end
            if mode.state then g.state = mode.state end
            if mode.startFunc then mode.startFunc() end
        end
        if mode.frames then
            g.modeTimer = g.modeTimer - 1
            if g.modeTimer == 0 then
                if mode.endFunc then mode.endFunc() end
                if mode.nextMode then g.mode = mode.nextMode else g.mode = false end
                mode.started = false
            end
        end
    end

end

return mode
