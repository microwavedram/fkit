local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Component = require(ReplicatedStorage.fKit.Packages.Component)
local LocalTool = require(ReplicatedStorage.fKit.Common.Extensions.LocalTool)

local fKitGun = Component.new{ Tag = "@fKit.Gun", Ancestors = { Players, workspace }, Extensions = { LocalTool } }

local LocalPlayer = Players.LocalPlayer

function fKitGun:Construct()
    
end

function fKitGun:Equip()
    
end

function fKitGun:Start()
    self.Instance.AncestryChanged:Connect(function()
        if self.Instance.Parent == LocalPlayer.Character then
            self:Equip()
        end
    end)
end

function fKitGun:SteppedUpdate(dt)

end

function fKitGun:Stop()
    
end

return fKitGun