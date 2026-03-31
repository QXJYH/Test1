local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")

local sortChannelMessagesAscending = require(LuaDiscussions.Messages.Selectors.sortChannelMessagesAscending)
local populateFromIds = require(LuaDiscussions.Selectors.populateFromIds)

local function getChannelMessagesFromChannelId(state, channelId)
	local listOfMessageIdsInChannel = state.DiscussionsAppReducer.channelMessages.byChannelId[channelId] or {}
	local dictionaryOfMessagesById = state.DiscussionsAppReducer.channelMessages.byId

	return sortChannelMessagesAscending(populateFromIds(listOfMessageIdsInChannel, dictionaryOfMessagesById))
end

return getChannelMessagesFromChannelId