--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Map = require(ReplicatedStorage.fKit.Common.Modules.Map)

local BASE_FOLDER = ServerScriptService.fKit.Resources

type ResourceContainer = ScreenGui

local fKitService

local ResourceService = Knit.CreateService {
    Name = "ResourceService",
    Client = {},
}

ResourceService.ResourceContainers = Map.new()


function ResourceService:GetResource(path) : Instance
    local item = BASE_FOLDER
    for _, part in pairs(string.split(path,"/")) do
        item = item[part]
    end
    return item
end

function ResourceService:KnitStart()
    fKitService = Knit.GetService("fKitService")

    Players.PlayerAdded:Connect(function(player)
        local ResourcesContainer = Instance.new("ScreenGui")
        ResourcesContainer.Name = "Resources"
        ResourcesContainer.Parent = player.PlayerGui
        ResourcesContainer.ResetOnSpawn = false

        self.ResourceContainers:Add(player, ResourcesContainer)
    end)
end

function ResourceService:KnitInit()
    
end

function ResourceService.Client:RequestResource(client, path)
    local ServerResource: Instance = self.Server:GetResource(path)
    
    if ServerResource == nil then fKitService.Logger:Debug("debug.resource_requested_no_exist", path); return end
    if ServerResource:GetAttribute("Client") ~= true then fKitService.Logger:Debug("debug.resource_requested_no_permission", path); return end

    local Container: ResourceContainer = self.Server.ResourceContainers:Get(client)
    
    local ClientResource = ServerResource:Clone()
    ClientResource.Name = HttpService:GenerateGUID(false)
    ClientResource.Parent = Container

    return ClientResource
end

return ResourceService