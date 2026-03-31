local Modules = game:GetService("CoreGui").RobloxGui.Modules
local ChinaCatalogCard = require(Modules.LuaApp.Themes.Catalog.China.ChinaCatalogCard)

return function()
	return {
		ChinaCatalogCard = ChinaCatalogCard.new(),
	}
end