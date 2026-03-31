local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Modules = CoreGui.RobloxGui.Modules

local ApiFetchUsersFriendCount = require(Modules.LuaApp.Thunks.ApiFetchUsersFriendCount)
local ApiFetchUsersPresences = require(CorePackages.AppTempCommon.LuaApp.Thunks.ApiFetchUsersPresences)
local ApiFetchUsersThumbnail = require(CorePackages.AppTempCommon.LuaApp.Thunks.ApiFetchUsersThumbnail)
local AddUser = require(Modules.LuaApp.Actions.AddUser)
local UserModel = require(Modules.LuaApp.Models.User)
local Promise = require(Modules.LuaApp.Promise)
local UpdateUsers = require(Modules.LuaApp.Thunks.UpdateUsers)

local ConversationModel = require(Modules.LuaChat.Models.Conversation)
local ReceivedConversation = require(Modules.LuaChat.Actions.ReceivedConversation)

local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local LuaAppRemoveGetFriendshipCountApiCalls = settings():GetFFlag("LuaAppRemoveGetFriendshipCountApiCalls")
local FFlagLuaAppUseNewAvatarThumbnailsApi = FlagSettings.LuaAppUseNewAvatarThumbnailsApi()

local AVATAR_THUMBNAIL_REQUEST = Constants.AvatarThumbnailRequests.USER_CAROUSEL_HEAD_SHOT

local function AddNewFriend(store, networking, addedFriendUserId)
	-- Unfortunately this event does not pass in the username of the new friend.
	local username = Players:GetNameFromUserIdAsync(tonumber(addedFriendUserId))

	local newUser = UserModel.fromData(addedFriendUserId, username, true)
	if LuaAppRemoveGetFriendshipCountApiCalls then
		store:dispatch(UpdateUsers({ newUser }))
	else
		store:dispatch(AddUser(newUser))
	end

	local friendIds = { addedFriendUserId }

	local promises = {
		store:dispatch(ApiFetchUsersPresences(networking, friendIds)),
	}
	if FFlagLuaAppUseNewAvatarThumbnailsApi then
		table.insert(promises, store:dispatch(ApiFetchUsersThumbnail.Fetch(networking, friendIds, AVATAR_THUMBNAIL_REQUEST)))
	else
		table.insert(promises, store:dispatch(ApiFetchUsersThumbnail(networking, friendIds, AVATAR_THUMBNAIL_REQUEST)))
	end

	Promise.all(promises):andThen(function()
		-- LuaChat needs to create a mock 1:1 conversation for new friends
		local state = store:getState()

		local needsMockConversation = true
		for _, conversation in pairs(state.ChatAppReducer.Conversations) do
			if conversation.conversationType == ConversationModel.Type.ONE_TO_ONE_CONVERSATION then
				for _, participantId in ipairs(conversation.participants) do
					if participantId == addedFriendUserId then
						needsMockConversation = false
						break
					end
				end
			end
		end

		if needsMockConversation then
			local conversation = ConversationModel.fromUser(newUser)
			store:dispatch(ReceivedConversation(conversation))
		end
	end)
end

return function(networking, addedFriendUserId)
	return function(store)
		if LuaAppRemoveGetFriendshipCountApiCalls then
			AddNewFriend(store, networking, addedFriendUserId)
		else
			return store:dispatch(ApiFetchUsersFriendCount(networking)):andThen(function()
				AddNewFriend(store, networking, addedFriendUserId)
			end)
		end
	end
end