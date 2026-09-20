local EXPERIMENTAL = require("src.modules.experimental.experimental")

local renderer_request = {}
renderer_request["a3D"] = {}
renderer_request["a2D"] = {}

function renderer_request.a3D.find_and_run(tasker, data, rendererContext)
    if tasker == "world" then
        if data.type == "testing_place" then
            --rendererContext.table.raylib.DrawCube(rendererContext.table.raylib.Vector3({0,0,0}), 2.0, 2.0, 2.0, rendererContext.table.raylib.RED);
            --rendererContext.table.raylib.DrawCubeWires(rendererContext.table.raylib.Vector3({0,0,0}), 2.0, 2.0, 2.0, rendererContext.table.raylib.MAROON);

            rendererContext.table.raylib.DrawGrid(500, 1);

            return true
        elseif data.type == "block" then
            local pos, size = data.position, data.size

            rendererContext.table.raylib.DrawCube(pos, size.x, size.y, size.z, rendererContext.table.raylib.RED);
            rendererContext.table.raylib.DrawCubeWires(pos, size.x, size.y, size.z, rendererContext.table.raylib.MAROON);

            return true
        end
    end

    print(EXPERIMENTAL.format_output_message("WARN", "renderer->renderer_requests", "got a 3D render request, but it was not recognized: tasker: "..tasker.." data.type: "..data.type))
    return false
end

function renderer_request.a2D.find_and_run(tasker, data, rendererContext)
    if tasker == "player" then
        if data.type == "statistics" then
            --void DrawText(const char *text, int posX, int posY, int fontSize, Color color);--
            rendererContext.table.raylib.DrawFPS(10, 10)
            rendererContext.table.raylib.DrawText("Game State: "..rendererContext.table.game_state, 10, 35, 20, rendererContext.table.raylib.BLACK)
            --[[
            rendererContext.table.raylib.DrawText(
                "Position: x="..rendererContext.camera.position.x..
                " y="..rendererContext.camera.position.y..
                " z="..rendererContext.camera.position.z
                , 10, 60, 20, rendererContext.table.raylib.BLACK)
            ]]
            do --Position Rendering
                rendererContext.table.raylib.DrawText("Position:", 10, 60, 20, rendererContext.table.raylib.BLACK)
                rendererContext.table.raylib.DrawText("x="..rendererContext.camera.position.x, 100, 60, 20, rendererContext.table.raylib.BLACK)
                rendererContext.table.raylib.DrawText("y="..rendererContext.camera.position.y, 100, 85, 20, rendererContext.table.raylib.BLACK)
                rendererContext.table.raylib.DrawText("z="..rendererContext.camera.position.z, 100, 110, 20, rendererContext.table.raylib.BLACK)
            end
            return true
        end
    end

    print(EXPERIMENTAL.format_output_message("WARN", "renderer->renderer_requests", "got a 2D render request, but it was not recognized: tasker: "..tasker.." data.type: "..data.type))
    return false
end

return(renderer_request)