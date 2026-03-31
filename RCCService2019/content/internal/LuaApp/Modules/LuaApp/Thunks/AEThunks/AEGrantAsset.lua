local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEAddAssetInfo = require(Modules.LuaApp.Actions.AEActions.AEAddAssetsInfo)
local AEGrantAsset = require(Modules.LuaApp.Actions.AEActions.AEGrantAsset)
local AEAssetModel = require(Modules.LuaApp.Models.AEAssetInfo)
local AEGetAssetInfo = require(Modules.LuaApp.Thunks.AEThunks.AEGetAssetInfo)

return function(assetTypeId, assetId)
	return function(store)
		local assetInfo = { [tostring(assetId)] = AEAssetModel.fromGrantSignal(assetTypeId, assetId) }
		store:dispatch(AEGrantAsset(assetTypeId, assetId))
		store:dispatch(AEAddAssetInfo(assetInfo))
		store:dispatch(AEGetAssetInfo(assetId))
	end
end