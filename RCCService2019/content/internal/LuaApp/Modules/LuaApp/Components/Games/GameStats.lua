local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local Text = require(Modules.Common.Text)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.LuaApp.withLocalization)

local abbreviateCount = require(Modules.LuaApp.abbreviateCount)

local THUMB_UP_IMAGE = "LuaApp/icons/GameDetails/rating_small"
local PLAYER_COUNT_IMAGE = "LuaApp/icons/GameDetails/playing_small"

local GameStats = Roact.PureComponent:extend("GameStats")


function GameStats:renderSponsored(stylePalette)
	local theme = stylePalette.Theme
	local font = stylePalette.Font
	local fontClass = font.CaptionHeader.Font
	local fontSize = font.CaptionHeader.RelativeSize * font.BaseSize

	local renderFunction = function(localized)
		local text = localized.sponsoredText
		local textBounds = Text.GetTextBounds(text, fontClass, fontSize, Vector2.new(10000, 10000))
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, textBounds.Y),
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = theme.UIDefault.Color,
			BackgroundTransparency = theme.UIDefault.Transparency,
			BorderSizePixel = 0,
		}, {
			SponsorText = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				TextSize = fontSize,
				TextColor3 = theme.TextEmphasis.Color,
				TextTransparency = theme.TextEmphasis.Transparency,
				Font = font.CaptionHeader.Font,
				Text = text,
			})
		})
	end

	return withLocalization({
		sponsoredText = "Feature.GamePage.Label.Sponsored"
	})(renderFunction)
end

function GameStats:renderGameStats(stylePalette, props)
	local stats = props.stats
	local playerCount = stats.playerCount
	local totalUpVotes = stats.totalUpVotes
	local totalDownVotes = stats.totalDownVotes

	local localization = props.localization

	local playerCountText = abbreviateCount(playerCount, localization:GetLocale())

	local votePercentageText = "--"

	if totalUpVotes == nil or totalUpVotes < 0 then
		totalUpVotes = 0
	end

	if totalDownVotes == nil or totalDownVotes < 0 then
		totalDownVotes = 0
	end

	local totalVotes = totalUpVotes + totalDownVotes

	if totalVotes > 0 then
		votePercentageText = math.floor(totalUpVotes / totalVotes * 100) .. '%'
	end

	local theme = stylePalette.Theme
	local font = stylePalette.Font
	local fontClass = font.CaptionSubHeader.Font
	local textSize = font.BaseSize * font.CaptionSubHeader.RelativeSize
	local textBounds = Text.GetTextBounds('%', fontClass, textSize, Vector2.new(10000, 10000))
	local textboxHeight = textBounds.Y

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		VoteInfo = Roact.createElement("Frame", {
			Size = UDim2.new(0.5, 0, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		},{
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0.05, 0)
			}),
			Icon = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0.25, 0, 0, textboxHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Image = THUMB_UP_IMAGE,
				ImageColor3 = theme.TextMuted.Color,
				ImageTransparency = theme.TextMuted.Transparency,
				ScaleType = Enum.ScaleType.Fit,
			}),
			Vote = Roact.createElement("TextLabel", {
				Size = UDim2.new(0.6, 0, 0, textboxHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Text = votePercentageText,
				Font = fontClass,
				TextColor3 = theme.TextMuted.Color,
				TextTransparency = theme.TextMuted.Transparency,
				TextSize = textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
			}),
		}),
		PlayerCountInfo = Roact.createElement("Frame", {
			Size = UDim2.new(0.5, 0, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		},{
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0.05, 0)
			}),
			Icon = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0.25, 0, 0, textboxHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Image = PLAYER_COUNT_IMAGE,
				ImageColor3 = theme.TextMuted.Color,
				ImageTransparency = theme.TextMuted.Transparency,
				ScaleType = Enum.ScaleType.Fit,
			}),
			PlayerCount = Roact.createElement("TextLabel", {
				Size = UDim2.new(0.6, 0, 0, textboxHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Text = playerCountText,
				Font = fontClass,
				TextColor3 = theme.TextMuted.Color,
				TextTransparency = theme.TextMuted.Transparency,
				TextSize = textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
			}),
		}),
	})
end

function GameStats:render()
	local stats = self.props.stats
	if stats == nil then
		return nil
	end

	local renderFunction = function(stylePalette)
		local isSponsored = stats.isSponsored
		if isSponsored then
			return self:renderSponsored(stylePalette)
		else
			return self:renderGameStats(stylePalette, self.props)
		end
	end

	return withStyle(renderFunction)
end

GameStats = RoactServices.connect({
	localization = RoactLocalization,
})(GameStats)

return GameStats