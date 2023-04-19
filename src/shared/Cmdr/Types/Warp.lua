local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")

local Util = require(script.Parent.Parent.Shared.Util)

local warpType = {
	Transform = function (text)
		local findwarp = Util.MakeFuzzyFinder(CollectionService:)

		return findwarp(text)
	end;

	Validate = function (warps)
		return #warps > 0, "No warp with that name could be found."
	end;

	Autocomplete = function (warps)
		return Util.GetNames(warps)
	end;

	Parse = function (warps)
		return warps[1]
	end;
}

return function (cmdr)
	cmdr:RegisterType("warp", warpType)
end
