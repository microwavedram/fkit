local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

Knit.AddServices(ServerScriptService.Server.Services)

Knit.Start():andThen(function()
    Cmdr:RegisterDefaultCommands()
    Cmdr.Registry:RegisterCommandsIn(ReplicatedStorage.Cmdr.Commands)
    Cmdr.Registry:RegisterTypesIn(ReplicatedStorage.Cmdr.Types)
    Cmdr.Registry:RegisterHooksIn(ReplicatedStorage.Cmdr.Hooks)
end):andThen(function()
    print("Server Started")
end):catch(warn)