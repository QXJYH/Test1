local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact

local PaddedImageButton = Roact.PureComponent:extend("PaddedImageButton")
PaddedImageButton.defaultProps = {
	Image = nil,
	Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 0)),
	paddingHeight = 0,
	paddingWidth = 0,
	onActivated = nil,
}

function PaddedImageButton:render()
	local image = self.props.Image
	local size = self.props.Size
	local paddingWidth = self.props.paddingWidth
	local paddingHeight = self.props.paddingHeight
	local layoutOrder = self.props.LayoutOrder
	local children = self.props[Roact.Children]

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = size,
		LayoutOrder = layoutOrder,
	},{
		padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, paddingHeight),
			PaddingBottom = UDim.new(0, paddingHeight),
			PaddingLeft = UDim.new(0, paddingWidth),
			PaddingRight = UDim.new(0, paddingWidth),
		}),
		imageButton = Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			Size = UDim2.new(UDim.new(1, 0), UDim.new(1, 0)),
			Image = image,
			[Roact.Event.Activated] = self.props.onActivated,
		}, children),
	})
end

return PaddedImageButton
