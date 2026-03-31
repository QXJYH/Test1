local LuaChat = script.Parent.Parent
local LuaApp = game:GetService("CoreGui").RobloxGui.Modules.LuaApp
local WebApi = require(LuaChat.WebApi)
local FetchChatSettingsStarted = require(LuaChat.Actions.FetchChatSettingsStarted)
local FetchChatSettingsCompleted = require(LuaChat.Actions.FetchChatSettingsCompleted)
local FetchChatSettingsFailed = require(LuaChat.Actions.FetchChatSettingsFailed)
local PerformFetch = require(LuaApp.Thunks.Networking.Util.PerformFetch)
local Promise = require(LuaApp.Promise)

local FFlagLuaChatFetchChatSettings = settings():GetFFlag("LuaChatFetchChatSettings")
local fetchChatSettingsKey = "fetch.chat.settings.key"

if FFlagLuaChatFetchChatSettings then
	return function()
		return PerformFetch.Single(fetchChatSettingsKey, function(store)
			store:dispatch(FetchChatSettingsStarted())
			return Promise.new(function(resolve, reject)
				spawn(function()
					local status, response = WebApi.GetChatSettings()
					if status == WebApi.Status.OK then
						store:dispatch(FetchChatSettingsCompleted(response))
						resolve(response)
					else
						store:dispatch(FetchChatSettingsFailed(status))
						warn("Failure in WebApi.GetChatSettings", status)
						reject(response)
					end
				end)
			end)
		end)
	end
else
	return function(onSuccess)
		return function(store)
			store:dispatch(FetchChatSettingsStarted())

			spawn(function()
				local status, response = WebApi.GetChatSettings()
				if status ~= WebApi.Status.OK then
					store:dispatch(FetchChatSettingsFailed(status))
					warn("Failure in WebApi.GetChatSettings", status)
					return
				end
				store:dispatch(FetchChatSettingsCompleted(response))
				if onSuccess then
					onSuccess(response)
				end
			end)
		end
	end
end