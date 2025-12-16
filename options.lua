local options = {
    name = "options"
}

local graphics = require("graphics")
local menus = require("menus")
local animations = require("animations")
local menus = require("menus")
local maze = require("maze")

local gw, gh = 224, 288

local menu = {
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
            { text = "None", action = function() g.config.background = "none" end },
            { text = "Stars", action = function() g.config.background = "stars" end },
            { text = "Beach", action = function() g.config.background = "beach" end },
            { text = "Arcade", action = function() g.config.background = "arcade" end },
            { text = "Forest", action = function() g.config.background = "forest" end },
            { text = "Abstract", action = function() g.config.background = "abstract" end },
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
                g.fullscreen = true
                local _, _, flags = love.window.getMode()
                local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
                love.window.setMode(desktopWidth, desktopHeight, {
                    borderless = true
                })
                resizeCanvases()
            end },
            { text = "No", action = function() 
                g.fullscreen = false
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
        text = "Back",
        action = function()
            setScene("attract")
        end
    }
}

function options.resetSelectedOptions()
    menu[1].selectedOption = g.config.pinkyBug and 1 or 2
    menu[2].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[3].selectedOption = g.config.freeGhost and 1 or 2
    menu[4].selectedOption = g.config.fastPac and 1 or 2
    menu[5].selectedOption = g.config.background == "none" and 1 or g.config.background == "stars" and 2 or g.config.background == "beach" and 3 or g.config.background == "arcade" and 4 or g.config.background == "forest" and 5 or g.config.background == "abstract" and 6
    menu[6].selectedOption = g.config.mazeColor
    menu[7].selectedOption = g.fullscreen and 1 or 2
    menu[8].selectedOption = g.config.crtEffect and 1 or 2
    menu[9].selectedOption = g.config.volume + 1
end

function options.start()
    menu[1].selectedOption = g.config.pinkyBug and 1 or 2
    menu[2].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[3].selectedOption = g.config.freeGhost and 1 or 2
    menu[4].selectedOption = g.config.fastPac and 1 or 2
    menu[5].selectedOption = g.config.background == "none" and 1 or g.config.background == "stars" and 2 or g.config.background == "beach" and 3 or g.config.background == "arcade" and 4 or g.config.background == "forest" and 5 or g.config.background == "abstract" and 6
    menu[6].selectedOption = g.config.mazeColor
    menu[7].selectedOption = g.fullscreen and 1 or 2
    menu[8].selectedOption = g.config.crtEffect and 1 or 2
    menu[9].selectedOption = g.config.volume + 1
    menu.selectedItem = 1
end

function options.update(dt)
end

function options.keypressed(key)
    menus.keypressed(menu, key)
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
    graphics.print("Pinky Bug", 5, 10)
    graphics.print("Scatter", 5, 11)
    graphics.print("Free Ghosts", 5, 12)
    graphics.print("Fast Pac", 5, 13)
    graphics.print("Background", 5, 14)
    graphics.print("Maze Color", 5, 15)
    graphics.print("Full screen", 5, 16)
    graphics.print("CRT Effect", 5, 17)
    graphics.print("Volume", 5, 18)
    menus.draw(menu, 18, 10, 1)

    graphics.drawSpriteAtTile("spr8", g.config.mazeColor + 2, 20, 15)
    graphics.print("up/down to select", 5, 25, 2)
    graphics.print("left/right to change", 5, 27, 2)
    love.graphics.setCanvas()

end

return options