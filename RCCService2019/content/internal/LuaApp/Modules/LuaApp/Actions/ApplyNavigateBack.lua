local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

if FFlagLuaNavigationLockRefactor then
	return Action(script.Name, function(bypassNavigationLock)
		return {
			bypassNavigationLock = ArgCheck.isTypeOrNil(bypassNavigationLock, "boolean", "bypassNavigationLock")
		}
	end)
else
	return Action(script.Name, function(timeout)
		assert(type(timeout) == "nil" or type(timeout) == "number",
			string.format("NavigateBack action expects timeout to be nil or a number, was %s", type(timeout)))

		return {
			timeout = timeout,
		}
	end)
end
