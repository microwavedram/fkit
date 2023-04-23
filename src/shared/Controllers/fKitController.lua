local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Logger = require(ReplicatedStorage.fKit.Common.Modules.Logger)
local LanguageParser = require(ReplicatedStorage.fKit.Common.Modules.LanguageParser)

local Config = require(ReplicatedStorage.fKit.Configuration.MainConfig)

local fKitController = Knit.CreateController { Name = "fKitController" }

function fKitController:KnitStart()
    self.Logger = Logger.new("fKit Client", RunService:IsStudio())
    
    self.Logger("fKit client initialisation start")
    self.Logger(`Setting up Language "{Config.LANGUAGE}"`)
    
    local Language = require(ReplicatedStorage.fKit.Configuration.Languages:FindFirstChild(Config.LANGUAGE))
    self.LanguageParser = LanguageParser.new(Language)
    self.Logger._languageParser = self.LanguageParser

    self.Logger("log.startup.success")
end

function fKitController:KnitInit()
    
end

return fKitController