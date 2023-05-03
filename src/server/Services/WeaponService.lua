local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)

local WeaponService = Knit.CreateService {
    Name = "GunService",
    Client = {},
}

function WeaponService:KnitStart()
    
end

function WeaponService:KnitInit()
    
end

return WeaponService