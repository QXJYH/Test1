local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local getGameCardSize = require(Modules.LuaApp.getGameCardSize)

local GameCard = require(Modules.LuaApp.Components.Games.GameCard)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local SectionHeader = require(Modules.LuaApp.Components.SectionHeader)
local ShimmerPanel = require(Modules.LuaApp.Components.ShimmerPanel)

local RecommendedGames = require(Modules.LuaApp.Thunks.RecommendedGames)

local GAME_FETCH_COUNT = Constants.DEFAULT_RECOMMENDED_GAMES_FETCH_COUNT
local CAROUSEL_MARGIN = Constants.GAME_CAROUSEL_PADDING
local CARD_MARGIN = Constants.GAME_CAROUSEL_CHILD_PADDING
local TITLE_CONTENT_PADDING = 10

local RecommendedGameCarousel = Roact.PureComponent:extend("RecommendedGameCarousel")

function RecommendedGameCarousel:init()
	self.loadRecommendedGames = function()
		return self.props.dispatchGetRecommendedGames(self.props.networking, self.props.universeId)
	end

	self.reportGameDetailOpened = function(index) end

	self.reportQuickGameLaunch = {
		entry = function() end,
		success = function() end,
		failure = function(reason) end,
	}
end

function RecommendedGameCarousel:renderShimmerCards()
	local gameCardSize = self.props.gameCardSize

	local shimmerCards = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, CARD_MARGIN),
		}),
	}

	for index = 1, GAME_FETCH_COUNT do
		shimmerCards["Card"..tostring(index)] = Roact.createElement(ShimmerPanel, {
			LayoutOrder = index,
			Size = UDim2.new(0, gameCardSize.X, 0, gameCardSize.Y),
		})
	end

	return Roact.createElement("Frame", {
		LayoutOrder = 2,
		Size = UDim2.new(1, CAROUSEL_MARGIN, 0, gameCardSize.Y),
		BackgroundTransparency = 1,
	}, shimmerCards)
end

function RecommendedGameCarousel:renderGameCards()
	local entries = self.props.recommendedGameEntries
	local gameCardSize = self.props.gameCardSize
	local canvasWidth = math.max(0, #entries * (CARD_MARGIN + gameCardSize.X))
	local useSidewaysNavigation = self.props.useSidewaysNavigation

	local gameCards = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, CARD_MARGIN),
		}),
	}

	for index, entry in ipairs(entries) do
		gameCards[index] = Roact.createElement(GameCard, {
			entry = entry,
			layoutOrder = index,
			size = gameCardSize,
			reportGameDetailOpened = self.reportGameDetailOpened,
			reportQuickGameLaunch = self.reportQuickGameLaunch,
			index = index,
			useSidewaysNavigation = useSidewaysNavigation,
		})
	end

	return Roact.createElement("ScrollingFrame", {
		LayoutOrder = 2,
		Size = UDim2.new(1, CAROUSEL_MARGIN, 0, gameCardSize.Y),
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		CanvasSize = UDim2.new(0, canvasWidth, 0, gameCardSize.Y),
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.Always,
	}, gameCards)
end

function RecommendedGameCarousel:render()
	local theme = self._context.AppTheme

	local universeId = self.props.universeId
	local layoutOrder = self.props.LayoutOrder
	local gameCardSize = self.props.gameCardSize
	local recommendedGamesFetchingStatus = self.props.recommendedGamesFetchingStatus

	return Roact.createElement(FitChildren.FitFrame, {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		fitAxis = FitChildren.FitAxis.Height,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, TITLE_CONTENT_PADDING),
		}),
		Title = Roact.createElement(SectionHeader, {
			LayoutOrder = 1,
			TextColor3 = theme.GameDetails.Carousel.Text.Color,
			Font = theme.GameDetails.Text.BoldFont,
			text = "Feature.GameDetails.Heading.Recommended",
			useLocalizedText = true,
		}),
		Content = Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, gameCardSize.Y),
			BackgroundTransparency = 1,
		}, {
			LoadingStateWrapper = Roact.createElement(LoadingStateWrapper, {
				dataStatus = recommendedGamesFetchingStatus,
				onRetry = self.loadRecommendedGames,
				debugName = "RecommendedGameCarousel-" .. universeId,
				renderOnLoading = function()
					return self:renderShimmerCards()
				end,
				renderOnLoaded = function()
					return self:renderGameCards()
				end,
			})
		}),
	})
end

RecommendedGameCarousel = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local screenSize = state.ScreenSize
		local containerWidth = screenSize.X - CAROUSEL_MARGIN
		local gameCardSize = getGameCardSize(containerWidth, CAROUSEL_MARGIN, CARD_MARGIN, 0.25)

		local useSidewaysNavigation = nil
		-- Use sideways navigation for multiple levels of game details
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		local currentPageName = currentRoute[#currentRoute].name
		local previousPage = currentRoute[#currentRoute - 1]

		if previousPage then
			useSidewaysNavigation = previousPage.name == currentPageName
		end

		return {
			gameCardSize = gameCardSize,
			recommendedGameEntries = state.RecommendedGameEntries[props.universeId],
			recommendedGamesFetchingStatus = RecommendedGames.GetFetchingStatus(state, props.universeId),
			useSidewaysNavigation = useSidewaysNavigation,
		}
	end,
	function(dispatch)
		return {
			dispatchGetRecommendedGames = function(networking, universeId)
				return dispatch(RecommendedGames.Fetch(networking, universeId, false, {
					maxRows = GAME_FETCH_COUNT,
				}))
			end,
		}
	end
)(RecommendedGameCarousel)

return RoactServices.connect({
	networking = RoactNetworking,
})(RecommendedGameCarousel)
