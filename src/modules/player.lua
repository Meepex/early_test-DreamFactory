local player_table = {}
player_table.__index = player_table
player_table.__type  = "player_table"

function player_table.init(camera)
    local meta = setmetatable({}, player_table)
    
    meta.camera = camera
    meta.enabled_statistics = false

    return(meta)
end

function player_table:update(game_table, dt)
    if game_table.raylib.IsKeyPressed(game_table.raylib.KEY_X) then
        self.enabled_statistics = not self.enabled_statistics  
    end

    local a = true

    if self.enabled_statistics then
        game_table.renderer:add_to_2Drender_queue("player", {type = "statistics"})
    end
    
    if game_table.game_state == "World" then
        
    end
end

return(player_table)