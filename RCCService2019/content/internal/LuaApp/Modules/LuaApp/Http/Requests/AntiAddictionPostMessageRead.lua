local Modules = game:getService("CoreGui").RobloxGui.Modules
local HttpService = game:GetService("HttpService")
local Url = require(Modules.LuaApp.Http.Url)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

--[[
	https://apis.rcs.roblox.com/screen-time-api/v1/messages/mark-read

	Documentation of endpoint:
	https://apis.rcs.roblox.com/screen-time-api/swagger/v1/swagger.json

	input:
		messageID : string
]]

return function(requestImpl, messageId)
	ArgCheck.isType(messageId, "string", "messageId")

	local url = string.format("%sscreen-time-api/v1/messages/mark-read?messageId=%s", Url.APIS_RCS_URL,messageId)

	return requestImpl(url, "POST", {})
end