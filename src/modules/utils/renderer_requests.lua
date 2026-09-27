local EXPERIMENTAL = require("src.modules.experimental.experimental")

local renderer_request = {}
renderer_request["a3D"] = {}
renderer_request["a2D"] = {}

function renderer_request.a3D.prepare(rendererContext)
    local rl = rendererContext.table.raylib
    local mesh = rl.GenMeshCube(1, 1, 1)
    rl.UploadMesh(mesh, false);
    renderer_request.a3D.mesh_cube = mesh
end

function renderer_request.a3D.find_and_run(tasker, data, rendererContext)
    local rl = rendererContext.table.raylib

    if tasker == "world" then
        if data.type == "testing_place" then
            --EXPERIMENTAL.DEPRICATED("testing_place")
            --rl.DrawCube(rl.Vector3({0,0,0}), 2.0, 2.0, 2.0, rl.RED);
            --rl.DrawCubeWires(rl.Vector3({0,0,0}), 2.0, 2.0, 2.0, rl.MAROON);

            rl.DrawGrid(500, 1);

            return true
        elseif data.type == "block" then
            local pos, size, tint = rl.Vector3(data.position), rl.Vector3(data.size), data.tint or rl.RED

            rl.DrawCube(pos, size.x, size.y, size.z, tint);
            rl.DrawCubeWires(pos, size.x, size.y, size.z, rl.MAROON);

            return true
        elseif data.type == "block_mesh" then
            --Mesh GenMeshCube(float width, float height, float length);
            --void UploadMesh(Mesh *mesh, bool dynamic);
            --void DrawMesh(Mesh mesh, Material material, Matrix transform);
            --void UnloadMesh(Mesh mesh);
            local x, y, z = data.position[1], data.position[2], data.position[3]
            local material = data.material

            if not material or not rl.IsMaterialValid(material) then
                material = rl.LoadMaterialDefault()
            end

            rl.DrawMesh(renderer_request.a3D.mesh_cube, material, rl.MatrixTranslate(x, y, z));

            return true
        elseif data.type == "chunk_mesh" then
                
        end
    end

    print(EXPERIMENTAL.format_output_message("WARN", "renderer->renderer_requests", "got a 3D render request, but it was not recognized: tasker: "..tasker.." data.type: "..data.type))
    return false
end

function renderer_request.a2D.find_and_run(tasker, data, rendererContext)
    local rl = rendererContext.table.raylib

    if tasker == "player" then
        if data.type == "statistics" then
            --void DrawText(const char *text, int posX, int posY, int fontSize, Color color);--
            rl.DrawFPS(10, 10)
            rl.DrawText("Game State: "..rendererContext.table.game_state, 10, 35, 20, rl.BLACK)
            --[[
            rl.DrawText(
                "Position: x="..rendererContext.camera.position.x..
                " y="..rendererContext.camera.position.y..
                " z="..rendererContext.camera.position.z
                , 10, 60, 20, rl.BLACK)
            ]]
            do --Position Rendering
                rl.DrawText("Position:", 10, 60, 20, rl.BLACK)
                rl.DrawText("x="..rendererContext.camera.position.x, 100, 60, 20, rl.BLACK)
                rl.DrawText("y="..rendererContext.camera.position.y, 100, 85, 20, rl.BLACK)
                rl.DrawText("z="..rendererContext.camera.position.z, 100, 110, 20, rl.BLACK)
            end
            return true
        end
    end

    print(EXPERIMENTAL.format_output_message("WARN", "renderer->renderer_requests", "got a 2D render request, but it was not recognized: tasker: "..tasker.." data.type: "..data.type))
    return false
end

return(renderer_request)