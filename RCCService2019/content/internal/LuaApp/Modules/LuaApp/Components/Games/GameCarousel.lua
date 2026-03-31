local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local getGameCardSize = require(Modules.LuaApp.getGameCardSize)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)

local GameCard = require(Modules.LuaApp.Components.Games.GameCard)
local AppGameTile = require(Modules.LuaApp.Components.Games.AppGameTile)
local CarouselWidget = require(Modules.LuaApp.Components.Generic.CarouselWidget)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local SectionHeaderWithSeeAll = require(Modules.LuaApp.Components.SectionHeaderWithSeeAll)

local ApiFetchGamesInSort = require(Modules.LuaApp.Thunks.ApiFetchGamesInSort)
local FetchDataWithErrorToasts = require(Modules.LuaApp.Thunks.FetchDataWithErrorToasts)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local CAROUSEL_MARGIN = Constants.GAME_CAROUSEL_PADDING
local CARD_MARGIN = Constants.GAME_CAROUSEL_CHILD_PADDING
local CAROUSEL_AND_HEADER_HEIGHT = 183
local HEADER_HEIGHT = 26
local CARD_INFO_HEIGHT = 70

-- We would like to start loading more before user reaches the end.
-- The default distance from the bottom of that would be 1000.
local DEFAULT_PRELOAD_DISTANCE = 1000

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()

local GameCarousel = Roact.PureComponent:extend("GameCarousel")

GameCarousel.defaultProps = {
	friendFooterEnabled = false,
}

function GameCarousel:init()
	self.state = {
		cardWindowStart = 1,
		cardsInWindow = 0,
		gameCardSize = Vector2.new(0, 0),
	}

	self.isLoadingMoreGames = false

	self.scrollingFrameRefCallback = function(rbx)
		self.scrollingFrameRef = rbx

		spawn(self.updateCardWindowBounds)
	end

	self.onCanvasPositionChanged = function()
		-- Since this function is spawned, it's possible that the component
		-- has been destroyed.
		if not self.scrollingFrameRef then
			return
		end

		local gameSortContents = self.props.gameSortContents
		local loadMoreGames = self.loadMoreGames
		local canLoadMore = gameSortContents.hasMoreRows

		if canLoadMore and not self.isLoadingMoreGames then
			local canvasPosition = self.scrollingFrameRef.CanvasPosition.X
			local windowWidth = self.scrollingFrameRef.AbsoluteWindowSize.X
			local canvasWidth = self.scrollingFrameRef.CanvasSize.X.Offset
			local loadMoreThreshold = canvasWidth - windowWidth - DEFAULT_PRELOAD_DISTANCE

			if canvasPosition > loadMoreThreshold then
				self.isLoadingMoreGames = true

				loadMoreGames():andThen(
					function()
						self.isLoadingMoreGames = false
					end,
					function()
						self.isLoadingMoreGames = false
					end
				)
			end
		end
	end

	self.updateCardWindowBounds = function()
		if not self.scrollingFrameRef then
			return
		end

		local gameCardSize = self.props.gameCardSize
		local fractionalCardsPerRow = self.props.fractionalCardsPerRow

		local windowOffset = self.scrollingFrameRef.CanvasPosition.X
		local cardWindowStart = math.max(1, math.floor(windowOffset / (gameCardSize.X + CARD_MARGIN)))
		local cardsInWindow = math.ceil(fractionalCardsPerRow) + 2

		local shouldUpdate = cardWindowStart ~= self.state.cardWindowStart
			or cardsInWindow ~= self.state.cardsInWindow
			or gameCardSize ~= self.state.gameCardSize

		if shouldUpdate then
			self:setState({
				cardWindowStart = cardWindowStart,
				cardsInWindow = cardsInWindow,
				gameCardSize = gameCardSize,
			})
		end
	end

	self.onSeeAll = function()
		local navigateToSort = self.props.navigateToSort
		local sort = self.props.sort
		local analytics = self.props.analytics
		local layoutOrder = self.props.LayoutOrder

		-- show the sort
		navigateToSort(self.props.sortName)

		-- report to the server that we've tapped on the SeeAll button
		analytics.reportSeeAll(sort.name, layoutOrder)
	end

	self.reportGameDetailOpened = function(index)
		local sort = self.props.sort
		local gameSortContents = self.props.gameSortContents
		local analytics = self.props.analytics

		local entries = gameSortContents.entries

		local sortName = sort.name
		local gameSetTargetId = sort.gameSetTargetId
		local itemsInSort = #entries
		local indexInSort = index
		local entry = entries[index]
		local placeId = entry.placeId
		local isAd = entry.isSponsored

		analytics.reportOpenGameDetail(
			placeId,
			sortName,
			gameSetTargetId,
			indexInSort,
			itemsInSort,
			isAd)
	end

	self.reportQuickGameLaunch = {
		entry = function()
			return self.props.analytics.reportQuickGameLaunchEntry()
		end,
		success = function()
			return self.props.analytics.reportQuickGameLaunchSuccess()
		end,
		failure = function(reason)
			return self.props.analytics.reportQuickGameLaunchFailed(reason)
		end,
	}

	self.loadMoreGames = function(count)
		local loadCount = count or Constants.DEFAULT_GAME_FETCH_COUNT
		local networking = self.props.networking
		local sort = self.props.sort
		local gameSortContents = self.props.gameSortContents
		local dispatchLoadMoreGames = self.props.dispatchLoadMoreGames

		return dispatchLoadMoreGames(networking, sort, gameSortContents.rowsRequested, loadCount,
			gameSortContents.nextPageExclusiveStartId)
	end

	self.reloadSort = function()
		local networking = self.props.networking
		local sort = self.props.sort
		local dispatchReloadSort = self.props.dispatchReloadSort
		return dispatchReloadSort(networking, sort)
	end
end

function GameCarousel:renderScrollableGameCards()
	local gameSortContents = self.props.gameSortContents

	local entries = gameSortContents.entries

	local gameCardSize = self.props.gameCardSize
	local cardWindowStart = self.state.cardWindowStart
	local cardsInWindow = self.state.cardsInWindow

	local friendFooterEnabled = self.props.friendFooterEnabled

	local cardWindowEnd = math.min(#entries, cardWindowStart + cardsInWindow - 1)
	local canvasWidth = math.max(0, #entries * (CARD_MARGIN + gameCardSize.X))
	local leftPadding = (cardWindowStart - 1) * (gameCardSize.X + CARD_MARGIN)

	local gameCards = {}

	gameCards.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, CARD_MARGIN),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	})

	gameCards.Padding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, leftPadding),
	})

	for index = cardWindowStart, cardWindowEnd do
		local entry = entries[index]
		local key = index % cardsInWindow

		gameCards[key] = Roact.createElement(GameCard, {
			entry = entry,
			layoutOrder = index,
			size = gameCardSize,
			reportGameDetailOpened = self.reportGameDetailOpened,
			reportQuickGameLaunch = self.reportQuickGameLaunch,
			index = index,
			friendFooterEnabled = friendFooterEnabled,
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
		[Roact.Change.CanvasPosition] = function()
			self.onCanvasPositionChanged()

			self.updateCardWindowBounds()
		end,
		[Roact.Ref] = self.scrollingFrameRefCallback,
	}, gameCards)
end


function GameCarousel:newRender()
	local sort = self.props.sort
	local layoutOrder = self.props.LayoutOrder
	local gameSortContents = self.props.gameSortContents
	local entries = gameSortContents.entries
	local gameCardSize = self.props.gameCardSize
	local gameSortFetchingStatus = self.props.gameSortFetchingStatus
	local friendFooterEnabled = self.props.friendFooterEnabled

	local cardsInWindow = self.state.cardsInWindow
	local cardWindowStart = self.state.cardWindowStart
	local cardWindowEnd = math.min(#entries, cardWindowStart + cardsInWindow - 1)
	local canvasWidth = math.max(0, #entries * (CARD_MARGIN + gameCardSize.X))
	local leftPadding = (cardWindowStart - 1) * (gameCardSize.X + CARD_MARGIN)

	gameCardSize = Vector2.new(gameCardSize.X, gameCardSize.X + CARD_INFO_HEIGHT)

	local gameTiles = {}

	gameTiles.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, CARD_MARGIN),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	})

	gameTiles.Padding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, leftPadding),
	})

	for index = cardWindowStart, cardWindowEnd do
		local entry = entries[index]
		local key = index % cardsInWindow
		gameTiles[key] = Roact.createElement(AppGameTile, {
			entry = entry,
			layoutOrder = index,
			size = gameCardSize,
			reportGameDetailOpened = self.reportGameDetailOpened,
			reportQuickGameLaunch = self.reportQuickGameLaunch,
			index = index,
			friendFooterEnabled = friendFooterEnabled,
		})
	end

	local carouselWidget = Roact.createElement(CarouselWidget, {
		title = sort.displayName,
		items = gameTiles,
		onSeeAll = self.onSeeAll,
		carouselHeight = gameCardSize.Y,
		canvasWidth = canvasWidth,
		onChangeCanvasPosition = function()
			self.onCanvasPositionChanged()
			self.updateCardWindowBounds()
		end,
		onRefCallback = self.scrollingFrameRefCallback,
	})

	return Roact.createElement("Frame", {
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT + gameCardSize.Y),
	}, {
		LoadingStateWrapper = Roact.createElement(LoadingStateWrapper, {
			dataStatus = gameSortFetchingStatus,
			onRetry = self.reloadSort,
			debugName = "GameCarousel-" .. self.props.sortName,
			renderOnLoading = function()
				return nil
			end,
			renderOnLoaded = function()
				return carouselWidget
			end,
		})
	})
end


function GameCarousel:oldRender()
	local sort = self.props.sort
	local layoutOrder = self.props.LayoutOrder
	local gameCardSize = self.props.gameCardSize
	local gameSortFetchingStatus = self.props.gameSortFetchingStatus

	return Roact.createElement(FitChildren.FitFrame, {
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, CAROUSEL_AND_HEADER_HEIGHT),
		fitFields = {
			Size = FitChildren.FitAxis.Height,
		},
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		Title = Roact.createElement(SectionHeaderWithSeeAll, {
			LayoutOrder = 1,
			text = sort.displayName,
			value = sort,
			onSelected = self.onSeeAll,
		}),
		Content = Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, gameCardSize.Y),
			BackgroundTransparency = 1,
		}, {
			LoadingStateWrapper = Roact.createElement(LoadingStateWrapper, {
				dataStatus = gameSortFetchingStatus,
				onRetry = self.reloadSort,
				debugName = "GameCarousel-" .. self.props.sortName,
				renderOnLoading = function()
					return nil
				end,
				renderOnLoaded = function()
					return self:renderScrollableGameCards()
				end,
			})
		}),
	})
end

--NOTE: when cleaning up LuaAppEnableStyleProvider replace render with newRender
if useNewAppStyle then
	GameCarousel.render = GameCarousel.newRender
else
	GameCarousel.render = GameCarousel.oldRender
end

function GameCarousel:didUpdate(prevProps)
	if self.props.gameCardSize ~= prevProps.gameCardSize or
		self.props.fractionalCardsPerRow ~= prevProps.fractionalCardsPerRow then
		self.updateCardWindowBounds()
	end
end

GameCarousel = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local screenSize = state.ScreenSize
		local containerWidth = screenSize.X - CAROUSEL_MARGIN
		local gameCardSize, fractionalCardsPerRow = getGameCardSize(
			containerWidth, CAROUSEL_MARGIN, CARD_MARGIN, 0.25)

		return {
			sort = state.GameSorts[props.sortName],
			gameSortContents = state.GameSortsContents[props.sortName],
			gameCardSize = gameCardSize,
			fractionalCardsPerRow = fractionalCardsPerRow,
			gameSortFetchingStatus = state.RequestsStatus.GameSortsStatus[props.sortName] or
				RetrievalStatus.NotStarted,
		}
	end,
	function(dispatch)
		return {
			navigateToSort = function(sortName)
				dispatch(NavigateDown({ name = AppPage.GamesList, detail = sortName }))
			end,
			dispatchLoadMoreGames = function(networking, sort, startRows, maxRows, nextPageExclusiveStartId)
				return dispatch(FetchDataWithErrorToasts(ApiFetchGamesInSort(networking, sort, true, {
					startRows = startRows,
					maxRows = maxRows,
					exclusiveStartId = nextPageExclusiveStartId
				})))
			end,
			dispatchReloadSort = function(networking, sort)
				return dispatch(ApiFetchGamesInSort(networking, sort, false, nil))
			end,
		}
	end
)(GameCarousel)

return RoactServices.connect({
	networking = RoactNetworking,
})(GameCarousel)