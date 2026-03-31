local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat


local ShareGameMessagePolicy = require(LuaChat.Thunks.ShareGameToChatFromChat.ShareGameMessagePolicy)
local SendMessageUsingPolicy = require(LuaChat.Thunks.SendMessageUsingPolicy)

return function (conversationId, universeId)
	local sendPolicy = ShareGameMessagePolicy:new(conversationId, universeId)

	return SendMessageUsingPolicy(sendPolicy)
end
