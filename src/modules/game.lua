local WORLD    = require("src.modules.world")
local PLAYER   = require("src.modules.player")
local RENDERER = require("src.modules.renderer")

local EXPERIMENTAL = require("src.modules.experimental.experimental")

local GAME_TYPE = "game_table"

function init_game(raylib, camera)
    local localGameTable = {
        __type = GAME_TYPE,

        world    = nil,
        player   = nil,
        renderer = nil,

        game_state = "World",

        raylib = nil
    }

    localGameTable.raylib   = raylib

    localGameTable.world    = WORLD.init()
    localGameTable.player   = PLAYER.init(camera)
    localGameTable.renderer = RENDERER.init(localGameTable, camera)

    return localGameTable
end

function update_game(localGameTable, dt)
    localGameTable.world:update(localGameTable,    dt)
    localGameTable.player:update(localGameTable,   dt)
--  localGameTable.renderer:update(localGameTable, dt)
end

function render_game(localGameTable, alpha)
    localGameTable.renderer:render(localGameTable, alpha)
end

return({
    init_game   = init_game, 
    update_game = update_game,
    render_game = render_game
})