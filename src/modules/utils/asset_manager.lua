local EXPERIMENTAL = require("src.modules.experimental.experimental")
local asset_manager = {}

function asset_manager.new(gameContext)
    local meta = setmetatable({}, asset_manager)

    meta.game_context = gameContext

    return(meta)
end

function asset_manager:get_block()
    
end

function asset_manager:get_model()
    
end