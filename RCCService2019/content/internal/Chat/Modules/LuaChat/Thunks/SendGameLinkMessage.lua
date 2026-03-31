local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat


local SendGameLinkMessagePolicy = require(LuaChat.Thunks.SendPolicies.SendGameLinkMessagePolicy)
local SendMessageUsingPolicy = require(LuaChat.Thunks.SendMessageUsingPolicy)

return function (conversationId, universeId)
	local sendPolicy = SendGameLinkMessagePolicy:new(conversationId, universeId)

	return SendMessageUsingPolicy(sendPolicy)
end
