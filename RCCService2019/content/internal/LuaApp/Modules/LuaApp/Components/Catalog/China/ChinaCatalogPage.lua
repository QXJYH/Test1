local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)
local ChinaCatalogTheme = require(Modules.LuaApp.Themes.Catalog.China.ChinaCatalogTheme)
local GetGridLayoutSettings = require(Modules.LuaApp.GetGridLayoutSettings)
local Colors = require(Modules.LuaApp.Themes.Colors)
-- Components
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local FitChildren = require(Modules.LuaApp.FitChildren)
local MyRobuxArea = require(Modules.LuaApp.Components.Home.MyRobuxArea)
local AppPage = require(Modules.LuaApp.AppPage)
local AppPageProperties = require(Modules.LuaApp.AppPageProperties)
local AppPageWithNavigationBar = require(Modules.LuaApp.Components.Generic.AppPageWithNavigationBar)
local CatalogGrid = require(Modules.LuaApp.Components.Catalog.China.CatalogGrid)
local ChinaCatalogCard = require(Modules.LuaApp.Components.Catalog.China.ChinaCatalogCard)
-- Thunks
local AEGetAssetInfo = require(Modules.LuaApp.Thunks.AEThunks.AEGetAssetInfo)
-- Constants
local BUY_BUTTON_HEIGHT = 60
local GRID_PADDING = 10
local THUMBNAIL_SIZE = 150
local THUMBNAIL_SIZE_KEY = CatalogConstants.ThumbnailSize["150"]
local THUMBNAIL_SUBDIVIDE_COUNT = 20
local ROBUX_AREA_BACKGROUND_COLOR = Colors.Obsidian

local ChinaCatalogPage = Roact.PureComponent:extend("ChinaCatalogPage")

local function getNavBarSettings(formFactor)
	if formFactor == FormFactor.COMPACT then
		return {
			topBarHeight = 44,
			showRobuxBuyButtonBackground = true,
			buyButtonOffsetTop = 44,
			buyButtonPaddingRight = 20,
		}
	else
		return {
			topBarHeight = 105,
			showRobuxBuyButtonBackground = false,
			buyButtonOffsetTop = 32,
			buyButtonPaddingRight = 42,
		}
	end
end

function ChinaCatalogPage:init()
	self._context.ChinaCatalogTheme = ChinaCatalogTheme()

	self.renderItem = function(entry, cardSize, index)
		local itemInfo
		if entry.itemType == CatalogConstants.ItemType.Asset then
			-- TODO: perform multiget with asset info as we do with bundles once endpoint is available.
			self.props.getAssetInfo(entry.itemId)
			local assetInfo = self.props.assets or {}
			itemInfo = assetInfo[entry.itemId] or {}
		elseif entry.itemType == CatalogConstants.ItemType.Bundle then
			local bundleInfo = self.props.bundleInfo or {}
			itemInfo = bundleInfo[entry.itemId] or {}
		end

		local thumbData = itemInfo.thumbnails or {}
		local thumbnail = thumbData[THUMBNAIL_SIZE_KEY]

		return Roact.createElement(ChinaCatalogCard, {
			LayoutOrder = index,
			Size = cardSize,
			deviceOrientation = self.props.deviceOrientation,
			thumbnail = thumbnail,
			itemInfo = itemInfo,
			itemId = entry.itemId,
			itemType = entry.itemType,
			onActivated = function(...) return self.onActivated(entry.itemId, entry.itemType) end,
		});
	end
end

function ChinaCatalogPage:renderContent(innerPadding)
	local assetIds = self.props.chinaAssetIds
	local bundleIds = self.props.chinaBundleIds
	local screenSize = self.props.screenSize
	local formFactor = self.props.formFactor
	local navBarLayout = getNavBarSettings(formFactor)
	local topBarHeight = navBarLayout.topBarHeight
	local showRobuxBuyButtonBackground = navBarLayout.showRobuxBuyButtonBackground

	if screenSize.X <= innerPadding * 2 or screenSize.Y <= 0 then
		return
	end

	local gridWidth = screenSize.X - innerPadding * 2
	local _, cardWidth = GetGridLayoutSettings.Medium(gridWidth, GRID_PADDING)
	local gridHeight = screenSize.Y - topBarHeight
	local buyButtonHeight = showRobuxBuyButtonBackground and BUY_BUTTON_HEIGHT or 0
	local windowSize = Vector2.new(gridWidth, gridHeight)
	local cardHeight = ChinaCatalogCard.getHeight(cardWidth, windowSize)

	return Roact.createElement(FitChildren.FitFrame, {
		Position = UDim2.new(0, 0, 0, buyButtonHeight),
		Size = UDim2.new(0, windowSize.X, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		fitAxis = FitChildren.FitAxis.Both,
	},{
		CatalogGrid = Roact.createElement(CatalogGrid, {
			Size = UDim2.new(0, windowSize.X, 0, windowSize.Y),
			assetIds = assetIds,
			bundleIds = bundleIds,
			cardSize = Vector2.new(cardWidth, cardHeight),
			hasMoreRows = false,
			renderItem = function(...) return self.renderItem(...) end,
			thumbnailSize = THUMBNAIL_SIZE,
			thumbnailSubdivideCount = THUMBNAIL_SUBDIVIDE_COUNT,
			windowSize = windowSize,
		})
	})
end

function ChinaCatalogPage:render()
	local statusBarHeight = self.props.statusBarHeight
	local globalGuiInset = self.props.globalGuiInset
	local safeAreaPositionY = globalGuiInset.top
	safeAreaPositionY = safeAreaPositionY + statusBarHeight

	local formFactor = self.props.formFactor
	local navBarLayout = getNavBarSettings(formFactor)
	local showRobuxBuyButtonBackground = navBarLayout.showRobuxBuyButtonBackground
	local buyButtonPosition = UDim2.new(0, 0, 0, navBarLayout.buyButtonOffsetTop + safeAreaPositionY)
	local paddingRight = UDim.new(0,navBarLayout.buyButtonPaddingRight)

	local horizontalAlignment
	local backgroundColor
	local backgroundTransparency
	if showRobuxBuyButtonBackground then
		backgroundColor = ROBUX_AREA_BACKGROUND_COLOR
		horizontalAlignment = Enum.HorizontalAlignment.Center
		backgroundTransparency = 0
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		MyRobuxArea = Roact.createElement(MyRobuxArea, {
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			HorizontalAlignment = horizontalAlignment,
			Position = buyButtonPosition,
			paddingRight = paddingRight,
		}),
		AppPageWithNavigationBar = Roact.createElement(AppPageWithNavigationBar, {
			title = AppPageProperties[AppPage.ChinaCatalog].nameLocalizationKey,
			topBuffer = showRobuxBuyButtonBackground and BUY_BUTTON_HEIGHT or 0,
			renderContentOnLoaded = function(...)
				return self:renderContent(...)
			end
		})
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			assets = state.CatalogAppReducer.Assets,
			bundleInfo = state.CatalogAppReducer.Bundles,
			chinaAssetIds = state.CatalogAppReducer.ChinaCatalogItems and state.CatalogAppReducer.ChinaCatalogItems.AssetIds,
			chinaBundleIds = state.CatalogAppReducer.ChinaCatalogItems and state.CatalogAppReducer.ChinaCatalogItems.BundleIds,
			deviceOrientation = state.DeviceOrientation,
			screenSize = state.ScreenSize,
			statusBarHeight = state.TopBar.statusBarHeight,
			globalGuiInset = state.GlobalGuiInset,
		}
	end,
	function(dispatch)
		return {
			getAssetInfo = function(assetId)
				dispatch(AEGetAssetInfo(assetId))
			end,
		}
	end
)(ChinaCatalogPage)
