local options = {
    name = "options"
}

local graphics = require("graphics")
local menus = require("menus")
local animations = require("animations")
local menus = require("menus")
local maze = require("maze")

local gw, gh = 224, 288

backgroundOptions = { "none", "stars", "beach", "arcade", "forest", "canyon", "clouds", "abstract", "wave1", "wave2", "lines", "retro","xmas" }

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
    {
        options = {
            { text = "pac", action = function() g.config.maze = "pac"; g.currentMaze = "pac" end },
            { text = "mspac1", action = function() g.config.maze = "mspac1"; g.currentMaze = "mspac1" end },
            { text = "booze1", action = function() g.config.maze = "booze1"; g.currentMaze = "booze1" end },
            { text = "random", action = function() g.config.maze = "random"; g.currentMaze = g.mazes[math.random(1, #g.mazes)] end },
        }
    },
    {
        options = {
            { text = "1", action = function() g.config.startingLives = 1 end },
            { text = "3", action = function() g.config.startingLives = 3 end },
            { text = "5", action = function() g.config.startingLives = 5 end },
        }
    },
    {
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
        options = {
            { text = "10000", action = function() g.config.freeGuy = 1 end },
            { text = "20000", action = function() g.config.freeGuy = 2 end },
            { text = "every 10k", action = function() g.config.freeGuy = 3 end },
            { text = "none", action = function() g.config.freeGuy = 4 end },
        }
    },
    {
        options = {
            { text = "On", action = function() g.config.hardMode = true end },
            { text = "Off", action = function() g.config.hardMode = false end },
        }
    },
    {
        options = {
            { text = "No", action = function() g.config.afterDark = false end },
            { text = "Maze", action = function() g.config.afterDark = 1 end },
            { text = "Dots", action = function() g.config.afterDark = 2 end },
            { text = "Both", action = function() g.config.afterDark = 3 end },
            { text = "All", action = function() g.config.afterDark = 4 end },
        }
    },
    {
        options = {
            { text = "Yes", action = function() g.config.pinkyBug = true end },
            { text = "No", action = function() g.config.pinkyBug = false end },
        },
    },
    {
        options = {
            { text = "Normal", action = function() g.config.scatterOption = false end },
            { text = "Random", action = function() g.config.scatterOption = 1 end },
            { text = "None", action = function() g.config.scatterOption = 2 end },
        },
    },
    {
        options = {
            { text = "Yes", action = function() g.config.freeGhost = true end },
            { text = "No", action = function() g.config.freeGhost = false end },
        }
    },
    {
        options = {
            { text = "Yes", action = function() g.config.fastPac = true end },
            { text = "No", action = function() g.config.fastPac = false end },
        },
    },
    {
        options = {
            { text = "Yes", action = function() g.config.phasing = true end },
            { text = "No", action = function() g.config.phasing = false end },
        },
    },
    {
        options = {
            { text = "0", action = function() g.config.extraGhosts = 0 end },
            { text = "1", action = function() g.config.extraGhosts = 1 end },
            { text = "2", action = function() g.config.extraGhosts = 2 end },
            { text = "3", action = function() g.config.extraGhosts = 3 end },
        }
    },
    {
        options = {
            { text = "None", action = function() g.config.background = "none"; g.currentBackground = "none" end },
            { text = "Stars", action = function() g.config.background = "stars"; g.currentBackground = "stars" end },
            { text = "Beach", action = function() g.config.background = "beach"; g.currentBackground = "beach" end },
            { text = "Arcade", action = function() g.config.background = "arcade"; g.currentBackground = "arcade" end },
            { text = "Forest", action = function() g.config.background = "forest"; g.currentBackground = "forest" end },
            { text = "Canyon", action = function() g.config.background = "canyon"; g.currentBackground = "canyon" end },
            { text = "Clouds", action = function() g.config.background = "clouds"; g.currentBackground = "clouds" end },
            { text = "Abstract", action = function() g.config.background = "abstract"; g.currentBackground = "abstract" end },
            { text = "Wave1", action = function() g.config.background = "wave1"; g.currentBackground = "wave1" end },
            { text = "Wave2", action = function() g.config.background = "wave2"; g.currentBackground = "wave2" end },
            { text = "Lines", action = function() g.config.background = "lines"; g.currentBackground = "lines" end },
            { text = "Retro", action = function() g.config.background = "retro"; g.currentBackground = "retro" end },
            { text = "Xmas", action = function() g.config.background = "xmas"; g.currentBackground = "xmas" end },
            { text = "Random", action = function() g.config.background = "random"; g.currentBackground = backgroundOptions[math.random(2, #backgroundOptions)] end },
        },
    },
    {
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
            { text = "Random", action = function() g.config.mazeColor = 0 end },
        }
    },
    {
        options = {
            { text = "Yes", action = function() 
                g.config.fullscreen = true
                local _, _, flags = love.window.getMode()
                local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
                love.window.setMode(desktopWidth, desktopHeight, {
                    borderless = true
                })
                resizeCanvases()
            end },
            { text = "No", action = function() 
                g.config.fullscreen = false
                love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption, {resizable = true})
                resizeCanvases()
            end },
        }
    },
    {
        options = {
            { text = "Yes", action = function() g.config.crtEffect = true; resizeCanvases() end },
            { text = "No", action = function() g.config.crtEffect = false; resizeCanvases() end },
        }
    },
    {
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
        x = 3, y = 23,
        action = function()
            saveConfig()
        end
    },
    {
        text = "Restore Defaults",
        sound = "phase",

        x = 5, y = 25,
        action = function()
            resetConfigs()
            options.resetSelectedOptions()
            saveConfig()
        end
    },
    {
        text = "Reset High Score",
        sound = "phase",

        x = 5, y = 27,
        action = function()
            -- Overwrite the file with empty string to reset it
            love.filesystem.write("player.dat", "")
            g.highScore = false
        end
    },
    {
        text = "Back",
        x = 11, y = 29,
        action = function()
            setScene("attract")
        end
    }
}

function options.resetSelectedOptions(fullscreenOnly)

    if fullscreenOnly then
        menu[14].selectedOption = g.config.fullscreen and 1 or 2
        return
    end
    
    menu[1].selectedOption = g.config.maze == "random" and 4 or g.config.maze == "pac" and 1 or g.config.maze == "mspac1" and 2 or g.config.maze == "booze1" and 3
    menu[2].selectedOption = g.config.startingLives == 1 and 1 or g.config.startingLives == 3 and 2 or g.config.startingLives == 5 and 3
    menu[3].selectedOption = g.config.startingLevel
    menu[4].selectedOption = g.config.freeGuy
    menu[5].selectedOption = g.config.hardMode and 1 or 2
    menu[6].selectedOption = g.config.afterDark == false and 1 or g.config.afterDark == 1 and 2 or g.config.afterDark == 2 and 3 or g.config.afterDark == 3 and 4 or g.config.afterDark == 4 and 5
    menu[7].selectedOption = g.config.pinkyBug and 1 or 2
    menu[8].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[9].selectedOption = g.config.freeGhost and 1 or 2
    menu[10].selectedOption = g.config.fastPac and 1 or 2
    menu[11].selectedOption = g.config.phasing and 1 or 2
    menu[12].selectedOption = g.config.extraGhosts + 1
    menu[13].selectedOption = g.config.background == "random" and 14 or getBackgroundIndex()
    menu[14].selectedOption = g.config.mazeColor == 99 and 1 or g.config.mazeColor == 0 and maze.maxColors or g.config.mazeColor + 1
    menu[15].selectedOption = g.config.fullscreen and 1 or 2
    menu[16].selectedOption = g.config.crtEffect and 1 or 2
    menu[17].selectedOption = g.config.volume + 1

    for i = 1, #menu do
        if menu[i].options then
            menu[i].options[menu[i].selectedOption].action()
        end
    end
end

function options.start()
    menu[1].selectedOption = g.config.maze == "random" and 4 or g.config.maze == "pac" and 1 or g.config.maze == "mspac1" and 2 or g.config.maze == "booze1" and 3
    menu[2].selectedOption = g.config.startingLives == 1 and 1 or g.config.startingLives == 3 and 2 or g.config.startingLives == 5 and 3
    menu[3].selectedOption = g.config.startingLevel
    menu[4].selectedOption = g.config.freeGuy
    menu[5].selectedOption = g.config.hardMode and 1 or 2
    menu[6].selectedOption = g.config.afterDark == false and 1 or g.config.afterDark == 1 and 2 or g.config.afterDark == 2 and 3 or g.config.afterDark == 3 and 4 or g.config.afterDark == 4 and 5
    menu[7].selectedOption = g.config.pinkyBug and 1 or 2
    menu[8].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[9].selectedOption = g.config.freeGhost and 1 or 2
    menu[10].selectedOption = g.config.fastPac and 1 or 2
    menu[11].selectedOption = g.config.phasing and 1 or 2
    menu[12].selectedOption = g.config.extraGhosts + 1
    menu[13].selectedOption = g.config.background == "random" and 14 or getBackgroundIndex()
    menu[14].selectedOption = g.config.mazeColor == 99 and 1 or g.config.mazeColor == 0 and maze.maxColors or g.config.mazeColor + 1
    menu[15].selectedOption = g.config.fullscreen and 1 or 2
    menu[16].selectedOption = g.config.crtEffect and 1 or 2
    menu[17].selectedOption = g.config.volume + 1
    menu.selectedItem = 1
end

function options.update(dt)
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

    graphics.print("options", 10, 3, 3)
    graphics.print("Maze", 2, 5)
    graphics.print("Starting Lives", 2, 6)
    graphics.print("Starting Level", 2, 7)
    graphics.print("extra life", 2, 8)
    graphics.print("Hard Mode", 2, 9)
    graphics.print("Blindfold", 2, 10)
    graphics.print("Pinky Bug", 2, 11)
    graphics.print("Scatter", 2, 12)
    graphics.print("Free Ghosts", 2, 13)
    graphics.print("Fast Pac", 2, 14)
    graphics.print("Phasing", 2, 15)
    graphics.print("Extra Ghosts", 2, 16)
    graphics.print("Background", 2, 17)
    graphics.print("Maze Style", 2, 18)
    graphics.print("Full screen", 2, 19)
    graphics.print("CRT Effect", 2, 20)
    graphics.print("Volume", 2, 21)
    menus.draw(menu, 18, 5, 1)

    if g.config.mazeColor > 0 and g.config.mazeColor < 99 then 
        graphics.drawSpriteAtTile("spr8", g.config.mazeColor + 2, 21, 18)
    end

    graphics.print("up/down to select", 4, 32, 2)
    graphics.print("left/right to change", 3, 33, 2)
    love.graphics.setCanvas()

end

return options