local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local PLACEHOLDER_BACK_ICON = "rbxasset://textures/ui/LuaChat/icons/ic-back-android.png"
local PADDING = 24

local PaddedImageButton = require(Components.PaddedImageButton)

local NavigateBackButton = Roact.PureComponent:extend("NavigateBackButton")
NavigateBackButton.defaultProps = {
	fullExtents = 72,
	onActivated = nil,
}

function NavigateBackButton:render()
	return UIBlox.Style.withStyle(function(style)
		local fullExtents = self.props.fullExtents
		local onActivated = self.props.onActivated
		local layoutOrder = self.props.LayoutOrder

		return Roact.createElement(PaddedImageButton, {
			Size = UDim2.new(UDim.new(0, fullExtents), UDim.new(0, fullExtents)),
			paddingHeight = PADDING,
			paddingWidth = PADDING,
			Image = PLACEHOLDER_BACK_ICON,
			LayoutOrder = layoutOrder,

			[Roact.Event.Activated] = onActivated,
		})
	end)
end

return NavigateBackButton
