local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat
local LuaApp = Modules.LuaApp
local Promise = require(LuaApp.Promise)
local ConversationActions = require(LuaChat.Actions.ConversationActions)
local GetFriendCount = require(LuaChat.Actions.GetFriendCount)
local SetAppLoaded = require(LuaChat.Actions.SetAppLoaded)

local Constants = require(LuaChat.Constants)
local FetchChatSettings = require(LuaChat.Actions.FetchChatSettings)
local FFlagLuaChatFetchChatSettings = settings():GetFFlag("LuaChatFetchChatSettings")

if FFlagLuaChatFetchChatSettings then
	return function(onEnabled, loadOnlyIfRecentlyUsed)
		return function(store)
			return store:dispatch(FetchChatSettings()):andThen(
				function(result)
					local shouldLoad = true
					if loadOnlyIfRecentlyUsed then
						shouldLoad = result.isActiveChatUser
					end

					if result.chatEnabled and shouldLoad then
						store:dispatch(ConversationActions.GetUnreadConversationCountAsync())
						store:dispatch(GetFriendCount())
						store:dispatch(
							ConversationActions.GetLocalUserConversationsAsync(1, Constants.PageSize.GET_CONVERSATIONS)
						):andThen(function()
							store:dispatch(SetAppLoaded(true))
						end)
					end

					if onEnabled then
						onEnabled(result.chatEnabled)
					end

					return Promise.resolve(result)
				end,
				function(err)
					return Promise.reject(err)
				end
			)
		end
	end
else
	return function(onEnabled, loadOnlyIfRecentlyUsed)
		return function(store)
			store:dispatch(FetchChatSettings(function(settings)
				local shouldLoad = true
				if loadOnlyIfRecentlyUsed then
					shouldLoad = settings.isActiveChatUser
				end

				if settings.chatEnabled and shouldLoad then
					store:dispatch(ConversationActions.GetUnreadConversationCountAsync())
					store:dispatch(GetFriendCount())
					store:dispatch(
						ConversationActions.GetLocalUserConversationsAsync(1, Constants.PageSize.GET_CONVERSATIONS)
					):andThen(function()
						store:dispatch(SetAppLoaded(true))
					end)
				end

				if onEnabled then
					onEnabled(settings.chatEnabled)
				end
			end))
		end
	end
end
