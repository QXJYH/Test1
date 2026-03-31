local Modules = game:getService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
	https://economy.roblox.com/docs#%21/Currency/get_v1_users_userId_currency

	input:
		userId
]]

return function(requestImpl, userId)
	assert(type(userId) == "string", "EconomyGetCurrency request expects userId to be a string")

	local url = string.format("%s/v1/users/%s/currency", Url.ECONOMY_URL, userId)

	return requestImpl(url, "GET")
end