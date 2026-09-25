local player_table = {}
player_table.__index = player_table
player_table.__type  = "player_table"

local JUMP_FORCE = 10
local FLOOR = 2 --temp--

function player_table.init(camera)
    local meta = setmetatable({}, player_table)
    
    meta.camera = camera
    meta.velocity_y = 0
    meta.on_ground = true
    meta.enabled_statistics = false

    return(meta)
end

function player_table:standing_update(onGroup)
    self.on_ground = onGroup
end

function player_table:update(game_table, dt)
    if game_table.raylib.IsKeyPressed(game_table.raylib.KEY_X) then
        self.enabled_statistics = not self.enabled_statistics  
    end

    if self.on_ground and rl.IsKeyPressed(rl.KEY_SPACE) then
        self.velocity_y = JUMP_FORCE
        self.on_ground = false
    end

    if not self.on_ground then
        self.velocity_y = self.velocity_y - game_table.gravity * dt
        self.camera.position.y = self.camera.position.y + self.velocity_y * dt
        self.camera.target.y = self.camera.target.y + self.velocity_y * dt
    end

    if self.camera.position.y <= FLOOR then
        self.camera.position.y = FLOOR
        self.velocity_y = 0
        self.on_ground = true
    end

    if self.enabled_statistics then
        game_table.renderer:add_to_2Drender_queue("player", {type = "statistics"})
    end
    
    if game_table.game_state == "World" then
        
    end
end

return(player_table)