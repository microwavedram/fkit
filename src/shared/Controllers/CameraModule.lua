local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Spring = require(ReplicatedStorage.fKit.Common.Modules.Spring)
local InputHandler = require(ReplicatedStorage.fKit.Common.Modules.InputHandler)

local CameraModule = Knit.CreateController { Name = "CameraModule" }

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Input = InputHandler.new()

CameraModule.XSpring = Spring.new()
CameraModule.YSpring = Spring.new()
CameraModule.ZSpring = Spring.new()
CameraModule.DSpring = Spring.new(20)
CameraModule.OSpring = Spring.new(Vector3.new(0,2,0))


CameraModule.Enabled = true
CameraModule.Focus = nil
CameraModule.FirstPerson = false

function CameraModule:CalculateCameraPosition()
    if self.Focus == nil then return end

    local Distance = self.DSpring.Position

    if self.FirstPerson then
        Distance = 0
    end

    -- Made for readablility, not efficiency
    return CFrame.new(self.Focus.Position + self.OSpring.Position)
    * CFrame.Angles(self.XSpring.Position, 0, 0)
    * CFrame.Angles(0, self.YSpring.Position, 0)
    * CFrame.Angles(0, 0, self.ZSpring.Position)
    * CFrame.new(0,0,-Distance)
end

function CameraModule:KnitStart()
    local function CharacterAdded(character)
        self.Focus = character:WaitForChild("HumanoidRootPart")
    end

    RunService:BindToRenderStep("fKit.Camera", Enum.RenderPriority.Camera.Value, function()
        
        if self.Enabled and self.Focus then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed

            workspace.CurrentCamera.CFrame = self:CalculateCameraPosition()
        end
    end)

    LocalPlayer.CharacterAdded:Connect(CharacterAdded)
    if self.Focus == nil then
        if LocalPlayer.Character then
            CharacterAdded(LocalPlayer.Character)
        end
    end
    
    workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(function(value)
        if value == Enum.CameraType.Scriptable then
            self.Enabled = false
        elseif value == Enum.CameraType.Custom then
            self.Enabled = true
        end
    end)


    Mouse.Move:Connect(function(...)
        print{...}
    end)
    
end

function CameraModule:KnitInit()
    
end

return CameraModule