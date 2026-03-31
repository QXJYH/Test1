local Modules = game:getService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
		https://games.roblox.com/docs#!/Games/get_v1_games_games_product_info

	input: list of universe ids,
	output:
	{
		"data": [
			{
				"universeId": number,
				"isForSale": boolean,
				"productId": number,
				"price": number,
				"sellerId": number,
			}
		]
	}
]]

local MAX_UNIVERSE_IDS = 100

return function(requestImpl, universeIds)
	assert(type(universeIds) == "table", "GamesGetProductInfo request expects universeIds to be a table")
	assert(#universeIds > 0, "GamesGetProductInfo request expects universeIds count to be greater than 0")
	assert(#universeIds <= MAX_UNIVERSE_IDS,
		"GamesGetProductInfo request expects universeIds count to not exceed " .. MAX_UNIVERSE_IDS)

	local universeIdList = table.concat(universeIds, ",")
	local url = string.format("%sv1/games/games-product-info?universeIds=%s", Url.GAME_URL, universeIdList)

	return requestImpl(url, "GET")
end