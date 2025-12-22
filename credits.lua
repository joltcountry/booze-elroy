local credits = {
    name = "credits"
}

local graphics = require("graphics")
local menus = require("menus")
local animations = require("animations")
local menu = menus.credits

booze = {
    x = 112,
    y = 35,
    dir = 0,
    speed = 0,
    animator = function() return animations.booze end
}

local fc
function credits.start()
    menu.selectedItem = 1
    fc = 0
end

function credits.update(dt)
    fc = fc + 1
    graphics.updateAnimation(booze, fc)
end

function credits.keypressed(key)
    menus.keypressed(menu, key)
end

function credits.gamepadpressed(joystick, button)
    menus.gamepadpressed(menu, button)
end

function credits.update(dt)
    menus.update(menu, dt)
end

function credits.draw()

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.origin()

    if not g.currentBackground then g.currentBackground = g.config.background end
    if g.backgrounds[g.currentBackground] then
        love.graphics.setColor(.4, .4, .4)
        love.graphics.draw(g.backgrounds[g.currentBackground], 0, 0, 0, 224 / g.backgrounds[g.currentBackground]:getWidth(), 288  / g.backgrounds[g.currentBackground]:getHeight())
        love.graphics.setColor(1, 1, 1)
    end

    local msg1 = "booze elroy"
    local msg2 = "designed and developed by"
    local msg3 = "pinback"
    local msg4 = "joystick support by"
    local msg5 = "ice cream jonsey"
    local msg6 = "special thanks to"
    local msg7 = "dj larry"
    local msg8 = "the beefer"
    local msg10 = "based on"
    local msg11 = "by toru iwatani"
    -- Draw score
    graphics.print("1up", 3, 0)
    graphics.print("high score", 9, 0)
    graphics.print(formatScore(g.score or 0), 0, 1, 0)
    if g.highScore then
        graphics.print(formatScore(g.highScore), 10, 1)
    end

    graphics.print(msg1, 14 - string.len(msg1) / 2, 7, 3)
    graphics.print(msg2, 14 - string.len(msg2) / 2, 9)
    graphics.print(msg3, 14 - string.len(msg3) / 2, 11, 4)
    graphics.print(msg4, 14 - string.len(msg4) / 2, 14)
    graphics.print(msg5, 14 - string.len(msg5) / 2, 16, 4)
    graphics.print(msg6, 14 - string.len(msg6) / 2, 19)
    graphics.print(msg7, 14 - string.len(msg7) / 2, 21, 4)
    graphics.print(msg8, 14 - string.len(msg8) / 2, 23, 4)
    graphics.print(msg10, 14 - string.len(msg10) / 2, 26)
    graphics.print("pac-man", 2.5, 28, 6)
    graphics.print(msg11, 10.5, 28)
    
    menus.draw(menus.credits, 12, 30)
    graphics.drawChar(booze, booze.x, booze.y)
    love.graphics.setCanvas()

end

return credits