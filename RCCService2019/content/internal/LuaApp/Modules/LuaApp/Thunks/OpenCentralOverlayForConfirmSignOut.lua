local Modules = game:GetService("CoreGui").RobloxGui.Modules

local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.LuaApp.Actions.SetCentralOverlay)

return function(continueFunc, theme)
	return function(store)
		store:dispatch(SetCentralOverlay(OverlayType.ConfirmSignOut, {
			continueFunc = continueFunc,
			theme = theme,
		}))
	end
end