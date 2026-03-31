local Modules = game:GetService("CoreGui").RobloxGui.Modules
local RoactAnalytics = require(script.Parent.RoactAnalytics)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local buttonClick = require(Modules.LuaApp.Analytics.Events.buttonClick)

local BottomBarAnalytics = {}

function BottomBarAnalytics.get(context)
	local eventStreamImpl = RoactAnalytics.get(context).EventStream

	local service = {}

	function service.ButtonActivated(associatedPageType, currentPage)
		ArgCheck.isType(associatedPageType, "string", "associatedPageType")
		ArgCheck.isType(currentPage, "string", "currentPage")

		buttonClick(eventStreamImpl, "BottomBarButton", associatedPageType, currentPage)
	end

	return service
end

return BottomBarAnalytics
