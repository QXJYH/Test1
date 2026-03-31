local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return Action(script.Name, function(bypassNavigationLock)
	return {
		bypassNavigationLock = ArgCheck.isTypeOrNil(bypassNavigationLock, "boolean", "bypassNavigationLock")
	}
end)
