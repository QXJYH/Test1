local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Modules = CoreGui.RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local FitChildren = require(Modules.LuaApp.FitChildren)
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
local UNSELECTED_TRANSPARENCY = 0.5

local NavBarButtonWithText = Roact.PureComponent:extend("NavBarButtonWithText")

NavBarButtonWithText.defaultProps = {
	size = UDim2.new(1, 0, 1, 0),
	badgeCount = 0,
	fillDirection = Enum.FillDirection.Horizontal,
}

function NavBarButtonWithText:init()
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
		local onActivated = ArgCheck.isType(self.props.onActivated, "function", "NavBarButtonWithText.props.onActivated")
		onActivated(self.props.page, self.props.actionType)
	end
end

function NavBarButtonWithText:render()
	local size = self.props.size
	local layoutOrder = self.props.layoutOrder
	local icon = self.props.icon
	local selected = self.props.selected
	local badgeCount = self.props.badgeCount
	local titleKey = ArgCheck.isType(self.props.titleKey, "string", "UniversalBottomBarButton.props.titleKey")
	local fillDirection = self.props.fillDirection

	local iconSize = self.state.iconSize

	return withStyle(function(style)
		return withLocalization({
			titleText = titleKey
		})(function(localized)
			local transparency = selected and style.Theme.SystemPrimaryDefault.Transparency or UNSELECTED_TRANSPARENCY
			local textSize = style.Font.BaseSize * style.Font.CaptionHeader.RelativeSize

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
					ImageColor3 = style.Theme.SystemPrimaryDefault.Color,
					ImageTransparency = transparency,
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
					Size = UDim2.new(0, 0, 0, textSize),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = localized.titleText,
					TextColor3 = style.Theme.SystemPrimaryDefault.Color,
					TextTransparency = transparency,
					TextSize = textSize,
					Font = style.Font.CaptionHeader.Font,
					LayoutOrder = 2,

					fitAxis = FitChildren.FitAxis.Width,
				}),
			})
		end)
	end)
end

return NavBarButtonWithText