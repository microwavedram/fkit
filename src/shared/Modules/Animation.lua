local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local TableUtil = require(ReplicatedStorage.fKit.Packages.TableUtil)
local Signal = require(ReplicatedStorage.fKit.Packages.Signal)

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

function AnimationTrack.new(Model, Name, Loop, Keyframes)
    local self = setmetatable({}, AnimationTrack)

    self.Name = Name

    self.Loop = Loop
    self.Keyframes = Keyframes
    
    self.Instance = Model
    self.Time = 0
    self.Speed = 1
    self.Length = self.Keyframes[#self.Keyframes].Time
    self.Playing = false

    self.Ended = Signal.new()

    return self
end

function AnimationTrack:FindPreviousKeyframe(Time, Path)
    for _,Keyframe in pairs(TableUtil.Reverse(self.Keyframes)) do
        if Keyframe.Keyframe[Path] == nil then continue end

        if Keyframe.Time < Time then
            if Keyframe.Keyframe[Path].Weight > 0 then
                return Keyframe
            end
        end
    end
end

function AnimationTrack:FindNextKeyframe(Time, Path)
    for _,Keyframe in pairs(self.Keyframes) do
        if Keyframe.Keyframe[Path] == nil then continue end

        if Keyframe.Time > Time then
            if Keyframe.Keyframe[Path].Weight > 0 then
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
    local Sections: table = {select(2,table.unpack(string.split(Path, "/")))}

    local Item = Root
    for _,Section in pairs(Sections) do
        Item = Item:FindFirstChild(Section)
    end
    
    return Item
end

function AnimationTrack:GetJointInstance(Name)
    for _,Motor6D in pairs(self.Instance:GetDescendants()) do
        if Motor6D:IsA("Motor6D") then
            if Motor6D.Name == Name then
                return Motor6D
            end
        end
    end
end

function AnimationTrack:GetJointName(Path)
    local Sections = string.split(Path,"/")
    return Sections[#Sections]
end

function AnimationTrack:GetStateAtTime(Time)
    local Keyframes = {}

    for _,JointPath in pairs(self:GetAllJoints()) do
        local Joint = self:GetJointInstance(self:GetJointName(JointPath))

        local Previous = self:FindPreviousKeyframe(Time, JointPath)
        local Next = self:FindNextKeyframe(Time, JointPath)

        if Previous == nil then
            Joint.C1 = Next.Keyframe[JointPath].CFrame:Inverse()
            continue
        end
        if Next == nil then
            continue
        end
        
        -- print(Previous, Next)

        local Alpha = (Time-Previous.Time)/(Next.Time-Previous.Time)
        -- print(Previous.Keyframe[JointPath], Next.Keyframe[JointPath], Alpha)

        Keyframes[JointPath] = {
            CFrame = Previous.Keyframe[JointPath].CFrame:Lerp(Next.Keyframe[JointPath].CFrame, Alpha);
            Weight = 1;
        }
    end

    return {
        Time = Time,
        Keyframe = Keyframes
    }
end

function AnimationTrack:SetStateAtTime(Time)
    for _,JointPath in pairs(self:GetAllJoints()) do
        local Joint = self:GetJointInstance(self:GetJointName(JointPath))

        local Previous = self:FindPreviousKeyframe(Time, JointPath)
        local Next = self:FindNextKeyframe(Time, JointPath)

        if Previous == nil then
            Joint.C1 = Next.Keyframe[JointPath].CFrame:Inverse()
            continue
        end
        if Next == nil then
            continue
        end
        
        -- print(Previous, Next)

        local Alpha = (Time-Previous.Time)/(Next.Time-Previous.Time)
        -- print(Previous.Keyframe[JointPath], Next.Keyframe[JointPath], Alpha)

        Joint.C1 = Previous.Keyframe[JointPath].CFrame:Lerp(Next.Keyframe[JointPath].CFrame, Alpha):Inverse()
    end
end

function AnimationTrack:GetUpdatePositionUpdateSignal(Path)
    local Joint = self:GetJointInstance(self:GetJointName(Path))

    return Joint:GetPropertyChangedSignal("C1")
end

function AnimationTrack:Play()
    self.Id = HttpService:GenerateGUID(false)
    RunService:BindToRenderStep(`fKit.Animation.{self.Id}`, Enum.RenderPriority.Camera.Value + 1, function(dt)
        if self.Playing == false then return end
        self.Time = self.Time + (dt * self.Speed)

        if self.Time > self.Length then
            if self.Loop == true then
                self.Time = 0
            else
                self:Stop()
                self.Ended:Fire()
            end
        end

        self:SetStateAtTime(self.Time)
    end)
    self.Playing = true
    return self.id
end

function AnimationTrack:Stop()
    RunService:UnbindFromRenderStep(`fkit.Animation.{self.Id}`)
    self.Playing = false
end

function AnimationTrack:Destroy()
    
end

return AnimationTrack