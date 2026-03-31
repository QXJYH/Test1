local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local BACKGROUND_IMAGE_9_SLICE_FILL = "LuaApp/buttons/buttonFill"
local BACKGROUND_IMAGE_9_SLICE_BORDER = "LuaApp/buttons/buttonStroke"

local GenericTextBox = Roact.PureComponent:extend("GenericTextBox")

function GenericTextBox:render()
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local text = self.props.Text
	local font = self.props.Font
	local textSize = self.props.TextSize
	local onChangeText = self.props.onChangeText
	local placeholderText = self.props.PlaceholderText
	local textXAlignment = self.props.TextXAlignment
	local textColor = self.props.TextColor
	local placeholderColor = self.props.PlaceholderColor
	local isPassword = self.props.IsPassword
	local clearTextOnFocus = self.props.ClearTextOnFocus

	local backgroundColor = self.props.Color
	local backgroundTransparency = self.props.Transparency
	local textTransparency = self.props.TextTransparency

	local paddingX = self.props.PaddingX
	local paddingY = self.props.PaddingY

	local textBoxRef = self.props.TextBoxRef

	return Roact.createElement(ImageSetLabel, {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		Image = BACKGROUND_IMAGE_9_SLICE_FILL,
		ImageColor3 = backgroundColor,
		ImageTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 8, 9, 9),
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, paddingY),
			PaddingBottom = UDim.new(0, paddingY),
			PaddingLeft = UDim.new(0, paddingX),
			PaddingRight = UDim.new(0, paddingX)
		}),
		TextBox = Roact.createElement("TextBox", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = text,
			PlaceholderText = placeholderText,
			PlaceholderColor3 = placeholderColor,
			Font = font,
			TextSize = textSize,
			TextColor3 = textColor,
			TextTransparency = textTransparency,
			TextXAlignment = textXAlignment,
			TextYAlignment = Enum.TextYAlignment.Center,
			BackgroundTransparency = 1,
			IsPassword = isPassword,
			ClearTextOnFocus = clearTextOnFocus,
			OverlayNativeInput = true,
			[Roact.Ref] = textBoxRef,
			[Roact.Change.Text] = onChangeText
		}),
	})
end

return GenericTextBox
