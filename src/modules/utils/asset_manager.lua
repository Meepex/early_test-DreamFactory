local EXPERIMENTAL = require("src.modules.experimental.experimental")
local BLOCK_ENTRIES = require("src.assets.block_entries")
local asset_manager = {}

local function prepare_mesh(gameContext, type)
    if type == "block" then
        local mesh = gameContext.raylib.GenMeshCube(1, 1, 1)
        gameContext.raylib.UploadMesh(mesh, false)
        return mesh
    end
end

function asset_manager.init(gameContext)
    local meta = setmetatable({}, asset_manager)

    meta.game_context = gameContext

    --prepare commonly used meshes--
    meta.meshes = {}
    meta.models = {}
    meta.meshes["block"] = prepare_mesh(gameContext, "block")


    return(meta)
end

function asset_manager:get_block_by_name(name)
    --later we will use also generics implementation of blocks, but for now we do not need them--
    return self.meshes[name]
end

function asset_manager:get_object(name)
    local model = self.models[name]

    if not model then
        model = BLOCK_ENTRIES[name].model
        if model == "block" then
            --maybe in the future we will convert all meshes into models and just use models--
            print(EXPERIMENTAL.format_output_message(1, "asset_manager->get_model", "Required model, but got cube mesh for block: "..name.." please use 'get_block' instead."))
            assert(false)
        else
            model = self.game_context.raylib.LoadModel(model)
            if self.game_context.IsModelValid(model) then
                self.models[name] = model
                return model
            else
                print(EXPERIMENTAL.format_output_message(1, "asset_manager->get_model", "Required modelis not valid. Block name: "..name))
                assert(false)
            end
        end
    end
end

return asset_manager