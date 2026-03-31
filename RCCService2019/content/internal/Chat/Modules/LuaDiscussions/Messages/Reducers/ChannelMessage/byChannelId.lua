local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Cryo = dependencies.Cryo
local Rodux = dependencies.Rodux

local Messages = script:FindFirstAncestor("Messages")
local GetChannelMessages = require(Messages.NetworkRequests.GetChannelMessages)
local PostChannelMessage = require(Messages.NetworkRequests.PostChannelMessage)

local function addMessagesByChannelId(state, data, channelId)
	local newMessageIds = Cryo.List.map(data, function(message)
		return message.id
	end)

	local allMessagesInChannel = Cryo.List.join(state[channelId] or {}, newMessageIds)
	return Cryo.Dictionary.join(state, {
		[channelId] = allMessagesInChannel,
	})
end

local DEFAULT_STATE = {}
return Rodux.createReducer(DEFAULT_STATE, {
	[GetChannelMessages.Succeeded.name] = function(state, action)
		local channelId = action.firstId
		local responseBody = action.responseBody

		local data = responseBody.data
		if data then
			return addMessagesByChannelId(state, data, channelId)
		end

		return state
	end,
	[PostChannelMessage.Succeeded.name] = function(state, action)
		local channelId = action.firstId
		local responseBody = action.responseBody

		return addMessagesByChannelId(state, { responseBody }, channelId)
	end,
})