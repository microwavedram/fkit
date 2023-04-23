local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Component = require(ReplicatedStorage.fKit.Packages.Component)
local LocalTool = require(ReplicatedStorage.fKit.Common.Extensions.LocalTool)

local GunController = Knit.GetController("GunController")

local fKitGun = Component.new{ Tag = "@fKit.Gun", Ancestors = { Players, workspace }, Extensions = { LocalTool } }

local LocalPlayer = Players.LocalPlayer

function fKitGun:Construct()
    
end

function fKitGun:Start()
    self.Instance.AncestryChanged:Connect(function()
        if self.Instance.Parent == LocalPlayer.Character then
            GunController:EquipGun(self.Instance.Gun.Value)
        elseif GunController.CurrentGun == self.Instance.Gun.Value then
            GunController:UnEquipGun()
        end
    end)
end

function fKitGun:SteppedUpdate(dt)

end

function fKitGun:Stop()
    
end

return fKitGun