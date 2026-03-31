local Modules = game:GetService("CoreGui").RobloxGui.Modules
local TweenService = game:GetService("TweenService")

local Roact = require(Modules.Common.Roact)
local AECategoryButton = require(Modules.LuaApp.Components.Avatar.UI.Views.Landscape.AECategoryButton)
local CommonConstants = require(Modules.LuaApp.Constants)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)
local AECategoryMenuCloseButton = require(Modules.LuaApp.Components.Avatar.UI.Views.AECategoryMenuCloseButton)
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
	local showTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local showPropertyGoals = { Size = UDim2.new(0, 90, 1, -22) }
	self.showTween = TweenService:Create(self.categoryMenuOpenRef.current, showTweenInfo, showPropertyGoals)

	local closeTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local closePropertyGoals = { Size = UDim2.new(0, 90, 0, 90) }
	self.closeTween = TweenService:Create(self.categoryMenuOpenRef.current, closeTweenInfo, closePropertyGoals)
end

function AECategoryMenuOpen:render()
	local analytics = self.props.analytics
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AECategoryMenuAndButtons:getThemeInfo(nil, themeName) or nil
	local visible = self.props.visible
	local categories = self.state.categories
	local categoryScrollerChildren = {}
	local roundedEndBorder = nil

	for index, category in pairs(categories) do
		categoryScrollerChildren[category.name] = Roact.createElement(AECategoryButton, {
			analytics = analytics,
			index = index,
			category = category,
		})
	end

	local categoryScrollerSizeConstraint = Roact.createElement("UISizeConstraint", {})
	categoryScrollerChildren[#categoryScrollerChildren + 1] = categoryScrollerSizeConstraint

	if FFlagAvatarEditorEnableThemes then
		roundedEndBorder = Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Image = 'AE/Graphic/gr-tablet-primary-nav-border',
			ImageColor3 = themeInfo.ColorTheme.Background.Border,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(48, 48, 48, 48),
			ZIndex = 2,
		})
	end

	return Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 15, 0, 15),
		Size = UDim2.new(0, 90, 0, 90),
		Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-tablet-primary-nav'
			or "rbxasset://textures/AvatarEditorImages/Landscape/gr-primary-nav-tablet.png",
		ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Background.Fill or CommonConstants.Color.WHITE,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(48, 48, 48, 48),
		Visible = visible,

		[Roact.Ref] = self.categoryMenuOpenRef,
	}, {
		RoundedEndBorder = roundedEndBorder,
		CategoryScroller = Roact.createElement("ScrollingFrame", {
			ScrollBarThickness = 0,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 90),
			Size = UDim2.new(1, 0, 1, -135),
			CanvasSize = UDim2.new(1, 0, 0, #AECategories.categories * 90),
		},
			categoryScrollerChildren
		),
		CloseButton = Roact.createElement(AECategoryMenuCloseButton)
	})
end

return AECategoryMenuOpen