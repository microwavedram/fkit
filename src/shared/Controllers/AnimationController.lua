local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.fKit.Packages.Knit)
local Animation = require(ReplicatedStorage.fKit.Common.Modules.Animation)

local fKitController

local AnimationController = Knit.CreateController { Name = "AnimationController" }

--[[keyframe_sequence.Loop = true]]
--[[Keyframe.Time = 0]]
--[[Pose.CFrame]]
--[[Pose.Weight]]

local function merge(x,y)
    local t = table.clone(x)
    for c,d in pairs(y) do
        t[c] = d
    end
    return t
end

local function GetPoseData(Keyframe, Parent: Keyframe | Pose, Path)
    Path = Path or ""

    local Time = 0
    if Parent:IsA("Keyframe") then
        Time = Parent.Time
    else
        if Parent.Weight > 0 then
            Keyframe[Path] = {CFrame = Parent.CFrame, Weight = Parent.Weight}
        end
    end

    for _,Pose in pairs(Parent:GetChildren()) do
        Keyframe = merge(Keyframe,(GetPoseData(Keyframe, Pose, `{Path}/{Pose.Name}`)))
    end
    
    return Keyframe, Time
end

function AnimationController:GenerateKeyframes(KeyframeSequence: KeyframeSequence)
    local Keyframes = {}
    
    for _,RobloxKeyframe in pairs(KeyframeSequence:GetChildren()) do
        local Keyframe, Time =  GetPoseData({}, RobloxKeyframe)
        Keyframes[#Keyframes+1] = {Time = Time, Keyframe = Keyframe}
    end

    table.sort(Keyframes, function(a,b)
        return a.Time < b.Time
    end)

    return Keyframes
end

function AnimationController:GenerateTransition(Animation1, Animation2, Time)
    fKitController.Logger:Assert(Animation1.Instance == Animation2.Instance, "error.animation.different_models", Animation1.Instance, Animation2.Instance)

    local FromKeyframe = table.clone(Animation1:GetStateAtTime(Animation1.Time))
    local ToKeyframe = table.clone(Animation2.Keyframes[1])

    FromKeyframe.Time = 0
    ToKeyframe.Time = Time

    local Keyframes = {FromKeyframe, ToKeyframe}

    return Animation.new(Animation1.Instance, `Transition[{Animation1.Name},{Animation2.Name}]`, false, Keyframes)
end

function AnimationController:LoadAnimation(Model, KeyframeSequence: KeyframeSequence)
    local Keyframes = self:GenerateKeyframes(KeyframeSequence)

    return Animation.new(Model, KeyframeSequence.Name, KeyframeSequence.Loop, Keyframes)
end

function AnimationController:TransitionAnimations(Animation1, Animation2, Time)
    fKitController.Logger:Assert(Animation2.Playing == false, "error.animation.transition_to_animation_playing", Animation2)

    local Transition = self:GenerateTransition(Animation1, Animation2, Time)

    Animation1:Stop()
    Transition:Play()
    Transition.Ended:Wait()
    Animation2:Play()
end

function AnimationController:KnitStart()
    fKitController = Knit.GetController("fKitController")

    local a = self:LoadAnimation(workspace.AnimationTest,workspace.AnimationTest.AnimSaves.Movement)
    local b = self:LoadAnimation(workspace["Development Arms"],workspace["Development Arms"].AnimSaves.ADS)

    a:Play()
    b:Play()
end

function AnimationController:KnitInit()
    
end

return AnimationController