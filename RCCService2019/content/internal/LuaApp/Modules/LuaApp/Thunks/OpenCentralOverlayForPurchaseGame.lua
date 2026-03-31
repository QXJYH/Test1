local Modules = game:GetService("CoreGui").RobloxGui.Modules

local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.LuaApp.Actions.SetCentralOverlay)

return function(universeId, gameName, price, productId, sellerId, theme, pageFilter)
	return function(store)
		store:dispatch(SetCentralOverlay(OverlayType.PurchaseGame, {
			universeId = universeId,
			gameName = gameName,
			price = price,
			productId = productId,
			sellerId = sellerId,
			theme = theme,
			pageFilter = pageFilter,
		}))
	end
end