local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(key, nextDataExpirationTime)
	assert(type(key) == "string", "SetNextDataExpirationTime: key must be a string!")
	assert(type(nextDataExpirationTime) == "number" and nextDataExpirationTime > 0,
		"SetNextDataExpirationTime: nextDataExpirationTime must be a positive number!")

	return {
		key = key,
		nextDataExpirationTime = nextDataExpirationTime,
	}
end)