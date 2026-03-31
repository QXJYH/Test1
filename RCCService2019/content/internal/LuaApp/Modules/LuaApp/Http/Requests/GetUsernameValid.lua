local Modules = game:getService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)
local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)

--[[
	Documentation of endpoint:
	https://auth.roblox.com/docs#/
]]

local builder = UrlBuilder.new({
	base = Url.AUTH_URL,
	path = "v2/usernames/validate",
	query = "request.username={username}",
})
return function(requestImpl,username)
	local url = builder({["username"] = username})
	
	return requestImpl(url, "GET", {maxRetryCount = 0})
end