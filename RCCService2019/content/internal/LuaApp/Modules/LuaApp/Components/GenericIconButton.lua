local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)

local BUTTON_BORDER_9S_IMAGE = "LuaApp/buttons/buttonStroke"
local BUTTON_BORDER_9S_CENTER = Rect.new(8, 8, 9, 9)
local BUTTON_FILL_9S_IMAGE = "LuaApp/buttons/buttonFill"
local BUTTON_FILL_9S_CENTER = Rect.new(8, 8, 9, 9)

local GenericIconButton = Roact.PureComponent:extend("GenericIconButton")

GenericIconButton.defaultProps = {
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	LayoutOrder = 1,
	isDisabled = false,
	isChecked = false,
	isLoading = false,
}

function GenericIconButton:init()
	self.state = {
		isButtonPressed = false,
	}

	self.onInputBegan = function()
		self:setState({
			isButtonPressed = true
		})
	end

	self.onInputEnded = function()
		self:setState({
			isButtonPressed = false
		})
	end
end

function GenericIconButton:render()
	local iconButtonTheme = self._context.AppTheme.IconButton
	local anchorPoint = self.props.AnchorPoint
	local size = self.props.Size
	local buttonRef = self.props.buttonRef
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local iconImage = self.props.iconImage
	local iconSize = self.props.iconSize
	local onActivated = self.props.onActivated
	local isDisabled = self.props.isDisabled
	local isChecked = self.props.isChecked
	local isLoading = self.props.isLoading
	local isLoaded = not isLoading

	local isButtonPressed = self.state.isButtonPressed

	local border = iconButtonTheme.Border.Off
	local fill = iconButtonTheme.Fill.Off
	local icon = iconButtonTheme.Icon.Off
	if isDisabled then
		border = iconButtonTheme.Border.Disabled
		fill = iconButtonTheme.Fill.Disabled
		icon = iconButtonTheme.Icon.Disabled
		isButtonPressed = false
		isChecked = false
		isLoading = false
	end
	if isChecked then
		border = iconButtonTheme.Border.On
		fill = iconButtonTheme.Fill.On
		icon = iconButtonTheme.Icon.On
	end
	if isLoading then
		border = iconButtonTheme.Border.Loading
		fill = iconButtonTheme.Fill.Loading
		icon = iconButtonTheme.Icon.Loading
	end
	if isButtonPressed and isLoaded then
		border = iconButtonTheme.Border.OnPress
		fill = iconButtonTheme.Fill.OnPress
		icon = iconButtonTheme.Icon.OnPress
	end

	return Roact.createElement(ImageSetButton, {
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			AnchorPoint = anchorPoint,
			Size = size,
			Position = position,
			Image = BUTTON_FILL_9S_IMAGE,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = BUTTON_FILL_9S_CENTER,
			ImageTransparency = fill.Transparency,
			ImageColor3 = fill.Color,
			LayoutOrder = layoutOrder,
			ClipsDescendants = false, -- Disable clip so size blending behaves nicely on all devices
			[Roact.Event.Activated] = isLoaded and onActivated or nil,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Ref] = buttonRef,
		}, {
			Border = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ImageTransparency = border.Transparency,
				ImageColor3 = border.Color,
				Image = BUTTON_BORDER_9S_IMAGE,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = BUTTON_BORDER_9S_CENTER,
			},{
				Icon = Roact.createElement(ImageSetLabel, {
					Size = iconSize,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Image = iconImage,
					ImageTransparency = icon.Transparency,
					ImageColor3 =  icon.Color,
				})
			}),
			ShimmerAnimation = isLoading and Roact.createElement(ShimmerAnimation, {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				shimmerSpeed = 1.5,
			}),
		})
end

return GenericIconButton
