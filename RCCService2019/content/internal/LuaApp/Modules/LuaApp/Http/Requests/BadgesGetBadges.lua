local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
		Find document here: https://badges.roblox.com/docs#!/Badges/get_v1_universes_universeId_badges

		This endpoint returns a promise that resolves to:

		[
			{
				"id": 123456,
				"name": "string",
				"description": "string",
				"enabled": false,
				"iconImageId": 123456,
				"created": "1970-01-01T01:23:45.678+09:00",
				"updated": "1970-01-01T01:23:45.678+09:00",
				"statistics": {
					"pastDayAwardedCount": 0,
					"awardedCount": 123456,
					"winRatePercentage": 0
				},
				"awardingUniverse": {
					"id": 123456,
					"name": "string",
					"rootPlaceId": 123456
				}
			}, {...}, ...
		]
]]--

return function(requestImpl, universeId)
	local url = string.format("%sv1/universes/%d/badges", Url.BADGES_URL, universeId)

	return requestImpl(url, "GET")
end
