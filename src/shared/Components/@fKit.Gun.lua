local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Component = require(ReplicatedStorage.fKit.Packages.Component)
local LocalTool = require(ReplicatedStorage.fKit.Common.Extensions.LocalTool)

local WeaponController = Knit.GetController("WeaponController")

local fKitGun = Component.new{ Tag = "@fKit.Gun", Ancestors = { Players, workspace }, Extensions = { LocalTool } }

local LocalPlayer = Players.LocalPlayer

function fKitGun:Start()
    self.Instance.AncestryChanged:Connect(function()
        if self.Instance.Parent == LocalPlayer.Character then
            self.GunId = WeaponController:EquipWeapon(self.Instance.Gun.Value, self.GunId)
        elseif WeaponController.CurrentWeapon == self.Instance.Gun.Value then
            WeaponController:UnEquipWeapon(self.GunId)
        end
    end)
end

return fKitGun