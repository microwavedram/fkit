local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Maid = require(Knit.Util.Maid)

local Component = {}
Component.__index = Component

Component.Tag = "Component"

function Component.new(instance)
    local self = setmetatable({}, Component)
   
    self._maid = Maid.new()
    return self
end

function Component:Init()
    
end

function Component:Destroy()
    self._maid:Destroy()
end


return Component