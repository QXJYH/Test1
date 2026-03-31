local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)

local Colors = require(Modules.LuaApp.Themes.Colors)
local FitChildren = require(Modules.LuaApp.FitChildren)
local IconTextBar = require(Modules.LuaApp.Components.Generic.IconTextBar)

local BACKGROUND_COLOR = Colors.White
local BACKGROUND_IMAGE_SLICE_CENTER = Rect.new(9, 9, 9, 9)

local DEFAULT_TITLE_PADDING = {
	PaddingTop = UDim.new(0, 0),
	PaddingBottom = UDim.new(0, 0),
	PaddingLeft = UDim.new(0, 0),
	PaddingRight = UDim.new(0, 0),
}

local DEFAULT_CONTENT_PADDING = {
	PaddingTop = UDim.new(0, 0),
	PaddingBottom = UDim.new(0, 0),
	PaddingLeft = UDim.new(0, 0),
	PaddingRight = UDim.new(0, 0),
}

local Widget = Roact.PureComponent:extend("Widget")

Widget.defaultProps = {
	backgroundColor = BACKGROUND_COLOR,
	backgroundTransparency = 0,
	iconSize = 26,
	titleGutterSize = 9,
	titleSize = 28,
	titleFont = Enum.Font.SourceSans,
}

function Widget:render()
	local layoutOrder = self.props.layoutOrder
	local titlePadding = Cryo.Dictionary.join(DEFAULT_TITLE_PADDING, self.props.titlePadding or {})
	local contentPadding = Cryo.Dictionary.join(DEFAULT_CONTENT_PADDING, self.props.contentPadding or {})
	local backgroundImage = self.props.backgroundImage
	local backgroundColor = self.props.backgroundColor
	local backgroundTransparency = self.props.backgroundTransparency
	local icon = self.props.icon
	local iconSize = self.props.iconSize
	local titleGutterSize = self.props.titleGutterSize
	local titleKey = self.props.titleKey
	local titleSize = self.props.titleSize
	local titleColor = self.props.titleColor
	local titleFont = self.props.titleFont
	local renderContent = self.props.renderContent

	return Roact.createElement(FitChildren.FitImageLabel, {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		fitAxis = FitChildren.FitAxis.Height,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = BACKGROUND_IMAGE_SLICE_CENTER,
		ClipsDescendants = true,
		Image = backgroundImage,
		ImageColor3 = backgroundColor,
		ImageTransparency = backgroundTransparency,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		TitleBar = Roact.createElement(IconTextBar, {
			layoutOrder = 1,
			padding = titlePadding,
			icon = icon,
			iconSize = iconSize,
			gutterSize = titleGutterSize,
			textKey = titleKey,
			textSize = titleSize,
			textColor = titleColor,
			textFont = titleFont,
		}),
		ContentFrame = renderContent and Roact.createElement(FitChildren.FitFrame, {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			fitAxis = FitChildren.FitAxis.Height,
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout"),
			Padding = Roact.createElement("UIPadding", contentPadding),
			Content = Roact.createElement(renderContent),
		})
	})
end

return Widget