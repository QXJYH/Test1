local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local ApiFetchUsersThumbnail = require(Modules.LuaApp.Thunks.ApiFetchUsersThumbnail)
local ChatConstants = require(Modules.LuaChat.Constants)
local Constants = require(Modules.LuaApp.Constants)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local IMAGE_PROFILE_NO_BORDER = "rbxasset://textures/ui/LuaApp/graphic/gr-avatar-frame-36x36.png"
local IMAGE_PROFILE_DEFAULT = "LuaApp/icons/ic-profile"

local FFlagLuaAppUseNewAvatarThumbnailsApi = FlagSettings.LuaAppUseNewAvatarThumbnailsApi()

local FriendIcon = Roact.PureComponent:extend("FriendIcon")

FriendIcon.defaultProps = {
	layoutOrder = 0,
	maskColor = Constants.Color.WHITE,
}

function FriendIcon:render()
	local getUserThumbnail = self.props.getUserThumbnail
	local networking = self.props.networking
	local user = self.props.user
	local dotSize = self.props.dotSize
	local itemSize = self.props.itemSize
	local layoutOrder = self.props.layoutOrder

	local maskColor = self.props.maskColor

	local isPresenceIndicatorEnabled = dotSize ~= nil

	local presenceIndicatorSizeKey = ChatConstants:GetPresenceIndicatorSizeKey(dotSize)

	local imageFriend = nil
	local iconDot = nil
	if user then
		if isPresenceIndicatorEnabled then
			iconDot = ChatConstants.PresenceIndicatorImagesBySize[presenceIndicatorSizeKey][user.presence]
		end

		-- Find images for the friend portraits:
		if user.thumbnails and user.thumbnails.HeadShot
			and user.thumbnails.HeadShot.Size48x48 then
			imageFriend = user.thumbnails.HeadShot.Size48x48
		end

		if imageFriend == nil then
			imageFriend = IMAGE_PROFILE_DEFAULT
			if FFlagLuaAppUseNewAvatarThumbnailsApi then
				getUserThumbnail(networking, user.id)
			else
				getUserThumbnail(user.id)
			end
		end
	end

	return Roact.createElement("Frame", {
		BackgroundColor3 = Constants.Color.GRAY_AVATAR_BACKGROUND,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(0, itemSize, 0, itemSize),
	}, {
		Profile = Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = imageFriend,
			Size = UDim2.new(0, itemSize, 0, itemSize),
			ZIndex = 1,
		}),

		Mask = Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = IMAGE_PROFILE_NO_BORDER,
			ImageColor3 = maskColor,
			Size = UDim2.new(0, itemSize, 0, itemSize),
			ZIndex = 2,
		}),

		Dot = isPresenceIndicatorEnabled and Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = iconDot,
			Position = UDim2.new(1, -dotSize, 1, -dotSize),
			Size = UDim2.new(0, dotSize, 0, dotSize),
			ZIndex = 3,
		}),
	})
end

FriendIcon = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		local getUserThumbnail
		if FFlagLuaAppUseNewAvatarThumbnailsApi then
			getUserThumbnail = function(networking, friendId)
				dispatch(ApiFetchUsersThumbnail.Fetch(networking, { friendId },
					Constants.AvatarThumbnailRequests.FRIEND_CAROUSEL
				))
			end
		else
			getUserThumbnail = function(friendId)
				spawn(function()
					dispatch(ApiFetchUsersThumbnail(nil, { friendId },
						Constants.AvatarThumbnailRequests.FRIEND_CAROUSEL
					))
				end)
			end
		end

		return {
			getUserThumbnail = getUserThumbnail,
		}
	end
)(FriendIcon)

FriendIcon = RoactServices.connect({
	networking = RoactNetworking,
})(FriendIcon)

return FriendIcon