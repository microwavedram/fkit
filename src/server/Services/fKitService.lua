local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Logger = require(ReplicatedStorage.fKit.Common.Modules.Logger)
local LanguageParser = require(ReplicatedStorage.fKit.Common.Modules.LanguageParser)

local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

local fKitService = Knit.CreateService {
    Name = "fKitService",
    Client = {},
}

function fKitService:KnitStart()
end

function fKitService:KnitInit()
    self.Logger = Logger.new("fKit Server", RunService:IsStudio())
    
    self.Logger("fKit server initialisation start")
    self.Logger(`Setting up Language "{Config.LANGUAGE}"`)
    
    local Language = require(ReplicatedStorage.fKit.Configuration.Languages:FindFirstChild(Config.LANGUAGE))
    self.LanguageParser = LanguageParser.new(Language)
    self.Logger._languageParser = self.LanguageParser

    self.Logger("log.startup.success")
end

return fKitService