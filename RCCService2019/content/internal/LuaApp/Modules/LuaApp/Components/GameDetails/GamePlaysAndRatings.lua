local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local FitChildren = require(Modules.LuaApp.FitChildren)
local abbreviateCount = require(Modules.LuaApp.abbreviateCount)

local PrimaryStatWidget = require(Modules.LuaApp.Components.PrimaryStatWidget)
local GameRatings = require(Modules.LuaApp.Components.GameDetails.GameRatings)

local PLAY_ICON_IMAGE = "LuaApp/icons/GameDetails/playing_large"
local VISITS_ICON_IMAGE = "LuaApp/icons/GameDetails/sessions_large"

local GamePlaysAndRatings = Roact.PureComponent:extend("GamePlaysAndRatings")

function GamePlaysAndRatings:getLayoutInfo(playCountText, playLabelText,
	visitsCountText, visitsLabelText)
	local theme = self._context.AppTheme
	local containerWidth = self.props.containerWidth
	local playWidgetMinWidth = PrimaryStatWidget.GetMinimumWidth(
		playCountText, playLabelText, theme.GameDetails.Text.BoldFont)
	local visitsWidgetMinWidth = PrimaryStatWidget.GetMinimumWidth(
		visitsCountText, visitsLabelText, theme.GameDetails.Text.BoldFont)

	-- The play widget and visits widget needs to be the same width
	local widgetWidth = math.max(playWidgetMinWidth, visitsWidgetMinWidth)

	-- If the sum of the play widget and visits widget will exceed half of the container,
	-- put play and visits to one row, each taking half the width,
	-- and the vote section to another row.
	if widgetWidth * 2 > containerWidth / 2 then
		return {
			isOneRow = false,
			subSectionWidth = containerWidth,
			widgetWidth = containerWidth / 2,
		}
	else
		-- Otherwise, put play, visits and vote all in one row
		-- where play/visits each take 1/4 of the row, and votes takes 1/2
		return {
			isOneRow = true,
			subSectionWidth = containerWidth / 2,
			widgetWidth = containerWidth / 4,
		}
	end
end

function GamePlaysAndRatings:render()
	local theme = self._context.AppTheme
	local containerWidth = self.props.containerWidth
	local rowPadding = self.props.rowPadding
	local playing = self.props.playing
	local visits = self.props.visits
	local universeId = self.props.universeId
	local layoutOrder = self.props.LayoutOrder
	local localization = self.props.localization

	local playCountText = abbreviateCount(playing, localization:GetLocale())
	local playLabelText = string.upper(localization:Format("Feature.GameDetails.Label.Playing"))
	local visitsCountText = abbreviateCount(visits, localization:GetLocale())
	local visitsLabelText = string.upper(localization:Format("Feature.GameDetails.Label.Visits"))

	local layoutInfo = self:getLayoutInfo(playCountText, playLabelText, visitsCountText, visitsLabelText)
	local isOneRow = layoutInfo.isOneRow
	local subSectionWidth = layoutInfo.subSectionWidth
	local widgetWidth = layoutInfo.widgetWidth

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(0, containerWidth, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		fitAxis = FitChildren.FitAxis.Height,
	}, {
		ListLayout = Roact.createElement("UIListLayout", {
			FillDirection = isOneRow and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, isOneRow and 0 or rowPadding),
		}),
		Ratings = Roact.createElement(GameRatings, {
			LayoutOrder = isOneRow and 1 or 2,
			universeId = universeId,
			width = subSectionWidth,
		}),
		PlaysAndVisitsSection = Roact.createElement(FitChildren.FitFrame, {
			Size = UDim2.new(0, subSectionWidth, 0, 0),
			BackgroundTransparency = 1,
			LayoutOrder = isOneRow and 2 or 1,
			fitAxis = FitChildren.FitAxis.Height,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			PlaySection = Roact.createElement(PrimaryStatWidget, {
				icon = PLAY_ICON_IMAGE,
				number = playCountText,
				label = playLabelText,
				font = theme.GameDetails.Text.BoldFont,
				color = theme.GameDetails.Text.Color.Main,
				width = widgetWidth,
				LayoutOrder = 1,
			}),
			VisitsSection = Roact.createElement(PrimaryStatWidget, {
				icon = VISITS_ICON_IMAGE,
				number = visitsCountText,
				label = visitsLabelText,
				font = theme.GameDetails.Text.BoldFont,
				color = theme.GameDetails.Text.Color.Main,
				width = widgetWidth,
				LayoutOrder = 2,
			}),
		}),
	})
end

GamePlaysAndRatings = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gameDetail = state.GameDetails[props.universeId]
		return {
			playing = gameDetail.playing,
			visits = gameDetail.visits,
		}
	end
)(GamePlaysAndRatings)

GamePlaysAndRatings = RoactServices.connect({
	localization = RoactLocalization,
})(GamePlaysAndRatings)

return GamePlaysAndRatings