local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local AvatarThumbnailTypes = require(CorePackages.AppTempCommon.LuaApp.Enum.AvatarThumbnailTypes)
local Constants = require(Modules.LuaApp.Constants)

local User = require(Modules.LuaApp.Models.User)
local Text = require(Modules.Common.Text)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local UserTile = Roact.PureComponent:extend("UserTile")

local DEFAULT_THUMBNAIL_ICON = "LuaApp/graphic/ph-avatar-portrait"
local IMAGE_MASK = "LuaApp/graphic/profilemask"

local THUMBNAIL_TYPE = AvatarThumbnailTypes.HeadShot
local AVATAR_THUMBNAIL_SIZE = Constants.AvatarThumbnailSizes.Size150x150
local THUMBNAIL_PADDING = 8

local PRESENCE_ICON = "LuaApp/graphic/friendpresence"
local PRESENCE_ICON_SiZE = 12
local PRESENCE_ICON_PADDING = 4

function UserTile:render()
	local user = self.props.user
	local thumbnailSize = self.props.thumbnailSize
	local width = self.props.width
	local height = self.props.height
	local layoutOrder = self.props.layoutOrder
	local ref = self.props.ref
	local onActivated = self.props.onActivated
	local userName = user.name
	local isOnline = user.presence ~= User.PresenceType.OFFLINE
	local userThumbnail = user and user.thumbnails and user.thumbnails[THUMBNAIL_TYPE] 
		and user.thumbnails[THUMBNAIL_TYPE][AVATAR_THUMBNAIL_SIZE] or DEFAULT_THUMBNAIL_ICON

	local renderFunction = function(stylePalette)
		local theme = stylePalette.Theme
		local font = stylePalette.Font

		local maskColor = theme.BackgroundDefault.Color
		local placeHolerColor = theme.PlaceHolder.Color
		local placeHolderTransparency = theme.PlaceHolder.Transparency
		local usernameFont = font.CaptionHeader.Font
		local usernameTextSize = font.CaptionHeader.RelativeSize * font.BaseSize
		local usernameTextColor = theme.TextEmphasis.Color
		local usernameTextTransparency = theme.TextEmphasis.Transparency
		local presenceIconColor = theme.OnlineStatus.Color
		local presenceIconTransparency = theme.OnlineStatus.Transparency

		local textBounds = Text.GetTextBounds(userName.."...", usernameFont, usernameTextSize, Vector2.new(10000, 10000))
		local textboxWidth = math.min(width - PRESENCE_ICON_SiZE - PRESENCE_ICON_PADDING, textBounds.X)
		return Roact.createElement("TextButton", {
			Size = UDim2.new(0, width, 0, height),
			BackgroundTransparency = 1,
			Text = "",
			LayoutOrder = layoutOrder,
			[Roact.Ref] = ref,
			[Roact.Event.Activated] = onActivated,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, THUMBNAIL_PADDING),
			}),
			Thumbnail = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
				BorderSizePixel = 0,
				Image = userThumbnail,
				BackgroundColor3 = placeHolerColor,
				BackgroundTransparency = placeHolderTransparency,
				LayoutOrder = 1,
			}, {
				MaskFrame = Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = IMAGE_MASK,
					ImageColor3 = maskColor,
				}),
			}),
			UsernameFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, usernameTextSize),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, PRESENCE_ICON_PADDING),
				}),
				PresenceIcon = isOnline and Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, PRESENCE_ICON_SiZE, 0, PRESENCE_ICON_SiZE),
					Image = PRESENCE_ICON,
					ImageColor3 = presenceIconColor,
					ImageTransparency = presenceIconTransparency,
					LayoutOrder = 1,
					BackgroundTransparency = 1,
				}) or nil,
				Username = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, textboxWidth, 0, textBounds.Y),
					BackgroundTransparency = 1,
					Text = user.name,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextSize = usernameTextSize,
					TextColor3 = usernameTextColor,
					TextTransparency = usernameTextTransparency,
					Font = usernameFont,
					LayoutOrder = 2,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			}),
		})
	end

	return withStyle(renderFunction)
end

return UserTile