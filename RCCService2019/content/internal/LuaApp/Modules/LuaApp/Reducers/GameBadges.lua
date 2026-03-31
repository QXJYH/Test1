local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Cryo)
local SetGameBadges = require(Modules.LuaApp.Actions.SetGameBadges)

return function(state, action)
	state = state or {}

	if action.type == SetGameBadges.name then
		state = Cryo.Dictionary.join(state, {
			[action.universeId] = action.badges,
		})
	end

	return state
end
