local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

if Config.I_HAVE_READ_THIS == false then
    warn("fKit not configured. See ReplicatedStorage/fKit/Configuration/MainConfig")
    return
end

for _,Controller in pairs(ReplicatedStorage.fKit.Common.Controllers:GetChildren()) do
    local success, errorMessage = pcall(require, Controller)
    if not success then
        warn("fKit Controller Failed to Load", errorMessage)
    end
end

Knit.Start():andThen(function()
    CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
end):andThen(function()
    for _,Component in pairs(ReplicatedStorage.fKit.Common.Components:GetChildren()) do
        require(Component)
    end
end):catch(warn)

_G.UPTIME = os.time()