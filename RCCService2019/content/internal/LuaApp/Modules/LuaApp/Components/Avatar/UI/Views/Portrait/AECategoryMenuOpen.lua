local Modules = game:GetService("CoreGui").RobloxGui.Modules
local TweenService = game:GetService("TweenService")

local Roact = require(Modules.Common.Roact)
local AECategoryButton = require(Modules.LuaApp.Components.Avatar.UI.Views.Portrait.AECategoryButton)
local CommonConstants = require(Modules.LuaApp.Constants)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AECategoryMenuOpen = Roact.PureComponent:extend("AECategoryMenuOpen")

function AECategoryMenuOpen:init()
	self.categoryMenuOpenRef = Roact.createRef()
	self.state = {
		categories = AECategories.categories,
	}
end

function AECategoryMenuOpen:willUpdate(nextProps, nextState)
	if nextProps.visible and not self.props.visible then
		self.showTween:Play()
	elseif not nextProps.visible and self.props.visible then
		self.closeTween:Play()
	end
end

function AECategoryMenuOpen:didMount()
	local showTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local showPropertyGoals = { Position = UDim2.new(0, -52, 0, -10) }
	self.showTween = TweenService:Create(self.categoryMenuOpenRef.current, showTweenInfo, showPropertyGoals)

	local closeTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local closePropertyGoals = { Position = UDim2.new(0, -300, 0, -10) }
	self.closeTween = TweenService:Create(self.categoryMenuOpenRef.current, closeTweenInfo, closePropertyGoals)
end

function AECategoryMenuOpen:render()
	local analytics = self.props.analytics
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AECategoryMenuAndButtons:getThemeInfo(nil, themeName) or nil
	local categoryScrollerChildren = {}
	local categories = self.state.categories
	local visible = self.props.visible
	local backgroundFill

	for index, category in ipairs(categories) do
		categoryScrollerChildren[category.name] = Roact.createElement(AECategoryButton, {
			analytics = analytics,
			index = index,
		})
	end

	local categoryScrollerSizeConstraint = Roact.createElement("UISizeConstraint", {})
	categoryScrollerChildren["SizeConstraint"] = categoryScrollerSizeConstraint

	if FFlagAvatarEditorEnableThemes then
		backgroundFill = Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -32, 0, 60),
			Position = UDim2.new(0, 0, 0, 5),
			Image = 'AE/Graphic/gr-nav',
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(0.5, 1, 0.5, 1),
			ImageColor3 = themeInfo.ColorTheme.Background.Fill,
			ImageRectSize = Vector2.new(1, 1),
			ZIndex = 2,
		})
	else
		backgroundFill = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -34, 0, 60),
			Position = UDim2.new(0, 0, 0, 5),
			Image = "rbxasset://textures/AvatarEditorImages/Portrait/gr-primary-nav-rectangle.png",
			ImageColor3 = CommonConstants.Color.WHITE,
		})
	end

	local imageButtonSize = 15 + 70 * #AECategories.categories

	return Roact.createElement("ImageButton", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, -300, 0, -10),
		Size = UDim2.new(0, imageButtonSize, 0, 70),
		ImageColor3 = CommonConstants.Color.WHITE,
		Visible = visible,

		[Roact.Ref] = self.categoryMenuOpenRef,
	}, {
		BackgroundFill = backgroundFill,
		BackgroundFillBorder = FFlagAvatarEditorEnableThemes and Roact.createElement(ImageSetLabel, {
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
		RoundedEnd = Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -34, 0, 5),
			Size = UDim2.new(0, 29, 0, 60),
			Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-phone-primary-nav'
				or "rbxasset://textures/AvatarEditorImages/Portrait/gr-primary-nav-half-circle.png",
			ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Background.Fill or CommonConstants.Color.WHITE,
		}),
		RoundedEndBorder = FFlagAvatarEditorEnableThemes and Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -34, 0, 5),
			Size = UDim2.new(0, 29, 0, 60),
			Image = 'AE/Graphic/gr-phone-primary-nav-border',
			ImageColor3 = themeInfo.ColorTheme.Background.Border,
			ZIndex = 2,
		}),
		Frame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, categoryScrollerChildren),
	})
end

return AECategoryMenuOpen