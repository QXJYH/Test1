local Modules = game:GetService("CoreGui").RobloxGui.Modules
local TweenService = game:GetService("TweenService")

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESetCategoryMenuOpen = require(Modules.LuaApp.Actions.AEActions.AESetCategoryMenuOpen)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local CommonConstants = require(Modules.LuaApp.Constants)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorEmotesSupport = settings():GetFFlag("AvatarEditorEmotesSupport")

local AECategoryMenuClosed = Roact.PureComponent:extend("AECategoryMenuClosed")

function AECategoryMenuClosed:init()
	self.categoryMenuClosedRef = Roact.createRef()
end

function AECategoryMenuClosed:willUpdate(nextProps, nextState)
	if nextProps.visible and not self.props.visible then
		self.showTween:Play()
	elseif not nextProps.visible and self.props.visible then
		self.closeTween:Play()
	end
end

function AECategoryMenuClosed:didMount()
	local showTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local showPropertyGoals = { Position = UDim2.new(0, -300, 0, -10) }
	self.showTween = TweenService:Create(self.categoryMenuClosedRef.current, showTweenInfo, showPropertyGoals)

	local closeTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local closePropertyGoals = { Position = UDim2.new(0, -52, 0, -10) }
	self.closeTween = TweenService:Create(self.categoryMenuClosedRef.current, closeTweenInfo, closePropertyGoals)
end

function AECategoryMenuClosed:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AECategoryMenuAndButtons:getThemeInfo(nil, themeName) or nil
	local currentCategory = AECategories.categories[self.props.categoryIndex]
	local setCategoryMenuOpen = self.props.setCategoryMenuOpen
	local visible = self.props.visible

	local navWheelImage = "AE/Graphic/gr-phone-nav-tracker"
	local navIndicatorImage = "AE/Graphic/gr-phone-nav-tracker-0" ..(currentCategory.positionInCategoryMenu - 1) % 5 + 1
	local navWheelRotation = 0

	if FFlagAvatarEditorEmotesSupport then
		navWheelImage = "AE/Graphic/nav-wheel"
		navIndicatorImage = "AE/Graphic/nav-highlight"

		local categoryPosition = currentCategory.positionInCategoryMenu - 1
		navWheelRotation = categoryPosition * (360 / #AECategories.categories)
	end

	if not FFlagAvatarEditorEnableThemes and not FFlagAvatarEditorEmotesSupport then
		return Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, -300, 0, -10),
			Size = UDim2.new(0, 365, 0, 70),
			ImageColor3 = CommonConstants.Color.WHITE,
			ScaleType = Enum.ScaleType.Stretch,
			Visible = visible,

			[Roact.Ref] = self.categoryMenuClosedRef,
			[Roact.Event.Activated] = setCategoryMenuOpen,
		}, {
			BackgroundFill = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 5),
				Size = UDim2.new(1, -34, 0, 60),
				Image = "rbxasset://textures/AvatarEditorImages/Portrait/gr-primary-nav-rectangle.png",
				ImageColor3 = CommonConstants.Color.WHITE,
			}),
			IndexIndicator = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -59, 0.5, -24),
				Size = UDim2.new(0, 48, 0, 48),
				ZIndex = 2,
				Image = AEConstants.IMAGE_SHEET,
				ImageColor3 = CommonConstants.Color.WHITE,
				ImageRectOffset = AESpriteSheet.getImage(
					'ring'..((currentCategory.positionInCategoryMenu - 1) % 5 + 1)).imageRectOffset,
				ImageRectSize = AESpriteSheet.getImage(
					'ring'..((currentCategory.positionInCategoryMenu - 1) % 5 + 1)).imageRectSize,
			}),
			RoundedEnd = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -34, 0, 5),
				Size = UDim2.new(0, 29, 0, 60),
				Image = "rbxasset://textures/AvatarEditorImages/Portrait/gr-primary-nav-half-circle.png",
				ImageColor3 = CommonConstants.Color.WHITE,
			}),
			SelectedIcon = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -49, 0.5, -14),
				Size = UDim2.new(0, 28, 0, 28),
				ZIndex = 2,
				Image = AEConstants.IMAGE_SHEET,
				ImageColor3 = CommonConstants.Color.WHITE,
				ImageRectOffset = AESpriteSheet.getImage(currentCategory.iconImageName).imageRectOffset,
				ImageRectSize = AESpriteSheet.getImage(currentCategory.iconImageName).imageRectSize,
			}),
		})
	else
		return Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, -300, 0, -10),
			Size = UDim2.new(0, 365, 0, 70),
			ImageColor3 = CommonConstants.Color.WHITE,
			ScaleType = Enum.ScaleType.Stretch,
			Visible = visible,

			[Roact.Ref] = self.categoryMenuClosedRef,
			[Roact.Event.Activated] = setCategoryMenuOpen,
		}, {
			BackgroundFill = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 5),
				Size = UDim2.new(1, -32, 0, 60),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(0.5, 1, 0.5, 1),
				Image = 'AE/Graphic/gr-nav',
				ImageColor3 = themeInfo.ColorTheme.Background.Fill,
				ImageRectSize = Vector2.new(1, 1),
				ZIndex = 2,
			}),
			BackgroundFillBorder = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -32, 0, 60),
				Position = UDim2.new(0, 0, 0, 5),
				Image = 'AE/Graphic/gr-nav-border',
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(0.5, 0, 0.5, 0),
				ImageColor3 = themeInfo.ColorTheme.Background.Border,
				ZIndex = 3,
			}),
			BackgroundNav = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 48, 0, 48),
				Position = UDim2.new(1, -59, 0.5, -24),
				Rotation = navWheelRotation,
				Image = navWheelImage,
				ImageColor3 = themeInfo.ColorTheme.Button.Indicator,
				ZIndex = 3,
			}),
			IndexIndicator = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -59, 0.5, -24),
				Size = UDim2.new(0, 48, 0, 48),
				ZIndex = 4,
				Rotation = navWheelRotation,
				Image = navIndicatorImage,
				ImageColor3 = themeInfo.ColorTheme.Button.BackgroundSelected,
			}),
			RoundedEnd = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -34, 0, 5),
				Size = UDim2.new(0, 29, 0, 60),
				Image = 'AE/Graphic/gr-phone-primary-nav',
				ImageColor3 = themeInfo.ColorTheme.Background.Fill,
			}),
			RoundedEndBorder = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -34, 0, 5),
				Size = UDim2.new(0, 29, 0, 60),
				Image = 'AE/Graphic/gr-phone-primary-nav-border',
				ImageColor3 = themeInfo.ColorTheme.Background.Border,
				ZIndex = 2,
			}),
			SelectedIcon = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -47, 0.5, -12),
				Size = UDim2.new(0, 24, 0, 24),
				ZIndex = 2,
				Image = currentCategory.imageSetName,
				ImageColor3 = themeInfo.ColorTheme.Button.IconSelected,
			}),
		})
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			resolutionScale = state.AEAppReducer.AEResolutionScale,
		}
	end,

	function(dispatch)
		return {
			setCategoryMenuOpen = function()
				dispatch(AESetCategoryMenuOpen(AEConstants.CategoryMenuOpen.OPEN))
			end,
		}
	end
)(AECategoryMenuClosed)