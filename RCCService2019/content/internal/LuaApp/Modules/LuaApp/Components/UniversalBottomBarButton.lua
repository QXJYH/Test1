local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Modules = CoreGui.RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local withLocalization = require(Modules.LuaApp.withLocalization)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local NumericalBadge = require(Modules.LuaApp.Components.NumericalBadge)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)

local ICON_SIZE = 36
local NUMERICAL_BADGE_OFFSET = 16
local ICON_TEXT_PADDING = {
	[Enum.FillDirection.Horizontal] = 12,
	[Enum.FillDirection.Vertical] = -4,
}

local IsLuaBottomBarWithText = FlagSettings.IsLuaBottomBarWithText()
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local UniversalBottomBarButton = Roact.PureComponent:extend("UniversalBottomBarButton")

UniversalBottomBarButton.defaultProps = {
	size = UDim2.new(1, 0, 1, 0),
	badgeCount = 0,
	fillDirection = Enum.FillDirection.Horizontal,
}

function UniversalBottomBarButton:init()
	self.state = {
		iconSize = ICON_SIZE,
	}

	self.onAbsoluteSizeChanged = function(rbx)
		local iconSize = math.min(ICON_SIZE, math.min(rbx.AbsoluteSize.X, rbx.AbsoluteSize.Y))
		if iconSize ~= self.state.iconSize then
			self:setState({
				iconSize = iconSize,
			})
		end
	end

	self.onActivated = function()
		local onActivated = self.props.onActivated
		ArgCheck.isType(onActivated, "function", "UniversalBottomBarButton.props.onActivated")
		onActivated(self.props.page, self.props.actionType)
	end
end

function UniversalBottomBarButton:render()
	local theme = self._context.AppTheme

	local size = self.props.size
	local layoutOrder = self.props.layoutOrder
	local icon = self.props.icon
	local selected = self.props.selected
	local badgeCount = self.props.badgeCount
	local titleKey = self.props.titleKey
	local fillDirection = self.props.fillDirection

	local iconSize = self.state.iconSize

	if IsLuaBottomBarWithText then
		ArgCheck.isType(titleKey, "string", "UniversalBottomBarButton.props.titleKey")

		local renderButton = function(localized, iconStyle, textStyle)
			return Roact.createElement("TextButton", {
				Size = size,
				Text = "",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				LayoutOrder = layoutOrder,

				[Roact.Event.Activated] = self.onActivated,
				[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = fillDirection,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, ICON_TEXT_PADDING[fillDirection]),
				}),
				Icon = Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, iconSize, 0, iconSize),
					Image = icon,
					ImageColor3 = iconStyle.Color,
					ImageTransparency = iconStyle.Transparency,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
				}, {
					Badge = badgeCount > 0 and Roact.createElement(NumericalBadge, {
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, NUMERICAL_BADGE_OFFSET, 1, -NUMERICAL_BADGE_OFFSET),
						badgeCount = badgeCount,
						inAppChrome = true,
					}),
				}),
				Title = Roact.createElement(FitTextLabel, {
					Size = UDim2.new(0, 0, 0, textStyle.Size),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = localized.titleText,
					TextColor3 = textStyle.Color,
					TextTransparency = textStyle.Transparency,
					TextSize = textStyle.Size,
					Font = textStyle.Font,
					LayoutOrder = 2,

					fitAxis = FitChildren.FitAxis.Width,
				}),
			})
		end
		if UseNewAppStyle then
			return withStyle(function(style)
				local iconStyle = {
					Color = style.Theme.SystemPrimaryDefault.Color,
					Transparency = selected and style.Theme.SystemPrimaryDefault.Transparency or 0.5,
				}
				local textStyle = {
					Color = style.Theme.SystemPrimaryDefault.Color,
					Transparency = selected and style.Theme.SystemPrimaryDefault.Transparency or 0.5,
					Size = style.Font.BaseSize * style.Font.CaptionHeader.RelativeSize,
					Font = style.Font.CaptionHeader.Font,
				}
				return withLocalization({
					titleText = titleKey
				})(function(localized)
					return renderButton(localized, iconStyle, textStyle)
				end)
			end)
		else
			local iconTheme = selected and theme.BottomBarButton.Icon.On or theme.BottomBarButton.Icon.Off
			local titleTheme = theme.BottomBarButton.Title

			local iconStyle = {
				Color = iconTheme.Color,
				Transparency = iconTheme.Transparency,
			}
			local textStyle = {
				Color = iconTheme.Color,
				Transparency = iconTheme.Transparency,
				Size = titleTheme.Size,
				Font = titleTheme.Font,
			}
			return withLocalization({
				titleText = titleKey
			})(function(localized)
				return renderButton(localized, iconStyle, textStyle)
			end)
		end
	else
		local renderButton = function(iconStyle)
			return Roact.createElement("TextButton", {
				Size = size,
				Text = "",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				LayoutOrder = layoutOrder,

				[Roact.Event.Activated] = self.onActivated,
				[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,
			}, {
				Icon = Roact.createElement(ImageSetLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, iconSize, 0, iconSize),
					Image = icon,
					ImageColor3 = iconStyle.Color,
					ImageTransparency = iconStyle.Transparency,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Badge = badgeCount > 0 and Roact.createElement(NumericalBadge, {
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.new(0, NUMERICAL_BADGE_OFFSET, 1, -NUMERICAL_BADGE_OFFSET),
						badgeCount = badgeCount,
						inAppChrome = true,
					}),
				}),
			})
		end

		if UseNewAppStyle then
			return withStyle(function(style)
				local iconStyle = {
					Color = style.Theme.SystemPrimaryDefault.Color,
					Transparency = selected and style.Theme.SystemPrimaryDefault.Transparency or 0.5,
				}
				return renderButton(iconStyle)
			end)
		else
			local iconTheme = selected and theme.BottomBarButton.Icon.On or theme.BottomBarButton.Icon.Off
			local iconStyle = {
				Color = iconTheme.Color,
				Transparency = iconTheme.Transparency,
			}
			return renderButton(iconStyle)
		end
	end
end

return UniversalBottomBarButton