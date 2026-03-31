local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AntiAddictionPostMessageRead = require(Modules.LuaApp.Http.Requests.AntiAddictionPostMessageRead)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return function (networkImpl, messageId)
	ArgCheck.isType(messageId, "string", "messageId")
	return function(store)
		return AntiAddictionPostMessageRead(networkImpl, messageId)
	end
end