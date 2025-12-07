-- Love2D Configuration File

function love.conf(t)
    t.title = "Love2D App"
    t.author = "Your Name"
    t.version = "11.5"
    
    t.window.width = 1440
    t.window.height = 900
    t.window.resizable = true
    t.window.minwidth = 400
    t.window.minheight = 300
    t.window.vsync = false
    t.console = true
    t.modules.joystick = false
    t.modules.physics = false
end

