local HttpService = game:GetService("HttpService")

local Hitscan = {}
Hitscan.__index = Hitscan

function Hitscan.new(WeaponModel: Instance, Behavior: table)
    local self = setmetatable({}, Hitscan)

    self.Instance = WeaponModel
    self.Behavior = Behavior

    self.Id = HttpService:GenerateGUID(false)

    return self
end

function Hitscan:fKitEquip()

end

function Hitscan:fKitUnEquip()

end

return Hitscan
