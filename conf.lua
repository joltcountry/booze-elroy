-- Love2D Configuration File

function love.conf(t)
    t.title = "Booze Elroy"
    t.author = "Pinback"
    t.version = "11.5"
    
    t.identity = "booze-elroy"

    t.window.width = 1440
    t.window.height = 1080
    t.window.resizable = true
    t.window.minwidth = 400
    t.window.minheight = 300
    t.window.vsync = false
    t.console = true
    t.modules.joystick = true
    t.modules.physics = false
end

