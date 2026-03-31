local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
	https://ads.roblox.com/docs#!/SponsoredPages/get_v1_sponsored_pages

	This endpoint returns a promise that resolves to:
	[{
		"name": "string",
		"title": "string",
		"logoImageUrl": "string",
		"pageType": "string",
		"pagePath": "string"
	},
	{
		"name": "Bloxys2019",
		"title": "Bloxys2019",
		"logoImageUrl": "https://images.rbxcdn.com/4dc0933783a9462bb67029ce1787a65c",
		"pageType": "Event",
		"pagePath": "/event/Bloxys2019"
	}]
]]--

return function(requestImpl)
	local url = string.format("%sv1/sponsored-pages", Url.ADS_URL)
	-- return a promise of the result listed above
	return requestImpl(url, "GET")
end