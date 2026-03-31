local GuiService = game:GetService("GuiService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local AEEquipAsset = require(Modules.LuaApp.Components.Avatar.UI.AEEquipAsset)
local AERecommendedFrame = require(Modules.LuaApp.Components.Avatar.UI.AERecommendedFrame)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local AvatarEditorCatalogRecommended = settings():GetFFlag("AvatarEditorCatalogRecommended")
	and not settings():GetFFlag("ChinaLicensingApp")
local AvatarEditorCurrentlyWearingPersistenceLogic2 = settings():GetFFlag("AvatarEditorCurrentlyWearingPersistenceLogic2")
local FFlagAvatarEditorRefactorPageType = settings():GetFFlag("AvatarEditorRefactorPageType")
local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")

local AERenderAssets = Roact.PureComponent:extend("AERenderAssets")
local RECENT_PAGE = 1
local OUTFITS_PAGE = 5

local View = {
	[DeviceOrientationMode.Portrait] = {
		EXTRA_VERTICAL_SHIFT = 8,
		GRID_PADDING = 6,
		INFO_TEXT_COLOR = Color3.fromRGB(65, 78, 89),
		INFO_TEXT_SIZE = 18,
		PAGE_LABEL_SIZE = 17,
	},

	[DeviceOrientationMode.Landscape] = {
		EXTRA_VERTICAL_SHIFT = 8,
		GRID_PADDING = 12,
		INFO_TEXT_COLOR = Color3.fromRGB(255, 255, 255),
		INFO_TEXT_SIZE = 32,
		PAGE_LABEL_SIZE = 0,
	},
}

function AERenderAssets:noAssetsLabelUI(visible)
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEScrollingFrame:getThemeInfo(deviceOrientation, themeName)
	local page = self.props.page

	local NoAssetsLabel = Roact.createElement(LocalizedTextLabel, {
		Text = page.emptyStringKey,
		BackgroundTransparency = 1,
		Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSansLight,
		TextSize = View[deviceOrientation].INFO_TEXT_SIZE,
		BorderSizePixel = 0,
		TextColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.PageLabelTextColor or View[deviceOrientation].INFO_TEXT_COLOR,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, -20),
		Size = UDim2.new(1, 0, 1, 0),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Visible = visible,
	})

	return NoAssetsLabel
end

function AERenderAssets:init()
	self.frameRef = Roact.createRef()

	if AvatarEditorCurrentlyWearingPersistenceLogic2 then
		self.isInitialized = false
		self.assetsToRender = {}
	else
		self.state = {
			assetsToRender = {},
			isInitialized = false,
		}
	end
end

function AERenderAssets:didUpdate(prevProps, prevState)
	local page = self.props.page

	if not AvatarEditorCurrentlyWearingPersistenceLogic2 then
		local frame = self.props.scrollingFrame
		local differentPage = page ~= prevProps.page
		local recentAssets = self.props.recentAssets
		local isRecentPage = (FFlagAvatarEditorRefactorPageType and page.pageType == AEConstants.PageType.RecentAll)
			or (not FFlagAvatarEditorRefactorPageType and page.recentPageType)

		-- Keep a local state of recent assets, to preserve order.
		local assetsToRender = {}

		if differentPage then
			frame.CanvasPosition = Vector2.new(0, 0)

			if isRecentPage and recentAssets then
				assetsToRender = recentAssets
			end
		end

		-- If an asset was revoked from the page you are on, update the list.
		if isRecentPage and not differentPage and #prevState.assetsToRender > #recentAssets then
			self:setState({ assetsToRender = recentAssets, frame = frame })
		elseif isRecentPage and #assetsToRender > 0 then
			self:setState({ assetsToRender = assetsToRender, frame = frame }) -- Update asset list
		elseif isRecentPage and #recentAssets > #prevProps.recentAssets then
			self:setState({ assetsToRender = recentAssets, frame = frame })
		end
	end

	if AEUtils.gamepadNavigationEnabled() and self.props.gamepadNavigationMenuLevel ~= prevProps.gamepadNavigationMenuLevel
		and self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.AssetsPage then
		if page.pageType ~= AEConstants.PageType.BodyColors and page.pageType ~= AEConstants.PageType.Scale then
			local assetsFrame = self.props.scrollingFrame.RenderedAssets.Frame

			if #assetsFrame:GetChildren() > 0 then
				GuiService.SelectedCoreObject = self.props.scrollingFrame.RenderedAssets.Frame:GetChildren()[1]
			end
		end
	end
end

function AERenderAssets:willUpdate(nextProps, nextState)
	if AvatarEditorCurrentlyWearingPersistenceLogic2 then
		local frame = nextProps.scrollingFrame
		local page = nextProps.page
		local differentPage = page ~= self.props.page
		local recentAssets = nextProps.recentAssets
		local equippedAssets = nextProps.equippedAssets or {}
		local isCurrentlyWearingPage = page.pageType == AEConstants.PageType.CurrentlyWearing
		-- Keep a local state of recent assets, to preserve order.
		local assetsToRender = {}
		local isRecentPage = (FFlagAvatarEditorRefactorPageType and page.pageType == AEConstants.PageType.RecentAll)
			or (not FFlagAvatarEditorRefactorPageType and page.recentPageType)

		if frame and (differentPage or self.isInitialized == false) then
			frame.CanvasPosition = Vector2.new(0, 0)

			if isRecentPage and recentAssets then
				assetsToRender = recentAssets
			elseif isCurrentlyWearingPage and next(equippedAssets) ~= nil then
				self.isInitialized = true
				assetsToRender = AEUtils.getEquippedAssetIds(equippedAssets)
			end
		end

		-- If an asset was revoked from the page you are on, update the list.
		if isRecentPage and not differentPage and #self.assetsToRender > #recentAssets then
			self.assetsToRender = recentAssets
		elseif isRecentPage and #assetsToRender > 0 then
			self.assetsToRender = assetsToRender -- Update asset list
		elseif differentPage and isCurrentlyWearingPage then
			self.assetsToRender = assetsToRender -- Update asset list
		elseif isRecentPage and #recentAssets > #self.props.recentAssets then
			self.assetsToRender = recentAssets
		end
	end
end

function AERenderAssets:render()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEScrollingFrame:getThemeInfo(deviceOrientation, themeName)
	local scrollingFrame = self.props.scrollingFrame
	local equippedAssets = self.props.equippedAssets or {}
	local ownedAssets = self.props.ownedAssets
	local page = self.props.page
	local assetTypeToRender = self.props.assetTypeToRender
	local categoryIndex = self.props.categoryIndex
	local analytics = self.props.analytics
	local assetButtonSize = self.props.assetButtonSize
	local assetsToRender = {}
	local assets = {}
	local canvasSize = UDim2.new(0, 0, 1, 0)
	local noAssetsLabel = nil
	local recommendedFrame = nil
	local isCostumePage = categoryIndex == OUTFITS_PAGE
	local buttonsPerRow = themeInfo.OrientationTheme.ButtonsPerRow
	local assetCardsToRender = self.props.assetCardsToRender
	local assetCardIndexStart = (self.props.assetCardIndexStart - 1) * buttonsPerRow + 1
	local isRecentPage = (FFlagAvatarEditorRefactorPageType and page.pageType == AEConstants.PageType.RecentAll)
			or (not FFlagAvatarEditorRefactorPageType and page.recentPageType)

	if assetTypeToRender == AEConstants.AvatarAssetGroup.Owned then
		assetsToRender = ownedAssets[page.assetTypeId]
	elseif assetTypeToRender == AEConstants.AvatarAssetGroup.Recent or (AvatarEditorCurrentlyWearingPersistenceLogic2 and
		assetTypeToRender == AEConstants.AvatarAssetGroup.Equipped) then
		if AvatarEditorCurrentlyWearingPersistenceLogic2 then
			assetsToRender = self.assetsToRender
		else
			assetsToRender = self.state.assetsToRender
		end
	elseif not AvatarEditorCurrentlyWearingPersistenceLogic2 and
		assetTypeToRender == AEConstants.AvatarAssetGroup.Equipped then
		assetsToRender = AEUtils.getEquippedAssetIds(equippedAssets)
	elseif assetTypeToRender == AEConstants.AvatarAssetGroup.None then
		return nil
	end

	if assetsToRender and self.props.scrollingFrame then
		local assetCardIndexEnd = math.min(#assetsToRender, assetCardIndexStart + assetCardsToRender - 1)
		canvasSize = UDim2.new(0, 0, 0,
			(math.ceil(#assetsToRender / buttonsPerRow) ) * (assetButtonSize + View[deviceOrientation].GRID_PADDING)
			+ View[deviceOrientation].GRID_PADDING
			+ View[deviceOrientation].EXTRA_VERTICAL_SHIFT + View[deviceOrientation].PAGE_LABEL_SIZE)
		for index = assetCardIndexStart, assetCardIndexEnd do
			local asset = assetsToRender[index]
			local isOutfit = (page.name == AEConstants.OUTFITS or page.name == AEConstants.PRESET_COSTUMES) and true or false

			local image = AEUtils.getThumbnail(isOutfit, asset)

			assets[index] = Roact.createElement(AEEquipAsset, {
				displayType = AEConstants.EquipAssetTypes.AssetCard,
				analytics = analytics,
				deviceOrientation = deviceOrientation,
				isOutfit = isOutfit,
				assetButtonSize = assetButtonSize,
				index = index, -- Current asset card #
				cardImage = image,
				assetId = asset,
			})
		end
	end

	if assetsToRender then
		-- if we don't have any assets to render, display a label in our scrolling frame
		local displayNoAssetsLabel = #assetsToRender == 0

		-- Don't display this label if we are still fetching data from the API.
		if isRecentPage and self.props.recentAssetsStatus[page.itemType] ~= RetrievalStatus.Done
			or (page.pageType == AEConstants.PageType.CurrentlyWearing
			and self.props.avatarDataStatus ~= RetrievalStatus.Done)
			or (isCostumePage and self.props.userOutfitsStatus[page.assetTypeId] ~= RetrievalStatus.Done) then
			displayNoAssetsLabel = false
		end

		noAssetsLabel = self:noAssetsLabelUI(displayNoAssetsLabel)

		if AvatarEditorCatalogRecommended then
			local recommendedYPosition = canvasSize.Y.Offset + 5
			recommendedFrame = Roact.createElement(AERecommendedFrame, {
				deviceOrientation = deviceOrientation,
				scrollingFrame = scrollingFrame,
				assetsToRender = assetsToRender,
				page = page,
				recommendedYPosition = recommendedYPosition,
				assetButtonSize = assetButtonSize,
			})
			if categoryIndex ~= RECENT_PAGE and categoryIndex ~= OUTFITS_PAGE and self.props.scrollingFrame then
				canvasSize = UDim2.new(0, 0, 0,
					(math.ceil(#assetsToRender / buttonsPerRow) + 1 ) * (assetButtonSize
					+ View[deviceOrientation].GRID_PADDING)
					+ View[deviceOrientation].GRID_PADDING
					+ 2 * themeInfo.OrientationTheme.ExtraVerticalShift
					+ themeInfo.OrientationTheme.BonusYPixels)
			end
		end

		if not AvatarEditorCatalogRecommended then
			if self.props.scrollingFrame and #assetsToRender > 0 then
				self.props.scrollingFrame.CanvasSize = canvasSize
			elseif self.props.scrollingFrame then
				self.props.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			end
		end
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		noAssetsLabel = noAssetsLabel,
		recommendedFrame = recommendedFrame,
		Frame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			[Roact.Ref] = self.frameRef,
		}, assets)
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			recentAssets = state.AEAppReducer.AECharacter.AERecentAssets,
			ownedAssets = state.AEAppReducer.AECharacter.AEOwnedAssets,
			equippedAssets = state.AEAppReducer.AECharacter.AEEquippedAssets,
			recentAssetsStatus = state.AEAppReducer.AERecentAssetsStatus,
			avatarDataStatus = state.AEAppReducer.AEAvatarDataStatus,
			userOutfitsStatus = state.AEAppReducer.AEUserOutfitsStatus,
			gamepadNavigationMenuLevel = state.AEAppReducer.AEGamepadNavigationMenuLevel,
		}
	end
)(AERenderAssets)