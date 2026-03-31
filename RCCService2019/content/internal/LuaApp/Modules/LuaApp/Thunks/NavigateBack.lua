local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ApplyNavigateBack = require(Modules.LuaApp.Actions.ApplyNavigateBack)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

if FFlagLuaNavigationLockRefactor then
	return function(bypassNavigationLock)
		ArgCheck.isTypeOrNil(bypassNavigationLock, "boolean", "bypassNavigationLock")

		return function(store)
			store:dispatch(ApplyNavigateBack(bypassNavigationLock))
		end
	end
else
	return function(navLockEndTime)
		assert(type(navLockEndTime) == "nil" or type(navLockEndTime) == "number",
			"NavigateBack thunk expects navLockEndTime to be nil or a number")

		return function(store)
			local state = store:getState()

			if state.Navigation.lockTimer > tick() then
				return
			end

			store:dispatch(ApplyNavigateBack(navLockEndTime))
		end
	end
end
