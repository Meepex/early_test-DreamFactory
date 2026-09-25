local OBJECT = require("src.modules.generics.object")
local Block = OBJECT:new():extends()

function Block:extends()
    local child = {}
    child.__index = child
    child.super = self

    setmetatable(child, {
        __index = self
    })

    return child
end

return Block