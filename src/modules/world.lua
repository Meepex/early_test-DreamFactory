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

function world_table:save_world()
    --EXPERIMENTAL.TODO("Implement converting world data to bytes")

    WORLD_SAVER.add_magic_number(self.saverBuffer)
    WORLD_SAVER.add_header(self.saverBuffer, 1, 0, 0)

    for i = 1, #self.worldData do
        WORLD_SAVER.add_block(self.saverBuffer, current)
    end

    WORLD_SAVER.write_file("build/worldData/test.bin", self.saverBuffer)
end

function world_table:update(game_table, dt)
    game_table.renderer:add_to_3Drender_queue("world", {type = "testing_place"})
end

return(world_table)