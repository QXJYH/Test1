local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Cryo)
local SetGamePasses = require(Modules.LuaApp.Actions.SetGamePasses)

return function(state, action)
	state = state or {}

	if action.type == SetGamePasses.name then
		state = Cryo.Dictionary.join(state, {
			[action.universeId] = action.passes
		})
	end

	return state
end
