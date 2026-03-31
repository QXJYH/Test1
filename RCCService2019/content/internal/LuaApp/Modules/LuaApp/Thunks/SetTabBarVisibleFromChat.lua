local Modules = game:GetService("CoreGui").RobloxGui.Modules

local AppPage = require(Modules.LuaApp.AppPage)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local SetTabBarVisible = require(Modules.LuaApp.Actions.SetTabBarVisible)

return function(isVisible)
	ArgCheck.isType(isVisible, "boolean", "SetTabBarVisibleFromChat.isVisible")

	return function(store)
		local curState = store:getState()
		local routeHistory = curState.Navigation.history
		local currentRootPageName = routeHistory[#routeHistory][1].name
		if currentRootPageName == AppPage.Chat and curState.TabBarVisible ~= isVisible then
			store:dispatch(SetTabBarVisible(isVisible))
		end
	end
end