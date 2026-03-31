local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESelectCategory = require(Modules.LuaApp.Thunks.AEThunks.AESelectCategory)
local AESetCategoryMenuOpen = require(Modules.LuaApp.Actions.AEActions.AESetCategoryMenuOpen)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local CommonConstants = require(Modules.LuaApp.Constants)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)
local AESendAnalytics = require(Modules.LuaApp.Thunks.AEThunks.AESendAnalytics)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorEmotesAnalytics3 = settings():GetFFlag("AvatarEditorEmotesAnalytics3")

local AECategoryButton = Roact.PureComponent:extend("AECategoryButton")

function AECategoryButton:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AECategoryMenuAndButtons:getThemeInfo(nil, themeName) or nil
	local position = self.state.position
	local categoryIndex = self.props.categoryIndex
	local index = self.props.index
	local categoryInfo = AECategories.categories[index]
	local image, iconLabel, imageColor, iconImage, backgroundColor

	if index == categoryIndex then
		image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-nav-selected' or AESpriteSheet.getImage("gr-orange-circle")
		if not FFlagAvatarEditorEnableThemes then
			iconLabel = AESpriteSheet.getImage(categoryInfo.selectedIconImageName)
		end
		imageColor = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Background.SelectedImageColor or nil
		backgroundColor = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Button.BackgroundSelected or nil
		iconImage = categoryInfo.imageSetSelectedName
	else
		image = FFlagAvatarEditorEnableThemes
			and 'AE/Graphic/gr-nav-selector' or AESpriteSheet.getImage("gr-category-selector")
		if not FFlagAvatarEditorEnableThemes then
			iconLabel = AESpriteSheet.getImage(categoryInfo.iconImageName)
		end
		imageColor = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Background.UnSelectedImageColor or nil
		backgroundColor = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Button.BackgroundUnselected or nil
		iconImage = categoryInfo.imageSetName
	end

	if not FFlagAvatarEditorEnableThemes then
		return Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = position,
			Size = UDim2.new(0, 52, 0, 52),
			Image = image.image,
			ImageColor3 = CommonConstants.Color.WHITE,
			ImageRectSize = image.imageRectSize,
			ImageRectOffset = image.imageRectOffset,

			[Roact.Event.Activated] = function()
				self.selectCategory(categoryIndex, index)
			end
		}, {
			IconLabel = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, -14, 0.5, -14),
				Size = UDim2.new(0, 28, 0, 28),
				Image = iconLabel.image,
				ImageRectOffset = iconLabel.imageRectOffset,
				ImageRectSize = iconLabel.imageRectSize,
				ImageTransparency = iconLabel.imageTransparency,
			}),
		})
	else
		return Roact.createElement(ImageSetButton, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = position,
			Size = FFlagAvatarEditorEnableThemes and UDim2.new(0, 48, 0, 48) or UDim2.new(0, 52, 0, 52),
			Image = image,
			ImageColor3 = backgroundColor,

			[Roact.Event.Activated] = function()
				self.selectCategory(categoryIndex, index)
			end
		}, {
			IconLabel = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, -12, 0.5, -12),
				Size = UDim2.new(0, 24, 0, 24),
				Image = iconImage,
				ImageColor3 = imageColor,
			}),
		})
	end
end

function AECategoryButton:init()
	local setCategoryMenuClosed = self.props.setCategoryMenuClosed
	local selectCategory = self.props.selectCategory
	local index = self.props.index
	local analytics = self.props.analytics

	local categories = #AECategories.categories
	local position = FFlagAvatarEditorEnableThemes and UDim2.new(1, - (categories - index + 1) * 61, 0.5, -24)
		or UDim2.new(1, - (categories - index + 1) * 61, 0.5, -26)

	self.selectCategory = function(categoryIndex, index)
		if categoryIndex ~= index then
			if FFlagAvatarEditorEmotesAnalytics3 then
				local newCategoryPage = AEUtils.getCurrentCategory(index)
				if newCategoryPage.name == AEConstants.EMOTES then
					self.props.sendAnalytics(analytics.openedEmotesPage, self.props.userId)
				end
			end

			selectCategory(index)
		end
		setCategoryMenuClosed()
	end

	self.state = {
		position = position,
	}
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			resolutionScale = state.AEAppReducer.AEResolutionScale,
			userId = state.LocalUserId,
		}
	end,

	function(dispatch)
		return {
			selectCategory = function(index)
				dispatch(AESelectCategory(index))
			end,
			setCategoryMenuClosed = function()
				dispatch(AESetCategoryMenuOpen(AEConstants.CategoryMenuOpen.CLOSED))
			end,
			sendAnalytics = function(analyticsFunction, value)
				dispatch(AESendAnalytics(analyticsFunction, value))
			end,
		}
	end
)(AECategoryButton)