local options = {
    name = "options"
}

local graphics = require("graphics")
local menus = require("menus")
local animations = require("animations")
local menus = require("menus")

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
            { text = "Tiny", action = function() 
                g.scaleOption = 2
                love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption)
                resizeCanvases()
             end
            },
            { text = "Small", action = function() 
                g.scaleOption = 3
                love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption)
                resizeCanvases()
             end
            },
            { text = "Medium", action = function()
                g.scaleOption = 4
                love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption)
                resizeCanvases()
            end
            },
            { text = "Large", action = function()
                g.scaleOption = 5
                love.window.setMode(224 * g.scaleOption, 288 * g.scaleOption)
                resizeCanvases()
            end
            },
        }
    },
    {
        text = "Back",
        action = function()
            setScene("attract")
        end
    }
}
function options.start()
    menu[1].selectedOption = g.config.pinkyBug and 1 or 2
    menu[2].selectedOption = g.config.fastPac and 1 or 2
    menu[3].selectedOption = g.config.background == "none" and 1 or g.config.background == "stars" and 2 or g.config.background == "beach" and 3 or g.config.background == "arcade" and 4
    menu[4].selectedOption = g.config.scatterOption == false and 1 or g.config.scatterOption == 1 and 2 or g.config.scatterOption == 2 and 3
    menu[5].selectedOption = g.scaleOption == 2 and 1 or g.scaleOption == 3 and 2 or g.scaleOption == 4 and 3 or g.scaleOption == 5 and 4
    menu[6].selectedOption = g.config.freeGhost and 1 or 2
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


    -- Draw score
    graphics.print("1up", 3, 0)
    graphics.print("high score", 9, 0)
    graphics.print(formatScore(g.score or 0), 0, 1, 0)
    if g.highScore then
        graphics.print(formatScore(g.highScore), 10, 1)
    end

    graphics.print("options", 10, 5, 3)
    graphics.print("Pinky Bug", 5, 10)
    graphics.print("Fast Pac", 5, 11)
    graphics.print("Background", 5, 12)
    graphics.print("Scatter", 5, 13)
    graphics.print("Free Ghosts", 5, 14)
    graphics.print("Window Size", 5, 15)
    menus.draw(menu, 18, 10, 1)

    graphics.print("arrows to select", 5, 25, 2)
    graphics.print("enter to change", 5, 26, 2)
    love.graphics.setCanvas()

end

return options