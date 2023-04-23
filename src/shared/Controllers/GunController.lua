local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)

local ResourceService
local fKitController

local GunController = Knit.CreateController { Name = "GunController" }

function GunController:EquipGun(GunId)
    local WorldModel = ResourceService:RequestResource(`Guns/{GunId}/WorldModel`):expect()

end

function GunController:KnitStart()
    ResourceService = Knit.GetService("ResourceService")
    fKitController = Knit.GetController("fKitController")
end

function GunController:KnitInit()
    
end

return GunController