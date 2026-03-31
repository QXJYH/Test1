local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelMessage = require(Components.ChatMessage.ChannelMessage)

local MAX_WIDTH = 325
local MARGIN = 50

local function createMessage(messageBody)
	return Roact.createElement(ChannelMessage, {
		maxWidth = MAX_WIDTH - MARGIN,
		isIncoming = messageBody.isIncoming,
		messageChunks = messageBody.messageChunks,
		LayoutOrder = messageBody.LayoutOrder,
	})
end

return Roact.createElement("ScrollingFrame", {
	ScrollBarThickness = 4,
	VerticalScrollBarInset = Enum.ScrollBarInset.Always,
	BackgroundColor3 = Color3.fromRGB(35, 37, 39),
	Size = UDim2.new(0, MAX_WIDTH, 1, 0),
}, {
	layout = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 16),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	message1 = createMessage({
		LayoutOrder = 1,
		isIncoming = true,
		messageChunks = {
			{
				id = 1,
				message = "Hello there.",
			},
			{
				id = 2,
				message = "What game are you playing?",
			},
		}
	}),

	message2 = createMessage({
		LayoutOrder = 2,
		isIncoming = false,
		messageChunks = {
			{
				id = 3,
				message = "Sorry, I was at dinner. 😄",
			},
		}
	}),

	message3 = createMessage({
		LayoutOrder = 3,
		isIncoming = true,
		messageChunks = {
			{
				id = 4,
				message = "No worries. :)",
			},
		}
	}),

	message4 = createMessage({
		LayoutOrder = 4,
		isIncoming = false,
		messageChunks = {
			{
				id = 5,
				message = "I was playing Hot Dog Factory Tycoon.",
			},
			{
				id = 6,
				message = "hbu?",
			},
		}
	}),

	message5 = createMessage({
		LayoutOrder = 5,
		isIncoming = true,
		messageChunks = {
			{
				id = 7,
				message = "Sec, joining...",
			},
		}
	}),
})
