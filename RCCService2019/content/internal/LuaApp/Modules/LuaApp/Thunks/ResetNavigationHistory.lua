local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ApplyResetNavigationHistory = require(Modules.LuaApp.Actions.ApplyResetNavigationHistory)

return function(route)
	return function(store)
		store:dispatch(ApplyResetNavigationHistory(route))
	end
end