local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local SetUserGameVotes = require(Modules.LuaApp.Actions.SetUserGameVotes)
local ClearUserGameVotes = require(Modules.LuaApp.Actions.ClearUserGameVotes)

return function(state, action)
	state = state or {}

	if action.type == SetUserGameVotes.name then
		local votes = {
			canVote = action.canVote,
			userVote = action.userVote,
			reasonForNotVoteable = action.reasonForNotVoteable,
		}

		state = Immutable.Set(state, action.universeId, votes)
	elseif action.type == ClearUserGameVotes.name then
		state = Immutable.Set(state, action.universeId, nil)
	end

	return state
end