local PlayerService = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return function(eventStreamImpl, eventContext, name, detail)
	ArgCheck.isType(eventContext, "string", "eventContext")
	ArgCheck.isType(name, "string", "name")

	if detail ~= nil then
		if type(detail) == "number" then
			detail = tostring(detail)
		end
		if type(detail) ~= "string" then
			detail = nil
		end
	end

	local eventName = "luaPageLoad"
	local userId = tostring(PlayerService.LocalPlayer.UserId)
	local locale = LocalizationService.RobloxLocaleId

	eventStreamImpl:setRBXEventStream(eventContext, eventName, {
		uid = userId,
		page = name,
		detail = detail,
		locale = locale,
	})
end
