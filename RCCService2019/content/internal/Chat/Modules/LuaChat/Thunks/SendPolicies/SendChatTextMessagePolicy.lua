local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp
local LuaChat = Modules.LuaChat

local Message = require(LuaChat.Models.Message)
local Requests = CorePackages.AppTempCommon.LuaApp.Http.Requests
local ChatSendGameLinkMessage = require(Requests.ChatSendGameLinkMessage)
local SendChatMessagePolicy = require(LuaChat.Thunks.SendPolicies.SendChatMessagePolicy)

local networkImpl = require(LuaApp.Http.request)

local Requests = CorePackages.AppTempCommon.LuaApp.Http.Requests
local ChatSendMessage = require(Requests.ChatSendMessage)

local SendChatTextMessagePolicy = setmetatable({}, SendChatMessagePolicy)
SendChatTextMessagePolicy.__index = SendChatTextMessagePolicy

function SendChatTextMessagePolicy:new(conversationId, messageText, decorators)
	local instance = SendChatMessagePolicy:new(conversationId)
	setmetatable(instance, self)

	instance.messageText = messageText
	instance.decorators = decorators

	return instance
end

function SendChatTextMessagePolicy:sendMessage(store)
	return ChatSendMessage(networkImpl, self.conversationId, self.messageText, self.decorators)
end

function SendChatTextMessagePolicy:sendingMessagePayload()
	return {
		messageType = Message.MessageTypes.PlainText,
		content = self.messageText
	}
end


return SendChatTextMessagePolicy
