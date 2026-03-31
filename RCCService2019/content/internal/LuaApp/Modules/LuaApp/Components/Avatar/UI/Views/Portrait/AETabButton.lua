local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESelectCategoryTab = require(Modules.LuaApp.Thunks.AEThunks.AESelectCategoryTab)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local CommonConstants = require(Modules.LuaApp.Constants)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local AEGetUserInventory = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserInventory)
local AEGetUserOutfits = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserOutfits)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AETabButton = Roact.PureComponent:extend("AETabButton")

local TAB_HEIGHT = 50
local FIRST_TAB_BONUS_WIDTH = 10
local PROP_KEYS = {
	tabListRef = "tabListRef",
	screenSize = "screenSize",
	tabWidth = "tabWidth",
	avatarType = "avatarType",
}

function AETabButton:getDivider()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AETabListAndButtons:getThemeInfo(nil, themeName) or nil
	local index = self.props.index

	if index > 1 then
		return Roact.createElement("Frame", {
			BackgroundColor3 = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.DividerColor or CommonConstants.Color.GRAY4,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 1, .6, 0),
			Position = UDim2.new(0, -1, .2, 0),
		})
	end
end

function AETabButton:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AETabListAndButtons:getThemeInfo(nil, themeName) or nil
	self.index = self.props.index
	self.currentTabPage = self.props.currentTabPage
	self.categoryIndex = self.props.categoryIndex
	local avatarType = self.props.avatarType
	local page = self.props.page
	local tabWidth = self.props.tabWidth
	local divider = self:getDivider()
	local notFirstTabBonusWidth = self.index ~= 1 and FIRST_TAB_BONUS_WIDTH or 0
	local firstTabBonusWidth = self.index == 1 and FIRST_TAB_BONUS_WIDTH or 0

	local imageInfo
	if page.iconImageSelectedName and page.iconImageName then
		imageInfo = self.index == self.currentTabPage
			and AESpriteSheet.getImage(page.iconImageSelectedName) or AESpriteSheet.getImage(page.iconImageName)
	end

	local imageButton = {}
	local image = {}

	imageButton.backgroundColor3 = FFlagAvatarEditorEnableThemes
		and themeInfo.ColorTheme.TabButton.DefaultBackgroundColor or CommonConstants.Color.WHITE
	imageButton.size = UDim2.new(0, tabWidth + firstTabBonusWidth, 0, TAB_HEIGHT)
	imageButton.position = UDim2.new(0, (self.index - 1) * (tabWidth + 1) + notFirstTabBonusWidth, 0, 0)

	if self.index == self.currentTabPage then
		if page.iconImageSetSelectedName then
			image.image = 'AE/Icons/'..page.iconImageSetSelectedName
		end

		image.imageColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabButton.SelectedImageColor or Color3.fromRGB(255, 255, 255)
		imageButton.backgroundColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabButton.SelectedBackgroundColor or CommonConstants.Color.ORANGE

		if page.pageType == AEConstants.PageType.Scale and avatarType == AEConstants.AvatarType.R6 then
			imageButton.backgroundColor3 = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.TabButton.SelectedUnusableBackgroundColor or CommonConstants.Color.BROWN_WARNING
		end
	else
		if page.iconImageSetName then
			image.image = 'AE/Icons/'..page.iconImageSetName
		end

		image.imageColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabButton.UnselectedImageColor or Color3.fromRGB(255, 255, 255)
		if page.pageType == AEConstants.PageType.Scale and avatarType == AEConstants.AvatarType.R6 then
			imageButton.backgroundColor3 = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.TabButton.UnusableBackgroundColor or CommonConstants.Color.GRAY3
		end

		-- The BodyColors image needs to stay colored, not turn black.
		if page.pageType == AEConstants.PageType.BodyColors then
			image.imageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.TabButton.SelectedImageColor
				or Color3.fromRGB(255, 255, 255)
		end
	end

	image.position = FFlagAvatarEditorEnableThemes and UDim2.new(.5, -12, .5, -12) or UDim2.new(.5, -14, .5, -14)

	if self.index == 1 then
		image.position = image.position + UDim2.new(0, FIRST_TAB_BONUS_WIDTH * .5, 0, 0)
	end

	if FFlagAvatarEditorEnableThemes then
		image.imageRectSize = nil
		image.imageRectOffset = nil
	else
		image.imageRectSize = imageInfo.imageRectSize
		image.imageRectOffset = imageInfo.imageRectOffset
	end

	local imageLabel
	if page.iconText then
		imageLabel = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Size = FFlagAvatarEditorEnableThemes and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 28, 0, 28),
			Position = image.position,
		}, {
			Text = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Text = page.iconText,
				Font = themeInfo.ColorTheme.Text.FontBold,
				TextColor3 = self.index == self.currentTabPage and themeInfo.ColorTheme.IconText.SelectedTextColor
							or themeInfo.ColorTheme.IconText.UnselectedTextColor,
				TextScaled = true,
			}),
		})
	else
		imageLabel = Roact.createElement((FFlagAvatarEditorEnableThemes or not imageInfo) and ImageSetLabel or "ImageLabel", {
			BackgroundTransparency = 1,
			Size = FFlagAvatarEditorEnableThemes and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 28, 0, 28),
			Position = image.position,
			ImageRectSize = image.imageRectSize,
			ImageRectOffset = image.imageRectOffset,
			Image = (FFlagAvatarEditorEnableThemes or not imageInfo) and image.image or imageInfo.image,
			ImageColor3 = FFlagAvatarEditorEnableThemes and image.imageColor3 or Color3.fromRGB(255, 255, 255),
		})
	end

	return Roact.createElement("ImageButton", {
		Image = imageButton.image,
		BackgroundColor3 = imageButton.backgroundColor3,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = imageButton.size,
		Position = imageButton.position,

		[Roact.Event.Activated] = self.dispatchFunction
	} , {
		ImageLabel = imageLabel,
		Divider = divider,
	})
end

function AETabButton:checkForUpdate()
	local page = self.props.page
	local getUserInventory = self.props.getUserInventory
	local initializedTabs = self.props.initializedTabs
	local getUserOutfits = self.props.getUserOutfits
	local costumePage = page.assetTypeId == AEConstants.OUTFITS or page.assetTypeId == AEConstants.PRESET_COSTUMES

	-- Check if this tab has been accessed before. If not, dispatch an action for a web call.
	if not costumePage and page.assetTypeId and not initializedTabs[page.assetTypeId]
		and self.currentTabPage == self.index then
		getUserInventory(page.assetTypeId)
	elseif costumePage and not initializedTabs[page.assetTypeId]
		and self.currentTabPage == self.index then
		getUserOutfits(page.assetTypeId)
	end
end

function AETabButton:didUpdate()
	self:checkForUpdate()
end

-- Tabs should only re-render with changes to these props.
function AETabButton:shouldUpdate(nextProps, nextState)
	local index = self.index
	local tab = self.props.currentTabPage
	local nextTab = nextProps.currentTabPage

	if self.props[PROP_KEYS.tabListRef] ~= nextProps[PROP_KEYS.tabListRef]
		or self.props[PROP_KEYS.screenSize] ~= nextProps[PROP_KEYS.screenSize]
		or self.props[PROP_KEYS.tabWidth] ~= nextProps[PROP_KEYS.tabWidth]
		or self.props[PROP_KEYS.avatarType] ~= nextProps[PROP_KEYS.avatarType]
		or index == tab or index == nextTab then
		return true
	else
		return false
	end
end

function AETabButton:init()
	local selectCategoryTab = self.props.selectCategoryTab
	self.currentTabPage = self.props.currentTabPage
	self.index = self.props.index

	self.dispatchFunction = function()
		if self.currentTabPage ~= self.index then
			selectCategoryTab(self.categoryIndex, self.index)
		end
	end

	self:checkForUpdate()
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			avatarType = state.AEAppReducer.AECharacter.AEAvatarType,
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			screenSize = state.ScreenSize,
			initializedTabs = state.AEAppReducer.AECategory.AEInitializedTabs,
		}
	end,

	function(dispatch)
		return {
			getUserInventory = function(assetType)
				dispatch(AEGetUserInventory(assetType))
			end,
			selectCategoryTab = function(categoryIndex, tabIndex)
				dispatch(AESelectCategoryTab(categoryIndex, tabIndex))
			end,
			getUserOutfits = function(costumeType, pageNumber)
				dispatch(AEGetUserOutfits(costumeType, pageNumber))
			end,
		}
	end
)(AETabButton)
