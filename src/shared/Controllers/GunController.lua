local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)

local ViewmodelController
local ResourceService
local fKitController

local GunController = Knit.CreateController { Name = "GunController" }

function GunController:UnEquipGun()
    RunService:UnbindFromRenderStep("fKit.GunAttach")

    local Viewmodel = ViewmodelController.CurrentViewmodel.RightHand:FindFirstChildOfClass("Model")
    Viewmodel:Destroy()
end

function GunController:EquipGun(GunId)
    if self.CurrentGun ~= nil then
        self:UnEquipGun()
    end

    local WorldModel: Model = ResourceService:RequestResource(`Guns/{GunId}/WorldModel`):expect()

    if WorldModel == nil then fKitController.Logger:Debug("debug.resource_requested_no_exist", `Guns/{GunId}/WorldModel`); return end

    local ViewmodelArms: Model = ViewmodelController.CurrentViewmodel
    WorldModel.Parent = ViewmodelArms.RightHand
    
    self.CurrentGun = GunId
    RunService:BindToRenderStep("fKit.GunAttach", Enum.RenderPriority.Camera.Value + 1, function()
        WorldModel:PivotTo(ViewmodelArms.RightHand.CFrame)
    end)
end

function GunController:KnitStart()
    ResourceService = Knit.GetService("ResourceService")

    ViewmodelController = Knit.GetController("ViewmodelController")
    fKitController = Knit.GetController("fKitController")
end

function GunController:KnitInit()
    
end

return GunController