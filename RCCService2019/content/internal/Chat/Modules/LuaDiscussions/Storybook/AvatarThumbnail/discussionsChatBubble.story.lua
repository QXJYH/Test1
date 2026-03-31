local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local AvatarThumbnail = require(script.Parent.Parent.Parent.Components.ChatMessage.AvatarThumbnail)

return Roact.createElement(AvatarThumbnail, {
	presetSize = AvatarThumbnail.PresetSize.MEDIUM,
	avatarBackgroundColor3 = Color3.fromRGB(209, 209, 209),
	containerBackgroundColor3 = Color3.fromRGB(35, 37, 39),
})
