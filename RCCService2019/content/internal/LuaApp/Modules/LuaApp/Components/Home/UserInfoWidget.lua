local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local LuaApp = Modules.LuaApp

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local AvatarThumbnailTypes = require(CorePackages.AppTempCommon.LuaApp.Enum.AvatarThumbnailTypes)
local Constants = require(Modules.LuaApp.Constants)

local Text = require(Modules.Common.Text)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local FFlagLuaAppUseNewPremiumIcon = require(LuaApp.Flags.LuaAppUseNewPremiumIcon)

local UserInfoWidget = Roact.PureComponent:extend("UserWidget")

local DEFAULT_THUMBNAIL_ICON = "LuaApp/graphic/ph-avatar-portrait"
local IMAGE_MASK = "LuaApp/graphic/profilemask"
local IMAGE_MASK_36 = "LuaApp/graphic/profilemask_36"
local THUMBNAIL_TYPE = AvatarThumbnailTypes.HeadShot
local AVATAR_THUMBNAIL_SIZE = Constants.AvatarThumbnailSizes.Size150x150

local WIDE_USER_THUMBNAIL_SIZE = 80
local COMPACT_USER_THUMBNAIL_SIZE = 36

local MEMBERSHIP_ICONS = {
	[Enum.MembershipType.BuildersClub] = "LuaApp/icons/status_BC",
	[Enum.MembershipType.TurboBuildersClub] = "LuaApp/icons/status_TBC",
	[Enum.MembershipType.OutrageousBuildersClub] = "LuaApp/icons/status_OBC",
	[Enum.MembershipType.Premium] =
		FFlagLuaAppUseNewPremiumIcon() and "LuaApp/icons/status_premium" or "LuaApp/icons/status_OBC",
}
local ICON_PADDING = 12
local WIDE_PADDING = 24
local COMPACT_PADDING = 12

function UserInfoWidget:render()
	local localUserModel = self.props.localUserModel
	local onActivated = self.props.onActivated
	local layoutOrder = self.props.layoutOrder
	--NOTE: formFactor will be used to control mobile vs tablet. In the future the grid system should be used.
	local formFactor = self.props.formFactor

	if localUserModel == nil then
		return nil
	end

	local thumbnailSize = WIDE_USER_THUMBNAIL_SIZE
	local padding = WIDE_PADDING
	local imageMask = IMAGE_MASK
	if formFactor == FormFactor.COMPACT then
		thumbnailSize = COMPACT_USER_THUMBNAIL_SIZE
		padding = COMPACT_PADDING
		imageMask = IMAGE_MASK_36
	end

	local username = localUserModel.name
	local membership = localUserModel.membership
	local hasMembership = membership ~= Enum.MembershipType.None

	local renderFunction = function(stylePalette)
		local font = stylePalette.Font
		local theme = stylePalette.Theme
		local fontClass = font.Title
		if formFactor == FormFactor.COMPACT then
			fontClass = font.Header1
		end

		local maskColor = theme.BackgroundDefault.Color
		local textFont = fontClass.Font
		local textSize = font.BaseSize * fontClass.RelativeSize
		local iconSize = textSize
		local textColor = theme.TextEmphasis.Color
		local textTransparency = theme.TextEmphasis.Transparency
		local placeHolerColor = theme.PlaceHolder.Color
		local placeHolderTransparency = theme.PlaceHolder.Transparency

		-- clickable area is equal to the text bounds
		local textBounds = Text.GetTextBounds(username, textFont, textSize, Vector2.new(10000, 10000))

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 0, thumbnailSize),
		},{
			HorizontalLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, padding),
			}),
			UserAvartar = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
				LayoutOrder = 1,
				BackgroundColor3 = placeHolerColor,
				BackgroundTransparency = placeHolderTransparency,
				BorderSizePixel = 0,
				Image = localUserModel.thumbnails and localUserModel.thumbnails[THUMBNAIL_TYPE]
					and localUserModel.thumbnails[THUMBNAIL_TYPE][AVATAR_THUMBNAIL_SIZE] or DEFAULT_THUMBNAIL_ICON,
			}, {
				MaskFrame = Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = imageMask,
					ImageColor3 = maskColor,
				}),
			}),
			UsernameFrame = Roact.createElement("Frame", {
				Size = UDim2.new(0, textBounds.X + iconSize + ICON_PADDING, 0, textBounds.Y),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				HorizontalLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, ICON_PADDING),
				}),
				MembershipIcon = hasMembership and Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, iconSize, 0, iconSize),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = MEMBERSHIP_ICONS[membership],
					ImageColor3 = textColor,
					ImageTransparency = textTransparency,
					LayoutOrder = 1,
				}),
				Username = Roact.createElement("TextButton", {
					Size = UDim2.new(0, textBounds.X, 0, textBounds.Y),
					BackgroundTransparency = 1,
					TextSize = textSize,
					TextColor3 = textColor,
					TextTransparency = textTransparency,
					Font = textFont,
					Text = username,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 2,
					[Roact.Event.Activated] = onActivated,
				}),
			}),
		})
	end
	return withStyle(renderFunction)
end


return UserInfoWidget