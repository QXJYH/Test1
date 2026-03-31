local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")

local AppTempCommon = CorePackages.AppTempCommon
local LuaApp = CoreGui.RobloxGui.Modules.LuaApp

local Promise = require(AppTempCommon.LuaApp.Promise)
local CatalogWebApi = require(LuaApp.Components.Catalog.CatalogWebApi)
local ApiFetchThumbnails = require(AppTempCommon.LuaApp.Utils.ApiFetchThumbnails)
local SetBundleThumbnailsAction = require(LuaApp.Actions.Catalog.SetBundleThumbnailsAction)

return function(networkImpl, bundleIds, thumbnailSize)
	return function(store)
		local state = store:getState()

		local idsToGet = {}
		-- Filter out the icons that are already in the store.
		for _, targetId in pairs(bundleIds) do
			local assetInfo = state.CatalogAppReducer.Bundles[tostring(targetId)]
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
				"Bundle",
				CatalogWebApi.FetchBundleThumbnails,
				SetBundleThumbnailsAction,
				store
			)
		end
	end
end