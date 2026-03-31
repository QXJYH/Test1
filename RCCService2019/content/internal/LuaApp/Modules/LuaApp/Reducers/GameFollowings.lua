local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local SetGameFollowingStatus = require(Modules.LuaApp.Actions.SetGameFollowingStatus)
local SetGameFollow = require(Modules.LuaApp.Actions.SetGameFollow)

return function(state, action)
	state = state or {}

	if action.type == SetGameFollowingStatus.name then
		state = Immutable.Set(state, action.universeId, {
			canFollow = action.canFollow,
			isFollowed = action.isFollowed,
		})
	elseif action.type == SetGameFollow.name then
		local following = state[action.universeId]
		if following then
			following = Immutable.Set(following, "isFollowed", action.isFollowed)
			state = Immutable.Set(state, action.universeId, following)
		end
	end

	return state
end
