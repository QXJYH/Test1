local Modules = game:GetService("CoreGui").RobloxGui.Modules

local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.LuaApp.Actions.SetCentralOverlay)

return function(gameName, robuxShortfall, theme, pageFilter)
	return function(store)
		store:dispatch(SetCentralOverlay(OverlayType.PurchaseGameRobuxShortfall, {
			gameName = gameName,
			robuxShortfall = robuxShortfall,
			theme = theme,
			pageFilter = pageFilter,
		}))
	end
end