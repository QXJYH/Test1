local Modules = game:GetService("CoreGui").RobloxGui.Modules
local RunService = game:GetService("RunService")
local CorePackages = game:GetService("CorePackages")

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)

local FlagSettings = require(Modules.LuaApp.FlagSettings)

local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local RETRY_BUTTON_HEIGHT = 76
local RETRY_BUTTON_WIDTH = 76
local RETRY_BACKGROUND_IMAGE = "LuaApp/9-slice/white_button_9slices"

local RETRY_SPINNER_HEIGHT = 28
local RETRY_SPINNER_WIDTH = 28
local RETRY_SPINNER_IMAGE = "LuaApp/icons/icon_retry_white"

-- TODO: The retry button needs to be re-implemented with a GenericButton once it's avaialble.
if UseNewAppStyle then
	RETRY_BUTTON_WIDTH = 44
	RETRY_BUTTON_HEIGHT = 44
	RETRY_BACKGROUND_IMAGE = {
		Image = "LuaApp/buttons/buttonFill",
		SliceCenter = Rect.new(8, 8, 9, 9),
	}

	RETRY_SPINNER_WIDTH = 36
	RETRY_SPINNER_HEIGHT = 36
	RETRY_SPINNER_IMAGE = "LuaApp/icons/common_refresh"
end

local BACKGROUND_IMAGE_9_SLICE_BORDER = {
	Image = "LuaApp/buttons/buttonStroke",
	SliceCenter = Rect.new(8, 8, 9, 9),
}

-- We don't want the user to be spamming the retry button too much
local BUTTON_COOLDOWN = 1.5

-- The button has rounded corners, we want to make the shimmer
-- slightly smaller, to not go above the corners.
local SHIMMER_SHRINK_SIZE = 1

local RetryButton = Roact.PureComponent:extend("RetryButton")

function RetryButton:init()
	self.state = {
		isRetrying = false,
		isInCooldown = false,
	}

	self._isMounted = false
	self.cooldownTimer = 0

	self.safeSetState = function(newState)
		if self._isMounted then
			self:setState(newState)
		end
	end

	self.onActivated = function()
		local onRetry = self.props.onRetry
		local isRetrying = self.state.isRetrying
		local isInCooldown = self.state.isInCooldown
		local isButtonDisabled = isRetrying or isInCooldown

		if not isButtonDisabled and onRetry then
			self.cooldownTimer = 0
			self.safeSetState({
				isRetrying = true,
				isInCooldown = true,
			})

			onRetry():andThen(
				function()
					self.safeSetState({
						isRetrying = false,
					})
				end,
				function()
					self.safeSetState({
						isRetrying = false,
					})
				end
			)
		end
	end

	self.renderSteppedCallback = function(dt)
		local isInCooldown = self.state.isInCooldown

		if isInCooldown then
			self.cooldownTimer = self.cooldownTimer + dt
			if self.cooldownTimer >= BUTTON_COOLDOWN then
				self.safeSetState({
					isInCooldown = false,
				})
			end
		end
	end
end

function RetryButton:didMount()
	self._isMounted = true
end

function RetryButton:willUnmount()
	self._isMounted = false
end

function RetryButton:isDisabled()
	local isRetrying = self.state.isRetrying
	local isInCooldown = self.state.isInCooldown

	return isRetrying or isInCooldown
end

local function getCombinedTransparency(transparency1, transparency2)
	return 1 - (1 - transparency1) * (1 - transparency2)
end

function RetryButton:render()
	local theme = self._context.AppTheme
	local position = self.props.Position
	local anchorPoint = self.props.AnchorPoint
	local layoutOrder = self.props.LayoutOrder

	local isButtonDisabled = self:isDisabled()

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement(ImageSetButton, {
				Size = UDim2.new(0, RETRY_BUTTON_WIDTH, 0, RETRY_BUTTON_HEIGHT),
				Position = position,
				AnchorPoint = anchorPoint,
				LayoutOrder = layoutOrder,
				BackgroundTransparency = 1,
				Image = RETRY_BACKGROUND_IMAGE.Image,
				ImageColor3 = style.Theme.UIEmphasis.Color,
				ImageTransparency = getCombinedTransparency(style.Theme.UIEmphasis.Transparency,
					isButtonDisabled and 0.5 or 0),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = RETRY_BACKGROUND_IMAGE.SliceCenter,
				[Roact.Event.Activated] = self.onActivated,
			},{
				Border = Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = BACKGROUND_IMAGE_9_SLICE_BORDER.Image,
					ImageColor3 = style.Theme.SecondaryDefault.Color,
					ImageTransparency = getCombinedTransparency(style.Theme.SecondaryDefault.Transparency,
						isButtonDisabled and 0.5 or 0),
					BorderSizePixel = 0,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = BACKGROUND_IMAGE_9_SLICE_BORDER.SliceCenter,
				}),
				Spinner = Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, RETRY_SPINNER_WIDTH, 0, RETRY_SPINNER_HEIGHT),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					BackgroundTransparency = 1,
					Image = RETRY_SPINNER_IMAGE,
					ImageColor3 = style.Theme.IconEmphasis.Color,
					ImageTransparency = getCombinedTransparency(style.Theme.IconEmphasis.Transparency,
						isButtonDisabled and 0.5 or 0),
				}),
				Shimmer = isButtonDisabled and Roact.createElement(ShimmerAnimation, {
					Size = UDim2.new(1, -SHIMMER_SHRINK_SIZE * 2, 1, -SHIMMER_SHRINK_SIZE * 2),
					Position = UDim2.new(0, SHIMMER_SHRINK_SIZE, 0, SHIMMER_SHRINK_SIZE),
				}),
				renderStepped = Roact.createElement(ExternalEventConnection, {
					event = RunService.renderStepped,
					callback = self.renderSteppedCallback,
				}),
			})
		end)
	else
		return Roact.createElement(ImageSetButton, {
			Size = UDim2.new(0, RETRY_BUTTON_WIDTH, 0, RETRY_BUTTON_HEIGHT),
			Position = position,
			AnchorPoint = anchorPoint,
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
			Image = RETRY_BACKGROUND_IMAGE,
			ImageColor3 = isButtonDisabled and theme.RetryButton.DisabledColor or theme.RetryButton.Color,
			ImageTransparency = isButtonDisabled and theme.RetryButton.DisabledTransparency or 0,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(7,7,9,9),
			[Roact.Event.Activated] = self.onActivated,
		},{
			Spinner = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, RETRY_SPINNER_WIDTH, 0, RETRY_SPINNER_HEIGHT),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				Image = RETRY_SPINNER_IMAGE,
				ImageColor3 = isButtonDisabled and theme.RetryButton.DisabledColor or theme.RetryButton.Color,
				ImageTransparency = isButtonDisabled and theme.RetryButton.DisabledTransparency or 0,
			}),
			Shimmer = isButtonDisabled and Roact.createElement(ShimmerAnimation, {
				Size = UDim2.new(1, -SHIMMER_SHRINK_SIZE * 2, 1, -SHIMMER_SHRINK_SIZE * 2),
				Position = UDim2.new(0, SHIMMER_SHRINK_SIZE, 0, SHIMMER_SHRINK_SIZE),
			}),
			renderStepped = Roact.createElement(ExternalEventConnection, {
				event = RunService.renderStepped,
				callback = self.renderSteppedCallback,
			}),
		})
	end
end

return RetryButton