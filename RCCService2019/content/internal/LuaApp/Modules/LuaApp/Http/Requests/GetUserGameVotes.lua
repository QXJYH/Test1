local Modules = game:getService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
	https://games.roblox.com/docs#!/Games/get_v1_games_universeId_votes_user

	input:
		universeId
	output:
		{
			canVote : boolean,
			userVote : boolean or nil,
			reasonForNotVoteable : string,
		}
]]

return function(requestImpl, universeId)
	assert(type(universeId) == "string", "GetUserGameVotes request expects universeId to be a string")

	local url = string.format("%sv1/games/%s/votes/user", Url.GAME_URL, universeId)

	return requestImpl(url, "GET")
end