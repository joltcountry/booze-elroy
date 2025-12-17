local menus = {}
local graphics = require("graphics")
local mode = require("mode")

menus.main = {
    {
        text = "Play",
        action = function()
            mode.setMode("play")
        end
    },
    {
        text = "Options",
        action = function()
            setScene("options")
        end
    },
    {
        text = "Reset High Score",
        action = function()
            scoreFile:seek(0)  -- Seek to beginning
            scoreFile:write("")
            scoreFile:flush()
            g.highScore = false
        end
    },
    {
        text = "Credits",
        action = function()
            setScene("credits")
        end
    },
    {
        text = "Exit",
        action = function()
            love.event.quit()
        end
    }
}

menus.credits = {
    {
        text = "Back",
        action = function()
            setScene("attract")
        end
    },
}

menus.keypressed = function(menu, key)
    if key == "up" then
        g.sounds.coindrop:stop()
        g.sounds.coindrop:play()
        menu.selectedItem = menu.selectedItem - 1
    elseif key == "down" then
        g.sounds.coindrop:stop()
        g.sounds.coindrop:play()
        menu.selectedItem = menu.selectedItem + 1
    elseif key == "left" then
        g.sounds.coindrop:stop()
        g.sounds.coindrop:play()
        if menu[menu.selectedItem].options then
            menu[menu.selectedItem].selectedOption = menu[menu.selectedItem].selectedOption - 1
            if menu[menu.selectedItem].selectedOption < 1 then menu[menu.selectedItem].selectedOption = #menu[menu.selectedItem].options end
            menu[menu.selectedItem].options[menu[menu.selectedItem].selectedOption].action()
        end
    elseif key == "right" then
        g.sounds.coindrop:stop()
        g.sounds.coindrop:play()
        if menu[menu.selectedItem].options then
            menu[menu.selectedItem].selectedOption = menu[menu.selectedItem].selectedOption + 1
            if menu[menu.selectedItem].selectedOption > #menu[menu.selectedItem].options then menu[menu.selectedItem].selectedOption = 1 end
            menu[menu.selectedItem].options[menu[menu.selectedItem].selectedOption].action()
        end
    end
    if menu.selectedItem < 1 then menu.selectedItem = #menu end
    if menu.selectedItem > #menu then menu.selectedItem = 1 end
    if key == "return" then
        if menu[menu.selectedItem].text and menu[menu.selectedItem].text ~= "Exit" then
            g.sounds.coindrop:stop()
            g.sounds.coindrop:play()
        end
        if menu[menu.selectedItem].options then
            menu.selectedItem = menu.selectedItem + 1
            if menu.selectedItem < 1 then menu.selectedItem = #menu end
            if menu.selectedItem > #menu then menu.selectedItem = 1 end
        else
            menu[menu.selectedItem].action()
        end
    end

end

menus.draw = function(menu, x, y, spacing)
    spacing = spacing or 2
    x = x or 10
    y = y or 0
    for i, item in ipairs(menu) do
        local color = 0
        if menu.selectedItem == i then color = 1 end
        if item.text then
            graphics.print(item.text, x, y + i * spacing, color)
        elseif item.options then
            for j, option in ipairs(item.options) do
                if item.selectedOption == j then
                    graphics.print(option.text, x, y + (i - 1) * spacing, color)
                end
            end
        end                                                                 
    end
end

return menus