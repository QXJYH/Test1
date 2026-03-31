local Modules = game:getService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
	https://api.roblox.com/users/account-info

]]

return function(requestImpl)
	local url = string.format("%susers/account-info", Url.API_URL)

	return requestImpl(url, "GET", {maxRetryCount = 0})
end