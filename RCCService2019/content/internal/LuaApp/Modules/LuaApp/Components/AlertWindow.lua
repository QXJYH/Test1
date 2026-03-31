local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local Text = require(Modules.Common.Text)
local withLocalization = require(Modules.LuaApp.withLocalization)

local SystemPrimaryButton = require(Modules.LuaApp.Components.SystemPrimaryButton)
local SecondaryButton = require(Modules.LuaApp.Components.SecondaryButton)

local MAXIMUM_WIDTH = 400

local LEFT_OUTER_PADDING = 20
local RIGHT_OUTER_PADDING = 20
local LEFT_INNER_PADDING = 20
local RIGHT_INNER_PADDING = 20
local BOTTOM_INNER_PADDING = 20

local TITLE_PADDING = 11
local TITLE_HEIGHT = 28
local TITLE_TEXT_SIZE = 25
local TITLE_MESSAGE_PADDING = 40
local TITLE_DIVIDER_HEIGHT = 1

local MESSAGE_TEXT_SIZE = 20
local MESSAGE_BUTTON_PADDING = 46

local BUTTON_HEIGHT = 36
local BUTTON_PADDING = 10
local BUTTON_TEXT_SIZE = 22

local AlertWindow = Roact.PureComponent:extend("AlertWindow")

AlertWindow.defaultProps = {
	titleTextSize = TITLE_TEXT_SIZE,
	messageTextAlignment = Enum.TextXAlignment.Center
}

function AlertWindow:render()
	local theme = self._context.AppTheme
	local containerWidth = self.props.containerWidth
	local titleText = self.props.titleText
	local titleTextSize = self.props.titleTextSize
	local titleFont = self.props.titleFont
	local messageText = self.props.messageText
	local messageFont = self.props.messageFont
	local buttonFont = self.props.buttonFont
	local confirmButtonText = self.props.confirmButtonText
	local cancelButtonText = self.props.cancelButtonText
	local onConfirm = self.props.onConfirm
	local isConfirming = self.props.isConfirming
	local hasCancelButton = self.props.hasCancelButton
	local onCancel = self.props.onCancel
	local messageTextAlignment = self.props.messageTextAlignment

	local totalWidth = math.min(containerWidth - LEFT_OUTER_PADDING - RIGHT_OUTER_PADDING, MAXIMUM_WIDTH)

	local innerWidth = totalWidth - LEFT_INNER_PADDING - RIGHT_INNER_PADDING
	local buttonWidth = hasCancelButton and (innerWidth - BUTTON_PADDING) / 2 or innerWidth

	local messageTextHeight = Text.GetTextHeight(messageText, messageFont,
		MESSAGE_TEXT_SIZE, innerWidth)

	local totalHeight = TITLE_HEIGHT + TITLE_PADDING * 2 + TITLE_DIVIDER_HEIGHT +
		TITLE_MESSAGE_PADDING + messageTextHeight + MESSAGE_BUTTON_PADDING +
		BUTTON_HEIGHT + BOTTOM_INNER_PADDING

	local renderFrame = function(localized)
		return Roact.createElement("Frame", {
			Size = UDim2.new(0, totalWidth, 0, totalHeight),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = theme.AlertWindow.Background.Color,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, LEFT_INNER_PADDING),
				PaddingRight = UDim.new(0, RIGHT_INNER_PADDING),
				PaddingBottom = UDim.new(0, BOTTOM_INNER_PADDING),
			}),
			Title = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, TITLE_HEIGHT + TITLE_PADDING * 2),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				Title = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, TITLE_HEIGHT),
					Position = UDim2.new(0, 0, 0, TITLE_PADDING),
					BackgroundTransparency = 1,
					Text = titleText,
					Font = titleFont,
					TextSize = titleTextSize,
					TextColor3 = theme.AlertWindow.Title.Color,
					TextXAlignment = Enum.TextXAlignment.Center,
				}),
			}),
			Divider = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, TITLE_DIVIDER_HEIGHT),
				BackgroundColor3 = theme.AlertWindow.Divider.Color,
				BorderSizePixel = 0,
				LayoutOrder = 2,
			}),
			Message = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, TITLE_MESSAGE_PADDING + MESSAGE_BUTTON_PADDING + messageTextHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
			}, {
				Message = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, messageTextHeight),
					Position = UDim2.new(0, 0, 0, TITLE_MESSAGE_PADDING),
					BackgroundTransparency = 1,
					Text = messageText,
					Font = messageFont,
					TextSize = MESSAGE_TEXT_SIZE,
					TextColor3 = theme.AlertWindow.Message.Color,
					TextXAlignment = messageTextAlignment,
					TextWrapped = true,
				}),
			}),
			Buttons = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT),
				BackgroundTransparency = 1,
				LayoutOrder = 4,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, BUTTON_PADDING),
				}),
				CancelButton = hasCancelButton and Roact.createElement(SecondaryButton, {
					Size = UDim2.new(0, buttonWidth, 1, 0),
					Text = localized.cancelText,
					Font = buttonFont,
					TextSize = BUTTON_TEXT_SIZE,
					LayoutOrder = 1,
					onActivated = onCancel,
				}),
				ConfirmButton = Roact.createElement(SystemPrimaryButton, {
					Size = UDim2.new(0, buttonWidth, 1, 0),
					Text = isConfirming and "" or confirmButtonText,
					Font = buttonFont,
					TextSize = BUTTON_TEXT_SIZE,
					LayoutOrder = 2,
					onActivated = isConfirming and function() end or onConfirm,
					isLoading = isConfirming,
				}),
			})
		})
	end

	if cancelButtonText then
		return renderFrame({ cancelText = cancelButtonText })
	else
		return withLocalization({
			cancelText = "Feature.GamePage.LabelCancelField"
		})(function(localized)
			return renderFrame(localized)
		end)
	end
end

return AlertWindow
