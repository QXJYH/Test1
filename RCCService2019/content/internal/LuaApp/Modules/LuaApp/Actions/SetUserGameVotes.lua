local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)

--[[
	universeId: string,
	canVote = boolean,
	userVote = string,
	reasonForNotVoteable = string,
]]

return Action(script.Name, function(universeId, canVote, userVote, reasonForNotVoteable)
	assert(type(universeId) == "string", "SetUserGameVotes: universeId must be a string")
	assert(type(canVote) == "boolean", "SetUserGameVotes: canVote must be a boolean")
	assert(type(userVote) == "string", "SetUserGameVotes: userVote must be a string")
	assert(type(reasonForNotVoteable) == "string", "SetUserGameVotes: reasonForNotVoteable must be a string")

	return {
		universeId = universeId,
		canVote = canVote,
		userVote = userVote,
		reasonForNotVoteable = reasonForNotVoteable,
	}
end)