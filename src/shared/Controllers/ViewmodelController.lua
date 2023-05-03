local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Spring = require(ReplicatedStorage.fKit.Common.Modules.Spring)

local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

local ResourceService

local ViewmodelController = Knit.CreateController { Name = "ViewmodelController" }

ViewmodelController.ResourceCache = {}

function ViewmodelController:UseViewmodel(Viewmodel)
    self.CurrentViewmodel = Viewmodel:Clone()
    self.CurrentViewmodel.Parent = workspace.CurrentCamera

    RunService:BindToRenderStep("fKit.ArmsAttach", Enum.RenderPriority.Camera.Value + 1, function()
        if UserInputService:IsKeyDown(Enum.KeyCode.T) then return end

        self.ViewmodelSpring.Target = workspace.CurrentCamera.CFrame.LookVector

        local UpVector = workspace.CurrentCamera.CFrame.UpVector
        local LookVector = self.ViewmodelSpring.Position
        local RightVector = LookVector:Cross(UpVector)

        local Cframe = CFrame.fromMatrix(workspace.CurrentCamera.CFrame.Position, RightVector, UpVector)

        self.CurrentViewmodel:PivotTo(Cframe)
    end)
end

function ViewmodelController:KnitStart()
    ResourceService = Knit.GetService("ResourceService")

    self.ViewmodelSpring = Spring.new(Vector3.zAxis)
    self.ViewmodelSpring.Speed = Config.Viewmodel.Spring.Speed
    self.ViewmodelSpring.Damper = Config.Viewmodel.Spring.Damper

    self.ResourceCache.Viewmodel = ResourceService:RequestResource(Config.Viewmodel.Viewmodel):expect()
    self:UseViewmodel(self.ResourceCache.Viewmodel)
end

function ViewmodelController:KnitInit()
    
end

return ViewmodelController