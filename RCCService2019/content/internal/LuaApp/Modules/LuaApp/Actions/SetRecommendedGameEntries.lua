local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(universeId, entries)
	return {
		universeId = universeId,
		entries = entries
	}
end)
