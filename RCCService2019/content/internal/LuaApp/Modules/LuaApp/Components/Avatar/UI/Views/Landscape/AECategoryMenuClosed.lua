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
	local showTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local showPropertyGoals = { Size = UDim2.new(0, 90, 0, 90) }
	self.showTween = TweenService:Create(self.categoryMenuClosedRef.current, showTweenInfo, showPropertyGoals)

	local closeTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local closePropertyGoals = { Size = UDim2.new(0, 90, 1, -22) }
	self.closeTween = TweenService:Create(self.categoryMenuClosedRef.current, closeTweenInfo, closePropertyGoals)
end

function AECategoryMenuClosed:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AECategoryMenuAndButtons:getThemeInfo(nil, themeName) or nil
	local setCategoryMenuOpen = self.props.setCategoryMenuOpen
	local categoryIndex = self.props.categoryIndex
	local currentCategory = AECategories.categories[categoryIndex]
	local visible = self.props.visible

	local navWheelImage = "AE/Graphic/gr-tablet-nav-tracker"
	local navIndicatorImage = "AE/Graphic/gr-tablet-nav-tracker-0" ..(currentCategory.positionInCategoryMenu - 1) % 5 + 1
	local navWheelRotation = 0

	if FFlagAvatarEditorEmotesSupport then
		navWheelImage = "AE/Graphic/nav-wheel-tablet"
		navIndicatorImage = "AE/Graphic/nav-highlight-tablet"

		local categoryPosition = currentCategory.positionInCategoryMenu - 1
		navWheelRotation = categoryPosition * (360 / #AECategories.categories)
	end

	if not FFlagAvatarEditorEnableThemes and not FFlagAvatarEditorEmotesSupport then
		return Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 15, 0, 15),
			Size = UDim2.new(0, 90, 0, 90),
			Visible = visible,

			[Roact.Ref] = self.categoryMenuClosedRef,
			[Roact.Event.Activated] = setCategoryMenuOpen,
		}, {
			IndexIndicator = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 60, 0, 60),
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = AEConstants.IMAGE_SHEET,
				ImageColor3 = CommonConstants.Color.WHITE,
				ImageRectOffset = AESpriteSheet.getImage(
					'ring'..((currentCategory.positionInCategoryMenu  - 1) % 5 + 1)).imageRectOffset,
				ImageRectSize = AESpriteSheet.getImage(
					'ring'..((currentCategory.positionInCategoryMenu  - 1) % 5 + 1)).imageRectSize,
				ScaleType = Enum.ScaleType.Stretch,
			}),
			RoundedEnd = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Image = "rbxasset://textures/AvatarEditorImages/Landscape/gr-primary-nav-tablet.png",
				ImageColor3 = CommonConstants.Color.WHITE,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(48, 48, 48, 48),
			}),
			SelectedIcon = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 28, 0, 28),
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
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
			Position = UDim2.new(0, 15, 0, 15),
			Size = UDim2.new(0, 90, 0, 90),
			Visible = visible,

			[Roact.Ref] = self.categoryMenuClosedRef,
			[Roact.Event.Activated] = setCategoryMenuOpen,
		}, {
			BackgroundNav = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 60, 0, 60),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = navWheelRotation,
				Image = navWheelImage,
				ImageColor3 = themeInfo.ColorTheme.Button.Indicator,
				ZIndex = 3,
			}),
			IndexIndicator = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 60, 0, 60),
				ZIndex = 4,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = navWheelRotation,
				Image = navIndicatorImage,
				ImageColor3 = themeInfo.ColorTheme.Button.BackgroundSelected,
			}),
			RoundedEnd = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Image = 'AE/Graphic/gr-tablet-primary-nav',
				ImageColor3 = themeInfo.ColorTheme.Background.Fill,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(48, 48, 48, 48),
			}),
			RoundedEndBorder = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Image = 'AE/Graphic/gr-tablet-primary-nav-border',
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(48, 48, 48, 48),
				ImageColor3 = themeInfo.ColorTheme.Background.Border,
				ZIndex = 2,
			}),
			SelectedIcon = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 24, 0, 24),
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0.5),
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