local Modules = game:getService("CoreGui").RobloxGui.Modules
local HttpService = game:GetService("HttpService")
local Url = require(Modules.LuaApp.Http.Url)
local VoteStatus = require(Modules.LuaApp.Enum.VoteStatus)

local UserVote = {
	[VoteStatus.VotedUp] = true,
	[VoteStatus.VotedDown] = false,
	[VoteStatus.NotVoted] = "null",
}

--[[
	Documentation of endpoint:
	https://games.roblox.com/docs#!/Games/patch_v1_games_universeId_user_votes

	input:
		universeId : string,
		vote : string,
]]

return function(requestImpl, universeId, vote)
	assert(type(universeId) == "string", "GamesPatchUserVotes request expects universeId to be a string")

	local userVote = UserVote[vote]
	assert(userVote ~= nil, "GamesPatchUserVotes request expects a valid vote")

	local url = string.format("%sv1/games/%s/user-votes", Url.GAME_URL, universeId)

	local body = HttpService:JSONEncode({
		vote = userVote,
	})

	return requestImpl(url, "PATCH", { postBody = body })
end