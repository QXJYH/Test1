local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local AESlider = require(Modules.LuaApp.Components.Avatar.UI.AESlidersFrame)
local AEBodyColors = require(Modules.LuaApp.Components.Avatar.UI.AEBodyColorsFrame)
local CommonConstants = require(Modules.LuaApp.Constants)
local AERenderAssets = require(Modules.LuaApp.Components.Avatar.UI.AERenderAssets)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local AECurrentPage = require(Modules.LuaApp.Selectors.AESelectors.AECurrentPage)
local AEGetRecentAssets = require(Modules.LuaApp.Thunks.AEThunks.AEGetRecentAssets)
local AEGetUserOutfits = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserOutfits)
local AEGetUserInventory = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserInventory)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local FFlagAvatarEditorRefactorPageType = settings():GetFFlag("AvatarEditorRefactorPageType")
local FFlagAvatarEditorCatalogRecommended = settings():GetFFlag("AvatarEditorCatalogRecommended")
	and not settings():GetFFlag("ChinaLicensingApp")
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")

local BOTTOM_BUFFER = 80
local TOP_BUFFER = 25
local LOAD_MORE_BUFFER = FFlagAvatarEditorCatalogRecommended and 250 or 125

local AEScrollingFrame = Roact.PureComponent:extend("AEScrollingFrame")

local View = {
	[DeviceOrientationMode.Portrait] = {
		GRID_PADDING = 6,
		LIST_PADDING = 6,
	},

	[DeviceOrientationMode.Landscape] = {
		GRID_PADDING = 12,
		LIST_PADDING = 6,
	},
}

function AEScrollingFrame:pageTitleLabelUI()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEScrollingFrame:getThemeInfo(deviceOrientation, themeName)
	local categoryIndex = self.props.categoryIndex
	local tabsInfo = self.props.tabsInfo
	local page = AEUtils.getCurrentPage(categoryIndex, tabsInfo)

	local PageTitle = Roact.createElement(LocalizedTextLabel, {
		Position = UDim2.new(0, 7, 0, 3),
		Size = UDim2.new(1, -14, 0, 25),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSansLight,
		FontSize = Enum.FontSize.Size18,
		Text = page.title,
		TextColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.PageLabelTextColor or Color3.fromRGB(65, 78, 89),
		TextXAlignment = Enum.TextXAlignment.Left,

		LayoutOrder = -10,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 7)
		}),
	})

	return PageTitle
end

function AEScrollingFrame:render()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEScrollingFrame:getThemeInfo(deviceOrientation, themeName)
	local borderSizePixel = FFlagAvatarEditorEnableThemes
		and themeInfo.ColorTheme.BorderSize or themeInfo.OrientationTheme.BorderSizePixel
	local categoryIndex = self.props.categoryIndex
	local tabsInfo = self.props.tabsInfo
	local analytics = self.props.analytics
	local page = AEUtils.getCurrentPage(categoryIndex, tabsInfo)
	local slider = nil
	local bodyColors = nil
	local pageLabel = nil
	local assetTypeToRender = AEConstants.AvatarAssetGroup.None
	local isRecentPage = (FFlagAvatarEditorRefactorPageType and page.pageType == AEConstants.PageType.RecentAll)
		or (not FFlagAvatarEditorRefactorPageType and page.recentPageType)

	if isRecentPage then
		assetTypeToRender = AEConstants.AvatarAssetGroup.Recent
	elseif page.assetTypeId then
		assetTypeToRender = AEConstants.AvatarAssetGroup.Owned
	elseif page.pageType == AEConstants.PageType.CurrentlyWearing then
		assetTypeToRender = AEConstants.AvatarAssetGroup.Equipped
	end

	-- Display the page label if on a Phone.
	if deviceOrientation == DeviceOrientationMode.Portrait then
		pageLabel = self:pageTitleLabelUI()
	end

	if page.pageType == AEConstants.PageType.Scale then
		slider = Roact.createElement(AESlider, {
			deviceOrientation = deviceOrientation,
			analytics = analytics,
			scrollingFrameRef = self.frameRef.current,
		})
	elseif page.pageType == AEConstants.PageType.BodyColors then
		bodyColors = Roact.createElement(AEBodyColors, {
			scrollingFrameRef = self.frameRef.current,
			deviceOrientation = deviceOrientation,
			analytics = analytics,
		})
	end

	return Roact.createElement("ScrollingFrame", {
		AnchorPoint = themeInfo.OrientationTheme.AnchorPoint,
		ClipsDescendants = true,
		Size = themeInfo.OrientationTheme.Size,
		Position = themeInfo.OrientationTheme.Position,
		BackgroundTransparency = themeInfo.OrientationTheme.BackgroundTransparency,
		BorderColor3 = CommonConstants.Color.GRAY3,
		BorderSizePixel = borderSizePixel,
		BackgroundColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.BackgroundColor or Color3.fromRGB(227, 227, 227),
		ScrollBarThickness = 0,
		Selectable = false,

		[Roact.Ref] = self.frameRef,
		[Roact.Change.CanvasPosition] = function(rbx)
			self.loadMoreAssets(rbx)
			spawn(self.updateAssetCardIndicies)
		end,
		[Roact.Change.AbsoluteSize] = function(rbx)
			self.assetButtonSize = themeInfo.OrientationTheme.getAssetButtonSize(rbx)
			-- Needs a re-render on size change for asset cards.
			spawn(function()
				if self.isMounted and self.assetButtonSize ~= self.state.assetButtonSize then
					self:setState({ assetButtonSize = self.assetButtonSize })
				end
				self.updateAssetCardIndicies()
			end)
		end,
	}, {
		ListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, View[deviceOrientation].LIST_PADDING),
		}),

		PageLabel = pageLabel,
		Sliders = slider,
		BodyColors = bodyColors,
		RenderedAssets = Roact.createElement(AERenderAssets, {
			scrollingFrame = self.frameRef.current,
			assetButtonSize = self.assetButtonSize,
			analytics = analytics,
			assetTypeToRender = assetTypeToRender,
			page = page,
			deviceOrientation = deviceOrientation,
			assetCardsToRender = self.state.assetCardsToRender,
			assetCardIndexStart = self.state.assetCardIndexStart,
		}),
	})
end

function AEScrollingFrame:didMount()
	self.updateAssetCardIndicies()
	self.isMounted = true

	if AEUtils.gamepadNavigationEnabled() then
		GuiService:AddSelectionParent("ScrollingFrame", self.frameRef.current)
	end
end

function AEScrollingFrame:willUnmount()
	self.isMounted = false
	if AEUtils.gamepadNavigationEnabled() then
		self.selectedCoreObjectConnection:Disconnect()
		self.selectedCoreObjectConnection = nil
	end

	if AEUtils.gamepadNavigationEnabled() then
		GuiService:RemoveSelectionGroup("ScrollingFrame")
	end
end

function AEScrollingFrame:didUpdate(prevProps, prevState)
	local categoryIndex = self.props.categoryIndex
	local tabsInfo = self.props.tabsInfo
	local page = AEUtils.getCurrentPage(categoryIndex, tabsInfo)
	local recentAssetsStatus = self.props.recentAssetsStatus
	local getRecentAssets = self.props.getRecentAssets
	local deviceOrientation = self.props.deviceOrientation

	-- When visiting the recent all tab, retry this call if it failed
	if tabsInfo[categoryIndex] ~= prevProps[prevProps.categoryIndex] and page.itemType and
		(not recentAssetsStatus[page.itemType] or recentAssetsStatus[page.itemType] == RetrievalStatus.Failed) then
		getRecentAssets(page.itemType)
	end

	if prevState.absoluteSize ~= self.state.absoluteSize or prevProps.deviceOrientation ~= deviceOrientation then
		self:setState({ absoluteSize = self.frameRef.current.AbsoluteSize })
	end

	-- Reset the selected core object as the first asset in this page.
	if AEUtils.gamepadNavigationEnabled()
		and self.props.gamepadNavigationMenuLevel ~= prevProps.gamepadNavigationMenuLevel
		and self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.AssetsPage and
		page.pageType ~= AEConstants.PageType.BodyColors and page.pageType ~= AEConstants.PageType.Scale then
		self.frameRef.current.CanvasPosition = Vector2.new(0, 0)
		self.updateAssetCardIndicies()
		local assetsFrame = self.frameRef.current.RenderedAssets.Frame

		if #assetsFrame:GetChildren() > 0 then
			GuiService.SelectedCoreObject = assetsFrame[1]
		end
	end
end

function AEScrollingFrame:tweenCanvas(nextProps)
	local frameRef = self.frameRef.current
	local currentPosition = GuiService.SelectedCoreObject.Position.Y.Offset
	local currentSize = GuiService.SelectedCoreObject.Size.Y.Offset
	local scrollingFrameYBottom = frameRef.AbsoluteWindowSize.Y + frameRef.CanvasPosition.Y
	local bottomDistance = scrollingFrameYBottom - (currentPosition + currentSize)
	local topDistance = currentPosition - frameRef.CanvasPosition.Y
	local newCanvasPositionY = frameRef.CanvasPosition.Y

	if bottomDistance < BOTTOM_BUFFER then
		newCanvasPositionY =  newCanvasPositionY + BOTTOM_BUFFER - bottomDistance
	elseif topDistance < TOP_BUFFER then
		newCanvasPositionY = newCanvasPositionY + topDistance - 40
	end

	newCanvasPositionY = math.max(0, math.min(newCanvasPositionY,
		frameRef.CanvasSize.Y.Offset - frameRef.AbsoluteWindowSize.Y))

	frameRef.CanvasPosition = Vector2.new(frameRef.CanvasPosition.X, newCanvasPositionY)
end

function AEScrollingFrame:init()
	local getUserInventory = self.props.getUserInventory
	local getUserOutfits = self.props.getUserOutfits
	self.assetButtonSize = 0
	self.frameRef = Roact.createRef()
	self.state = {
		absoluteSize = nil,
		assetCardIndexStart = 1,
		assetCardsToRender = 0,
	}

	self.loadMoreAssets = function(rbx)
		if rbx.CanvasSize.Y.Offset - rbx.CanvasPosition.Y - LOAD_MORE_BUFFER > rbx.AbsoluteSize.Y then
			return
		end

		local categoryIndex = self.props.categoryIndex
		local tabsInfo = self.props.tabsInfo
		local page = AEUtils.getCurrentPage(categoryIndex, tabsInfo)
		local assetTypeCursor = self.props.assetTypeCursor
		local costumePage = page.assetTypeId == AEConstants.OUTFITS or page.assetTypeId == AEConstants.PRESET_COSTUMES

		-- Load more assets when the bottom of the page has been reached.
		if page.assetTypeId and assetTypeCursor[page.assetTypeId] ~= AEConstants.REACHED_LAST_PAGE and not costumePage then
			getUserInventory(page.assetTypeId)
		end

		if costumePage and assetTypeCursor[page.assetTypeId] ~= AEConstants.REACHED_LAST_PAGE then
			getUserOutfits(page.assetTypeId)
		end
	end

	self.updateAssetCardIndicies = function()
		if not self.frameRef.current then
			return
		end

		local deviceOrientation = self.props.deviceOrientation
		local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
		local themeInfo = self._context.AvatarEditorTheme.AEScrollingFrame:getThemeInfo(deviceOrientation, themeName)
		local windowOffset = self.frameRef.current.CanvasPosition.Y
		local buttonsPerRow = themeInfo.OrientationTheme.ButtonsPerRow
		local pageTitleLabelY = deviceOrientation == DeviceOrientationMode.Portrait and 25 or 0
		local assetCardIndexStart = math.max(1, math.floor((windowOffset - pageTitleLabelY)
			/ (self.assetButtonSize + View[deviceOrientation].GRID_PADDING)))
		local cardsPerColumn = deviceOrientation == DeviceOrientationMode.Portrait and 4 or 8
		local assetCardsToRender = (cardsPerColumn + 2) * buttonsPerRow

		local shouldUpdate = assetCardIndexStart ~= self.state.assetCardIndexStart
			or assetCardsToRender ~= self.state.assetCardsToRender

		if self.isMounted and shouldUpdate then
			self:setState({
				assetCardIndexStart = assetCardIndexStart,
				assetCardsToRender = assetCardsToRender,
			})
		end
	end

	if AEUtils.gamepadNavigationEnabled() then
		self.selectedCoreObjectConnection = GuiService:GetPropertyChangedSignal('SelectedCoreObject'):connect(function()
			local currentSelection = GuiService.SelectedCoreObject
			if currentSelection and self.props.page.pageType ~= AEConstants.PageType.Scale
				and self.props.page.pageType ~= AEConstants.PageType.BodyColors then
				self:tweenCanvas()
			end
		end)
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			tabsInfo = state.AEAppReducer.AECategory.AETabsInfo,
			assetTypeCursor = state.AEAppReducer.AEAssetTypeCursor,
			recentAssetsStatus = state.AEAppReducer.AERecentAssetsStatus,
			gamepadNavigationMenuLevel = state.AEAppReducer.AEGamepadNavigationMenuLevel,
			screenSize = state.ScreenSize,
			page = AECurrentPage(state.AEAppReducer),
		}
	end,

	function(dispatch)
		return {
			getRecentAssets = function(category)
				dispatch(AEGetRecentAssets(category))
			end,
			getUserInventory = function(assetTypeId)
				dispatch(AEGetUserInventory(assetTypeId))
			end,
			getUserOutfits = function(costumeType)
				dispatch(AEGetUserOutfits(costumeType))
			end,
		}
	end
)(AEScrollingFrame)