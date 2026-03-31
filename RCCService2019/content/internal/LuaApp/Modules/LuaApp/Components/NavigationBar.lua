--[[
	A navigation bar that simply has a button at left, and a title (can be nil)
	-----------------------------
	#          title
	-----------------------------
	Can be placed on top of a page, or on top of an overlay.
]]

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local Colors = require(Modules.LuaApp.Themes.Colors)

local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local TouchFriendlyIconButton = require(Modules.LuaApp.Components.Generic.TouchFriendlyIconButton)

local NavigateBack = require(Modules.LuaApp.Thunks.NavigateBack)

local NavigationBar = Roact.PureComponent:extend("NavigationBar")

NavigationBar.defaultProps = {
	icon = "LuaApp/icons/ic-roblox-close",
	iconSize = 36,
	iconColor = Colors.White,
	buttonSize = 36,
	buttonLeftPadding = 10,
	titleFont = Enum.Font.SourceSansBold,
	titleTextSize = 23,
	titleColor = Colors.White,
	paddingTop = 0,
	paddingBottom = 0,
}

function NavigationBar:render()
	local size = self.props.Size
	local position = self.props.Position
	local icon = self.props.icon
	local iconSize = self.props.iconSize
	local iconColor = self.props.iconColor
	local buttonSize = self.props.buttonSize
	local buttonLeftPadding = self.props.buttonLeftPadding
	local title = self.props.title
	local titleFont = self.props.titleFont
	local titleTextSize = self.props.titleTextSize
	local titleColor = self.props.titleColor
	local paddingTop = self.props.paddingTop
	local paddingBottom = self.props.paddingBottom
	local onNavigationButtonActivated = self.props.onNavigationButtonActivated or self.props.navigateBack

	return Roact.createElement("Frame", {
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, paddingTop),
			PaddingBottom = UDim.new(0, paddingBottom),
		}),
		NavigationButton = Roact.createElement(TouchFriendlyIconButton, {
			Position = UDim2.new(0, buttonLeftPadding, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(0, buttonSize, 0, buttonSize),
			onActivated = onNavigationButtonActivated,
			icon = icon,
			iconColor = iconColor,
			iconSize = iconSize,
		}),
		Title = title and Roact.createElement(LocalizedTextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			Text = title,
			Font = titleFont,
			TextSize = titleTextSize,
			TextColor3 = titleColor,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			BackgroundTransparency = 1,
		}),
	})
end

NavigationBar = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			navigateBack = function()
				return dispatch(NavigateBack())
			end
		}
	end
)(NavigationBar)

return NavigationBar
