local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat
local LuaApp = Modules.LuaApp

local RequestTimeDiag = require(LuaChat.Utils.RequestTimeDiag)
local Constants = require(LuaChat.Constants)
local Promise = require(LuaApp.Promise)

return function(sendPolicy)
	local diag = RequestTimeDiag:new(Constants.PerformanceMeasurement.LUA_CHAT_SEND_MESSAGE)

	return function(store)
		sendPolicy:onBeforeSendingMessage(store)

		return sendPolicy:sendMessage(store)
			:andThen(function(response)
				diag:report()

				if response and response.responseBody and response.responseBody.resultType ~= "Success" then
					return Promise.reject(response)
				end
				return response
			end)
			:andThen(function(response)
				return sendPolicy:onSuccess(store, response)
			end)
			:catch(function(response)
				return sendPolicy:onFailure(store, response)
			end)
	end
end