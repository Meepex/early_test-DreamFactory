local player_table = {}
player_table.__index = player_table
player_table.__type  = "player_table"

function player_table.init(camera)
    local meta = setmetatable({}, player_table)
    
    meta.camera = camera

    return(meta)
end

function player_table:update(game_table, dt)
    game_table.renderer:add_to_2Drender_queue("player", {type = "fps"})
end

return(player_table)