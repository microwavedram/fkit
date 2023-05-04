local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Spring = require(ReplicatedStorage.fKit.Common.Modules.Spring)
local InputHandler = require(ReplicatedStorage.fKit.Common.Modules.InputHandler)
local Trove = require(ReplicatedStorage.fKit.Packages.Trove)

local CameraController = Knit.CreateController { Name = "CameraController" }

local LocalPlayer = Players.LocalPlayer
local Input = InputHandler.new()

CameraController.XSpring = Spring.new()
CameraController.XSpring.Speed = 50
CameraController.XSpring.Damper = 0.95

CameraController.YSpring = Spring.new()
CameraController.YSpring.Speed = 50
CameraController.YSpring.Damper = 0.95

CameraController.ZSpring = Spring.new()
CameraController.ZSpring.Speed = 50
CameraController.ZSpring.Damper = 0.95

CameraController.DSpring = Spring.new(20)
CameraController.DSpring.Speed = 50
CameraController.DSpring.Damper = 0.95

CameraController.OSpring = Spring.new(Vector3.new(0,2,0))
CameraController.OSpring.Speed = 50
CameraController.OSpring.Damper = 0.95

CameraController.CameraSensitivity = 0.001
CameraController.ZoomSensitivity = 3
CameraController.MinZoom = 4
CameraController.MaxZoom = 20
CameraController.CharacterFadeTime = 0.25
CameraController.NormalOffset  = Vector3.new(0,2,0)
CameraController.ThirdPersonOffset = Vector3.new(2,2,0)

CameraController.CharacterTweenTrove = Trove.new()

CameraController.MouseButton2Held = false
CameraController.FirstPerson = false
CameraController.WeaponHeld = false
CameraController.Enabled = true
CameraController.Focus = nil

local function clamp(x, mi, ma)
    if x > ma then
        return ma
    elseif x < mi then
        return mi
    end
    return x
end

function CameraController:CalculateCameraPosition()
    if self.Focus == nil then return end

    local Distance = self.DSpring.Position

    if self.FirstPerson then
        Distance = 0
    end

    local _,_,_,c00,c01,c02,c10,c11,c12,c20,c21,c22 = self.Focus.CFrame:GetComponents()

    local Offset = CFrame.new(self.Focus.CFrame.Position) * CFrame.new(0,0,0,c00,c01,c02,c10,c11,c12,c20,c21,c22) * CFrame.new(self.OSpring.Position)

    -- Made for readablility, not efficiency
    return CFrame.new(Offset.Position)
    * CFrame.Angles(0, self.YSpring.Position, 0)
    * CFrame.Angles(self.XSpring.Position, 0, 0)
    * CFrame.Angles(0, 0, self.ZSpring.Position)
    * CFrame.new(0,0,Distance)
end

function CameraController:KnitStart()
    local function CharacterAdded(character)
        self.Focus = character:WaitForChild("HumanoidRootPart")
        
        self.CurrentCharacter = character
    end

    local function CharacterRemoving()
        self.CurrentCharacter = nil
    end

    RunService:BindToRenderStep("fKit.Camera", Enum.RenderPriority.Camera.Value, function()

        if self.Enabled and self.Focus and workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Fixed

            if self.FirstPerson then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            else
                if self.WeaponHeld then
                    if self.MouseButton2Held then
                        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                        self.OSpring.Target = self.ThirdPersonOffset
                    else
                        self.OSpring.Target = self.NormalOffset
                        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                    end
                elseif self.MouseButton2Held then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                else
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end
            end
            
            workspace.CurrentCamera.CFrame = self:CalculateCameraPosition()
        end
    end)

    RunService:BindToRenderStep("fKit.Character", Enum.RenderPriority.Camera.Value - 1, function()
        if self.CurrentCharacter then
            if self.FirstPerson then
                local Position = self.CurrentCharacter.HumanoidRootPart.CFrame.Position

                self.CurrentCharacter.HumanoidRootPart.CFrame = CFrame.new(Position) * CFrame.Angles(0,self.YSpring.Position,0)

                self.CharacterTweenTrove:Clean()
                for _,Part in pairs(self.CurrentCharacter:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        local Tween = TweenService:Create(Part, TweenInfo.new(self.CharacterFadeTime), {LocalTransparencyModifier = 1})
                        Tween:Play()
                        self.CharacterTweenTrove:Add(Tween)
                    end
                end
            else
                self.CharacterTweenTrove:Clean()
                for _,Part in pairs(self.CurrentCharacter:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        local Tween = TweenService:Create(Part, TweenInfo.new(self.CharacterFadeTime), {LocalTransparencyModifier = 0})
                        Tween:Play()
                        self.CharacterTweenTrove:Add(Tween)
                    end
                end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(CharacterAdded)
    if self.Focus == nil then
        if LocalPlayer.Character then
            CharacterAdded(LocalPlayer.Character)
        end
    end

    LocalPlayer.CharacterRemoving:Connect(CharacterRemoving)
    
    workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(function(value)
        if value == Enum.CameraType.Scriptable then
            self.Enabled = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        elseif value == Enum.CameraType.Fixed then
            self.Enabled = true
        elseif value == Enum.CameraType.Custom then
            self.Enabled = true
        end
    end)

    Input{Event = "InputBegan", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton2}}:Connect(function()
        self.MouseButton2Held = true
    end)
    Input{Event = "InputEnded", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton2}}:Connect(function()
        self.MouseButton2Held = false
    end)
    Input{Event = "InputChanged", Filter = {UserInputType = Enum.UserInputType.MouseMovement}}:Connect(function(input)
        self.XSpring.Target = self.XSpring.Target + -input.Delta.Y * self.CameraSensitivity
        self.YSpring.Target = self.YSpring.Target + -input.Delta.X * self.CameraSensitivity
    end)
    Input{Event = "InputChanged", Filter = {UserInputType = Enum.UserInputType.MouseWheel}}:Connect(function(input)
        if self.FirstPerson then return end
        self.DSpring.Target = clamp(self.DSpring.Target - input.Position.Z * self.ZoomSensitivity, self.MinZoom, self.MaxZoom)
    end)

    Input{Event = "InputBegan", Filter = {UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.T}}:Connect(function()
        self.FirstPerson = not self.FirstPerson
    end)
end

function CameraController:KnitInit()
    
end

return CameraController