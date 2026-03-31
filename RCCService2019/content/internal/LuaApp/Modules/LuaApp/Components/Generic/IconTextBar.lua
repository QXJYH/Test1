local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)

local Colors = require(Modules.LuaApp.Themes.Colors)
local FitChildren = require(Modules.LuaApp.FitChildren)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)

local DEFAULT_PADDING = {
	PaddingTop = UDim.new(0, 0),
	PaddingBottom = UDim.new(0, 0),
	PaddingLeft = UDim.new(0, 0),
	PaddingRight = UDim.new(0, 0),
}

local IconTextBar = Roact.PureComponent:extend("IconTextBar")

IconTextBar.defaultProps = {
	iconSize = 26,
	gutterSize = 9,
	textSize = 28,
	textColor = Colors.Green,
	textFont = Enum.Font.SourceSans,
}

function IconTextBar:render()
	local layoutOrder = self.props.layoutOrder
	local padding = Cryo.Dictionary.join(DEFAULT_PADDING, self.props.padding or {})
	local icon = self.props.icon
	local iconSize = self.props.iconSize
	local gutterSize = self.props.gutterSize
	local textKey = self.props.textKey
	local textSize = self.props.textSize
	local textColor = self.props.textColor
	local textFont = self.props.textFont

	local textWidthOffset = 0
	if icon then
		textWidthOffset = - (iconSize + gutterSize)
	end

	return Roact.createElement(FitChildren.FitFrame, {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		fitAxis = FitChildren.FitAxis.Height,
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, gutterSize),
		}),
		Padding = Roact.createElement("UIPadding", padding),
		Icon = icon and Roact.createElement(ImageSetLabel, {
			LayoutOrder = 1,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, iconSize, 0, iconSize),
			Image = icon,
		}),
		Text = textKey and Roact.createElement(LocalizedTextLabel, {
			LayoutOrder = 2,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, textWidthOffset, 0, textSize),
			TextSize = textSize,
			TextColor3 = textColor,
			Font = textFont,
			Text = textKey,
		}),
	})
end

return IconTextBar