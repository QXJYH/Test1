local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelMessage = require(Components.ChatMessage.ChannelMessage)

local MAX_WIDTH = 500
local MARGIN = 50

return Roact.createElement("ScrollingFrame", {
	ScrollBarThickness = 4,
	VerticalScrollBarInset = Enum.ScrollBarInset.Always,
	BackgroundColor3 = Color3.fromRGB(35, 37, 39),
	Size = UDim2.new(0, MAX_WIDTH, 1, 0),
}, {
	message = Roact.createElement(ChannelMessage, {
		maxWidth = MAX_WIDTH - MARGIN,
		isIncoming = false,
		messageChunks = {
			{
				id = 1,
				message = "Hello there.",
			},
			{
				id = 2,
				message = "Each bubble represents a new messageChunk.",
			},
		}
	})
})
