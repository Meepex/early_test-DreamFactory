local player_table = {}
player_table.__index = player_table
player_table.__type  = "player_table"

local JUMP_FORCE = 10

function player_table.init(camera)
    local meta = setmetatable({}, player_table)
    
    meta.camera = camera
    meta.velocity_y = 0
    meta.on_ground = true
    meta.enabled_statistics = false

    return(meta)
end

function process_input(playerContext, game_table)
    if game_table.raylib.IsKeyPressed(game_table.raylib.KEY_X) then
        playerContext.enabled_statistics = not playerContext.enabled_statistics  
    end

    if playerContext.on_ground and rl.IsKeyPressed(rl.KEY_SPACE) and game_table.game_state == "World" then
        playerContext.velocity_y = JUMP_FORCE
        playerContext.on_ground = false
    end
end

function process_gravity(playerContext, game_table, dt)
    if playerContext.camera.position.y > game_table.player_collision_y then
        playerContext.on_ground = false
    end

    if not playerContext.on_ground then
        local velocity = playerContext.velocity_y - game_table.gravity * dt

        --Limit max Y velocity to 20 or -20
        if math.abs(velocity) >= 20 then
            velocity = velocity < 0 and -20 or 20
        end

        playerContext.velocity_y = velocity
        playerContext.camera.position.y = playerContext.camera.position.y + playerContext.velocity_y * dt
        playerContext.camera.target.y = playerContext.camera.target.y + playerContext.velocity_y * dt
    end

    if playerContext.camera.position.y <= game_table.player_collision_y then
        playerContext.camera.position.y = game_table.player_collision_y
        playerContext.velocity_y = 0
        playerContext.on_ground = true
    end
end

function process_statistics(playerContext, game_table)
    if playerContext.enabled_statistics then
        game_table.renderer:add_to_2Drender_queue("player", {type = "statistics"})
    end
end

function player_table:standing_update(onGroup)
    self.on_ground = onGroup
end

function player_table:update(game_table, dt)
    process_input(self, game_table)

    --Other proccesses
    process_gravity(self, game_table, dt)
    process_statistics(self, game_table)
    
end

return(player_table)