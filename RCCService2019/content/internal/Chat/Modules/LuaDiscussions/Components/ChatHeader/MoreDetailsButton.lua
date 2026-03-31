local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local PLACEHOLDER_ICON = "rbxasset://textures/ui/LuaChat/graphic/gr-numbers.png"
local PADDING = 24

local PaddedImageButton = require(Components.PaddedImageButton)

local MoreDetailsButton = Roact.PureComponent:extend("MoreDetailsButton")
MoreDetailsButton.defaultProps = {
	fullExtents = 72,
	onActivated = nil,
}

function MoreDetailsButton:render()
	return UIBlox.Style.withStyle(function(style)
		local fullExtents = self.props.fullExtents
		local onActivated = self.props.onActivated
		local layoutOrder = self.props.LayoutOrder

		return Roact.createElement(PaddedImageButton, {
			Size = UDim2.new(UDim.new(0, fullExtents), UDim.new(0, fullExtents)),
			paddingHeight = PADDING,
			paddingWidth = PADDING,
			Image = PLACEHOLDER_ICON,
			LayoutOrder = layoutOrder,

			[Roact.Event.Activated] = onActivated,
		})
	end)
end

return MoreDetailsButton
