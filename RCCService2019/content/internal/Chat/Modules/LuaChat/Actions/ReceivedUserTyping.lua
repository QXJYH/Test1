local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat
local SetUserTyping = require(LuaChat.Actions.SetUserTyping)

local TYPING_INDICATOR_LIFETIME = 8

local typingCount = 0

return function(conversationId, userId)
	return function(store)
		spawn(function()
			typingCount = typingCount + 1
			local thisTypingCount = typingCount

			store:dispatch(SetUserTyping(conversationId, userId, true))

			wait(TYPING_INDICATOR_LIFETIME)

			if typingCount == thisTypingCount then
				store:dispatch(SetUserTyping(conversationId, userId, false))
			end
		end)
	end
end