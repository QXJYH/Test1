local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

if FFlagLuaNavigationLockRefactor then
	return Action(script.Name, function(route)
		return {
			route = ArgCheck.isTypeOrNil(route, "table", "route"),
		}
	end)
else
	return Action(script.Name, function(route)
		ArgCheck.isType(route, "table", "ApplyResetNavigationHistory expects route to be a table")

		return {
			route = route,
		}
	end)
end
