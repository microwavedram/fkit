local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Trove = require(ReplicatedStorage.fKit.Packages.Trove)
local Instancer = require(ReplicatedStorage.fKit.Common.Modules.Instancer)

local ViewmodelController
local AnimationController
local CameraController
local ResourceService
local fKitController

local WeaponController = Knit.CreateController { Name = "GunController" }

WeaponController.ResourceCache = {}
WeaponController.Weapons = {}
WeaponController.ViewmodelTrove = Trove.new()

function WeaponController:UnEquipWeapon()
    self.ViewmodelTrove:Clean()
    self.CurrentWeaponBehavior:fKitUnEquip()
    CameraController.WeaponHeld = false
end

function WeaponController:EquipWeapon(WeaponId, CachedId)
    -- Unequip held weapon before
    if self.CurrentWeapon ~= nil then
        self:UnEquipWeapon()
    end

    local WorldModel: Model = self.ResourceCache[`Weapons/{WeaponId}/WorldModel`] or ResourceService:RequestResource(`Weapons/{WeaponId}/WorldModel`):expect()
    self.ResourceCache[`Weapons/{WeaponId}/WorldModel`] = WorldModel

    WorldModel = WorldModel:Clone()

    local WeaponBehaviorModule: ModuleScript = self.ResourceCache[`Weapons/{WeaponId}/Behavior`] or ResourceService:RequestResource(`Weapons/{WeaponId}/Behavior`):expect()
    self.ResourceCache[`Weapons/{WeaponId}/Behavior`] = WeaponBehaviorModule

    if WorldModel == nil then
        fKitController.Logger:Debug("debug.resource_requested_no_exist", `Weapons/{WeaponId}/WorldModel`)
        return
    end
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

    local BehaviorTypeModule: ModuleScript = self.ResourceCache[`Behaviors/{WeaponBehavior.BehaviourType}`] or ResourceService:RequestResource(`Behaviors/{WeaponBehavior.BehaviourType}`):expect()
    self.ResourceCache[`Behaviors/{WeaponBehavior.BehaviourType}`] = BehaviorTypeModule

    local BehaviorTypeSuccess, BehaviorType = pcall(require, BehaviorTypeModule)

    if not BehaviorTypeSuccess then
        -- BehaviorType = error message
        fKitController.Logger:Error("error.weapon.behavior_type_fail_load", `Behaviors/{WeaponBehavior.BehaviourType}`, BehaviorType)
        return
    end

    local AnimationsResource: Folder = self.ResourceCache[`Weapons/{WeaponId}/Animations`] or ResourceService:RequestResource(`Weapons/{WeaponId}/Animations`):expect()
    self.ResourceCache[`Weapons/{WeaponId}/Animations`] = AnimationsResource

    local Animations = AnimationsResource:Clone()
    Animations.Parent = WorldModel
    Animations.Name = "Animations"

    local ViewmodelArms: Model = ViewmodelController.CurrentViewmodel
    WorldModel.Parent = ViewmodelArms.RightHand

    local Behavior = self.Weapons[CachedId] or BehaviorType.new(WorldModel, ViewmodelArms, WeaponBehavior.Behavior)
    self.Weapons[Behavior.Id] = Behavior

    local Holder = ViewmodelArms:FindFirstChild(WeaponBehavior.Render.Viewmodel.WeldTo)
    fKitController.Logger:Assert(Holder, "error.weapon.viewmodel.weld_to_no_exist", `Weapons/{WeaponId}/Behavior`)

    local Weld = Instancer{
        "Motor6D",
        Name = `{Holder}_Hold`,
        Part0 = Holder,
        Part1 = WorldModel.PrimaryPart,
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
    self.ViewmodelTrove:Add(WorldModel)
    
    self.CurrentWeapon = WeaponId
    self.CurrentWeaponBehavior = Behavior

    Behavior:fKitEquip()

    CameraController.WeaponHeld = true
    return Behavior.Id
end

function WeaponController:KnitStart()
    ResourceService = Knit.GetService("ResourceService")

    ViewmodelController = Knit.GetController("ViewmodelController")
    AnimationController = Knit.GetController("AnimationController")
    fKitController = Knit.GetController("fKitController")
    CameraController = Knit.GetController("CameraController")
end

function WeaponController:KnitInit()
    
end

return WeaponController