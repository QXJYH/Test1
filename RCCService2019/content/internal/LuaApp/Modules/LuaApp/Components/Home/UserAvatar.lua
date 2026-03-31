local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local Colors = require(Modules.LuaApp.Themes.Colors)
local Constants = require(Modules.LuaApp.Constants)
local AvatarThumbnailTypes = require(CorePackages.AppTempCommon.LuaApp.Enum.AvatarThumbnailTypes)

local FetchLocalUserAvatar = require(Modules.LuaApp.Thunks.FetchLocalUserAvatar)

local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local LoadingIndicator = require(Modules.LuaApp.Components.LoadingIndicator)
local UserAvatarRetryButton = require(Modules.LuaApp.Components.Home.UserAvatarRetryButton)

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

local LOADING_INDICATOR_SIZE = UDim2.new(0, 150, 0, 32)

local UserAvatar = Roact.PureComponent:extend("UserAvatar")


local function IsValidUserId(userId)
	return typeof(userId) == "string" and userId ~= ""
end

function UserAvatar:init()
	self.fetchUserThumbnail = function()
		local networking = self.props.networking
		return self.props.fetchUserThumbnail(networking)
	end
end

function UserAvatar:didMount()
	local localUserId = self.props.localUserId

	if IsValidUserId(localUserId) then
		self.fetchUserThumbnail()
	end
end

function UserAvatar:didUpdate(previousProps, previousState)
	local localUserId = self.props.localUserId
	local previousLocalUserId = previousProps.localUserId

	if IsValidUserId(localUserId) and previousLocalUserId ~= localUserId then
		self.fetchUserThumbnail()
	end
end

function UserAvatar:renderOnLoaded()
	local userThumbnail = self.props.userThumbnail
	local sizeConstraint = self.props.sizeConstraint

	return Roact.createElement("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		SizeConstraint = sizeConstraint,
		Image = userThumbnail,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	})
end

function UserAvatar:renderOnLoading()
	return Roact.createElement(LoadingIndicator, {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		DotHighlightColor = Colors.White,
		Size = LOADING_INDICATOR_SIZE,
	})
end

function UserAvatar:renderOnFailed()
	local maxTextWidth = self.props.maxTextWidth

	return Roact.createElement(UserAvatarRetryButton, {
		position = UDim2.new(0.5, 0, 0.5, 0),
		anchorPoint = Vector2.new(0.5, 0.5),
		maxTextWidth = maxTextWidth,
		onRetry = self.fetchUserThumbnail,
	})
end

function UserAvatar:render()
	local localUserId = self.props.localUserId
	local size = self.props.size
	local position = self.props.position
	local anchorPoint = self.props.anchorPoint
	local sizeConstraint = self.props.sizeConstraint
	local userThumbnailFetchingStatus = self.props.userThumbnailFetchingStatus

	return Roact.createElement("Frame", {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		SizeConstraint = sizeConstraint,
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}, {
		Roact.createElement(LoadingStateWrapper, {
			dataStatus = userThumbnailFetchingStatus,
			debugName = "UserAvatar-" .. (localUserId or "NoId"),
			renderOnLoading = function()
				return self:renderOnLoading()
			end,
			renderOnLoaded = function()
				return self:renderOnLoaded()
			end,
			renderOnFailed = function()
				return self:renderOnFailed()
			end,
		}),
	})
end

UserAvatar = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local localUserId = state.LocalUserId
		local localUserModel = state.Users[localUserId]

		local userThumbnail = localUserModel
			and localUserModel.thumbnails
			and localUserModel.thumbnails[THUMBNAIL_TYPE]
			and localUserModel.thumbnails[THUMBNAIL_TYPE][THUMBNAIL_SIZE]

		local userThumbnailFetchingStatus = FetchLocalUserAvatar.GetFetchingStatus(state)

		return {
			localUserId = localUserId,
			localUserModel = localUserModel,
			userThumbnail = userThumbnail,
			userThumbnailFetchingStatus = userThumbnailFetchingStatus,
		}
	end,
	function(dispatch)
		return {
			fetchUserThumbnail = function(networking)
				return dispatch(FetchLocalUserAvatar.Fetch(networking))
			end,
		}
	end
)(UserAvatar)

UserAvatar = RoactServices.connect({
	networking = RoactNetworking,
})(UserAvatar)

return UserAvatar