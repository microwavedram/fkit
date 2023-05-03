local Instancer = {}
Instancer.__index = Instancer

function Instancer.__call(_, Properties: { [string]: any })
    local instance = Instance.new(Properties[1])
    for Property, Value in pairs(Properties) do
        if Property == 1 then
            continue
        end
        instance[Property] = Value
    end
    return instance
end

return setmetatable({}, Instancer)