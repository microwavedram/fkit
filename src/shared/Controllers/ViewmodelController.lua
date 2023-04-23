local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)

local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

local ResourceService

local ViewmodelController = Knit.CreateController { Name = "ViewmodelController" }

local LocalPlayer = Players.LocalPlayer

function ViewmodelController:MakeArms()
    self.CurrentViewmodel = self._Arms:Clone()
    self.CurrentViewmodel.Parent = workspace.CurrentCamera

    RunService:BindToRenderStep("fKit.ArmsAttach", Enum.RenderPriority.Camera.Value + 2, function()
        self.CurrentViewmodel:PivotTo(workspace.CurrentCamera.CFrame)
    end)
end

function ViewmodelController:KnitStart()
    ResourceService = Knit.GetService("ResourceService")

    self._Arms = ResourceService:RequestResource(Config.ARMS):expect()
    self._Arms.Parent = nil

    self:MakeArms()
end

function ViewmodelController:KnitInit()
    
end

return ViewmodelController