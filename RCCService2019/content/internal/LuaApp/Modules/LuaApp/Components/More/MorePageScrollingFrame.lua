local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local FitChildren = require(Modules.LuaApp.FitChildren)

local MorePageScrollingFrame = Roact.PureComponent:extend("MorePageScrollingFrame")

function MorePageScrollingFrame:render()
	local position = self.props.Position
	local size = self.props.Size

	return Roact.createElement(FitChildren.FitScrollingFrame, {
		Position = position,
		Size = size,
		CanvasSize = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		ElasticBehavior = Enum.ElasticBehavior.Always,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		fitFields = {
			CanvasSize = FitChildren.FitAxis.Height,
		},
	}, self.props[Roact.Children])
end

return MorePageScrollingFrame
