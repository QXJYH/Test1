local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local FitChildren = require(Modules.LuaApp.FitChildren)

local ShimmerPanel = require(Modules.LuaApp.Components.ShimmerPanel)

local LoadingSkeleton = Roact.PureComponent:extend("LoadingSkeleton")

function LoadingSkeleton:render()
	local size = self.props.Size
	local position = self.props.Position
	local anchorPoint = self.props.AnchorPoint
	local layoutOrder = self.props.LayoutOrder
	local panels = self.props.panels
	local createLayout = self.props.createLayout

	local shimmerPanels = {}

	if createLayout then
		shimmerPanels.Layout = createLayout()
	end

	for index, panel in ipairs(panels) do
		shimmerPanels[index] = Roact.createElement(ShimmerPanel, {
			Size = panel.Size,
			Position = panel.Position,
			LayoutOrder = index,
		})
	end

	if size then
		return Roact.createElement("Frame", {
			Size = size,
			Position = position,
			AnchorPoint = anchorPoint,
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
		}, shimmerPanels)
	else
		return Roact.createElement(FitChildren.FitFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			Position = position,
			AnchorPoint = anchorPoint,
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
			fitAxis = FitChildren.FitAxis.Both,
		}, shimmerPanels)
	end
end

return LoadingSkeleton