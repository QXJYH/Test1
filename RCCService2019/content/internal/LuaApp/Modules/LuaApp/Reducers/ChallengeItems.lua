local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GetCLBSettings = require(Modules.LuaApp.GetCLBSettings)

return function(state, action)
	state = state or GetCLBSettings.GetChallengeItems()

	return state
end