local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))
local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllers(ReplicatedStorage.Common.Controllers)
Component.Auto(ReplicatedStorage.Common.ClientComponents)

Knit.Start():andThen(function()
    CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
end):andThen(function()
    print("Knit Client Started")
end):catch(warn)

_G.UPTIME = os.time()