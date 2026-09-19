local EXPERIMENTAL = require("src.modules.experimental.experimental")

local renderer_request = {}
renderer_request["a3D"] = {}
renderer_request["a2D"] = {}

function renderer_request.a3D.find_and_run(tasker, data, rendererContext)
    if tasker == "world" then
        if data.type == "testing_place" then
            rendererContext.raylib.DrawCube(rendererContext.raylib.Vector3({0,0,0}), 2.0, 2.0, 2.0, rendererContext.raylib.RED);
            rendererContext.raylib.DrawCubeWires(rendererContext.raylib.Vector3({0,0,0}), 2.0, 2.0, 2.0, rendererContext.raylib.MAROON);

            rendererContext.raylib.DrawGrid(10, 1.0);

            return true
        end
    end

    print(EXPERIMENTAL.format_output_message("WARN", "renderer->renderer_requests", "got a 3D render request, but it was not recognized: tasker: "..tasker.." data.type: "..data.type))
    return false
end

function renderer_request.a2D.find_and_run(tasker, data, rendererContext)
    if tasker == "player" then
        if data.type == "fps" then
            rendererContext.raylib.DrawFPS(10, 10)
            return true
        end
    end

    print(EXPERIMENTAL.format_output_message("WARN", "renderer->renderer_requests", "got a 2D render request, but it was not recognized: tasker: "..tasker.." data.type: "..data.type))
    return false
end

return(renderer_request)