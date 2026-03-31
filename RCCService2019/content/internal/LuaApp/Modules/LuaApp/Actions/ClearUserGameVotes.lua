local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(universeId)
	assert(type(universeId) == "string", "ClearUserGameVotes: universeId must be a string")

	return {
		universeId = universeId,
	}
end)