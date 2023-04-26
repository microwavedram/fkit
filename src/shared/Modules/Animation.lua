local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local TableUtil = require(ReplicatedStorage.fKit.Packages.TableUtil)

local AnimationTrack = {}
AnimationTrack.__index = AnimationTrack

local function isInTable(t,v)
    for _,value in pairs(t) do
        if value == v then
            return true
        end
    end
    return false
end

function AnimationTrack.new(Model, Name, Keyframes, Loop)
    local self = setmetatable({}, AnimationTrack)

    self.Name = Name

    self.Loop = Loop
    self.Keyframes = Keyframes
    
    self.Instance = Model
    self.Time = 0
    self.Speed = 0

    return self
end

function AnimationTrack:FindPreviousKeyframe(Time, Path)
    for _,Keyframe in pairs(TableUtil.Reverse(self.Keyframes)) do
        if Keyframe.Time < Time then
            if Keyframe.Keyframe[Path].Weight == 1 then
                return Keyframe
            end
        end
    end
end

function AnimationTrack:FindNextKeyframe(Time, Path)
    for _,Keyframe in pairs(self.Keyframes) do
        if Keyframe.Time > Time then
            if Keyframe.Keyframe[Path].Weight == 1 then
                return Keyframe
            end
        end
    end
end

function AnimationTrack:GetAllJoints()
    local Joints = {}
    for _,Keyframe in pairs(self.Keyframes) do
        for Path,_ in pairs(Keyframe.Keyframe) do
            if not isInTable(Joints, Path) then
                table.insert(Joints, Path)
            end
        end
    end
    return Joints
end

function AnimationTrack:GetInstanceFromPath(Root,Path)
    local Sections: table = select(2,string.split(Path, "/"))

    local Item = Root
    for _,Section in pairs(Sections) do
        Item = Item:FindFirstChild(Section)
    end
    
    return Item
end

function AnimationTrack:SetStateAtTime(Time)
    for _,JointPath in pairs(self:GetAllJoints()) do
        local Joint = self:GetInstanceFromPath(self.Instance, JointPath)

        local Previous = self:FindPreviousKeyframe(Time, JointPath)
        local Next = self:FindNextKeyframe(Time, JointPath)

        Joint.CFrame = Previous.Keyframe[JointPath]:Lerp(Next.Keyframe[JointPath], (Time-Previous.Time)/(Next.Time-Previous.Time))
    end
end

function AnimationTrack:Play()
    RunService:BindToRenderStep(`fKit.Animation.{HttpService:GenerateGUID(false)}`, Enum.RenderPriority.Camera.Value + 1, function(dt)
        self.Time = self.Time + (dt) * self.Speed
        self:SetStateAtTime(self.Time)
    end)
end

function AnimationTrack:Destroy()
    
end

return AnimationTrack