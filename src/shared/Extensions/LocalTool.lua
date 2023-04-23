local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local LocalTool = {}
function LocalTool.ShouldConstruct(component) 
    if LocalPlayer.Character then
        if component.Instance:IsDescendantOf(LocalPlayer.Backpack) then
            return true
        end
    end
    return false
end

return LocalTool