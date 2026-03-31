local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
		Find document here: https://games.roblox.com/docs#!/GamePasses/get_v1_games_universeId_game_passes

		This endpoint returns a promise that resolves to:

		[
			{
				"id": 1234567,
				"name": "string",
				"productId": 12345678,
				"price": 123
			}, {...}, ...
		]
]]--

return function(requestImpl, universeId)
	local url = string.format("%sv1/games/%d/game-passes", Url.GAME_URL, universeId)

	return requestImpl(url, "GET")
end
