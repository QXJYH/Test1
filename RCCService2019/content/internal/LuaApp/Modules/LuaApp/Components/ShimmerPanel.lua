local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)

local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)

local ShimmerPanel = Roact.PureComponent:extend("ShimmerPanel")

function ShimmerPanel:render()
	local theme = self._context.AppTheme
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder

	return Roact.createElement("Frame", {
		Size = size,
		Position = position,
		BackgroundColor3 = theme.ShimmerPanel.Color,
		BackgroundTransparency = theme.ShimmerPanel.Transparency,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
	}, {
		Roact.createElement(ShimmerAnimation, {
			Size = UDim2.new(1, 0, 1, 0),
			shimmerScale = 4,
			shimmerSpeed = 2.5,
		})
	})

end

return ShimmerPanel