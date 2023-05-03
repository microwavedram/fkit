local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Trove = require(ReplicatedStorage.fKit.Packages.Trove)
local Cancelable = require(ReplicatedStorage.fKit.Common.Modules.Cancelable)
local InputHandler = require(ReplicatedStorage.fKit.Common.Modules.InputHandler)

local AnimationController = Knit.GetController("AnimationController")

local Input = InputHandler.new()

local Hitscan = {}
Hitscan.__index = Hitscan

function Hitscan.new(WeaponModel: Instance, Viewmodel: Instance, Behavior: table)
    local self = setmetatable({}, Hitscan)

    self.Instance = WeaponModel
    self.Viewmodel = Viewmodel
    self.Behavior = Behavior

    self.Id = HttpService:GenerateGUID(false)

    self.CurrentADSAnimation = nil              
    self.CurrentAnimation = nil        

    self.Animations = {}
    self.Cancelable = Cancelable.new()

    self.Trove = Trove.new()

    return self
end

function Hitscan:SetADS(State)
    print(State)

    if self.CurrentADSAnimation then
        self.CurrentADSAnimation:Stop()
        self.Cancelable:Cancel()
        self.Cancelable = Cancelable.new()

        if State == true then
            self.CurrentADSAnimation = AnimationController:GenerateTransition(self.CurrentADSAnimation, self.Animations["ADS"], self.Behavior.ADS_Time)
        elseif State == false then
            self.CurrentADSAnimation = AnimationController:GenerateTransition(self.CurrentADSAnimation, self.Animations["Idle"], self.Behavior.ADS_Time)
        end
    else
        if State == true then
            self.CurrentADSAnimation = AnimationController:GenerateTransition(self.CurrentAnimation, self.Animations["ADS"], self.Behavior.ADS_Time)
        elseif State == false then
            self.CurrentADSAnimation = AnimationController:GenerateTransition(self.CurrentAnimation, self.Animations["Idle"], self.Behavior.ADS_Time)
        end
    end
    
    self.CurrentAnimation:Stop()
    task.wait() -- wait next heartbeat
    self.CurrentADSAnimation:Play()

    if State == true then
        self.CurrentAnimation = self.Animations["ADS"]
    elseif State == false then
        self.CurrentAnimation = self.Animations["Idle"]
    end
    
    self.Cancelable:AddCancelable(self.Behavior.ADS_Time, function()
        self.CurrentAnimation:Play()
        self.CurrentADSAnimation:Stop()
        self.CurrentADSAnimation = nil
    end)
end

function Hitscan:fKitEquip()
    print("Equip")
    Input{ Event = "InputBegan", Filter = { UserInputType = Enum.UserInputType.MouseButton2 } }:Connect(function()
        self:SetADS(true)
    end)
    Input{ Event = "InputEnded", Filter = { UserInputType = Enum.UserInputType.MouseButton2 } }:Connect(function()
        self:SetADS(false)
    end)

    for _,Animation in pairs(self.Instance:WaitForChild("Animations", 1):GetChildren()) do
        self.Animations[Animation.Name] = AnimationController:LoadAnimation(self.Viewmodel, Animation)
    end
    
    self.Animations["Idle"]:Play()
    self.CurrentAnimation = self.Animations["Idle"]
end

function Hitscan:fKitUnEquip()
    print("Un Equip")
    Input:DisconnectAll()
    self.Trove:Clean()
    if self.CurrentAnimation then
        self.CurrentAnimation:Stop()
    end
    if self.CurrentADSAnimation then
        self.CurrentADSAnimation:Stop()
    end
end

return Hitscan
