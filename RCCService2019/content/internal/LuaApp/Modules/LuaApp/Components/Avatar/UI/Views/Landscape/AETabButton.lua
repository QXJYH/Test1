local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESelectCategoryTab = require(Modules.LuaApp.Thunks.AEThunks.AESelectCategoryTab)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local CommonConstants = require(Modules.LuaApp.Constants)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local AEGetUserInventory = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserInventory)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local AEGetUserOutfits = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserOutfits)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")
local AETabButton = Roact.PureComponent:extend("AETabButton")

local TAB_HEIGHT = 90
local FIRST_TAB_BONUS_WIDTH = 45
local PROP_KEYS = {
	tabListRef = "tabListRef",
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
			Size = UDim2.new(1, -12, 0, 1),
			Position = UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
		})
	end

	return nil
end

function AETabButton:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AETabListAndButtons:getThemeInfo(nil, themeName) or nil
	self.index = self.props.index
	self.currentTabPage = self.props.currentTabPage
	self.categoryIndex = self.props.categoryIndex
	local page = self.props.page
	local divider = self:getDivider()
	local avatarType = self.props.avatarType
	local frame = {}
	local nameLabel = {}
	local imageFrame = {}
	local notFirstTabBonusWidth = self.index ~= 1 and FIRST_TAB_BONUS_WIDTH or 0
	local firstTabBonusWidth = self.index == 1 and FIRST_TAB_BONUS_WIDTH or 0

	local imageInfo
	if page.iconImageSelectedName and page.iconImageName then
		imageInfo = self.index == self.currentTabPage
			and AESpriteSheet.getImage(page.iconImageSelectedName) or AESpriteSheet.getImage(page.iconImageName)
	end
	local imageColor3, iconImage, imageLabel

	frame.size = UDim2.new(1, 0, 0, TAB_HEIGHT + firstTabBonusWidth)
	frame.position = UDim2.new(0, 0, 0, (self.index - 1) * (TAB_HEIGHT + 1) + notFirstTabBonusWidth)

	if self.index == self.currentTabPage then
		frame.backgroundColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabButton.SelectedBackgroundColor or CommonConstants.Color.ORANGE

		if page.pageType == AEConstants.PageType.Scale and avatarType == AEConstants.AvatarType.R6 then
			frame.backgroundColor3 = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.TabButton.SelectedUnusableBackgroundColor or CommonConstants.Color.BROWN_WARNING
		end

		imageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.TabButton.SelectedImageColor
			or Color3.fromRGB(255, 255, 255)
		nameLabel.textColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabButton.SelectedTextColor or CommonConstants.Color.WHITE
		frame.backgroundTransparency = 0
		iconImage = page.iconImageSetSelectedName
	else
		nameLabel.textColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabButton.UnselectedTextColor or CommonConstants.Color.GRAY2
		frame.backgroundTransparency = 1
		imageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.TabButton.UnselectedImageColor
			or Color3.fromRGB(255, 255, 255)
		iconImage = page.iconImageSetName

		if page.pageType == AEConstants.PageType.Scale and avatarType == AEConstants.AvatarType.R6 then
			frame.backgroundColor3 = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.TabButton.UnusableBackgroundColor or CommonConstants.Color.GRAY3
			frame.backgroundTransparency = 0
		end

		-- The BodyColors image needs to stay colored, not turn black.
		if page.pageType == AEConstants.PageType.BodyColors then
			imageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.TabButton.SelectedImageColor
				or Color3.fromRGB(255, 255, 255)
		end
	end

	imageFrame.size = UDim2.new(0, 28, 0, 28)
	imageFrame.position = FFlagAvatarEditorEnableThemes and UDim2.new(.5, -12, .5, -16) or UDim2.new(.5, -14, .5, -20)

	if self.index == 1 then
		imageFrame.position = imageFrame.position + UDim2.new(0, 0, 0, FIRST_TAB_BONUS_WIDTH * 0.5 - 6)
	end

	nameLabel.position = UDim2.new(0, 5, imageFrame.position.Y.Scale,
		imageFrame.position.Y.Offset + imageFrame.size.Y.Offset + 4)

	if page.iconText then
		imageLabel = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Size = imageFrame.size,
			Position = imageFrame.position,
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
	elseif FFlagAvatarEditorEnableThemes then
		imageLabel = Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 24, 0, 24),
			Position = imageFrame.position,
			Image = 'AE/Icons/' ..iconImage,
			ImageColor3 = imageColor3,
		})
	else
		imageLabel = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 28, 0, 28),
			Position = imageFrame.position,
			ImageRectSize = imageInfo.imageRectSize,
			ImageRectOffset = imageInfo.imageRectOffset,
			Image = imageInfo.image,
		})
	end

	local textLabel
	if page.iconText then
		textLabel = Roact.createElement("TextLabel", {
			Visible = false,
		})
	else
		textLabel = Roact.createElement(LocalizedTextLabel, {
			Text = page.titleLandscape or page.title,
			BackgroundTransparency = 1,
			Position = nameLabel.position,
			Size = UDim2.new(1, -10, 1, 0),
			Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
			FontSize = Enum.FontSize.Size14,
			TextColor3 = nameLabel.textColor3,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextScaled = FFlagAvatarEditorGothamFont and true or false,
		}, {
			TextSizeConstraint = FFlagAvatarEditorGothamFont and Roact.createElement("UITextSizeConstraint", {
				MaxTextSize = 14,
			}),
		})
	end

	return Roact.createElement("ImageButton", {
		Image = frame.image,
		BackgroundColor3 = frame.backgroundColor3,
		BackgroundTransparency = frame.backgroundTransparency,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Size = frame.size,
		Position = frame.position,

		[Roact.Event.Activated] = self.dispatchFunction
	} , {
		ImageLabel = imageLabel,
		TextLabel = textLabel,
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
	elseif costumePage and not initializedTabs[page.assetTypeId] and self.currentTabPage == self.index then
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
