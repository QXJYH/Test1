local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")

local AppTempCommon = CorePackages.AppTempCommon
local LuaApp = CoreGui.RobloxGui.Modules.LuaApp

local Promise = require(AppTempCommon.LuaApp.Promise)
local CatalogWebApi = require(LuaApp.Components.Catalog.CatalogWebApi)
local SetAssetThumbnailsAction = require(LuaApp.Actions.Catalog.SetAssetThumbnailsAction)
local ApiFetchThumbnails = require(AppTempCommon.LuaApp.Utils.ApiFetchThumbnails)

return function(networkImpl, assetIds, thumbnailSize)
	return function(store)
		local state = store:getState()

		-- Filter out the icons that are already in the store.
		local idsToGet = {}
		for _, targetId in pairs(assetIds) do
			local assetInfo = state.CatalogAppReducer.Assets[tostring(targetId)]
			if assetInfo == nil or assetInfo.thumbnails[tostring(thumbnailSize)] == nil then
				table.insert(idsToGet, targetId)
			end
		end

		if #idsToGet == 0 then
			return Promise.resolve()
		else
			return ApiFetchThumbnails.Fetch(
				networkImpl,
				idsToGet,
				thumbnailSize,
				"Asset",
				CatalogWebApi.FetchAssetThumbnails,
				SetAssetThumbnailsAction,
				store
			)
		end
	end
end