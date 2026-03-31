local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ApplyNavigateToRoute = require(Modules.LuaApp.Actions.ApplyNavigateToRoute)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

if FFlagLuaNavigationLockRefactor then
	return function(route, bypassNavigationLock)
		ArgCheck.isType(route, "table", "route")
		ArgCheck.isTypeOrNil(bypassNavigationLock, "boolean", "bypassNavigationLock")

		return function(store)
			store:dispatch(ApplyNavigateToRoute(route, bypassNavigationLock))
		end
	end
else
	return function(route, navLockEndTime)
		assert(type(route) == "table",
			string.format("NavigateToRoute thunk expects route to be a table, was %s", type(route)))
		assert(type(navLockEndTime) == "nil" or type(navLockEndTime) == "number",
			string.format("NavigateToRoute thunk expects navLockEndTime to be nil or a number, was %s", type(navLockEndTime)))

		return function(store)
			local state = store:getState()

			if state.Navigation.lockTimer > tick() then
				return
			end

			store:dispatch(ApplyNavigateToRoute(route, navLockEndTime))
		end
	end
end
