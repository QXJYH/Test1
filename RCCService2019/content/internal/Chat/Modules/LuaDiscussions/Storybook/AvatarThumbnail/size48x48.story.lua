local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local AvatarThumbnail = require(script.Parent.Parent.Parent.Components.ChatMessage.AvatarThumbnail)

return Roact.createElement(AvatarThumbnail, {
	presetSize = AvatarThumbnail.PresetSize.Size48x48,
})
