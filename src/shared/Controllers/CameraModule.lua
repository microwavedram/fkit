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
CameraModule.XSpring.Speed = 20
CameraModule.XSpring.Damper = 0.95

CameraModule.YSpring = Spring.new()
CameraModule.YSpring.Speed = 20
CameraModule.YSpring.Damper = 0.95

CameraModule.ZSpring = Spring.new()
CameraModule.ZSpring.Speed = 20
CameraModule.ZSpring.Damper = 0.95

CameraModule.DSpring = Spring.new(20)
CameraModule.DSpring.Speed = 20
CameraModule.DSpring.Damper = 0.95

CameraModule.OSpring = Spring.new(Vector3.new(0,2,0))
CameraModule.OSpring.Speed = 20
CameraModule.OSpring.Damper = 0.95

CameraModule.MouseButton2Held = false

CameraModule.Enabled = true
CameraModule.Focus = nil
CameraModule.FirstPerson = false
CameraModule.LockMouse = true

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

            local mouse_delta = Vector2.new()

            if self.LockMouse then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

                mouse_delta = UserInputService:GetMouseDelta()
            else
                if self.MouseButton2Held then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                else
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end
            end

            self.XSpring.Target = self.XSpring.Target + mouse_delta.X * self.Sensitivity
            self.YSpring.Target = self.YSpring.Target + mouse_delta.Y * self.Sensitivity
            
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

    Input{Event = "InputBegan", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton2}}:Connect(function() self.MouseButton2Held = true end)
    Input{Event = "InputEnded", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton2}}:Connect(function() self.MouseButton2Held = false end)
    
end

function CameraModule:KnitInit()
    
end

return CameraModule