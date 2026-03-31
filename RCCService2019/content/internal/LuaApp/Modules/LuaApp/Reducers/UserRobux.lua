local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local SetUserRobux = require(Modules.LuaApp.Actions.SetUserRobux)

return function(state, action)
	state = state or {}

	if action.type == SetUserRobux.name then
		state = Immutable.Set(state, action.userId, action.robux)
	end

	return state
end
