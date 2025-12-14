local menus = {}
local graphics = require("graphics")

menus.main = {
    {
        text = "Play",
        action = function()
            setScene("game")
        end
    },
    {
        text = "Options",
        action = function()
            setScene("options")
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
    end
    if menu.selectedItem < 1 then menu.selectedItem = #menu end
    if menu.selectedItem > #menu then menu.selectedItem = 1 end
    if key == "return" then
        g.sounds.coindrop:stop()
        g.sounds.coindrop:play()
        if menu[menu.selectedItem].options then
            menu[menu.selectedItem].selectedOption = menu[menu.selectedItem].selectedOption + 1
            if menu[menu.selectedItem].selectedOption > #menu[menu.selectedItem].options then menu[menu.selectedItem].selectedOption = 1 end
            menu[menu.selectedItem].options[menu[menu.selectedItem].selectedOption].action()
        else
            menu[menu.selectedItem].action()
        end
    end

end

menus.draw = function(menu, x, y)
    x = x or 10
    y = y or 0
    for i, item in ipairs(menu) do
        local color = 0
        if menu.selectedItem == i then color = 1 end
        if item.text then
            graphics.print(item.text, x, y + i * 2, color)
        elseif item.options then
            for j, option in ipairs(item.options) do
                if item.selectedOption == j then
                    graphics.print(option.text, x, y + (i - 1) * 2, color)
                end
            end
        end                                                                 
    end
end

return menus