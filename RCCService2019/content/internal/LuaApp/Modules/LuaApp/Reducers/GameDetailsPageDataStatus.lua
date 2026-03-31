local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local SetGameDetailsPageDataStatus = require(Modules.LuaApp.Actions.SetGameDetailsPageDataStatus)

return function(state, action)
	state = state or {}

	if action.type == SetGameDetailsPageDataStatus.name then
		state = Immutable.Set(state, action.universeId, action.status)
	end

	return state
end