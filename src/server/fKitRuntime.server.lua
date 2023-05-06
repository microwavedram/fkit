local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Cmdr = require(ReplicatedStorage.fKit.Packages.Cmdr)
local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

if Config.I_HAVE_READ_THIS == false then
    warn("fKit not configured. See ReplicatedStorage/fKit/Configuration/MainConfig")
    return
end

for _,Service in pairs(ServerScriptService.fKit.Server.Services:GetChildren()) do
    local success, errorMessage = pcall(require, Service)
    if not success then
        warn("fKit Service Failed to Load", errorMessage)
    end
end

Knit.Start():andThen(function()
    Cmdr:RegisterDefaultCommands()
    Cmdr.Registry:RegisterCommandsIn(ReplicatedStorage.fKit.Common.Cmdr.Commands)
    Cmdr.Registry:RegisterTypesIn(ReplicatedStorage.fKit.Common.Cmdr.Types)
    Cmdr.Registry:RegisterHooksIn(ReplicatedStorage.fKit.Common.Cmdr.Hooks)
end):andThen(function()
    for _,Component in pairs(ServerScriptService.fKit.Server.Components:GetChildren()) do
        pcall(require, Component)
    end
end):catch(warn)

_G.UPTIME = os.time()