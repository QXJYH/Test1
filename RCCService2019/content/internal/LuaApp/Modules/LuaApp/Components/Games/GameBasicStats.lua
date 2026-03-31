local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)

local abbreviateCount = require(Modules.LuaApp.abbreviateCount)
local Constants = require(Modules.LuaApp.Constants)

local FitImageTextFrame = require(Modules.LuaApp.Components.FitImageTextFrame)

local THUMB_UP_IMAGE = "LuaApp/icons/GameDetails/rating_small"
local PLAYER_COUNT_IMAGE = "LuaApp/icons/GameDetails/playing_small"

local GameBasicStatsLayoutInfo = {
	[Constants.GameBasicStatsLayoutType[Constants.GameCardLayoutType.Small]] = {
		Padding = 6,
		TextSize = 14,
		IconSize = 10,
		IconTextPadding = 3,
	},
	[Constants.GameBasicStatsLayoutType[Constants.GameCardLayoutType.Medium]] = {
		Padding = 12,
		TextSize = 14,
		IconSize = 10,
		IconTextPadding = 3,
	},
	[Constants.GameBasicStatsLayoutType[Constants.GameCardLayoutType.Large]] = {
		Padding = 12,
		TextSize = 16,
		IconSize = 12,
		IconTextPadding = 3,
	},
	[Constants.GameBasicStatsLayoutType.GameDetails] = {
		Padding = 13,
		TextSize = 22,
		IconSize = 17,
		IconTextPadding = 5,
	},
}

local GameBasicStats = Roact.PureComponent:extend("GameBasicStats")

function GameBasicStats:init()
	self.getImageProps = function(image)
		local themeInfo = self.props.themeInfo
		local layoutInfo = GameBasicStatsLayoutInfo[self.props.layoutType]
		return {
			Size = UDim2.new(0, layoutInfo.IconSize, 0, layoutInfo.IconSize),
			Image = image,
			ImageColor3 = themeInfo.Color,
			ImageTransparency = themeInfo.Transparency,
		}
	end

	self.getTextProps = function(text)
		local themeInfo = self.props.themeInfo
		local layoutInfo = GameBasicStatsLayoutInfo[self.props.layoutType]
		return {
			Text = text,
			Font = themeInfo.Font,
			TextColor3 = themeInfo.Color,
			TextTransparency = themeInfo.Transparency,
			TextSize = layoutInfo.TextSize,
		}
	end
end

function GameBasicStats:render()
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder

	local playerCount = self.props.playerCount
	local upVotes = self.props.upVotes
	local downVotes = self.props.downVotes
	local layoutType = self.props.layoutType
	local localization = self.props.localization

	assert(layoutType ~= nil, "GameBasicStats expects a layoutType props")

	local layoutInfo = GameBasicStatsLayoutInfo[layoutType]

	assert(layoutInfo ~= nil, "GameBasicStats expects a supported layoutType props; was given: " .. layoutType)

	local playerCountText = abbreviateCount(playerCount, localization:GetLocale())

	local votePercentageText = "--"

	if upVotes == nil or upVotes < 0 then
		upVotes = 0
	end

	if downVotes == nil or downVotes < 0 then
		downVotes = 0
	end

	local totalVotes = upVotes + downVotes

	if totalVotes > 0 then
		votePercentageText = math.floor(upVotes / totalVotes * 100) .. '%'
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, layoutInfo.TextSize),
		Position = position,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, layoutInfo.Padding),
		}),
		VoteInfo = Roact.createElement(FitImageTextFrame, {
			LayoutOrder = 1,
			padding = layoutInfo.IconTextPadding,
			imageProps = self.getImageProps(THUMB_UP_IMAGE),
			textProps = self.getTextProps(votePercentageText),
		}),
		PlayerCountInfo = Roact.createElement(FitImageTextFrame, {
			LayoutOrder = 2,
			padding = layoutInfo.IconTextPadding,
			imageProps = self.getImageProps(PLAYER_COUNT_IMAGE),
			textProps = self.getTextProps(playerCountText),
		}),
	})
end

GameBasicStats = RoactServices.connect({
	localization = RoactLocalization,
})(GameBasicStats)

return GameBasicStats