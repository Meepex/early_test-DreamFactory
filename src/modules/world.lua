local WORLD_SAVER = require("src.modules.utils.worldSaver")
local EXPERIMENTAL = require("src.modules.experimental.experimental")

local world_table = {}
world_table.__index = world_table
world_table.__type  = "world_table"

function world_table.init()
    local meta = setmetatable({}, world_table)

    world_table.worldData = {}
    world_table.saverBuffer = {}

    return(meta)
end

local function request_block(game_table, pos)
    game_table.renderer:add_to_3Drender_queue("world", {
        type = "block", 
        position = game_table.raylib.Vector3(pos),
        size = game_table.raylib.Vector3({1, 1, 1})
    })
end

function world_table:save_world()
    --EXPERIMENTAL.TODO("Implement converting world data to bytes")

    WORLD_SAVER.add_magic_number(self.saverBuffer)
    WORLD_SAVER.add_header(self.saverBuffer, 1, 0, 0)

    local jumping = false
    local jumped_over = 0
    local lastBlock = nil
    for i = 1, #self.worldData do
        local block, futureBlock = self.worldData[i], self.worldData[1+i]

        if jumping then
            if block:get_id() ~= futureBlock:get_id() or block:get_facing() ~= futureBlock:get_facing() then
                jumping = false
                WORLD_SAVER.add_jump(self.saverBuffer, jumped_over)
                WORLD_SAVER.add_block(self.saverBuffer, block)
            else
                jumped_over = jumped_over+1
            end
        else
            if block:get_id() == futureBlock:get_id() and block:get_facing() == futureBlock:get_facing() then
                jumping = true
                lastBlock = block
                WORLD_SAVER.add_block(self.saverBuffer, block)
            end
        end
    end

    WORLD_SAVER.write_file("build/worldData/test.bin", self.saverBuffer)
end

function world_table:update(game_table, dt)
    game_table.renderer:add_to_3Drender_queue("world", {type = "testing_place"})

    for y = 1, 10, 1 do
        for x = -5, 5, 1 do
            for z = -5, 5, 1 do
                request_block(game_table, {x, y, z})
            end
        end
    end
end

return(world_table)