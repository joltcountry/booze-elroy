local characters = require("characters")
local levels = require("levels")

-- local game = require("game")
-- local attract = require("attract")

local mode = {}

local modes = {
    attract = {
        startup = {
            frames = 30,
            state = {},
            nextMode = "hideGame",
            startFunc = function() 
                g.booze.x = 0 
            end
        },
        hideGame = {
            frames = 120,
            state = { showHelperText = true, showGameName = false },
            nextMode = "restart"
        },
        restart = {
            frames = 0,
            state = { showHelperText = true, showGameName = true, showBooze = true },
        }
    },
    game = {
        playerUp = {
            frames = 135,
            state = { running = false, showPac = false, showGhosts = false },
            nextMode = "ready",
            startFunc = function()
                g.sounds.opening:play()
            end
        },
        ready = {
            frames = 120,
            nextMode = "normal",
            startFunc = function()
                -- Update scenery animations
                for name, power in pairs(g.powers) do
                    power.frame = 1
                end
                g.chars.pac.frame = 1
                if g.newLevel then g.newLevel = false else
                    g.lives = g.lives - 1
                end
                g.fruitTimer = false
                if g.lives < 0 then
                    mode.setMode("gameover")
                else
                    -- set up level again, including ghost-leaving-mode?
                    g.state = { showPac = true, showGhosts = true, showReady = true }
                    g.starvation = 0
                    characters.reset()
                    levels.resetLevel()
                end 
            end,
            endFunc = function()
                playSiren()
            end
        },
        normal = {
            state = { running = true, showPac = true, showGhosts = true },
        },
        ateFruit = {
            state = { running = true, showPac = true, showGhosts = true },
            frames = 120, 
            nextMode = "normal", 
        },
        ateGhost = {
            state = { running = false, showPac = false, showGhosts = true },
            frames = 60,
            nextMode = "normal",
            endFunc = function()
                for _, char in pairs(g.chars) do
                    char.hidden = false
                end
                love.audio.play( g.sounds.dead )
            end
        },
        caught = {
            state = { running = false, showPac = true, showGhosts = true },
            frames = 60,
            nextMode = "dying",
            startFunc = function()
                stopSiren()
                g.sounds.dead:stop()
                g.sounds.scared:stop()
            end
        },
        dying = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 210,
            nextMode = "ready",
        },
        gameover = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 120,
            endFunc = function()
                setScene("attract")
            end
        },
        levelComplete = {
            state = { running = false, showPac = true, showGhosts = true },
            frames = 120,
            nextMode = "levelAnimation",
            startFunc = function()
                stopSiren()
                g.sounds.dead:stop()
                g.sounds.scared:stop()

            end
        },
        levelAnimation = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 85,
            nextMode = "pause",
        },
        pause = {
            state = { hideMaze = true, running = false, showPac = false, showGhosts = false },
            frames = 20,
            nextMode = "ready",
            endFunc = function()
                g.levelNumber = g.levelNumber + 1
                levels.startLevel(g.levelNumber)
                characters.initialize()
                characters.reset()
                maze.init()
                g.newLevel = true
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
