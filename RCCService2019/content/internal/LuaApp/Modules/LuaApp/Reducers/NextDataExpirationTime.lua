local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local SetNextDataExpirationTime = require(Modules.LuaApp.Actions.SetNextDataExpirationTime)

return function(state, action)
	state = state or {}

	if action.type == SetNextDataExpirationTime.name then
		state = Immutable.Set(state, action.key, action.nextDataExpirationTime)
	end

	return state
end