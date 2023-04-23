local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))
local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

if Config.I_HAVE_READ_THIS == false then warn("fKit not configured. See ReplicatedStorage/fKit/Configuration/MainConfig") return end

Knit.AddControllers(ReplicatedStorage.fKit.Common.Controllers)
for _,Component in pairs(ReplicatedStorage.fKit.Common.Components:GetChildren()) do require(Component) end

Knit.Start():andThen(function()
    CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
end):catch(warn)

_G.UPTIME = os.time()