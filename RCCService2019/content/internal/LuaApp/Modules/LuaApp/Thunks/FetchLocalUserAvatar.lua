local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local Constants = require(Modules.LuaApp.Constants)
local AvatarThumbnailTypes = require(CorePackages.AppTempCommon.LuaApp.Enum.AvatarThumbnailTypes)
local ThumbnailRequest = require(Modules.LuaApp.Models.ThumbnailRequest)
local RetrievalStatus = require(CorePackages.AppTempCommon.LuaApp.Enum.RetrievalStatus)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local ApiFetchUsersThumbnail = require(CorePackages.AppTempCommon.LuaApp.Thunks.ApiFetchUsersThumbnail)

local FFlagLuaAppUseNewAvatarThumbnailsApi = FlagSettings.LuaAppUseNewAvatarThumbnailsApi()
local FFlagLuaAppMakeAvatarThumbnailTypesEnum = settings():GetFFlag("LuaAppMakeAvatarThumbnailTypesEnum")

local THUMBNAIL_TYPE
local THUMBNAIL_SIZE

if FFlagLuaAppMakeAvatarThumbnailTypesEnum then
	THUMBNAIL_TYPE = AvatarThumbnailTypes.AvatarThumbnail
else
	THUMBNAIL_TYPE = Constants.AvatarThumbnailTypes.AvatarThumbnail
end

if FFlagLuaAppUseNewAvatarThumbnailsApi then
	THUMBNAIL_SIZE = Constants.AvatarThumbnailSizes.Size720x720
else
	THUMBNAIL_SIZE = Constants.AvatarThumbnailSizes.Size150x150
end

local THUMBNAIL_REQUEST_MODEL = ThumbnailRequest.fromData(
	THUMBNAIL_TYPE,
	THUMBNAIL_SIZE
)

local FetchLocalUserAvatar = {}

function FetchLocalUserAvatar.Fetch(networkImpl)
	return function(store)
		local localUserId = store:getState().LocalUserId

		ArgCheck.isNonEmptyString(localUserId, "localUserId in FetchLocalUserAvatar")

		if FFlagLuaAppUseNewAvatarThumbnailsApi then
			return store:dispatch(ApiFetchUsersThumbnail.Fetch(networkImpl, { localUserId }, { THUMBNAIL_REQUEST_MODEL }))
		else
			return store:dispatch(ApiFetchUsersThumbnail(networkImpl, { localUserId }, { THUMBNAIL_REQUEST_MODEL }))
		end
	end
end

function FetchLocalUserAvatar.GetFetchingStatus(state)
	local localUserId = state.LocalUserId
	local localUserModel = state.Users[localUserId]

	local userThumbnail = localUserModel
		and localUserModel.thumbnails
		and localUserModel.thumbnails[THUMBNAIL_TYPE]
		and localUserModel.thumbnails[THUMBNAIL_TYPE][THUMBNAIL_SIZE]

	local userThumbnailFetchingStatus
	if FFlagLuaAppUseNewAvatarThumbnailsApi then
		userThumbnailFetchingStatus = ApiFetchUsersThumbnail.GetFetchingStatus(
			state,
			localUserId,
			THUMBNAIL_TYPE,
			THUMBNAIL_SIZE
		)
	else
		if userThumbnail then
			userThumbnailFetchingStatus = RetrievalStatus.Done
		else
			userThumbnailFetchingStatus = RetrievalStatus.Fetching
		end
	end

	return userThumbnailFetchingStatus
end

return FetchLocalUserAvatar