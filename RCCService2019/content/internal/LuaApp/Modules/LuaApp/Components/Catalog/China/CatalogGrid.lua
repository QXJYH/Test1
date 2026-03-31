local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)
local GridView = require(Modules.LuaApp.Components.Generic.GridView)
local FetchBundleInfo = require(Modules.LuaApp.Thunks.Catalog.FetchBundleInfo)
local FetchBundleThumbnails = require(Modules.LuaApp.Thunks.Catalog.FetchBundleThumbnails)
local FetchAssetThumbnails = require(Modules.LuaApp.Thunks.Catalog.FetchAssetThumbnails)
local memoize = require(Modules.Common.memoize)

-- Constants
local GRID_PADDING_X = 10
local GRID_PADDING_Y = 30

local CatalogGrid = Roact.PureComponent:extend("CatalogGrid")

CatalogGrid.defaultProps = {
	assetIds = {},
	bundleIds = {},
}

local function combineCatalogItems(catalogItemsList, itemType, listToAdd)
	if listToAdd then
		for _,value in pairs(listToAdd) do
			local item = {
				itemId = tostring(value),
				itemType = itemType,
			}
			table.insert(catalogItemsList, item)
		end
	end
	return catalogItemsList
end

local selectCatalogItems = memoize(function(bundleIds, assetIds)
	local catalogItems = {}
	combineCatalogItems(catalogItems, CatalogConstants.ItemType.Bundle, bundleIds)
	combineCatalogItems(catalogItems, CatalogConstants.ItemType.Asset, assetIds)
	return catalogItems
end)

function CatalogGrid:init()
	self.fetchCatalogData = function()
		local networking = self.props.networking
		local assetIds = self.props.assetIds
		local bundleIds = self.props.bundleIds
		local thumbnailSize = self.props.thumbnailSize
		local thumbnailSubdivideCount = self.props.thumbnailSubdivideCount

		-- Bundles
		self.props.getBundleThumbnails(networking, bundleIds, thumbnailSize, thumbnailSubdivideCount)
		self.props.fetchBundleInfo(networking, bundleIds, thumbnailSize, thumbnailSubdivideCount)

		-- Assets
		self.props.getAssetThumbnails(networking, assetIds, thumbnailSize, thumbnailSubdivideCount)
	end
end

function CatalogGrid:didMount()
	self.fetchCatalogData()
end

function CatalogGrid:render()
	local windowSize = self.props.windowSize
	local catalogItems = self.props.catalogItems

	return Roact.createElement(GridView, {
		layoutOrder = 1,
		items = catalogItems,
		renderItem = function(...) return self.props.renderItem(...) end,
		windowAbsoluteSize = windowSize,
		itemAbsoluteSize = self.props.cardSize,
		cellPaddingOffset = Vector2.new(GRID_PADDING_X, GRID_PADDING_Y),
		numberOfRowsToShow = self.props.numberOfRowsToShow,
	})
end

CatalogGrid = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenSize = state.ScreenSize,
			topBarHeight = state.TopBar.topBarHeight,
			catalogItems = selectCatalogItems(props.bundleIds, props.assetIds),
		}
	end,
	function(dispatch)
		return {
			getAssetThumbnails = function(networking, assetIds, thumbnailSize, thumbnailSubdivideCount)
				dispatch(FetchAssetThumbnails(networking, assetIds, thumbnailSize, thumbnailSubdivideCount))
			end,
			getBundleThumbnails = function(networking, bundleIds, thumbnailSize, thumbnailSubdivideCount)
				dispatch(FetchBundleThumbnails(networking, bundleIds, thumbnailSize, thumbnailSubdivideCount))
			end,
			fetchBundleInfo = function(networking, bundleIds)
				dispatch(FetchBundleInfo(networking, bundleIds))
			end,
		}
	end
)(CatalogGrid)

CatalogGrid = RoactServices.connect({
	networking = RoactNetworking,
})(CatalogGrid)

return CatalogGrid