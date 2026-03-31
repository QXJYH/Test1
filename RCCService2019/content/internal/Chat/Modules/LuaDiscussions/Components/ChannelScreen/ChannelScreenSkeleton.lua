local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local RoactBlock = dependencies.RoactBlock
local UIBlox = dependencies.UIBlox

local Components = LuaDiscussions.Components

local ChannelChatHeader = require(Components.ChatHeader.ChannelChatHeader)
local ChannelScrollingArea = require(Components.ChannelScreen.ChannelScrollingArea)
local ChatInputBar = require(Components.ChatInput.ChatInputBar)

local ChannelScreenSkeleton = Roact.PureComponent:extend("ChannelScreenSkeleton")
ChannelScreenSkeleton.defaultProps = {
	channelMessages = {},
	postChannelMessage = nil,
	fullScreenWidth = 0,
}

function ChannelScreenSkeleton:render()
	return UIBlox.Style.withStyle(function(style)
		local channelMessages = self.props.channelMessages
		local fullScreenWidth = self.props.fullScreenWidth

		local chatInputHeight = 72
		local headerHeight = 64

		return Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(30, 31, 28),
			Size = UDim2.new(1, 0, 1, 0),
		}, RoactBlock.verticalLayout({
			RoactBlock.insert(
				UDim2.new(1, 0, 0, headerHeight),
				Roact.createElement(ChannelChatHeader)
			),

			RoactBlock.insert(
				UDim2.new(1, 0, 1, -(headerHeight + chatInputHeight)),
				Roact.createElement(ChannelScrollingArea, {
					channelMessages = channelMessages,
					contentMaxWidth = fullScreenWidth,
				})
			),

			RoactBlock.insert(
				UDim2.new(1, 0, 0, chatInputHeight),
				Roact.createElement(ChatInputBar, {
					onSend = self.props.postChannelMessage,
				})
			),
		}))
	end)
end

return ChannelScreenSkeleton