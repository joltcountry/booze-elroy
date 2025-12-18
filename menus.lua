local menus = {}
local graphics = require("graphics")
local mode = require("mode")

local function wakka()
    if g.wakka then
        g.sounds.wakka2:play()
        g.wakka = false
    else
        g.sounds.wakka1:play()
        g.wakka = true
    end
end

menus.main = {
    {
        text = "Play",
        x = 10, y = 25,
        action = function()
            g.autoplay = false
            mode.setMode("play")
        end
    },
    {
        x = 10, y = 26,
        text = "Options",
        action = function()
            setScene("options")
        end
    },
    {
        x = 10, y = 27,
        text = "Credits",
        action = function()
            setScene("credits")
        end
    },
    {
        x = 10, y = 28,
        text = "Exit",
        action = function()
            love.event.quit()
        end
    },
    {
        text = "Autoplay",
        x = 10, y = 30,
        action = function()
            g.autoplay = true
            mode.setMode("play")
        end
    },
}

menus.credits = {
    {
        text = "Back",
        action = function()
            setScene("attract")
        end
    },
}

local confirm = function(menu)
    if menu[menu.selectedItem].text and menu[menu.selectedItem].text == "Play" then
        g.sounds.coindrop:stop()
        g.sounds.coindrop:play()
    else
        if menu[menu.selectedItem].sound then
            g.sounds[menu[menu.selectedItem].sound]:play()
        else
            wakka()
        end
    end
    if menu[menu.selectedItem].options then
        menu.selectedItem = menu.selectedItem + 1
        if menu.selectedItem < 1 then menu.selectedItem = #menu end
        if menu.selectedItem > #menu then menu.selectedItem = 1 end
    else
        menu[menu.selectedItem].action()
    end
end

local up = function(menu)
    wakka()
    menu.selectedItem = menu.selectedItem - 1
end

local down = function(menu)
    wakka()
    menu.selectedItem = menu.selectedItem + 1
end

local left = function(menu)
    if menu[menu.selectedItem].options then
        wakka()
            menu[menu.selectedItem].selectedOption = menu[menu.selectedItem].selectedOption - 1
        if menu[menu.selectedItem].selectedOption < 1 then menu[menu.selectedItem].selectedOption = #menu[menu.selectedItem].options end
        menu[menu.selectedItem].options[menu[menu.selectedItem].selectedOption].action()
    end
end

local right = function(menu)
    wakka()
    if menu[menu.selectedItem].options then
        menu[menu.selectedItem].selectedOption = menu[menu.selectedItem].selectedOption + 1
        if menu[menu.selectedItem].selectedOption > #menu[menu.selectedItem].options then menu[menu.selectedItem].selectedOption = 1 end
        menu[menu.selectedItem].options[menu[menu.selectedItem].selectedOption].action()
    else
        confirm(menu)
    end
end

menus.gamepadpressed = function(menu, button)
    if button == "dpup"  then
        up(menu)
    elseif button == "dpdown" then
        down(menu)
    elseif button == "dpleft" then
        left(menu)
    elseif button == "dpright" then
        right(menu)
    end
    if menu.selectedItem < 1 then menu.selectedItem = #menu end
    if menu.selectedItem > #menu then menu.selectedItem = 1 end
    if button == "a" then
        confirm(menu)
    end

end

menus.keypressed = function(menu, key)
    if key == "up" then
        up(menu)
    elseif key == "down" then
        down(menu)
    elseif key == "left" then
        left(menu)
    elseif key == "right" then
        right(menu)
    end
    if menu.selectedItem < 1 then menu.selectedItem = #menu end
    if menu.selectedItem > #menu then menu.selectedItem = 1 end
    if key == "return" then
        confirm(menu)
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
            graphics.print(item.text, item.x or x, item.y or (y + i * spacing), color)
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