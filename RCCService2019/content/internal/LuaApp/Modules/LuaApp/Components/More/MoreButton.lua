local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local withLocalization = require(Modules.LuaApp.withLocalization)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local ICON_SIZE = 26
local RIGHT_IMAGE_SIZE = 18

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local MoreButton = Roact.PureComponent:extend("MoreButton")

MoreButton.defaultProps = {
	Size = UDim2.new(1, 0, 1, 0),
	Position = UDim2.new(0, 0, 0, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	LayoutOrder = 1,
}

function MoreButton:eventDisconnect()
	if self.onAbsolutePositionChanged then
		self.onAbsolutePositionChanged:disconnect()
		self.onAbsolutePositionChanged = nil
	end
end

function MoreButton:onButtonUp()
	if self.state.buttonPressed then
		self:setState({
			buttonPressed = false,
		})
	end
	self:eventDisconnect()
end

function MoreButton:onButtonDown()
	if not self.state.buttonPressed then
		self:eventDisconnect()
		self.onAbsolutePositionChanged = self.buttonRef.current and
			self.buttonRef.current:GetPropertyChangedSignal("AbsolutePosition"):connect(function()
			self:onButtonUp()
		end)
		self:setState({
			buttonPressed = true,
		})
	end
end

function MoreButton:init()
	self.state = {
		buttonPressed = false,
	}

	self.buttonRef = Roact.createRef()

	self.onButtonInputBegan = function(_, inputObject)
		if inputObject.UserInputState == Enum.UserInputState.Begin and
			(inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
			self:onButtonDown()
		end
	end

	self.onButtonInputEnded = function()
		self:onButtonUp()
	end

	self.onButtonActivated = function()
		self:onButtonUp()
		local onActivated = self.props.onActivated
		if onActivated then
			onActivated()
		end
	end
end

function MoreButton:render()
	local theme = self._context.AppTheme
	local buttonPressed = self.state.buttonPressed

	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local text = self.props.Text
	local textXAlignment = self.props.TextXAlignment
	local icon = self.props.icon
	local rightImage = self.props.rightImage
	local badgeComponent = self.props.badgeComponent
	local badgeCount = self.props.badgeCount

	local textXOffset = (textXAlignment == Enum.TextXAlignment.Center) and 0 or
		(icon and Constants.MORE_PAGE_TEXT_PADDING_WITH_ICON or Constants.MORE_PAGE_ROW_PADDING_LEFT)

	local showNotificationBadge = badgeComponent and badgeCount and badgeCount > 0

	local renderMoreButton = function(localized, backgroundStyle, textStyle, iconStyle, rightImageStyle)
		return Roact.createElement("ImageButton", {
			Size = size,
			Position = position,
			AutoButtonColor = false,
			LayoutOrder = layoutOrder,
			BackgroundColor3 = backgroundStyle.Color,
			BackgroundTransparency = backgroundStyle.Transparency,
			BorderSizePixel = 0,
			[Roact.Event.InputBegan] = self.onButtonInputBegan,
			[Roact.Event.InputEnded] = self.onButtonInputEnded,
			[Roact.Event.Activated] = self.onButtonActivated,
			[Roact.Ref] = self.buttonRef,
		}, {
			Icon = icon and Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
				Position = UDim2.new(0, Constants.MORE_PAGE_ROW_PADDING_LEFT, 0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClipsDescendants = false,
				Image = icon,
				ImageColor3 = iconStyle.Color,
				ImageTransparency = iconStyle.Transparency,
			}),
			Text = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, textXOffset, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = localized.moreButtonText,
				Font = textStyle.Font,
				TextSize = textStyle.Size,
				TextColor3 = textStyle.Color,
				TextTransparency = textStyle.Transparency,
				TextXAlignment = textXAlignment,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
			RightImage = rightImage and Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(1, 0.5),
				Size = UDim2.new(0, RIGHT_IMAGE_SIZE, 0, RIGHT_IMAGE_SIZE),
				Position = UDim2.new(1, -Constants.MORE_PAGE_ROW_PADDING_RIGHT, 0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = rightImage,
				ImageColor3 = rightImageStyle.Color,
				ImageTransparency = rightImageStyle.Transparency,
			}),
			NotificationBadge = showNotificationBadge and Roact.createElement(badgeComponent, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -Constants.MORE_PAGE_ROW_PADDING_RIGHT * 2 - RIGHT_IMAGE_SIZE, 0.5, 0),
				badgeCount = badgeCount,
			}),
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			local backgroundStyle = buttonPressed and style.Theme.BackgroundDefault or style.Theme.BackgroundUIDefault
			local textStyle = Cryo.Dictionary.join(style.Theme.TextDefault, {
				Font = style.Font.Header2.Font,
				Size = style.Font.BaseSize * style.Font.Header2.RelativeSize
			})
			return withLocalization({
				moreButtonText = text
			})(function(localized)
				return renderMoreButton(localized, backgroundStyle, textStyle,
				style.Theme.TextDefault, style.Theme.SecondaryDefault)
			end)
		end)
	else
		local buttonTheme = theme.MorePage.Button
		local backgroundStyle = buttonPressed and buttonTheme.Background.Pressed or buttonTheme.Background.Default
		local iconStyle = buttonTheme.Icon
		local rightImageStyle = buttonTheme.RightImage
		return withLocalization({
			moreButtonText = text
		})(function(localized)
			return renderMoreButton(localized, backgroundStyle, buttonTheme.Text, iconStyle, rightImageStyle)
		end)
	end
end

function MoreButton:willUnmount()
	self:eventDisconnect()
end

return MoreButton
