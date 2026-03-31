local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local NavigateToRoute = require(Modules.LuaApp.Thunks.NavigateToRoute)
local Cryo = require(CorePackages.Cryo)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

if FFlagLuaNavigationLockRefactor then
	return function(page, bypassNavigationLock)
		ArgCheck.isType(page, "table", "page")
		ArgCheck.isTypeOrNil(bypassNavigationLock, "boolean", "bypassNavigationLock")

		return function(store)
			local state = store:getState()

			local oldRoute = state.Navigation.history[#state.Navigation.history]
			local truncatedRoute = Cryo.List.removeIndex(oldRoute, #oldRoute)
			local newRoute = Cryo.List.join(truncatedRoute, { page })
			store:dispatch(NavigateToRoute(newRoute, bypassNavigationLock))
		end
	end
else
	return function(page, navLockEndTime)
		assert(type(page) == "table", "NavigateSideways thunk expects page to be a table")
		assert(type(navLockEndTime) == "nil" or type(navLockEndTime) == "number",
			"NavigateSideways thunk expects navLockEndTime to be nil or a number")

		return function(store)
			local state = store:getState()

			local oldRoute = state.Navigation.history[#state.Navigation.history]
			local truncatedRoute = Immutable.RemoveFromList(oldRoute, #oldRoute)
			local newRoute = Immutable.Append(truncatedRoute, page)
			store:dispatch(NavigateToRoute(newRoute, navLockEndTime))
		end
	end
end
