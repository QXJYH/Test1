local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return Action(script.Name, function(locked)
	return {
		locked = ArgCheck.isType(locked, "boolean", "locked"),
	}
end)
