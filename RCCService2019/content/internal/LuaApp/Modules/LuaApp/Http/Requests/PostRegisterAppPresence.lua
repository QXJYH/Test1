--[[
	Documentation of endpoint:
	https://presence.roblox.com/docs#!/Presence/post_v1_presence_register_app_presence

	Response json - none
]]
local Modules = game:getService("CoreGui").RobloxGui.Modules
local HttpService = game:GetService("HttpService")
local Url = require(Modules.LuaApp.Http.Url)

return function(requestImpl, locationId)
	assert(type(locationId) == "string", "PostRegisterAppPresence request expects locationId to be a string")

	local url = string.format("%s/presence/register-app-presence", Url.PRESENCE_URL)

	local body = HttpService:JSONEncode({
		location = locationId,
	})

	return requestImpl(url, "POST", { postBody = body })
end