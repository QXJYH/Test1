local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local function TouchFriendlyIconButton(props)
	local position = props.Position
	local anchorPoint = props.AnchorPoint
	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local onActivated = props.onActivated
	local icon = props.icon
	local iconSize = props.iconSize
	local iconPosition = props.iconPosition or UDim2.new(0.5, 0, 0.5, 0)
	local iconAnchorPoint = props.iconAnchorPoint or Vector2.new(0.5, 0.5)
	local iconColor = props.iconColor
	local iconTransparency = props.iconTransparency
	local children = props[Roact.Children]

	return Roact.createElement("TextButton", {
		Position = position,
		AnchorPoint = anchorPoint,
		Size = size,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		Text = "",
		[Roact.Event.Activated] = onActivated,
	}, {
		NavigationButton = Roact.createElement(ImageSetLabel, {
			Size = UDim2.new(0, iconSize, 0, iconSize),
			Position = iconPosition,
			AnchorPoint = iconAnchorPoint,
			Image = icon,
			ImageColor3 = iconColor,
			ImageTransparency = iconTransparency,
			BackgroundTransparency = 1,
		}, children),
	})
end

return TouchFriendlyIconButton