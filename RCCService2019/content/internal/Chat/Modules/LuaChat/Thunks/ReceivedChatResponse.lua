local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local Common = Modules.Common
local LuaApp = Modules.LuaApp
local LuaChat = Modules.LuaChat
local ReceivedMessages = require(LuaChat.Actions.ReceivedMessages)

local Message = require(LuaChat.Models.Message)

-- SMELL!!! action creator access store to create action payload
return function(conversationId, response)
	return function(store)
		local resultMessage = Message.fromSentWeb(response, conversationId)

		local conversation = store:getState().ChatAppReducer.Conversations[conversationId]
		if conversation.messages:Length() > 0 then
			resultMessage.previousMessageId = conversation.messages:Last().id
		end
		store:dispatch(ReceivedMessages(conversationId, { resultMessage }))
	end
end