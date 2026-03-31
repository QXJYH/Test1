local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(connectionState)
	assert(type(connectionState) == "userdata",
		string.format("AESetConnectionState: expected connectionState to be userdata, was a %s", type(connectionState)))

	return {
		connectionState = connectionState,
	}
end)