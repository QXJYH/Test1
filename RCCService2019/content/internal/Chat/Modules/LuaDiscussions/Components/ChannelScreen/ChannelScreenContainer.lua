local HttpRbxApiService = game:GetService("HttpRbxApiService")

local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local UIBlox = dependencies.UIBlox

local Roact = dependencies.Roact
local RoactRodux = dependencies.RoactRodux
local httpRequest = dependencies.httpRequest

local Components = LuaDiscussions.Components
local ChannelScreenSkeleton = require(Components.ChannelScreen.ChannelScreenSkeleton)

local GetChannelMessages = require(LuaDiscussions.Messages.NetworkRequests.GetChannelMessages)
local PostChannelMessage = require(LuaDiscussions.Messages.NetworkRequests.PostChannelMessage)

local getMessagesFromChannelId = require(LuaDiscussions.Messages.Selectors.getMessagesFromChannelId)

local ChannelScreenContainer = Roact.PureComponent:extend("ChannelScreenContainer")
ChannelScreenContainer.defaultProps = {
	networkImpl = httpRequest(HttpRbxApiService),
}

function ChannelScreenContainer:render()
	return UIBlox.Style.withStyle(function(style)
		local channelMessages = self.props.channelMessages
		local fullScreenWidth = self.props.fullScreenWidth
		local postChannelMessage = self.props.postChannelMessage

		return Roact.createElement(ChannelScreenSkeleton, {
			channelMessages = channelMessages,
			fullScreenWidth = fullScreenWidth,
			postChannelMessage = function(messageText)
				postChannelMessage(self.props.networkImpl, self.props.channelId, messageText)
			end,
		})
	end)
end

function ChannelScreenContainer:didMount()
	local fetchChannelMessages = self.props.fetchChannelMessages

	local channelId = self.props.channelId
	local networkImpl = self.props.networkImpl

	fetchChannelMessages(networkImpl, channelId)
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local channelId = props.channelId
		assert(channelId, "ChannelScreenContainer requires channelId prop")

		return {
			channelMessages = getMessagesFromChannelId(state, channelId),
			fullScreenWidth = 0,
		}
	end,
	function(dispatch)
		return {
			fetchChannelMessages = function(networkImpl, channelId)
				return dispatch(GetChannelMessages.API(networkImpl, channelId))
			end,
			postChannelMessage = function(networkImpl, channelId, message)
				return dispatch(PostChannelMessage.API(networkImpl, channelId, message))
			end,
		}
	end
)(ChannelScreenContainer)