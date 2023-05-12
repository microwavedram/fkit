local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Trove = require(ReplicatedStorage.fKit.Packages.Trove)
local Instancer = require(ReplicatedStorage.fKit.Common.Modules.Instancer)

local fKitGun = require(ServerScriptService.fKit.Server.Components["@fKit.Gun"])

local fKitService
local ResourceService

local WeaponService = Knit.CreateService {
    Name = "WeaponService",
    Client = {},
}

WeaponService.Weapons = {}
WeaponService.CurrentWeapons = {}
WeaponService.WeaponTroves = {}

WeaponService.Client.EquipWeapon = Knit.CreateSignal()

function WeaponService:UnEquipWeapon(Player)
    self.WeaponTroves[Player]:Clean()
    self.CurrentWeapons[Player] = nil
end

function WeaponService:EquipWeapon(Player, WeaponId, CachedId)
    print("equip")
    self.WeaponTroves[Player] = Trove.new()

    if Player.Character == nil then
        fKitService.Logger:Debug("debug.character_no_exist")
        return
    end
    -- Unequip held weapon before
    if self.CurrentWeapons[Player] ~= nil then
        self:UnEquipWeapon(Player)
    end

    local WorldModel: Model = ResourceService:GetResource(`Weapons/{WeaponId}/WorldModel`)

    if WorldModel == nil then
        fKitService.Logger:Debug("debug.resource_requested_no_exist", `Weapons/{WeaponId}/WorldModel`)
        return
    end

    local WeaponBehaviorModule: Model = ResourceService:GetResource(`Weapons/{WeaponId}/Behavior`)

    if WeaponBehaviorModule == nil then
        fKitService.Logger:Debug("debug.resource_requested_no_exist", `Weapons/{WeaponId}/Behavior`)
        return
    end

    local BehaviorModuleSuccess, WeaponBehavior = pcall(require, WeaponBehaviorModule)

    if not BehaviorModuleSuccess then
        -- WeaponBehavior = error message
        fKitService.Logger:Error("error.weapon.behavior_fail_load", `Weapons/{WeaponId}/Behavior`, WeaponBehavior)
        return
    end

    local WeaponBehaviorTypeModule = ResourceService:GetResource(`Behaviors/Server/{WeaponBehavior.BehaviourType}`)

    local BehaviorTypeModule, WeaponBehaviorType = pcall(require, WeaponBehaviorTypeModule)

    if not BehaviorTypeModule then
        -- WeaponBehavior = error message
        fKitService.Logger:Error("error.weapon.behavior_type_fail_load", `Behaviors/Server/{WeaponBehavior.BehaviourType}`, WeaponBehaviorType)
        return
    end

    local WeaponModel = WorldModel:Clone()

    local Behavior = self.Weapons[Player][CachedId] or WeaponBehaviorType.new(WeaponModel)



    local WeldTo = Player.Character:FindFirstChild(WeaponBehavior.Render.Viewmodel.WeldTo)

    WeaponModel.Name = HttpService:GenerateGUID(false)

    local Weld = Instancer{
        "Motor6D",
        Name = `{WeldTo.Name}_Hold`,
        Part0 = WeldTo,
        Part1 = WeaponModel.PrimaryPart,
        Parent = WeldTo,
        C0 = CFrame.Angles(-math.pi/2,0,0)
    }

    WeaponModel.Parent = WeldTo

    self.CurrentWeapons[Player] = Behavior

    self.WeaponTroves[Player]:Add(Weld)
    self.WeaponTroves[Player]:Add(WeaponModel)

    
    return Behavior.Id
end

function WeaponService:KnitStart()
    ResourceService = Knit.GetService("ResourceService")
    fKitService = Knit.GetService("fKitService")

    local function PlayerAdded(Player)
        self.Weapons[Player] = {}
    end

    Players.PlayerAdded:Connect(PlayerAdded)
    for _,Player in pairs(Players:GetPlayers()) do
        PlayerAdded(Player)
    end
end

function WeaponService:KnitInit()
    
end

function WeaponService.Client:RequestId(sender, tool)
    if tool.Parent == sender.Character or tool.Parent == sender.Backpack then
        local Component = fKitGun:FromInstance(tool)

        if Component then
            return Component.GunId
        end
    end
end

function WeaponService.Client:GetServersideModelName(sender)
    local CurrentWeapon = self.Server.CurrentWeapons[sender]
    if CurrentWeapon then
        return CurrentWeapon.Instance.Name
    end
end

function WeaponService.Client:FireBullet(sender, Behavior)
    
end

return WeaponService