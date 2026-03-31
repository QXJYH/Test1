local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local LuaApp = Modules.LuaApp
local Cryo = require(CorePackages.Cryo)
local AssetInfo = require(LuaApp.Models.Catalog.AssetInfo)
local SetAssetThumbnailsAction = require(LuaApp.Actions.Catalog.SetAssetThumbnailsAction)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return function(state, action)
	state = state or {}

	if action.type == SetAssetThumbnailsAction.name then
		ArgCheck.isType(action.thumbsData, "table", "ThumbsData must be a table of tables.")
		for key,thumbData in pairs(action.thumbsData) do
			local assetId = tostring(key)
			if not state[assetId] then
				local newAsset = AssetInfo.fromGetThumbnail(thumbData)
				state = Cryo.Dictionary.join(state, { [assetId] = newAsset })
			else
				local updatedAsset = AssetInfo.updateThumbnail(state[assetId], thumbData)
				state = Cryo.Dictionary.join(state, { [assetId] = updatedAsset })
			end
		end
		return state
	end

	return state
end
