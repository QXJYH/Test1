local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local SetRecommendedGameEntries = require(Modules.LuaApp.Actions.SetRecommendedGameEntries)

return function(state, action)
	state = state or {}

	if action.type == SetRecommendedGameEntries.name then
		state = Immutable.Set(state, action.universeId, action.entries)
	end
	return state
end
