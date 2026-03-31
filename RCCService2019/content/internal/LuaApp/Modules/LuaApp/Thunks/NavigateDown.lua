local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local Cryo = require(CorePackages.Cryo)
local NavigateToRoute = require(Modules.LuaApp.Thunks.NavigateToRoute)
local AppPageProperties = require(Modules.LuaApp.AppPageProperties)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

if FFlagLuaNavigationLockRefactor then
	return function(page, bypassNavigationLock)
		ArgCheck.isType(page, "table", "page")
		ArgCheck.isTypeOrNil(bypassNavigationLock, "boolean", "bypassNavigationLock")

		local pageProperties = AppPageProperties[page.name] or {}
		local isNativeWrapper = pageProperties.nativeWrapper or false

		if isNativeWrapper then
			page = Cryo.Dictionary.join(page, { nativeWrapper = true })
		end

		return function(store)
			local state = store:getState()

			local currentRoute = state.Navigation.history[#state.Navigation.history]
			local newRoute = Cryo.List.join(currentRoute, { page })
			store:dispatch(NavigateToRoute(newRoute, bypassNavigationLock))
		end
	end
else
	return function(page)
		assert(type(page) == "table",
			string.format("NavigateDown thunk expects page to be a table, was %s", type(page)))

		local pageProperties = AppPageProperties[page.name] or {}
		local isNativeWrapper = pageProperties.nativeWrapper or false

		if isNativeWrapper then
			page = Immutable.Set(page, "nativeWrapper", true)
		end

		return function(store)
			local state = store:getState()

			local currentRoute = state.Navigation.history[#state.Navigation.history]
			local newRoute = Immutable.Append(currentRoute, page)
			store:dispatch(NavigateToRoute(newRoute, isNativeWrapper and (tick() + 1) or nil))
		end
	end
end
