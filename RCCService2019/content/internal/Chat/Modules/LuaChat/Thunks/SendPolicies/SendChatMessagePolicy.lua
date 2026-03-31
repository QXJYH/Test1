local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp
local LuaChat = Modules.LuaChat

local Immutable = require(CorePackages.AppTempCommon.Common.Immutable)

local SendMessagePolicy = require(LuaChat.Thunks.SendPolicies.SendMessagePolicy)
local Message = require(LuaChat.Models.Message)
local DateTime = require(LuaChat.DateTime)

local ReceivedChatResponse = require(LuaChat.Thunks.ReceivedChatResponse)
local SendingMessage = require(LuaChat.Actions.SendingMessage)
local SentMessage = require(LuaChat.Actions.SentMessage)
local MessageFailedToSend = require(LuaChat.Actions.MessageFailedToSend)
local MessageModerated = require(LuaChat.Actions.MessageModerated)

local lastAscendingNumber = 0

-- SMELL!!! using global variable to maintain order of elements in reducer
local function getAscendingNumber()
	lastAscendingNumber = lastAscendingNumber + 1
	return lastAscendingNumber
end

local SendChatMessagePolicy = setmetatable({}, SendMessagePolicy)
SendChatMessagePolicy.__index = SendChatMessagePolicy

function SendChatMessagePolicy:new(conversationId)
	return setmetatable({
		messageSendingId = Message.newSendingId(),
		conversationId = conversationId,
	}, self)
end

local function GetSpoofedLatestMessageTime(conversation)
	-- Get the most recent message date of our messages so we can create a fake date after those
	local lastMessageInConvo = conversation.messages:Last()
	local lastSendingMessageInConvo = conversation.sendingMessages:Last()

	local lastSendingDate;
	if lastMessageInConvo then
		lastSendingDate = lastMessageInConvo.sent:GetUnixTimestamp()
	end
	if lastSendingMessageInConvo then
		local tempDate = lastSendingMessageInConvo.sent:GetUnixTimestamp()
		lastSendingDate = lastSendingDate and math.max(lastSendingDate, tempDate) or tempDate
	end

	-- Add 0.001 seconds to the message date so that we show up slightly after the current one
	local fakeSendingDate = lastSendingDate and DateTime.fromUnixTimestamp(lastSendingDate + 0.001) or DateTime.now()
	return fakeSendingDate
end

function SendChatMessagePolicy:onBeforeSendingMessage(store)
	-- SMELL!!! action creator access store to create action payload
	local conversation = store:getState().ChatAppReducer.Conversations[self.conversationId]

	local message = Message.newSending(
		Immutable.JoinDictionaries({
				id = self.messageSendingId,
				order = getAscendingNumber(), -- reducer can compute it
				conversationId = self.conversationId, -- reducer can compute it
				sent = GetSpoofedLatestMessageTime(conversation), -- reducer can compute it
			},
			self:sendingMessagePayload()
		)
	)
	assert(message, "Failed to create sending message placeholder")

	store:dispatch(SendingMessage(self.conversationId, message))
end

function SendChatMessagePolicy:sendingMessagePayload()
	error("Override me")
end

function SendChatMessagePolicy:onSuccess(store, response)
	store:dispatch(SentMessage(self.conversationId, self.messageSendingId))
	
	store:dispatch(ReceivedChatResponse(self.conversationId, response.responseBody))

	return response
end

function SendChatMessagePolicy:onFailure(store, response)
	if response and response.responseBody and response.responseBody.resultType == "Moderated" then
		store:dispatch(MessageModerated(self.conversationId, self.messageSendingId))
		warn("Message was moderated.")
	else
		store:dispatch(MessageFailedToSend(self.conversationId, self.messageSendingId))
		warn("Message could not be sent.")
	end

	return response
end

return SendChatMessagePolicy
