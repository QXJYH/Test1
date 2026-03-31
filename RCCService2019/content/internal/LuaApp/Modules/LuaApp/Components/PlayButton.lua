local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local PlayButtonStates = require(Modules.LuaApp.Enum.PlayButtonStates)

local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)

local PLAY_ICON_SIZE = 36
local ROBUX_ICON_SIZE = 26
local PRIVATE_ICON_SIZE = 36
local UNPLAYABLE_ICON_SIZE = 36

local ROBUX_TEXT_FONT_SIZE = 22
local ROBUX_ICON_TEXT_GAP = 5

local BACKGROUND_IMAGE_9_SLICE = "LuaApp/buttons/buttonFill"
local PLAY_ICON = "LuaApp/icons/GameDetails/play"
local ROBUX_ICON = "LuaApp/icons/ic-ROBUX"
local PRIVATE_ICON = "LuaApp/icons/GameDetails/private"
local UNPLAYABLE_ICON = "LuaApp/icons/GameDetails/unavailable"

local PlayButton = Roact.PureComponent:extend("PlayButton")

function PlayButton:init()
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

function PlayButton:render()
	local theme = self._context.AppTheme
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local font = self.props.Font
	local price = self.props.price
	local playButtonState = self.props.playButtonState
	local onActivated = self.props.onActivated
	local isButtonPressed = self.state.isButtonPressed

	local childElement = nil
	local buttonTransparency = 0

	if playButtonState == PlayButtonStates.Loading then
		buttonTransparency = theme.ContextPrimaryButton.LoadingTransparency

		childElement = Roact.createElement(ShimmerAnimation, {
			Size = UDim2.new(1, 0, 2, 0),
			Position = UDim2.new(0, 0, 0, 0),
			shimmerSpeed = 1.5,
		})

	elseif playButtonState == PlayButtonStates.Playable then
		if isButtonPressed then
			buttonTransparency = theme.ContextPrimaryButton.OnPressTransparency
		end

		childElement = Roact.createElement(ImageSetLabel, {
			Size = UDim2.new(0, PLAY_ICON_SIZE, 0, PLAY_ICON_SIZE),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = PLAY_ICON,
			ImageTransparency = buttonTransparency,
		})

	elseif playButtonState == PlayButtonStates.PaidAccess then
		if isButtonPressed then
			buttonTransparency = theme.ContextPrimaryButton.OnPressTransparency
		end

		childElement = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, ROBUX_ICON_TEXT_GAP),
			}),
			RobuxIcon = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, ROBUX_ICON_SIZE, 0, ROBUX_ICON_SIZE),
				BackgroundTransparency = 1,
				Image = ROBUX_ICON,
				ImageTransparency = buttonTransparency,
				LayoutOrder = 1,
			}),
			RobuxText = Roact.createElement(FitTextLabel, {
				Size = UDim2.new(0, 0, 0, ROBUX_TEXT_FONT_SIZE),
				BackgroundTransparency = 1,
				Text = price,
				Font = font,
				TextSize = ROBUX_TEXT_FONT_SIZE,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextWrapped = false,
				TextColor3 = theme.ContextPrimaryButton.Text.Color,
				TextTransparency = buttonTransparency,
				LayoutOrder = 2,
				fitAxis = FitChildren.FitAxis.Width,
			})
		})

	elseif playButtonState == PlayButtonStates.Private then
		buttonTransparency = theme.ContextPrimaryButton.DisabledTransparency

		childElement = Roact.createElement(ImageSetLabel, {
			Size = UDim2.new(0, PRIVATE_ICON_SIZE, 0, PRIVATE_ICON_SIZE),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = PRIVATE_ICON,
			ImageTransparency = buttonTransparency,
		})

	elseif playButtonState == PlayButtonStates.UnplayableOther then
		buttonTransparency = theme.ContextPrimaryButton.DisabledTransparency

		childElement = Roact.createElement(ImageSetLabel, {
			Size = UDim2.new(0, UNPLAYABLE_ICON_SIZE, 0, UNPLAYABLE_ICON_SIZE),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = UNPLAYABLE_ICON,
			ImageTransparency = buttonTransparency,
		})
	else
		error("invalid play button state!")
	end

	return Roact.createElement(ImageSetButton, {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Image = BACKGROUND_IMAGE_9_SLICE,
		ImageColor3 = theme.ContextPrimaryButton.Color,
		ImageTransparency = buttonTransparency,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 8, 9, 9),
		ClipsDescendants = true,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnded,
		[Roact.Event.Activated] = onActivated,
	}, {
		childElement,
	})
end

return PlayButton
