local Util = require(script.Parent.Parent.Shared.Util)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local toolType = {
	Transform = function (text)
		local findTool = Util.MakeFuzzyFinder(ReplicatedStorage.Tools:GetChildren())

		return findTool(text)
	end;

	Validate = function (tools)
		return #tools > 0, "No tool with that name could be found."
	end;

	Autocomplete = function (tools)
		return Util.GetNames(tools)
	end;

	Parse = function (tools)
		return tools[1]
	end;
}

return function (cmdr)
	cmdr:RegisterType("tool", toolType)
end
