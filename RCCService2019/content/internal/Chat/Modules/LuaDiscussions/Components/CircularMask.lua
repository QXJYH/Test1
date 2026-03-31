local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local UIBlox = dependencies.UIBlox

local OVERLAY_IMAGE_SIZE48x48 = "rbxasset://textures/ui/LuaChat/graphic/gr-profile-border-48x48.png"
local OVERLAY_IMAGE_SIZE36x36 = "rbxasset://textures/ui/LuaChat/graphic/gr-profile-border-36x36.png"

local CircularMask = Roact.PureComponent:extend("CircularMask")

CircularMask.PresetSize = {
	Size36x36 = "Size36x36",
	Size48x48 = "Size48x48",
}

CircularMask.defaultProps = {
	presetSize = CircularMask.PresetSize.Size48x48,
    containerBackgroundColor3 = nil,
    LayoutOrder = 0,
}

function CircularMask:render()
	return UIBlox.Style.withStyle(function(style)
		local presetSize = self.props.presetSize
	    local onActivated = self.props.onActivated
	    local children = self.props[Roact.Children]

		local diameter
		local overlayImage
	    if presetSize == CircularMask.PresetSize.Size36x36 then
			diameter = 36
			overlayImage = OVERLAY_IMAGE_SIZE36x36
	    elseif presetSize == CircularMask.PresetSize.Size48x48 then
			diameter = 48
			overlayImage = OVERLAY_IMAGE_SIZE48x48
		end

		return Roact.createElement("ImageButton", {
			LayoutOrder = self.props.LayoutOrder,
			BorderSizePixel = 0,
			BackgroundColor3 = self.props.ImageBackgroundColor3,
			Size = UDim2.new(0, diameter, 0, diameter),

			[Roact.Event.Activated] = onActivated,
		}, {
			maskFrame = Roact.createElement("ImageLabel", {
				ImageColor3 = self.props.containerBackgroundColor3,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Image = overlayImage,
	        }, children),
		})
	end)
end

return CircularMask
