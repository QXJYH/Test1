local Modules = game:getService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)
local HttpService = game:GetService("HttpService")

--[[
	Documentation of endpoint:
	https://auth.roblox.com/v1/login

]]

local url = string.format("%sv1/login", Url.AUTH_URL)
local LoginRequests = {}

LoginRequests.logByUsername = function(requestImpl, username, password)
	local payload = HttpService:JSONEncode({
		ctype = "Username",
		cvalue = username,
		password = password,
	})
	return requestImpl(url, "POST", { postBody = payload, maxRetryCount = 0 })
end

LoginRequests.logByEmail = function(requestImpl, email, password)
	local payload = HttpService:JSONEncode({
		ctype = "Email",
		cvalue = email,
		password = password,
	})
	return requestImpl(url, "POST", { postBody = payload, maxRetryCount = 0 })
end

LoginRequests.logByPhone = function(requestImpl, phone, password)
	local payload = HttpService:JSONEncode({
		ctype = "Phone",
		cvalue = phone,
		password = password,
	})
	return requestImpl(url, "POST", { postBody = payload, maxRetryCount = 0 })
end

return LoginRequests