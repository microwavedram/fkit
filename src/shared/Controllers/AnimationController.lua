local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local TableUtil = require(ReplicatedStorage.fKit.Packages.TableUtil)
local Animation = require(ReplicatedStorage.fKit.Common.Modules.Animation)

local AnimationController = Knit.CreateController { Name = "AnimationController" }

--[[keyframe_sequence.Loop = true]]
--[[Keyframe.Time = 0]]
--[[Pose.CFrame]]
--[[Pose.Weight]]

local function merge(x,y)
    local t = {}
    for a,b in pairs(x) do
        t[a] = b
    end
    for c,d in pairs(y) do
        t[c] = d
    end
    return t
end

local function GetPoseData(Keyframe, Parent)

    if Parent:IsA("Keyframe") then
        Keyframe[]
    end

    for _,Pose in pairs(Parent:GetChildren()) do
        Keyframe = merge(Keyframe,GetPoseData(Keyframe, Pose))
    end
    
    return Keyframe
end

function AnimationController:LoadAnimation(Model, KeyframeSequence: KeyframeSequence)
    local Keyframes = {}
    
    


    local AnimationTrack = Animation.new(Model, KeyframeSequence.Name, KeyframeSequence.Loop, Keyframes)

    return AnimationTrack
end

function AnimationController:KnitStart()
    
end

function AnimationController:KnitInit()
    
end

return AnimationController