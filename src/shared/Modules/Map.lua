--!strict
local HttpService = game:GetService("HttpService")

export type Map = {
    new: () -> Map,
    Add: (Map) -> string,
    Has: (Map) -> boolean,
    Remove: (Map) -> boolean,
    Get: (Map) -> any
}

local Map = {}
Map.__index = Map

function Map.new()
    local self = setmetatable({}, Map)
    self._content = {}
    return self
end

function Map:Add(Index, Item)
    local generateIndex = Item == nil
    if Item == nil then Item = Index end

    if generateIndex then
        while true do
            Index = HttpService:GenerateGUID(false)
            if self._content[Index] == nil then
                break
            end
        end
    end

    self._content[Index] = Item
    return Index
end

function Map:Has(Index: string)
    local Item = self._content[Index]
    return Item ~= nil
end

function Map:Remove(Index: string)
    local Item = self._content[Index]
    self._content[Index] = nil
    return Item ~= nil
end

function Map:Get(Index: string)
    return self._content[Index]
end

function Map:Shuffle()
    local shuffle = {}
    for _, value in pairs(self._content) do
        shuffle[#shuffle+1] = value
    end

    for i = 1,#shuffle,1 do
        local index
        while true do
            index = math.random(1,#shuffle)
            if index ~= i then
                break   
            end
        end
        local value = shuffle[index]
        shuffle[index] = shuffle[i]
        shuffle[i] =  value
    end

    self._content = shuffle
    return shuffle
end

function Map:Random()
    return if #self._content > 1 then self._content[math.random(1,#self._content)] else self._content[1]
end

function Map:Clear()
    self._content = {}
end

return Map
