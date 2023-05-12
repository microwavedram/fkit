local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Trove = require(ReplicatedStorage.fKit.Packages.Trove)
local Cancelable = require(ReplicatedStorage.fKit.Common.Modules.Cancelable)
local InputHandler = require(ReplicatedStorage.fKit.Common.Modules.InputHandler)

local AnimationController = Knit.GetController("AnimationController")
local fKitController = Knit.GetController("fKitController")
local WeaponService = Knit.GetService("WeaponService")

local Input = InputHandler.new()

local Hitscan = {}
Hitscan.__index = Hitscan

function Hitscan.new(WeaponModel: Instance, Viewmodel: Instance, Settings: table, Id)
    local self = setmetatable({}, Hitscan)

    self.Instance = WeaponModel
    self.Viewmodel = Viewmodel
    self.Behavior = Settings

    self.Id = Id
    if Id == nil then
        fKitController.Logger:Debug("debug.weapon.no_server_id")
        self.Id = HttpService:GenerateGUID(false)
    end

    self.CurrentADSAnimation = nil              
    self.CurrentAnimation = nil        

    self.Animations = {}
    self.Cancelable = Cancelable.new()

    self.CurrentClip = Settings.ClipSize
    self.FireMode = Settings.FireModes[1]
    self.FireModeIndex = 1

    self.Firing = true
    self.LastFireTime = 0

    self.Trove = Trove.new()

    return self
end

function Hitscan:Empty()
    print("Empty")
end

function Hitscan:Fire()
    if self.CurrentClip <= 0 then 
        self:Empty()
    end
    self.LastFireTime = tick()
    self.CurrentClip = self.CurrentClip - 1
    print("BANG")

    for _ = 1,self.Behavior.BulletsPerShot,1 do
        WeaponService:FireBullet(self)
    end
end

function Hitscan:SetADS(State)
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

function Hitscan:MouseButton1Down()
    if self.FireMode == "SEMI" then
        if self.LastFireTime + self.Behavior.FireDelay < tick() then
            self.Firing = true
            self:Fire()
            self.Firing = false
        end
    elseif self.FireMode == "BURST" then
        if self.LastFireTime + self.Behavior.FireDelay < tick() then
            self.Firing = true
            for _ = 1,math.min(3,self.CurrentClip),1 do
                self:Fire()
                task.wait(self.Behavior.BurstDelay)
            end
            self.Firing = false
        end
    elseif self.FireMode == "AUTO" then
        self.Firing = true
        while self.MouseButton1 do
            self:Fire()
            task.wait(self.Behavior.FireDelay)
        end
        self.Firing = false
    end
end

function Hitscan:MouseButton1Up()
    
end

function Hitscan:MouseButton2Down()
    
end

function Hitscan:MouseButton2Up()
    
end

function Hitscan:fKitEquip()
    Input{ Event = "InputBegan", Filter = { UserInputType = Enum.UserInputType.MouseButton2 } }:Connect(function()
        self:SetADS(true)
    end)
    Input{ Event = "InputEnded", Filter = { UserInputType = Enum.UserInputType.MouseButton2 } }:Connect(function()
        self:SetADS(false)
    end)
    Input{ Event = "InputBegan", Filter = { UserInputType = Enum.UserInputType.Keyboard, KeyCode = Enum.KeyCode.C } }:Connect(function()
        self.FireModeIndex = self.FireModeIndex + 1
        if self.FireModeIndex > #self.Behavior.FireModes then
            self.FireModeIndex = 1
        end

        self.FireMode = self.Behavior.FireModes[self.FireModeIndex]

        print(self.FireMode)
    end)

    local AnimationFolder = self.Instance:WaitForChild("Animations", 1)
    if AnimationFolder == nil then return end

    for _,Animation in pairs(AnimationFolder:GetChildren()) do
        self.Animations[Animation.Name] = AnimationController:LoadAnimation(self.Viewmodel, Animation)
    end
    
    self.Animations["Idle"]:Play()
    self.CurrentAnimation = self.Animations["Idle"]
end

function Hitscan:fKitUnEquip()
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
