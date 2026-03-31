local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components

local ChannelChatHeader = require(Components.ChatHeader.ChannelChatHeader)
local ChannelScrollingArea = require(Components.ChatMessage.ChannelScrollingArea)
local ChatInputBar = require(Components.ChatInput.ChatInputBar)

local SCREEN_SIZE = Vector2.new(800, 480)

local HEADER_HEIGHT = 64
local CHAT_INPUT_HEIGHT = 72

local MOCK_MESSAGES = {
	{
		senderName = "GollyGreg",
		isIncoming = true,
		messageChunks = {
			{
				id = 1,
				message = "QClash?",
			}
		}
	},
	{
		senderName = "portyspyce",
		isIncoming = true,
		messageChunks = {
			{
				id = 2,
				message = "Get back to work.",
			}
		}
	},
	{
		senderName = "you",
		isIncoming = false,
		messageChunks = {
			{
				id = 3,
				message = "owned",
			}
		}
	}
}

return Roact.createElement("Frame", {
	BackgroundColor3 = Color3.fromRGB(30, 31, 28),
	Size = UDim2.new(0, SCREEN_SIZE.X, 0, SCREEN_SIZE.Y),
}, {
	layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),

	headerBlock = Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		LayoutOrder = 1,
	}, {
		headerContent = Roact.createElement(ChannelChatHeader),
	}),

	contentBlock = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + CHAT_INPUT_HEIGHT)),
		LayoutOrder = 2,
	}, {
		channelScrollingArea = Roact.createElement(ChannelScrollingArea, {
			contentMaxWidth = SCREEN_SIZE.X,
			messages = MOCK_MESSAGES,
		})
	}),

	chatInputBlock = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 72),
		LayoutOrder = 3,
	}, {
		chatInputBar = Roact.createElement(ChatInputBar),
	}),
})
