local options = {
    name = "options"
}

local graphics = require("graphics")
local menus = require("menus")
local animations = require("animations")
local menus = require("menus")
local maze = require("maze")

local gw, gh = 224, 288

local backgroundOptions = { "none", "stars", "beach", "arcade", "forest", "canyon", "abstract", "retro","xmas" }

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
            { text = "1", action = function() g.config.startingLives = 1 end },
            { text = "3", action = function() g.config.startingLives = 3 end },
            { text = "5", action = function() g.config.startingLives = 5 end },
        }
    },
    {
        options = {
            { text = "10000", action = function() g.config.freeGuy = 1 end },
            { text = "20000", action = function() g.config.freeGuy = 2 end },
            { text = "every 10k", action = function() g.config.freeGuy = 3 end },
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
        }
    },
    {
        options = {
            { text = "None", action = function() g.config.background = "none" end },
            { text = "Stars", action = function() g.config.background = "stars" end },
            { text = "Beach", action = function() g.config.background = "beach" end },
            { text = "Arcade", action = function() g.config.background = "arcade" end },
            { text = "Forest", action = function() g.config.background = "forest" end },
            { text = "Canyon", action = function() g.config.background = "canyon" end },
            { text = "Abstract", action = function() g.config.background = "abstract" end },
            { text = "Retro", action = function() g.config.background = "retro" end },
            { text = "Xmas", action = function() g.config.background = "xmas" end },
        },
    },
    {
        options = {
            { text = "1", action = function() g.config.mazeColor = 1 end },
            { text = "2", action = function() g.config.mazeColor = 2 end },
            { text = "3", action = function() g.config.mazeColor = 3 end },
            { text = "4", action = function() g.config.mazeColor = 4 end },
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
            scoreFile:seek(0)  -- Seek to beginning
            scoreFile:write("")
            scoreFile:flush()
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

function options.resetSelectedOptions()
    menu[1].selectedOption = g.config.startingLives == 1 and 1 or g.config.startingLives == 3 and 2 or g.config.startingLives == 5 and 3
    menu[2].selectedOption = g.config.freeGuy
    menu[3].selectedOption = g.config.hardMode and 1 or 2
    menu[4].selectedOption = g.config.pinkyBug and 1 or 2
    menu[5].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[6].selectedOption = g.config.freeGhost and 1 or 2
    menu[7].selectedOption = g.config.fastPac and 1 or 2
    menu[8].selectedOption = g.config.phasing and 1 or 2
    menu[9].selectedOption = g.config.extraGhosts + 1
    menu[10].selectedOption = getBackgroundIndex()
    menu[11].selectedOption = g.config.mazeColor
    menu[12].selectedOption = g.config.fullscreen and 1 or 2
    menu[13].selectedOption = g.config.crtEffect and 1 or 2
    menu[14].selectedOption = g.config.volume + 1

    for i = 1, #menu do
        if menu[i].options then
            menu[i].options[menu[i].selectedOption].action()
        end
    end
end

function options.start()
    menu[1].selectedOption = g.config.startingLives == 1 and 1 or g.config.startingLives == 3 and 2 or g.config.startingLives == 5 and 3
    menu[2].selectedOption = g.config.freeGuy
    menu[3].selectedOption = g.config.hardMode and 1 or 2
    menu[4].selectedOption = g.config.pinkyBug and 1 or 2
    menu[5].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[6].selectedOption = g.config.freeGhost and 1 or 2
    menu[7].selectedOption = g.config.fastPac and 1 or 2
    menu[8].selectedOption = g.config.phasing and 1 or 2
    menu[9].selectedOption = g.config.extraGhosts + 1
    menu[10].selectedOption = getBackgroundIndex()
    menu[11].selectedOption = g.config.mazeColor
    menu[12].selectedOption = g.config.fullscreen and 1 or 2
    menu[13].selectedOption = g.config.crtEffect and 1 or 2
    menu[14].selectedOption = g.config.volume + 1
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

    if g.backgrounds[g.config.background] then
        love.graphics.setColor(.5, .5, .5)
        love.graphics.draw(g.backgrounds[g.config.background], 0, 0, 0, 224 / g.backgrounds[g.config.background]:getWidth(), 288  / g.backgrounds[g.config.background]:getHeight())
        love.graphics.setColor(1, 1, 1)
    end

    -- Draw score
    graphics.print("1up", 3, 0)
    graphics.print("high score", 9, 0)
    graphics.print(formatScore(g.score or 0), 0, 1, 0)
    if g.highScore then
        graphics.print(formatScore(g.highScore), 10, 1)
    end

    graphics.print("options", 10, 5, 3)
    graphics.print("Starting Lives", 2, 8)
    graphics.print("extra life", 2, 9)
    graphics.print("Hard Mode", 2, 10)
    graphics.print("Pinky Bug", 2, 11)
    graphics.print("Scatter", 2, 12)
    graphics.print("Free Ghosts", 2, 13)
    graphics.print("Fast Pac", 2, 14)
    graphics.print("Phasing", 2, 15)
    graphics.print("Extra Ghosts", 2, 16)
    graphics.print("Background", 2, 17)
    graphics.print("Maze Color", 2, 18)
    graphics.print("Full screen", 2, 19)
    graphics.print("CRT Effect", 2, 20)
    graphics.print("Volume", 2, 21)
    menus.draw(menu, 18, 8, 1)

    graphics.drawSpriteAtTile("spr8", g.config.mazeColor + 2, 20, 18)
    graphics.print("up/down to select", 4, 32, 2)
    graphics.print("left/right to change", 3, 33, 2)
    love.graphics.setCanvas()

end

return options