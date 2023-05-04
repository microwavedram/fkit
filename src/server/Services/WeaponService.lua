local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)

local WeaponService = Knit.CreateService {
    Name = "WeaponService",
    Client = {},
}

WeaponService.Weapons = {}

function WeaponService:UnEquipWeapon()
    
end

function WeaponService:EquipWeapon()
    
end

function WeaponService:KnitStart()
    
end

function WeaponService:KnitInit()
    
end

return WeaponService