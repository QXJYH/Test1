local Modules = game:GetService("CoreGui").RobloxGui.Modules

local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.LuaApp.Actions.SetCentralOverlay)

return function(universeId, theme, menuPosition, menuWidth)
	return function(store)
		store:dispatch(SetCentralOverlay(OverlayType.GameDetailMore, {
			universeId = universeId,
			theme = theme,
			menuPosition = menuPosition,
			menuWidth = menuWidth,
		}))
	end
end