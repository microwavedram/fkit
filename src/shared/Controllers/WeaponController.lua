local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Trove = require(ReplicatedStorage.fKit.Packages.Trove)
local InputHandler = require(ReplicatedStorage.fKit.Common.Modules.InputHandler)
local Instancer = require(ReplicatedStorage.fKit.Common.Modules.Instancer)

local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

local ViewmodelController
local AnimationController
local CameraController
local ResourceService
local fKitController
local WeaponService

local WeaponController = Knit.CreateController { Name = "WeaponController" }

local LocalPlayer = Players.LocalPlayer
local Input = InputHandler.new()

WeaponController.Weapons = {}
WeaponController.ResourceCache = {}

WeaponController.ViewmodelTrove = Trove.new()
WeaponController.ReticleTweenTrove = Trove.new()

WeaponController.MouseButton2Held = false
WeaponController.ReticleVisible = false
WeaponController.FocusReticle = false
WeaponController.CurrentADSTime = false

function WeaponController:UnEquipWeapon()
    self.ViewmodelTrove:Clean()
    self.CurrentWeaponBehavior:fKitUnEquip()
    self.CurrentWeaponBehavior = nil
    self.CurrentWeapon = nil
    CameraController.WeaponHeld = false
end

function WeaponController:EquipWeapon(WeaponId, BehaviorId)
    -- Unequip held weapon before
    if self.CurrentWeapon ~= nil then
        self:UnEquipWeapon()
    end

    local WorldModel: Model = self.ResourceCache[`Weapons/{WeaponId}/WorldModel`] or ResourceService:RequestResource(`Weapons/{WeaponId}/WorldModel`):expect()
    self.ResourceCache[`Weapons/{WeaponId}/WorldModel`] = WorldModel

    if WorldModel == nil then
        fKitController.Logger:Debug("debug.resource_requested_no_exist", `Weapons/{WeaponId}/WorldModel`)
        return
    end

    local WeaponModel = WorldModel:Clone()

    local WeaponBehaviorModule: ModuleScript = self.ResourceCache[`Weapons/{WeaponId}/Behavior`] or ResourceService:RequestResource(`Weapons/{WeaponId}/Behavior`):expect()
    self.ResourceCache[`Weapons/{WeaponId}/Behavior`] = WeaponBehaviorModule
    
    if WeaponBehaviorModule == nil then
        fKitController.Logger:Debug("debug.resource_requested_no_exist", `Weapons/{WeaponId}/Behavior`)
        return
    end
    local WeaponBehaviorSuccess, WeaponBehavior = pcall(require, WeaponBehaviorModule)

    if not WeaponBehaviorSuccess then
        -- Behavior = error message
        fKitController.Logger:Error("error.weapon.behavior_fail_load", `Weapons/{WeaponId}/Behavior`, WeaponBehavior)
        return
    end

    local BehaviorTypeModule: ModuleScript = self.ResourceCache[`Behaviors/Client/{WeaponBehavior.BehaviourType}`] or ResourceService:RequestResource(`Behaviors/Client/{WeaponBehavior.BehaviourType}`):expect()
    self.ResourceCache[`Behaviors/Client/{WeaponBehavior.BehaviourType}`] = BehaviorTypeModule

    local BehaviorTypeSuccess, BehaviorType = pcall(require, BehaviorTypeModule)

    if not BehaviorTypeSuccess then
        -- BehaviorType = error message
        fKitController.Logger:Error("error.weapon.behavior_type_fail_load", `Behaviors/Client/{WeaponBehavior.BehaviourType}`, BehaviorType)
        return
    end

    local AnimationsResource: Folder = self.ResourceCache[`Weapons/{WeaponId}/Animations`] or ResourceService:RequestResource(`Weapons/{WeaponId}/Animations`):expect()
    self.ResourceCache[`Weapons/{WeaponId}/Animations`] = AnimationsResource

    local Animations = AnimationsResource:Clone()
    Animations.Parent = WeaponModel
    Animations.Name = "Animations"

    local ViewmodelArms: Model = ViewmodelController.CurrentViewmodel
    WeaponModel.Parent = ViewmodelArms.RightHand

    local Behavior = self.Weapons[BehaviorId] or BehaviorType.new(WeaponModel, ViewmodelArms, WeaponBehavior.Behavior, BehaviorId)
    self.Weapons[Behavior.Id] = Behavior
    Behavior.Instance = WeaponModel
    Behavior.Viewmodel = ViewmodelArms

    local Holder = ViewmodelArms:FindFirstChild(WeaponBehavior.Render.Viewmodel.WeldTo)
    fKitController.Logger:Assert(Holder, "error.weapon.viewmodel.weld_to_no_exist", `Weapons/{WeaponId}/Behavior`)

    -- Some Custom Behaviors may not have the ADS_TIME
    if WeaponBehavior.Behavior.ADS_Time then
        self.CurrentADSTime = WeaponBehavior.Behavior.ADS_Time
    else
        self.CurrentADSTime = 1
    end

    local Weld = Instancer{
        "Motor6D",
        Name = `{Holder}_Hold`,
        Part0 = Holder,
        Part1 = WeaponModel.PrimaryPart,
        Parent = Holder
    }

    local EquipAnimation = Animations:FindFirstChild("Equip")

    if EquipAnimation then
        local Animation = AnimationController:LoadAnimation(ViewmodelArms, EquipAnimation)

        Animation:Play()
    else
        fKitController.Logger:Warn("warn.weapon.no_equip", `Weapons/{WeaponId}/Animations/Equip`)
    end

    self.ViewmodelTrove:Add(Weld)
    self.ViewmodelTrove:Add(WeaponModel)
    
    self.ServerModelName = WeaponService:GetServersideModelName():expect()
    self.CurrentWeapon = WeaponId
    self.CurrentWeaponBehavior = Behavior

    Behavior:fKitEquip()

    CameraController.WeaponHeld = true
    return Behavior.Id
end

function WeaponController:KnitStart()
    print(0)
    ViewmodelController = Knit.GetController("ViewmodelController")
    AnimationController = Knit.GetController("AnimationController")
    CameraController = Knit.GetController("CameraController")
    fKitController = Knit.GetController("fKitController")
    ResourceService = Knit.GetService("ResourceService")
    WeaponService = Knit.GetService("WeaponService")


    self.ReticleUI = LocalPlayer.PlayerGui:WaitForChild("Reticle")

    WeaponService.EquipWeapon:Connect(function(WeaponId, BehaviorId)
        self:EquipWeapon(WeaponId, BehaviorId)
    end)

    Input{Event = "InputBegan", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton1}}:Connect(function()
        self.MouseButton1Held = true
        if self.CurrentWeaponBehavior then
            self.CurrentWeaponBehavior:MouseButton1Down()
            self.CurrentWeaponBehavior.MouseButton1 = true
        end
    end)
    Input{Event = "InputEnded", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton1}}:Connect(function()
        self.MouseButton1Held = false
        if self.CurrentWeaponBehavior then
            self.CurrentWeaponBehavior:MouseButton1Up()
            self.CurrentWeaponBehavior.MouseButton1 = false
        end
    end)

    Input{Event = "InputBegan", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton2}}:Connect(function()
        self.MouseButton2Held = true
        if self.CurrentWeaponBehavior then
            self.CurrentWeaponBehavior:MouseButton2Down()
            self.CurrentWeaponBehavior.MouseButton2 = true
        end
    end)
    Input{Event = "InputEnded", AllowGameProcessed = true, Filter = {UserInputType = Enum.UserInputType.MouseButton2}}:Connect(function()
        self.MouseButton2Held = false
        if self.CurrentWeaponBehavior then
            self.CurrentWeaponBehavior:MouseButton2Up()
            self.CurrentWeaponBehavior.MouseButton2 = false
        end
    end)

    

    RunService:BindToRenderStep("fKit.Reticle", Enum.RenderPriority.Input.Value - 1, function()
        self.FocusReticle = self.CurrentWeapon ~= nil and (self.MouseButton2Held or CameraController.FirstPerson)
        self.ReticlePosition = UDim2.new(0.5,0,0.5,0)

        if self.CurrentWeaponBehavior and self.FocusReticle then
            if CameraController.FirstPerson then
                self.Firepoint = self.CurrentWeaponBehavior.Instance:FindFirstChild("Firepoint", true)
            else
                if LocalPlayer.Character then
                    if self.ServerModelName then
                        local Weapon = LocalPlayer.Character:FindFirstChild(self.ServerModelName, true)
                        if Weapon then
                            self.Firepoint = Weapon:FindFirstChild("Firepoint", true)
                        end
                    else
                        self.ServerModelName = WeaponService:GetServersideModelName():expect()
                    end
                end
            end

            if self.Firepoint then
                local CastInfo = workspace:Raycast(self.Firepoint.WorldCFrame.Position, self.Firepoint.WorldCFrame.LookVector * Config.DynamicCrosshair.CastDistance, Config.DynamicCrosshair.CastParams)

                if CastInfo then
                    local ScreenPos, IsOnScreen = workspace.CurrentCamera:WorldToScreenPoint(CastInfo.Position)

                    if IsOnScreen then
                        self.ReticlePosition = UDim2.new(0, ScreenPos.X, 0, ScreenPos.Y)
                    else
                        -- offscreen
                        self.ReticlePosition = UDim2.new(0,-100,0,-100)
                    end
                end
            end
        end

        UserInputService.MouseIconEnabled = not self.FocusReticle and not CameraController.FirstPerson

        if self.ReticleVisible then
            self.ReticleUI.Circle.Position = self.ReticlePosition
        end

        if self.FocusReticle ~= self.ReticleVisible then
            self.ReticleVisible = self.FocusReticle

            self.ReticleTweenTrove:Clean()
            if self.FocusReticle then
                local Tween = TweenService:Create(self.ReticleUI.Circle, TweenInfo.new(self.CurrentADSTime), {Size = UDim2.new(0,5,0,5)})
                self.ReticleTweenTrove:Add(Tween)
                Tween:Play()
            else
                local Tween = TweenService:Create(self.ReticleUI.Circle, TweenInfo.new(self.CurrentADSTime), {Size = UDim2.new(0,0,0,0)})
                self.ReticleTweenTrove:Add(Tween)
                Tween:Play()
            end
        end
    end)
end

function WeaponController:KnitInit()
    
end

return WeaponController