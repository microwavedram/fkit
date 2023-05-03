local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Signal = require(ReplicatedStorage.fKit.Packages.Signal)

local InputHandler = {}
InputHandler.__index = InputHandler

function InputHandler.new()
    local self = setmetatable({}, InputHandler)

    self.Connections = {}

    return self
end

function InputHandler:__call(Properties: { Event:  "InputBegan" | "InputChanged" | "InputEnded", AllowGameProcessed: boolean, Filter: {[string]: any} })
    local Input = Signal.new()

    self.Connections[#self.Connections+1] = UserInputService[Properties.Event]:Connect(function(input, gameProcessed)
        if gameProcessed == true and Properties.AllowGameProcessed ~= true then return end

        for Property, Value in pairs(Properties.Filter) do
            if input[Property] ~= Value then
                return
            end
        end

        Input:Fire(input)
    end)

    return Input
end

function InputHandler:DisconnectAll()
    for _,v in pairs(self.Connections) do
        v:Disconnect()
    end
end

return InputHandler