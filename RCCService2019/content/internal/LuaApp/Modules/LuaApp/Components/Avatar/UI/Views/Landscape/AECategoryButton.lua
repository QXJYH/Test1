local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESelectCategory = require(Modules.LuaApp.Thunks.AEThunks.AESelectCategory)
local AESetCategoryMenuOpen = require(Modules.LuaApp.Actions.AEActions.AESetCategoryMenuOpen)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local AESendAnalytics = require(Modules.LuaApp.Thunks.AEThunks.AESendAnalytics)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local CommonConstants = require(Modules.LuaApp.Constants)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local AECategoryButton = Roact.PureComponent:extend("AECategoryButton")
local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")
local FFlagAvatarEditorEmotesAnalytics3 = settings():GetFFlag("AvatarEditorEmotesAnalytics3")

function AECategoryButton:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AECategoryMenuAndButtons:getThemeInfo(nil, themeName) or nil
	local categoryIndex = self.props.categoryIndex
	local index = self.props.index
	local position = self.state.position
	local category = self.props.category
	local iconLabel, circleLabel, element
	local textLabel = {}

	textLabel.text = category.titleLandscape or category.title

	if FFlagAvatarEditorEnableThemes then
		local iconBorder, iconImage, textColor, iconImageColor, backgroundColor

		if index == categoryIndex then
			iconBorder = 'AE/Graphic/gr-nav-selected'
			iconImage = category.imageSetSelectedName
			textLabel.textColor3 = Color3.fromRGB(255, 161, 47)
			textColor = themeInfo.ColorTheme.Button.SelectedTextColor
			iconImageColor = themeInfo.ColorTheme.Background.SelectedImageColor
			backgroundColor = themeInfo.ColorTheme.Button.BackgroundSelected
		else
			iconBorder = 'AE/Graphic/gr-nav-selector'
			iconImage = category.imageSetName
			iconImageColor = themeInfo.ColorTheme.Background.UnSelectedImageColor
			textColor = themeInfo.ColorTheme.Button.TextColor
			backgroundColor = themeInfo.ColorTheme.Button.BackgroundUnselected
		end

		element = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = position,
			Size = UDim2.new(0, 90, 0, 90),

			[Roact.Event.Activated] = function()
				self.selectCategory(categoryIndex, index)
			end,
		}, {
			Icon = Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 48, 0, 48),
				Image = iconBorder,
				ImageColor3 = backgroundColor,
			}, {
				IconImage = Roact.createElement(ImageSetLabel, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, -12, 0.5, -12),
					Size = UDim2.new(0, 24, 0, 24),
					Image = iconImage,
					ImageColor3 = iconImageColor,
				}),
			}),
			TextLabel = Roact.createElement(LocalizedTextLabel, {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, 28),
				Size = UDim2.new(1, 0, 1, 0),
				Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
				Text = textLabel.text,
				TextColor3 = textColor,
				TextSize = 14,
				TextScaled = FFlagAvatarEditorGothamFont and true or false,
				TextTransparency = textLabel.textTransparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Top,
			}, {
				TextSizeConstraint = FFlagAvatarEditorGothamFont and Roact.createElement("UITextSizeConstraint", {
					MaxTextSize = 14,
				}),
			}),
		})
	else
		if index == categoryIndex then
			circleLabel = AESpriteSheet.getImage("icon-border-on")
			iconLabel = AESpriteSheet.getImage(category.selectedIconImageName)
			textLabel.textColor3 = Color3.fromRGB(255, 161, 47)
		else
			circleLabel = AESpriteSheet.getImage("icon-border")
			iconLabel = AESpriteSheet.getImage(category.iconImageName)
		end

		element = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = position,
			Size = UDim2.new(0, 90, 0, 90),
			ImageColor3 = CommonConstants.Color.WHITE,
			ImageRectSize = Vector2.new(52, 52),
			ScaleType = Enum.ScaleType.Stretch,

			[Roact.Event.Activated] = function()
				self.selectCategory(categoryIndex, index)
			end,
		}, {
			Icon = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 48, 0, 48),
				Image = circleLabel.image,
				ImageRectOffset = circleLabel.imageRectOffset,
				ImageRectSize = circleLabel.imageRectSize,
				ImageTransparency = circleLabel.imageTransparency,
			}, {
				IconImage = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, -14, 0.5, -14),
					Size = UDim2.new(0, 28, 0, 28),
					Image = iconLabel.image,
					ImageRectOffset = iconLabel.imageRectOffset,
					ImageRectSize = iconLabel.imageRectSize,
					ImageTransparency = iconLabel.imageTransparency,
				}),
			}),
			TextLabel = Roact.createElement(LocalizedTextLabel, {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0.5, 28),
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.SourceSans,
				Text = textLabel.text,
				TextColor3 = textLabel.textColor3,
				TextSize = 14,
				TextTransparency = textLabel.textTransparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
		})
	end

	return element
end

function AECategoryButton:init()
	local index = self.props.index
	local selectCategory = self.props.selectCategory
	local setCategoryMenuClosed = self.props.setCategoryMenuClosed
	local analytics = self.props.analytics

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
		position = UDim2.new(0.5, -45, 0, 90 * (index -1))
	}
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
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