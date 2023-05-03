local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Cmdr = require(ReplicatedStorage.fKit.Packages.Cmdr)
local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

if Config.I_HAVE_READ_THIS == false then
    warn("fKit not configured. See ReplicatedStorage/fKit/Configuration/MainConfig")
    return
end

Knit.AddServices(ServerScriptService.fKit.Server.Services)
for _,Component in pairs(ServerScriptService.fKit.Server.Components:GetChildren()) do
    require(Component)
end

Knit.Start():andThen(function()
    Cmdr:RegisterDefaultCommands()
    Cmdr.Registry:RegisterCommandsIn(ReplicatedStorage.fKit.Common.Cmdr.Commands)
    Cmdr.Registry:RegisterTypesIn(ReplicatedStorage.fKit.Common.Cmdr.Types)
    Cmdr.Registry:RegisterHooksIn(ReplicatedStorage.fKit.Common.Cmdr.Hooks)
end):catch(warn)

_G.UPTIME = os.time()