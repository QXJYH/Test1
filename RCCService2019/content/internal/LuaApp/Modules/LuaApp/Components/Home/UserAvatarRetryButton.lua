local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)

local FitChildren = require(Modules.LuaApp.FitChildren)
local RetryButton = require(Modules.LuaApp.Components.RetryButton)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)

local ICON_TO_TEXT_PADDING = 40
local MAX_TEXT_SIZE = 24
local TEXT_LABEL_MAX_HEIGHT = MAX_TEXT_SIZE * 3

local FAIL_MESSAGE_KEY = "Feature.Avatar.Message.FailedToLoadAvatar"

local UserAvatarRetryButton = Roact.PureComponent:extend("UserAvatarRetryButton")

function UserAvatarRetryButton:render()
	local theme = self._context.AppTheme

	local position = self.props.position
	local anchorPoint = self.props.anchorPoint
	local maxTextWidth = self.props.maxTextWidth
	local onRetry = self.props.onRetry

	local textLabelSize = UDim2.new(1, 0, 0, TEXT_LABEL_MAX_HEIGHT)
	if maxTextWidth then
		textLabelSize = UDim2.new(0, maxTextWidth, 0, TEXT_LABEL_MAX_HEIGHT)
	end

	return Roact.createElement(FitChildren.FitFrame, {
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
	}, {
		ListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, ICON_TO_TEXT_PADDING),
		}),
		RetryButton = Roact.createElement(RetryButton, {
			layoutOrder = 1,
			onRetry = onRetry,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),
		FailMessage = Roact.createElement(LocalizedTextLabel, {
			LayoutOrder = 2,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = textLabelSize,
			TextColor3 = theme.Main.BodyText.Color,
			Font = theme.Main.BodyText.Font,
			Text = FAIL_MESSAGE_KEY,
			TextScaled = true,
		}, {
			UITextSizeConstraint = Roact.createElement("UITextSizeConstraint", {
				MaxTextSize = MAX_TEXT_SIZE,
			}),
		}),
	})
end

return UserAvatarRetryButton