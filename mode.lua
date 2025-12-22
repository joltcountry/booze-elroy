local characters = require("characters")
local levels = require("levels")
local maze = require("maze")

-- Helper to get current maze instance
local function getCurrentMaze()
    if not g.currentMaze then g.currentMaze = g.config.maze end
    return maze.getMaze(g.currentMaze)
end

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
            frames = 600,
            state = { showHelperText = true, showGameName = true, showBooze = true },
            endFunc = function()
                g.attract = true
                g.originalVolume = g.config.volume
                g.config.volume = 0
                setScene("game")
            end
        },
        play = {
            frames = 20,
            state = { showHelperText = false, showGameName = false, showBooze = false },
            endFunc = function()
                setScene("game")
            end
        }
    },
    game = {
        pregame = {
            frames = 30,
            state = { running = false, showPac = false, showGhosts = false, hideMaze = true },
            nextMode = "playerUp",
        },
        playerUp = {
            frames = 135,
            state = { running = false, showPac = false, showGhosts = false },
            nextMode = "ready",
            startFunc = function()
                for name, power in pairs(g.powers) do
                    power.frame = 1
                end
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
                if g.lives < 0 then
                    mode.setMode("gameover")
                else
                    g.fruitTimer = false
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
                g.sounds.scared:stop()
                if not g.sounds.dead:isPlaying() then
                    g.sounds.dead:play()
                end
            end
        },
        caught = {
            state = { running = false, showPac = true, showGhosts = true },
            frames = 60,
            nextMode = "dying",
            startFunc = function()                
                g.particles = {}
                g.state.turnaroundCooldown = nil
                stopSiren()
                g.sounds.dead:stop()
                g.sounds.scared:stop()
            end,
        },
        dying = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 210,
            nextMode = "ready",
            startFunc = function()
                g.diedSoundPlayed = false
            end,
            endFunc = function()
                if g.attract then
                    g.config.volume = g.originalVolume
                    g.attract = false
                    g.originalVolume = nil
                    setScene("attract")
                end
            end
        },
        gameover = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 120,
            endFunc = function()
                if g.autoplay then
                    setScene("game")
                else
                    setScene("attract")
                end
            end
        },
        levelComplete = {
            state = { running = false, showPac = true, showGhosts = true },
            frames = 120,
            startFunc = function()
                g.particles = {}
                stopSiren()
                g.sounds.dead:stop()
                g.sounds.scared:stop()
            end,
            nextMode = "levelAnimation"
        },
        intermission1 = {
            state = { running = false, showPac = false, showGhosts = false, hideMaze = true, hideScore = true, hideLines = true },
            frames = 720,
            nextMode = "pause",
            endFunc = function()
                g.intermissionBoozes = nil
            end
        },
        levelAnimation = {
            state = { running = false, showPac = false, showGhosts = false },
            frames = 85,
            endFunc = function()
                if g.levelNumber == 2 or g.levelNumber == 5 or g.levelNumber == 9 or g.levelNumber == 13 or g.levelNumber == 17 then 
                    mode.setMode("intermission1")
                else
                    mode.setMode("pause")
                end
            end
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
                getCurrentMaze().init()
                g.newLevel = true
            end
        }
        
    }
}

mode.isStarted = function(modeName)
    return modes[g.scene.name][modeName].started
end

mode.setMode = function(modeName)
    if modes[g.scene.name][modeName] then
        g.mode = modeName
        modes[g.scene.name][modeName].started = false
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
