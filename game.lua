-- Game logic and fixed timestep updates

local game = {}

-- Game state variables
local frameCount = 0

function game.update(dt)
    -- Called every fixed timestep (60 FPS)
    frameCount = frameCount + 1
end

function game.getFrameCount()
    return frameCount
end

return game

