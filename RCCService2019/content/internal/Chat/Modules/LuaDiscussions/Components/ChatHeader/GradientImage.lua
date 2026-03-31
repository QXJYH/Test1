local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local UIBlox = dependencies.UIBlox

local PLACEHOLDER_GRADIENT_IMAGE = "rbxasset://textures/ui/LuaChat/graphic/friendmask.png"

local GradientImage = Roact.PureComponent:extend("GradientImage")
GradientImage.defaultProps = {
	backgroundImage = nil,
}

function GradientImage:render()
	return UIBlox.Style.withStyle(function(style)
		local backgroundImage = self.props.backgroundImage
		local children = self.props[Roact.Children]

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			backgroundImage = Roact.createElement("ImageLabel", {
				ScaleType = Enum.ScaleType.Crop,
				BackgroundTransparency = 1,
				Image = backgroundImage,
				Size = UDim2.new(1, 0, 1, 0),
			}, {
				gradientImage = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					Image = PLACEHOLDER_GRADIENT_IMAGE,
					Size = UDim2.new(1, 0, 1, 0),
				}, children)
			})
		})
	end)
end

return GradientImage
