local EXPERIMENTAL = require("src.modules.experimental.experimental")
local RENDERER_REQUESTS = require("src.modules.utils.renderer_requests")

local renderer_table = {}
renderer_table.__index = renderer_table
renderer_table.__type  = "renderer_table"

function renderer_table.init(game_table, camera)
    local meta = setmetatable({}, renderer_table)
    
    meta.camera = camera
    meta.render_3Dqueue = {}
    meta.render_2Dqueue = {}
    meta.raylib = game_table.raylib

    return(meta)
end

--[[
function renderer_table:update(localGameTable, dt)
    
end
]]--

function renderer_table:add_to_3Drender_queue(tasker, task_data)
    self.render_3Dqueue[#self.render_3Dqueue+1] = {
        ["tasker"] = tasker,
        ["data"] = task_data
    }
end

function renderer_table:add_to_2Drender_queue(tasker, task_data)
    self.render_2Dqueue[#self.render_2Dqueue+1] = {
        ["tasker"] = tasker,
        ["data"] = task_data
    }
end

function renderer_table:render(dt)
    self.raylib.BeginDrawing()
    do
        self.raylib.ClearBackground(self.raylib.RAYWHITE)
        self.raylib.UpdateCamera(self.camera, 1); --CAMERA_FREE

        self.raylib.BeginMode3D(self.camera);
        do
            for key=1, #self.render_3Dqueue do
                local render_data  = self.render_3Dqueue[key]
                local tasker, data = render_data.tasker, render_data.data
                self.render_3Dqueue[key] = nil
                --print(EXPERIMENTAL.format_output_message("INFO", "render", "Rendering task from "..tasker.."."))

                RENDERER_REQUESTS["a3D"].find_and_run(tasker, data, self)
            end
        end
        self.raylib.EndMode3D();

        do
            for key=1, #self.render_2Dqueue do
                local render_data = self.render_2Dqueue[key]
                local tasker, data = render_data.tasker, render_data.data
                self.render_2Dqueue[key] = nil
                --print(EXPERIMENTAL.format_output_message("INFO", "render", "Rendering task from "..tasker.."."))
                
                RENDERER_REQUESTS["a2D"].find_and_run(tasker, data, self)
            end
        end
    end
    self.raylib.EndDrawing()
end

return(renderer_table)