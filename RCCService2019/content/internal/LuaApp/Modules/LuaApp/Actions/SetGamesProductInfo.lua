local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)

--[[
	{
		gamesProductInfo : table of GameProductInfo models
    }
]]

return Action(script.Name, function(gamesProductInfo)
	return {
		gamesProductInfo = gamesProductInfo,
	}
end)
