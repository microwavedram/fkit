local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.fKit.Packages.Component)

local Test = Component.new{ Tag = "Test", Ancestors = {workspace}, Extensions = {} }

function Test:Construct()
    
end

function Test:Start()
    
end

function Test:SteppedUpdate(dt)
    
end

function Test:Stop()
    
end

return Test