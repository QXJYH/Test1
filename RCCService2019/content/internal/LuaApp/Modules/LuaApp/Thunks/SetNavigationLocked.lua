local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ApplySetNavigationLocked = require(Modules.LuaApp.Actions.ApplySetNavigationLocked)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return function(locked)
	ArgCheck.isType(locked, "boolean", "locked")

	return function(store)
		store:dispatch(ApplySetNavigationLocked(locked))
	end
end
