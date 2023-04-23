local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)

local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

local ResourceService

local ViewmodelController = Knit.CreateController { Name = "ViewmodelController" }

local LocalPlayer = Players.LocalPlayer

function ViewmodelController:MakeArms()
    local Arms = self.Arms:Clone()
    Arms.Parent = workspace.CurrentCamera

    RunService:BindToRenderStep("fKit.ArmsAttach", Enum.RenderPriority.Camera.Value + 1, function()
        Arms:PivotTo(workspace.CurrentCamera.CFrame)
    end)
end

function ViewmodelController:KnitStart()
    ResourceService = Knit.GetService("ResourceService")

    self.Arms = ResourceService:RequestResource(Config.ARMS):expect()
    self.Arms.Parent = nil

    self:MakeArms()
end

function ViewmodelController:KnitInit()
    
end

return ViewmodelController