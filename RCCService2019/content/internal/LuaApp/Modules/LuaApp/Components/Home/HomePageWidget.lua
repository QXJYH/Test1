local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)

local Widget = require(Modules.LuaApp.Components.Generic.Widget)

local BACKGROUND_IMAGE = "LuaApp/buttons/buttonFill"

local TITLE_TEXT_SIZE = Constants.HomePagePanelProps.WidgetTextSize
local TITLE_ICON_SIZE = Constants.HomePagePanelProps.WidgetIconSize
local TITLE_ICON_TEXT_GUTTER = Constants.HomePagePanelProps.WidgetIconTextGutter

local PADDING_TOP = UDim.new(0, 11)
local PADDING_BOTTOM = UDim.new(0, 30)
local PADDING_SIDE = UDim.new(0, 20)
local TITLE_TO_CONTENT_PADDING = UDim.new(0, 20)

local DEFAULT_TITLE_PADDING = {
	PaddingTop = PADDING_TOP,
	PaddingBottom = TITLE_TO_CONTENT_PADDING,
	PaddingLeft = PADDING_SIDE,
	PaddingRight = PADDING_SIDE,
}

local DEFAULT_CONTENT_PADDING = {
	PaddingTop = UDim.new(0, 0),
	PaddingBottom = PADDING_BOTTOM,
	PaddingLeft = PADDING_SIDE,
	PaddingRight = PADDING_SIDE,
}

local HomePageWidget = Roact.PureComponent:extend("HomePageWidget")

function HomePageWidget:render()
	local theme = self._context.AppTheme
	local formFactor = self.props.formFactor
	local backgroundColor = theme.Widget.Background[formFactor].Color
	local backgroundTransparency = theme.Widget.Background[formFactor].Transparency
	local titleColor = theme.Widget.Header.Text.Color
	local titleFont = theme.Widget.Header.Text.Font
	local layoutOrder = self.props.layoutOrder
	local contentPadding = Cryo.Dictionary.join(DEFAULT_CONTENT_PADDING, self.props.contentPadding or {})
	local icon = self.props.icon
	local titleKey = self.props.titleKey
	local renderContent = self.props.renderContent
	local onActivated = self.props.onActivated

	return Roact.createElement(FitChildren.FitImageButton, {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		fitAxis = FitChildren.FitAxis.Height,
		BorderSizePixel = 0,
		ImageTransparency = 1,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		[Roact.Event.Activated] = onActivated,
	}, {
		Widget = Roact.createElement(Widget, {
			layoutOrder = layoutOrder,
			titlePadding = DEFAULT_TITLE_PADDING,
			contentPadding = contentPadding,
			backgroundImage = BACKGROUND_IMAGE,
			backgroundColor = backgroundColor,
			backgroundTransparency = backgroundTransparency,
			icon = icon,
			iconSize = TITLE_ICON_SIZE,
			titleGutterSize = TITLE_ICON_TEXT_GUTTER,
			titleKey = titleKey,
			titleSize = TITLE_TEXT_SIZE,
			titleColor = titleColor,
			titleFont = titleFont,
			renderContent = renderContent,
		}),
	})
end

HomePageWidget = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
		}
	end
)(HomePageWidget)

return HomePageWidget