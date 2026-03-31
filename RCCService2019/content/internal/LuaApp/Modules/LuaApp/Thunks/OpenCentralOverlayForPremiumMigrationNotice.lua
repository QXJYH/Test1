local Modules = game:GetService("CoreGui").RobloxGui.Modules

local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.LuaApp.Actions.SetCentralOverlay)

return function(robuxGranted)
	return function(store)
		store:dispatch(SetCentralOverlay(OverlayType.PremiumMigrationNotice, {robuxGranted = robuxGranted}))
	end
end