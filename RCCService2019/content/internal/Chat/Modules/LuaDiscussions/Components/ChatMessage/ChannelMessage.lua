local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local FitFrameVertical = require(Components.FitFrameVertical)
local UsernameLabel = require(Components.ChatMessage.UsernameLabel)
local AvatarThumbnail = require(Components.ChatMessage.AvatarThumbnail)
local createMessageChunkChildren = require(Components.ChatMessage.createMessageChunkChildren)

local SOME_DARK_GREY_COLOR_USED_AS_BACKGROUND = Color3.fromRGB(35, 37, 39)
local SOME_LIGHT_GREY_COLOR_FOR_AVATAR_CIRCLE = Color3.fromRGB(209, 209, 209)

local AVATAR_WIDTH = 36
local AVATAR_PADDING = 4
local USERNAME_TEXT_HEIGHT = 12
local USERNAME_LEFT_PADDING = AVATAR_WIDTH + 4 + AVATAR_PADDING
local USERNAME_PADDING_HEIGHT = 6
local MARGIN_BETWEEN_CHUNKS = 8
local FULL_AVATAR_WIDTH = AVATAR_WIDTH + AVATAR_PADDING

local ChannelMessage = Roact.PureComponent:extend("ChannelMessage")
ChannelMessage.defaultProps = {
	innerPadding = 0,
	maxWidth = 0,
	usernameContent = "Username",
	isIncoming = true,
	channelMessage = {},
}

function ChannelMessage.getChunkHorizontalAlignmentFrom(props)
	local isIncoming = props.isIncoming

	local chunkHorizontalAlignment = Enum.HorizontalAlignment.Left
	if not isIncoming then
		chunkHorizontalAlignment = Enum.HorizontalAlignment.Right
	end

	return chunkHorizontalAlignment
end

function ChannelMessage.getAvatarWidthFrom(props)
	local isIncoming = props.isIncoming
	local avatarWidth = 0
	if isIncoming then
		avatarWidth = FULL_AVATAR_WIDTH
	end
	return avatarWidth
end

function ChannelMessage:render()
	return UIBlox.Style.withStyle(function(style)
		local innerPadding = self.props.innerPadding
		local maxWidth = self.props.maxWidth
		local channelMessage = self.props.channelMessage
		local layoutOrder = self.props.LayoutOrder
		local usernameContent = self.props.usernameContent
		local isIncoming = self.props.isIncoming

		local avatarWidth = ChannelMessage.getAvatarWidthFrom(self.props)
		local chunkHorizontalAlignment = ChannelMessage.getChunkHorizontalAlignmentFrom(self.props)
		local chunkChildrenMaxWidth = math.max(0, maxWidth - avatarWidth - innerPadding)

		local messageChunkChildren = createMessageChunkChildren({
			isIncoming = isIncoming,
			messageChunks = channelMessage.chunks,
			maxWidth = chunkChildrenMaxWidth,
		})

		return Roact.createElement(FitFrameVertical, {
			BackgroundTransparency = 1,
			width = UDim.new(1, 0),
			LayoutOrder = layoutOrder,
		}, {
			usernameRow = isIncoming and Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, USERNAME_TEXT_HEIGHT + USERNAME_PADDING_HEIGHT * 2),
				LayoutOrder = 1,
			}, {
				HorizontalLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				spacer = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, USERNAME_LEFT_PADDING, 0, 0),
					LayoutOrder = 1,
				}),
				usernameLabel = Roact.createElement(UsernameLabel, {
					usernameContent = usernameContent,
					textHeight = USERNAME_TEXT_HEIGHT,
					paddingHeight = USERNAME_PADDING_HEIGHT,
					LayoutOrder = 2,
				}),
			}),
			avatarAndContentRow = Roact.createElement(FitFrameVertical, {
				BackgroundTransparency = 1,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				padding = UDim.new(0, AVATAR_PADDING),
				width = UDim.new(1, 0),
				LayoutOrder = 2,
			}, {
				avatarThumbnail = isIncoming and Roact.createElement(AvatarThumbnail, {
					Size = UDim2.new(0, 50, 0, 50),
					presetSize = AvatarThumbnail.PresetSize.Size36x36,
					avatarBackgroundColor3 = SOME_LIGHT_GREY_COLOR_FOR_AVATAR_CIRCLE,
					containerBackgroundColor3 = SOME_DARK_GREY_COLOR_USED_AS_BACKGROUND,
				}),
				innerFlexContainer = Roact.createElement(FitFrameVertical, {
					HorizontalAlignment = chunkHorizontalAlignment,
					padding = UDim.new(0, MARGIN_BETWEEN_CHUNKS),
					BackgroundTransparency = 1,
					width = UDim.new(1, -avatarWidth),
					LayoutOrder = 2,
				}, messageChunkChildren)
			})
		})
	end)
end

return ChannelMessage