local options = {
    name = "options"
}

local graphics = require("graphics")
local menus = require("menus")
local animations = require("animations")
local menus = require("menus")
local maze = require("maze")

local gw, gh = 224, 288

backgroundOptions = { "none", "stars", "beach", "arcade", "forest", "city", "canyon", "clouds", "planets", "abstract", "wave1", "wave2", "lines", "retro", "tan", "aqua", "xmas", "newyear" }

local function getBackgroundIndex()
    for i, name in ipairs(backgroundOptions) do
        if g.config.background == name then
            return i
        end
    end
    -- Fallback to first option if config is unexpected
    return 1
end

local function saveConfig()
    -- Save g.config table to options.cfg as Lua
    local function serialize(tbl, indent)
        indent = indent or ""
        local result = "{\n"
        local first = true
        for k, v in pairs(tbl) do
            if not first then
                result = result .. ",\n"
            end
            first = false
            local keyStr = type(k) == "string" and string.format("[%q]", k) or string.format("[%s]", tostring(k))
            if type(v) == "table" then
                result = result .. indent .. "  " .. keyStr .. " = " .. serialize(v, indent .. "  ")
            elseif type(v) == "string" then
                result = result .. indent .. "  " .. keyStr .. " = " .. string.format("%q", v)
            elseif type(v) == "number" or type(v) == "boolean" then
                result = result .. indent .. "  " .. keyStr .. " = " .. tostring(v)
            elseif type(v) == "nil" then
                result = result .. indent .. "  " .. keyStr .. " = nil"
            end
        end
        result = result .. "\n" .. indent .. "}"
        return result
    end

    local serialized = "return " .. serialize(g.config)
    local configFile = love.filesystem.newFile("options.cfg", "w")
    configFile:write(serialized)
    configFile:flush()
    configFile:close()
end

local menu = {
    -- GAME configuration
    {
        y=4,
        options = {
            { text = "pac", action = function() g.config.maze = "pac"; g.currentMaze = "pac" end },
            { text = "mspac1", action = function() g.config.maze = "mspac1"; g.currentMaze = "mspac1" end },
            { text = "mspac2", action = function() g.config.maze = "mspac2"; g.currentMaze = "mspac2" end },
            { text = "mspac3", action = function() g.config.maze = "mspac3"; g.currentMaze = "mspac3" end },
            { text = "mspac4", action = function() g.config.maze = "mspac4"; g.currentMaze = "mspac4" end },
            { text = "booze1", action = function() g.config.maze = "booze1"; g.currentMaze = "booze1" end },
            { text = "booze2", action = function() g.config.maze = "booze2"; g.currentMaze = "booze2" end },
            { text = "booze3", action = function() g.config.maze = "booze3"; g.currentMaze = "booze3" end },
            { text = "booze4", action = function() g.config.maze = "booze4"; g.currentMaze = "booze4" end },
            { text = "booze5", action = function() g.config.maze = "booze5"; g.currentMaze = "booze5" end },
            { text = "random", action = function() g.config.maze = "random"; g.currentMaze = g.mazes[math.random(1, #g.mazes)] end },
        }
    },
    {
        y=5,
        options = {
            { text = "1", action = function() g.config.startingLevel = 1 end },
            { text = "2", action = function() g.config.startingLevel = 2 end },
            { text = "3", action = function() g.config.startingLevel = 3 end },
            { text = "4", action = function() g.config.startingLevel = 4 end },
            { text = "5", action = function() g.config.startingLevel = 5 end },
            { text = "6", action = function() g.config.startingLevel = 6 end },
            { text = "7", action = function() g.config.startingLevel = 7 end },
            { text = "8", action = function() g.config.startingLevel = 8 end },
            { text = "9", action = function() g.config.startingLevel = 9 end },
            { text = "10", action = function() g.config.startingLevel = 10 end },
            { text = "11", action = function() g.config.startingLevel = 11 end },
            { text = "12", action = function() g.config.startingLevel = 12 end },
            { text = "13", action = function() g.config.startingLevel = 13 end },
            { text = "14", action = function() g.config.startingLevel = 14 end },
            { text = "15", action = function() g.config.startingLevel = 15 end },
            { text = "16", action = function() g.config.startingLevel = 16 end },
            { text = "17", action = function() g.config.startingLevel = 17 end },
            { text = "18", action = function() g.config.startingLevel = 18 end },
            { text = "19", action = function() g.config.startingLevel = 19 end },
            { text = "20", action = function() g.config.startingLevel = 20 end },
            { text = "21", action = function() g.config.startingLevel = 21 end },
        }
    },
    {
        y=6,
        options = {
            { text = "Normal", action = function() g.config.difficulty = 0 end },
            { text = "Hard", action = function() g.config.difficulty = 1 end },
            { text = "Plus", action = function() g.config.difficulty = 2 end },
        }
    },
    { 
        y=7,
        options = {
            { text = "Off", action = function() g.config.plusMode = false end },
            { text = "On", action = function() g.config.plusMode = true end },
        }
    },
    {
        y=8,
        options = {
            { text = "Off", action = function() g.config.afterDark = false end },
            { text = "Maze", action = function() g.config.afterDark = 1 end },
            { text = "Dots", action = function() g.config.afterDark = 2 end },
            { text = "Both", action = function() g.config.afterDark = 3 end },
            { text = "All", action = function() g.config.afterDark = 4 end },
        }
    },
    
    -- PLAYER configuration
    {
        y=11,
        options = {
            { text = "1", action = function() g.config.startingLives = 1 end },
            { text = "3", action = function() g.config.startingLives = 3 end },
            { text = "5", action = function() g.config.startingLives = 5 end },
        }
    },
    {
        y=12,
        options = {
            { text = "10000", action = function() g.config.freeGuy = 1 end },
            { text = "20000", action = function() g.config.freeGuy = 2 end },
            { text = "every 10k", action = function() g.config.freeGuy = 3 end },
            { text = "none", action = function() g.config.freeGuy = 4 end },
        }
    },
    {
        y=13,
        options = {
            { text = "On", action = function() g.config.phasing = true end },
            { text = "Off", action = function() g.config.phasing = false end },
        },
    },
    {
        y=14,
        options = {
            { text = "On", action = function() g.config.fastPac = true end },
            { text = "Off", action = function() g.config.fastPac = false end },
        },
    },

    -- GHOST configuration
    {
        y=17,
        options = {
            { text = "0", action = function() g.config.ghostCount = 0 end },
            { text = "1", action = function() g.config.ghostCount = 1 end },
            { text = "2", action = function() g.config.ghostCount = 2 end },
            { text = "3", action = function() g.config.ghostCount = 3 end },
            { text = "4", action = function() g.config.ghostCount = 4 end },
            { text = "5", action = function() g.config.ghostCount = 5 end },
            { text = "6", action = function() g.config.ghostCount = 6 end },
            { text = "7", action = function() g.config.ghostCount = 7 end },
        }
    },
    {
        y=18,
        options = {
            { text = "On", action = function() g.config.pinkyBug = true end },
            { text = "Off", action = function() g.config.pinkyBug = false end },
        },
    },
    {
        y=19,
        options = {
            { text = "Normal", action = function() g.config.scatterOption = false end },
            { text = "Random", action = function() g.config.scatterOption = 1 end },
            { text = "None", action = function() g.config.scatterOption = 2 end },
        },
    },
    {
        y=20,
        options = {
            { text = "On", action = function() g.config.freeGhost = true end },
            { text = "Off", action = function() g.config.freeGhost = false end },
        }
    },



    -- AV configuration
    {
        y=23,
        options = {
            { text = "None", action = function() g.config.background = "none"; g.currentBackground = "none" end },
            { text = "Stars", action = function() g.config.background = "stars"; g.currentBackground = "stars" end },
            { text = "Beach", action = function() g.config.background = "beach"; g.currentBackground = "beach" end },
            { text = "Arcade", action = function() g.config.background = "arcade"; g.currentBackground = "arcade" end },
            { text = "Forest", action = function() g.config.background = "forest"; g.currentBackground = "forest" end },
            { text = "City", action = function() g.config.background = "city"; g.currentBackground = "city" end },
            { text = "Canyon", action = function() g.config.background = "canyon"; g.currentBackground = "canyon" end },
            { text = "Clouds", action = function() g.config.background = "clouds"; g.currentBackground = "clouds" end },
            { text = "Planets", action = function() g.config.background = "planets"; g.currentBackground = "planets" end },
            { text = "Abstract", action = function() g.config.background = "abstract"; g.currentBackground = "abstract" end },
            { text = "Wave1", action = function() g.config.background = "wave1"; g.currentBackground = "wave1" end },
            { text = "Wave2", action = function() g.config.background = "wave2"; g.currentBackground = "wave2" end },
            { text = "Lines", action = function() g.config.background = "lines"; g.currentBackground = "lines" end },
            { text = "Retro", action = function() g.config.background = "retro"; g.currentBackground = "retro" end },
            { text = "Tan", action = function() g.config.background = "tan"; g.currentBackground = "tan" end },
            { text = "Aqua", action = function() g.config.background = "aqua"; g.currentBackground = "aqua" end },
            { text = "Xmas", action = function() g.config.background = "xmas"; g.currentBackground = "xmas" end },
            { text = "Newyear", action = function() g.config.background = "newyear"; g.currentBackground = "newyear" end },
            { text = "Random", action = function() g.config.background = "random"; g.currentBackground = backgroundOptions[math.random(2, #backgroundOptions)] end },
        },
    },
    {
        y=24,
        options = {
            { text = "Default", action = function() g.config.mazeColor = 99 end },
            { text = "1", action = function() g.config.mazeColor = 1 end },
            { text = "2", action = function() g.config.mazeColor = 2 end },
            { text = "3", action = function() g.config.mazeColor = 3 end },
            { text = "4", action = function() g.config.mazeColor = 4 end },
            { text = "5", action = function() g.config.mazeColor = 5 end },
            { text = "6", action = function() g.config.mazeColor = 6 end },
            { text = "7", action = function() g.config.mazeColor = 7 end },
            { text = "8", action = function() g.config.mazeColor = 8 end },
            { text = "9", action = function() g.config.mazeColor = 9 end },
            { text = "10", action = function() g.config.mazeColor = 10 end },
            { text = "11", action = function() g.config.mazeColor = 11 end },
            { text = "12", action = function() g.config.mazeColor = 12 end },
            { text = "13", action = function() g.config.mazeColor = 13 end },
            { text = "14", action = function() g.config.mazeColor = 14 end },
            { text = "15", action = function() g.config.mazeColor = 15 end },
            { text = "16", action = function() g.config.mazeColor = 16 end },
            { text = "17", action = function() g.config.mazeColor = 17 end },
            { text = "18", action = function() g.config.mazeColor = 18 end },
            { text = "19", action = function() g.config.mazeColor = 19 end },
            { text = "20", action = function() g.config.mazeColor = 20 end },
            { text = "Random", action = function() g.config.mazeColor = 0 end },
        }
    },
    {
        y=25,
        options = {
            { text = "On", action = function() 
                g.config.fullscreen = true
                local _, _, flags = love.window.getMode()
                local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
                love.window.setMode(desktopWidth, desktopHeight, {
                    borderless = true
                })
                resizeCanvases()
            end },
            { text = "Off", action = function() 
                g.config.fullscreen = false
                love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption, {resizable = true})
                resizeCanvases()
            end },
        }
    },
    {
        y=26,
        options = {
            { text = "On", action = function() g.config.crtEffect = true; resizeCanvases() end },
            { text = "Off", action = function() g.config.crtEffect = false; resizeCanvases() end },
        }
    },
    {
        y=27,
        options = {
            { text = "0", action = function() g.config.volume = 0; applyVolume() end },
            { text = "1", action = function() g.config.volume = 1; applyVolume() end },
            { text = "2", action = function() g.config.volume = 2; applyVolume() end },
            { text = "3", action = function() g.config.volume = 3; applyVolume() end },
            { text = "4", action = function() g.config.volume = 4; applyVolume() end },
            { text = "5", action = function() g.config.volume = 5; applyVolume() end },
            { text = "6", action = function() g.config.volume = 6; applyVolume() end },
            { text = "7", action = function() g.config.volume = 7; applyVolume() end },
            { text = "8", action = function() g.config.volume = 8; applyVolume() end },
            { text = "9", action = function() g.config.volume = 9; applyVolume() end },
            { text = "10", action = function() g.config.volume = 10; applyVolume() end },
        }
    },
    {
        text = "Save Current Options",
        sound = "phase",
        x = 4, y = 29,
        action = function()
            saveConfig()
        end
    },
    {
        text = "Restore Defaults",
        sound = "phase",

        x = 6, y = 30,
        action = function()
            resetConfigs()
            options.resetSelectedOptions()
            saveConfig()
        end
    },
    {
        text = "Reset High Score",
        sound = "phase",

        x = 6, y = 31,
        action = function()
            -- Overwrite the file with empty string to reset it
            -- love.filesystem.write("player.dat", "")
            g.highScore = false
        end
    },
    {
        text = "Back",
        x = 12, y = 33,
        action = function()
            setScene("attract")
        end
    }
}

local function getMazeMenuIndex(mazeName)
    if mazeName == "random" then
        return #g.mazes + 1
    end
    for i, name in ipairs(g.mazes) do
        if name == mazeName then
            return i
        end
    end
    return 1 -- fallback
end

function options.resetSelectedOptions(fullscreenOnly)

    if fullscreenOnly then
        menu[16].selectedOption = g.config.fullscreen and 1 or 2
        return
    end
    
    menu[1].selectedOption = getMazeMenuIndex(g.config.maze)
    menu[2].selectedOption = g.config.startingLevel
    menu[3].selectedOption = g.config.difficulty == 1 and 2 or g.config.difficulty == 2 and 3 or 1
    menu[4].selectedOption = g.config.plusMode and 2 or 1
    menu[5].selectedOption = g.config.afterDark == false and 1 or g.config.afterDark == 1 and 2 or g.config.afterDark == 2 and 3 or g.config.afterDark == 3 and 4 or g.config.afterDark == 4 and 5
    menu[6].selectedOption = g.config.startingLives == 1 and 1 or g.config.startingLives == 3 and 2 or g.config.startingLives == 5 and 3
    menu[7].selectedOption = g.config.freeGuy
    menu[8].selectedOption = g.config.phasing and 1 or 2
    menu[9].selectedOption = g.config.fastPac and 1 or 2
    menu[10].selectedOption = g.config.ghostCount + 1
    menu[11].selectedOption = g.config.pinkyBug and 1 or 2
    menu[12].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[13].selectedOption = g.config.freeGhost and 1 or 2
    menu[14].selectedOption = g.config.background == "random" and #backgroundOptions + 1 or getBackgroundIndex()
    menu[15].selectedOption = g.config.mazeColor == 99 and 1 or g.config.mazeColor == 0 and maze.maxColors + 1 or g.config.mazeColor + 1
    menu[16].selectedOption = g.config.fullscreen and 1 or 2
    menu[17].selectedOption = g.config.crtEffect and 1 or 2
    menu[18].selectedOption = g.config.volume + 1

    for i = 1, #menu do
        if menu[i].options then
            menu[i].options[menu[i].selectedOption].action()
        end
    end
end

function options.start()
    menu[1].selectedOption = getMazeMenuIndex(g.config.maze)
    menu[2].selectedOption = g.config.startingLevel
    menu[3].selectedOption = g.config.difficulty == 1 and 2 or g.config.difficulty == 2 and 3 or 1
    menu[4].selectedOption = g.config.plusMode and 2 or 1
    menu[5].selectedOption = g.config.afterDark == false and 1 or g.config.afterDark == 1 and 2 or g.config.afterDark == 2 and 3 or g.config.afterDark == 3 and 4 or g.config.afterDark == 4 and 5
    menu[6].selectedOption = g.config.startingLives == 1 and 1 or g.config.startingLives == 3 and 2 or g.config.startingLives == 5 and 3
    menu[7].selectedOption = g.config.freeGuy
    menu[8].selectedOption = g.config.phasing and 1 or 2
    menu[9].selectedOption = g.config.fastPac and 1 or 2
    menu[10].selectedOption = g.config.ghostCount + 1
    menu[11].selectedOption = g.config.pinkyBug and 1 or 2
    menu[12].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[13].selectedOption = g.config.freeGhost and 1 or 2
    menu[14].selectedOption = g.config.background == "random" and #backgroundOptions + 1 or getBackgroundIndex()
    menu[15].selectedOption = g.config.mazeColor == 99 and 1 or g.config.mazeColor == 0 and maze.maxColors + 1 or g.config.mazeColor + 1
    menu[16].selectedOption = g.config.fullscreen and 1 or 2
    menu[17].selectedOption = g.config.crtEffect and 1 or 2
    menu[18].selectedOption = g.config.volume + 1
    menu.selectedItem = 1
end

function options.update(dt)
    menus.update(menu, dt)
end

function options.keypressed(key)
    menus.keypressed(menu, key)
end

function options.gamepadpressed(joystick, button)
    menus.gamepadpressed(menu, button)
end

function options.draw()

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    if not g.currentBackground then g.currentBackground = g.config.background end
    if g.backgrounds[g.currentBackground] then
        love.graphics.setColor(.4, .4, .4)
        love.graphics.draw(g.backgrounds[g.currentBackground], 0, 0, 0, 224 / g.backgrounds[g.currentBackground]:getWidth(), 288  / g.backgrounds[g.currentBackground]:getHeight())
        love.graphics.setColor(1, 1, 1)
    end

    -- Draw score
    graphics.print("1up", 3, 0)
    graphics.print("high score", 9, 0)
    graphics.print(formatScore(g.score or 0), 0, 1, 0)
    if g.highScore then
        graphics.print(formatScore(g.highScore), 10, 1)
    end

    graphics.print("GAME OPTIONS", 3, 3, 3)
    graphics.print("Maze", 3, 4)
    graphics.print("Starting Level", 3, 5)
    graphics.print("Difficulty", 3, 6)
    graphics.print("Plus Mode", 3, 7)
    graphics.print("Blindfold", 3, 8)
    
    graphics.print("PLAYER OPTIONS", 3, 10, 3)

    graphics.print("Starting Lives", 3, 11)
    graphics.print("extra life", 3, 12)
    graphics.print("Phasing", 3, 13)
    graphics.print("Fast Pac", 3, 14)

    graphics.print("GHOST OPTIONS", 3, 16, 3)
    graphics.print("Ghosts", 3, 17)
    graphics.print("Pinky Bug", 3, 18)
    graphics.print("Scatter", 3, 19)
    graphics.print("Unrestricted", 3, 20)

    graphics.print("AV OPTIONS", 3, 22, 3)
    graphics.print("Background", 3, 23)
    graphics.print("Maze Style", 3, 24)
    graphics.print("Full screen", 3, 25)
    graphics.print("CRT Effect", 3, 26)
    graphics.print("Volume", 3, 27)
    menus.draw(menu, 18, 5, 1)

    if g.config.mazeColor > 0 and g.config.mazeColor < 99 then 
        graphics.drawSpriteAtTile("spr8", g.config.mazeColor + 2, 21, 24)
    end

    love.graphics.setCanvas()

end

return options