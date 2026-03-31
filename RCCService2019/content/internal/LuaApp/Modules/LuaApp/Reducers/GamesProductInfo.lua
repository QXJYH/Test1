local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local SetGamesProductInfo = require(Modules.LuaApp.Actions.SetGamesProductInfo)

return function(state, action)
	state = state or {}

	if action.type == SetGamesProductInfo.name then
		state = Immutable.JoinDictionaries(state, action.gamesProductInfo)
	end

	return state
end