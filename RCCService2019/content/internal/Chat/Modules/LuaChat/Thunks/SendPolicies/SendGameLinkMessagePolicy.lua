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


local SendGameLinkMessagePolicy = setmetatable({}, SendChatMessagePolicy)
SendGameLinkMessagePolicy.__index = SendGameLinkMessagePolicy

function SendGameLinkMessagePolicy:new(conversationId, universeId, decorators)
	local instance = SendChatMessagePolicy:new(conversationId)
	setmetatable(instance, self)

	instance.universeId = universeId
	instance.decorators = decorators

	return instance
end

function SendGameLinkMessagePolicy:sendMessage(store)
	return ChatSendGameLinkMessage(networkImpl, self.conversationId, self.universeId, self.decorators)
end

function SendGameLinkMessagePolicy:sendingMessagePayload()
	return { 
		messageType = Message.MessageTypes.Link,
		link = {
			type = Message.LinkTypes.Game,
			game = {
				universeId = self.universeId
			}
		}
	}
end

return SendGameLinkMessagePolicy
