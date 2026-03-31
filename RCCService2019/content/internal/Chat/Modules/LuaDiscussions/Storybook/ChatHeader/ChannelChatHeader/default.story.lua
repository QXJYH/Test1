local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelChatHeader = require(Components.ChatHeader.ChannelChatHeader)

return Roact.createElement("Frame", {
	BackgroundColor3 = Color3.fromRGB(45, 45, 50),
	Size = UDim2.new(0, 300, 0, 100),
}, {
	channelHeader = Roact.createElement(ChannelChatHeader),
})
