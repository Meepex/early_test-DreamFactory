local Object = {}

function Object:extends()
    local child = {}
    child.__index = child
    child.super = self

    setmetatable(child, {
        __index = self
    })

    return child
end

function Object:new(...)
    local instance = setmetatable({}, self)

    if instance.init then
        instance:init(...)
    end

    return instance
end

return Object