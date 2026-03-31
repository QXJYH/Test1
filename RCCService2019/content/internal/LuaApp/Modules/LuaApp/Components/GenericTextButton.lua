local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)

local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)

local BACKGROUND_IMAGE_9_SLICE_FILL = "LuaApp/buttons/buttonFill"
local BACKGROUND_IMAGE_9_SLICE_BORDER = "LuaApp/buttons/buttonStroke"

local GenericTextButton = Roact.PureComponent:extend("GenericTextButton")

function GenericTextButton:init()
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

local function getCombinedTransparency(transparency1, transparency2)
	return 1 - (1 - transparency1) * (1 - transparency2)
end

function GenericTextButton:render()
	local themeSettings = self.props.themeSettings
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local text = self.props.Text
	local font = self.props.Font
	local textSize = self.props.TextSize
	local onActivated = self.props.onActivated
	local isLoading = self.props.isLoading
	local isDisabled = self.props.isDisabled
	local isButtonPressed = self.state.isButtonPressed
	local hasBorder = themeSettings.Border.Hidden == false

	local backgroundColor = themeSettings.Color
	local buttonTransparency = 0
	if isLoading or isDisabled then
		backgroundColor = themeSettings.DisabledColor
		buttonTransparency = themeSettings.DisabledTransparency
	elseif isButtonPressed then
		backgroundColor = themeSettings.OnPressColor
		buttonTransparency = themeSettings.OnPressTransparency
	end
	local backgroundTransparency = getCombinedTransparency(buttonTransparency, themeSettings.Transparency)
	local borderTransparency = hasBorder and
		getCombinedTransparency(buttonTransparency, themeSettings.Border.Transparency) or 0
	local textTransparency = getCombinedTransparency(buttonTransparency, themeSettings.Text.Transparency)

	return Roact.createElement(ImageSetButton, {
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
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.Activated] = onActivated,
		}, {
			Border = hasBorder and Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = BACKGROUND_IMAGE_9_SLICE_BORDER,
				ImageColor3 = themeSettings.Border.Color,
				ImageTransparency = borderTransparency,
				BorderSizePixel = 0,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(8, 8, 9, 9),
			}),
			Text = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, textSize),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Text = text,
				Font = font,
				TextSize = textSize,
				TextColor3 = themeSettings.Text.Color,
				TextTransparency = textTransparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				BackgroundTransparency = 1,
			}),
			ShimmerAnimation = isLoading and Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
			}, {
				Shimmer = Roact.createElement(ShimmerAnimation, {
					Size = UDim2.new(1, 0, 2, 0),
					Position = UDim2.new(0, 0, 0, 0),
					shimmerSpeed = 1.5,
				}),
			})
		})
end

return GenericTextButton
