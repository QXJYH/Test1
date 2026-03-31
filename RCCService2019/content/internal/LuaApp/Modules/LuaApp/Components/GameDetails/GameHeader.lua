local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local GameBasicStats = require(Modules.LuaApp.Components.Games.GameBasicStats)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

-- TODO: needs actual font and font size (since we need to run size conversion)
local TITLE_FONT_SIZE = 32

local GameHeader = Roact.PureComponent:extend("GameHeader")

function GameHeader:render()
	local theme = self._context.AppTheme
	local gameDetail = self.props.gameDetail
	local votes = self.props.votes
	local layoutOrder = self.props.LayoutOrder
	local showSubtitle = self.props.showSubtitle

	local upVotes = votes ~= nil and votes.upVotes or nil
	local downVotes = votes ~= nil and votes.downVotes or nil

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		fitAxis = FitChildren.FitAxis.Height,
	}, {
		ListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Title = Roact.createElement(FitTextLabel, {
			Size = UDim2.new(1, 0, 0, 0),
			Text = gameDetail.name,
			Font = theme.GameDetails.Text.BoldFont,
			TextSize = TITLE_FONT_SIZE,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.GameDetails.Text.Color.Main,
			TextWrapped = true,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}),
		SubTitle = showSubtitle and Roact.createElement(GameBasicStats, {
			playerCount = gameDetail.playing,
			upVotes = upVotes,
			downVotes = downVotes,
			themeInfo = theme.GameDetails.GameBasicStats,
			layoutType = Constants.GameBasicStatsLayoutType.GameDetails,
			LayoutOrder = 2,
		}),
	})
end

GameHeader = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			gameDetail = state.GameDetails[props.universeId],
			votes = state.GameVotes[props.universeId],
		}
	end
)(GameHeader)

if FFlagLuaAppPolicyRoactConnector then
	GameHeader = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			showSubtitle = appPolicy.getGameDetailsSubtitle(),
		}
	end)(GameHeader)
else
	GameHeader = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			showSubtitle = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.GameDetailsSubtitle),
		}
	end)(GameHeader)
end

return GameHeader
