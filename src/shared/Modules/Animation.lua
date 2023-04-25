local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local AnimationTrack = {}
AnimationTrack.__index = AnimationTrack

function AnimationTrack.new(Model, Name, Keyframes, Loop)
    local self = setmetatable({}, AnimationTrack)

    self.Name = Name

    self.Loop = Loop
    self.Keyframes = Keyframes
    
    self.Instance = Model
    self.Time = 0

    return self
end

function AnimationTrack:GetStateAtTime()
    
end

function AnimationTrack:Play()
    RunService:BindToRenderStep(`fKit.Animation.{HttpService:GenerateGUID(false)}`, Enum.RenderPriority.Camera.Value + 1, function(dt)
        self.Time = self.Time + dt
    end)
end

function AnimationTrack:Destroy()
    
end

return AnimationTrack