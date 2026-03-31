local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp

local Promise = require(LuaApp.Promise)

local SendMessagePolicy = {}
SendMessagePolicy.__index = SendMessagePolicy

function SendMessagePolicy:onBeforeSendingMessage(store)
end

function SendMessagePolicy:sendMessage(store)
	return Promise.reject("Not implemented")
end

function SendMessagePolicy:onSuccess(store, response)
	return response
end

function SendMessagePolicy:onFailure(store, response)
	return response
end

return SendMessagePolicy
