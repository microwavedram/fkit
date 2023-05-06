local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Logger = require(ReplicatedStorage.fKit.Common.Modules.Logger)
local LanguageParser = require(ReplicatedStorage.fKit.Common.Modules.LanguageParser)

local ResourceService

local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

local fKitService = Knit.CreateService {
    Name = "fKitService",
    Client = {},
}

function fKitService:KnitStart()
    local InterfaceContainer = ResourceService:GetResource("Interface")
    
    local function PlayerAdded(Player)
        for _, Interface in pairs(InterfaceContainer:GetChildren()) do
            Interface:Clone().Parent = Player.PlayerGui
        end
    end

    Players.PlayerAdded:Connect(PlayerAdded)
end

function fKitService:KnitInit()
    ResourceService = Knit.GetService("ResourceService")

    self.Logger = Logger.new("fKit Server", RunService:IsStudio())
    
    self.Logger("fKit server initialisation start")
    self.Logger(`Setting up Language "{Config.LANGUAGE}"`)
    
    local Language = require(ReplicatedStorage.fKit.Configuration.Languages:FindFirstChild(Config.LANGUAGE))
    self.LanguageParser = LanguageParser.new(Language)
    self.Logger._languageParser = self.LanguageParser

    self.Logger("log.startup.success")
end

return fKitService