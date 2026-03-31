local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat


local SendChatTextMessagePolicy = require(LuaChat.Thunks.SendPolicies.SendChatTextMessagePolicy)
local SendMessageUsingPolicy = require(LuaChat.Thunks.SendMessageUsingPolicy)


return function(conversationId, messageText, decorators)
	local sendText = SendChatTextMessagePolicy:new(conversationId, messageText, decorators)

	return SendMessageUsingPolicy(sendText)
end
