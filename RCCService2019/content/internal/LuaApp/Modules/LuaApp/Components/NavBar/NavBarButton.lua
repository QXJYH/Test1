local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Modules = CoreGui.RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local NumericalBadge = require(Modules.LuaApp.Components.NumericalBadge)

local ICON_SIZE = 36
local NUMERICAL_BADGE_OFFSET = 16
local UNSELECTED_TRANSPARENCY = 0.5

local NavBarButton = Roact.PureComponent:extend("NavBarButton")

NavBarButton.defaultProps = {
	size = UDim2.new(1, 0, 1, 0),
	badgeCount = 0,
}

function NavBarButton:init()
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
		local onActivated = ArgCheck.isType(self.props.onActivated, "function", "NavBarButton.props.onActivated")
		onActivated(self.props.page, self.props.actionType)
	end
end

function NavBarButton:render()
	local size = self.props.size
	local layoutOrder = self.props.layoutOrder
	local icon = self.props.icon
	local selected = self.props.selected
	local badgeCount = self.props.badgeCount

	local iconSize = self.state.iconSize

	return withStyle(function(style)
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
				ImageColor3 = style.Theme.SystemPrimaryDefault.Color,
				ImageTransparency = selected and style.Theme.SystemPrimaryDefault.Transparency or UNSELECTED_TRANSPARENCY,
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
	end)
end

return NavBarButton