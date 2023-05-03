local Cancelable = {}
Cancelable.__index = Cancelable

function Cancelable.new()
    local self = setmetatable({}, Cancelable)
    
    self.canceled = false

    return self
end

function Cancelable:AddCancelable(time, func)
    task.delay(time, function()
        if self.canceled == false then
            func()
        end
    end)
end

function Cancelable:Cancel()
    self.canceled = true
end

return Cancelable