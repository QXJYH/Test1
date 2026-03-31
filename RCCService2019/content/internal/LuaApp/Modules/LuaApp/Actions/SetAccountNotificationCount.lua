local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return Action(script.Name, function(accountNotificationCount)
	ArgCheck.isNonNegativeNumber(accountNotificationCount, "SetAccountNotificationCount: accountNotificationCount")

	return {
		accountNotificationCount = accountNotificationCount,
	}
end)