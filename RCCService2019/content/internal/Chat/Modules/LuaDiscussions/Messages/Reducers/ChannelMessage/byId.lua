local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Cryo = dependencies.Cryo
local Rodux = dependencies.Rodux

local Messages = script:FindFirstAncestor("Messages")
local ChannelMessage = require(Messages.Models.ChannelMessage)
local GetChannelMessages = require(Messages.NetworkRequests.GetChannelMessages)
local PostChannelMessage = require(Messages.NetworkRequests.PostChannelMessage)

local function listToDictionary(list, callback)
	local dictionary = {}

	for index, oldEntry in ipairs(list) do
		local key, newEntry = callback(oldEntry, index)
		dictionary[key] = newEntry
	end

	return dictionary
end

local function addMessagesToState(state, data)
	local newMessageModels = listToDictionary(data, function(message, index)
		return message.id, ChannelMessage.fromProps({
			created = message.created,
			id = message.id,
			chunks = message.messageChunks,
		})
	end)

	return Cryo.Dictionary.join(state, newMessageModels)
end

local DEFAULT_STATE = {}
return Rodux.createReducer(DEFAULT_STATE, {
	[GetChannelMessages.Succeeded.name] = function(state, action)
		local responseBody = action.responseBody

		local data = responseBody.data
		if data then
			return addMessagesToState(state, data)
		end

		return state
	end,
	[PostChannelMessage.Succeeded.name] = function(state, action)
		local responseBody = action.responseBody

		return addMessagesToState(state, { responseBody })
	end,
})
