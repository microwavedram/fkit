local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Component = require(ReplicatedStorage.fKit.Packages.Component)

local WeaponService = Knit.GetService("WeaponService")

local fKitGun = Component.new{ Tag = "@fKit.Gun", Ancestors = { Players, workspace }, Extensions = {} }

function fKitGun:Start()
    self.Instance.AncestryChanged:Connect(function()

        if self.Instance.Parent:IsA("Backpack") then
            self.Player = self.Instance.Parent.Parent
        elseif self.Instance.Parent:FindFirstChildOfClass("Humanoid") then
            self.Player = Players:GetPlayerFromCharacter(self.Instance.Parent)
        else
            self.Player = nil
        end

        if self.Player then
            if self.Instance.Parent == self.Player.Character then
                self.GunId = WeaponService:EquipWeapon(self.Player, self.Instance.Gun.Value, self.GunId)
            elseif WeaponService.CurrentWeapon == self.Instance.Gun.Value then
                WeaponService:UnEquipWeapon(self.Player)
            end
        end
    end)
end

return fKitGun