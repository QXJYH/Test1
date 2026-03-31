local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp
local LuaChat = Modules.LuaChat


local ShareGameToChatActions = LuaChat.Actions.ShareGameToChatFromChat
local ReceivedChatResponse = require(LuaChat.Thunks.ReceivedChatResponse)
local networkImpl = require(LuaApp.Http.request)

local PopRoute = require(LuaChat.Actions.PopRoute)
local ResetShareGame = require(ShareGameToChatActions.ResetShareGameToChatFromChat)
local ResetShareGameToChatAsync = require(ShareGameToChatActions.ResetShareGameToChatFromChatAsync)
local SharedGameToChat = require(ShareGameToChatActions.SharedGameToChatFromChat)
local SharingGameToChat = require(ShareGameToChatActions.SharingGameToChatFromChat)
local ClearAllGamesInSorts = require(ShareGameToChatActions.ClearAllGamesInSortsShareGameToChatFromChat)
local FailedToShareGameToChat = require(ShareGameToChatActions.FailedToShareGameToChatFromChat)

local Requests = CorePackages.AppTempCommon.LuaApp.Http.Requests
local ChatSendGameLinkMessage = require(Requests.ChatSendGameLinkMessage)

local Constants = require(LuaChat.Constants)
local ToastModel = require(LuaChat.Models.ToastModel)
local ShowToast = require(LuaChat.Actions.ShowToast)

local SendMessagePolicy = require(LuaChat.Thunks.SendPolicies.SendMessagePolicy)

local ShareGameMessagePolicy = setmetatable({}, SendMessagePolicy)
ShareGameMessagePolicy.__index = ShareGameMessagePolicy

function ShareGameMessagePolicy:new(conversationId, universeId, decorators)
	return setmetatable({
		conversationId = conversationId,
		universeId = universeId,
		decorators = decorators,
		networkImpl = networkImpl
	}, self)
end

function ShareGameMessagePolicy:sendMessage(store)
	if store:getState().ChatAppReducer.ShareGameToChatAsync.sharingGame or
		store:getState().ChatAppReducer.ShareGameToChatAsync.sharedGame then
		return
	end

	store:dispatch(SharingGameToChat())

	return ChatSendGameLinkMessage(self.networkImpl, self.conversationId, self.universeId)
end

function ShareGameMessagePolicy:onSuccess(store, response)
	store:dispatch(ReceivedChatResponse(self.conversationId, response.responseBody))

	store:dispatch(PopRoute())
	store:dispatch(SharedGameToChat())

	store:dispatch(ResetShareGame())
	store:dispatch(ClearAllGamesInSorts())
	store:dispatch(ResetShareGameToChatAsync())

	return response
end

function ShareGameMessagePolicy:onFailure(store, response)
	local messageKey = "Feature.Chat.ShareGameToChat.FailedToShareTheGame"
	local toastModel = ToastModel.new(Constants.ToastIDs.GAME_NOT_SHAREABLE, messageKey)

	store:dispatch(ShowToast(toastModel))
	store:dispatch(FailedToShareGameToChat())
end

return ShareGameMessagePolicy
