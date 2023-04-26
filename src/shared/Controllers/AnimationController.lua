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

local function GetPoseData(Keyframe, Parent: Keyframe | Pose, Path)
    local Time = 0
    if Parent:IsA("Keyframe") then
        Time = Parent.Time
        Path = "/"
    else
        if Parent.Weight == 1 then
            Keyframe[Path] = Parent.CFrame
        end
    end

    for _,Pose in pairs(Parent:GetChildren()) do
        Keyframe = merge(Keyframe,(GetPoseData(Keyframe, Pose, `{Path}{Pose.Name}/`)))
    end
    
    return Keyframe, Time
end

function AnimationController:LoadAnimation(Model, KeyframeSequence: KeyframeSequence)
    local Keyframes = {}
    
    for _,RobloxKeyframe in pairs(KeyframeSequence:GetChildren()) do
        local Keyframe, Time =  GetPoseData({}, RobloxKeyframe)
        Keyframes[#Keyframes+1] = {Time = Time, Keyframe = Keyframe}
    end
    
    Keyframes = table.sort(Keyframes, function(a,b)
        return a.Time < b.Time
    end)

    local AnimationTrack = Animation.new(Model, KeyframeSequence.Name, KeyframeSequence.Loop, Keyframes)

    return AnimationTrack
end

function AnimationController:KnitStart()
    
end

function AnimationController:KnitInit()
    
end

return AnimationController