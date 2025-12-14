local utils = {}
-- Helper function to activate frightened mode
utils.activateFrightenedMode = function()
    local logic = require("logic")
    g.frightened = g.level.frightened
    g.ghostScore = false
    g.chars.pac.speed = g.level.pacFrightenedSpeed
    if not g.sounds.scared:isPlaying( ) then
		love.audio.play( g.sounds.scared )
        stopSiren()
	end
    for name, char in pairs(g.chars) do
        if char.target and not char.dead then
            char.frightened = true
            char.speed = logic.getGhostSpeed(char)
            if not char.housing and not char.leaving and not char.entering then
                char.dir = (char.dir + 2) % 4
                char:target()
            end
        end
    end
end

return utils