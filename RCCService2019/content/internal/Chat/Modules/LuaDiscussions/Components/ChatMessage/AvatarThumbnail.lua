local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local DEFAULT_AVATAR_PLACEHOLDER = "rbxasset://textures/ui/LuaChat/icons/ic-profile.png"

local CircularMask = require(Components.CircularMask)
local AvatarThumbnail = Roact.PureComponent:extend("AvatarThumbnail")

AvatarThumbnail.PresetSize = {
	Size36x36 = "Size36x36",
	Size48x48 = "Size48x48",
}

AvatarThumbnail.defaultProps = {
	presetSize = AvatarThumbnail.PresetSize.Size36x36,
	avatarImage = DEFAULT_AVATAR_PLACEHOLDER,
	avatarBackgroundColor3 = nil,
	containerBackgroundColor3 = nil,
	onActivated = nil,
	LayoutOrder = 1,
}

function AvatarThumbnail:render()
	return UIBlox.Style.withStyle(function(style)
		local avatarBackgroundColor3 = self.props.avatarBackgroundColor3
		local avatarImage = self.props.avatarImage
		local onActivated = self.props.onActivated
		local presetSize = self.props.presetSize
		local circlePresetSize

		if presetSize == AvatarThumbnail.PresetSize.Size36x36 then
			circlePresetSize = CircularMask.PresetSize.Size36x36
		elseif presetSize == AvatarThumbnail.PresetSize.Size48x48 then
			circlePresetSize = CircularMask.PresetSize.Size48x48
		end

		return Roact.createElement(CircularMask, {
			presetSize = circlePresetSize,
			containerBackgroundColor3 = self.props.containerBackgroundColor3,
			LayoutOrder = self.props.LayoutOrder,
			[Roact.Event.Activated] = onActivated,
		}, {
			avatar = Roact.createElement("ImageLabel", {
				ImageColor3 = avatarBackgroundColor3,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Image = avatarImage,
			}),
		})
	end)
end

return AvatarThumbnail
