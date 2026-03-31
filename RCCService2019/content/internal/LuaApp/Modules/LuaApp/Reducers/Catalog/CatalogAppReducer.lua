local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AssetsReducer = require(Modules.LuaApp.Reducers.Catalog.Assets)
local BundlesReducer = require(Modules.LuaApp.Reducers.Catalog.Bundles)
local ChinaCatalogItemsReducer = require(Modules.LuaApp.Reducers.Catalog.ChinaCatalogItems)
local BundlesStatus = require(Modules.LuaApp.Reducers.Catalog.BundlesStatus)

return function(state, action)
    state = state or {}
    return {
        ChinaCatalogItems = ChinaCatalogItemsReducer(state.ChinaCatalogItems, action),
        Assets = AssetsReducer(state.Assets, action),
        Bundles = BundlesReducer(state.Bundles, action),
		BundlesStatus = BundlesStatus(state.BundlesStatus, action),
    }
end
