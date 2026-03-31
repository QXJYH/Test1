local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Find document here:
	https://games.roblox.com/docs#!/Games/get_v1_games_recommendations_game_universeId

	This endpoint returns a promise that resolves to:

	{
		"games": [
		{
			"creatorId": 0,
			"creatorName": "string",
			"creatorType": "string",
			"totalUpVotes": 0,
			"totalDownVotes": 0,
			"universeId": 0,
			"name": "string",
			"placeId": 0,
			"playerCount": 0,
			"imageToken": "string",
			"users": [
			{
				"userId": 0,
				"gameId": "string"
			}, {...}, ... ],
			"isSponsored": true,
			"nativeAdData": "string",
			"price": 0,
			"analyticsIdentifier": "string"
		}, {...}, ... ],
		"nextPaginationKey": "string",
	}

	requestImpl - (function<promise<HttpResponse>>(url, requestMethod, options))
	argTable - (Table) of argument that is passed into the request

	A sample argTable:
	{
		-- The key of a page, which includes the start row index and all other necessary information to
		-- query the data. This parameter is usually not needed for the first page.
		paginationKey = "SOME_PAGINATION_KEY",

		-- Must be aware that the games returned might be less than (filtered content) the number specified in maxRows.
		-- When not specified, Api defaults this to 20.
		maxRows = 20,
	}
]]--
return function(requestImpl, universeId, argTable)
	assert(type(universeId) == "string", "GameGetRecommendedGames request expects universeId to be a string")

	-- construct the url
	local args = Url:makeQueryString(argTable)
	local url = string.format("%sv1/games/recommendations/game/%s?%s", Url.GAME_URL, universeId, args)

	-- return a promise of the result listed above
	return requestImpl(url, "GET")
end