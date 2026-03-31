local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactAnalyticsGamesPage = require(Modules.LuaApp.Services.RoactAnalyticsGamesPage)
local RoactAnalyticsHomePage = require(Modules.LuaApp.Services.RoactAnalyticsHomePage)

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local NavigateSideways = require(Modules.LuaApp.Thunks.NavigateSideways)

local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local GamesDropDownList = require(Modules.LuaApp.Components.GamesDropDownList)
local GameGrid = require(Modules.LuaApp.Components.Games.GameGrid)
local TopBar = require(Modules.LuaApp.Components.TopBar)
local RefreshScrollingFrameWithLoadMore = require(Modules.LuaApp.Components.RefreshScrollingFrameWithLoadMore)
local ApiFetchGamesData = require(Modules.LuaApp.Thunks.ApiFetchGamesData)
local ApiFetchGamesInSort = require(Modules.LuaApp.Thunks.ApiFetchGamesInSort)
local FetchDataWithErrorToasts = require(Modules.LuaApp.Thunks.FetchDataWithErrorToasts)
local RefreshGameSorts = require(Modules.LuaApp.Thunks.RefreshGameSorts)
local RefreshExpiringSortTokens = require(Modules.LuaApp.Thunks.RefreshExpiringSortTokens)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local UseNewRefreshScrollingFrame = FlagSettings.UseNewRefreshScrollingFrame()

local GAME_GRID_PADDING = Constants.GAME_GRID_PADDING
local DROPDOWN_HEIGHT = 38
local DROPDOWN_SECTION_HEADER_GAP = 12
local SECTION_HEADER_HEIGHT = Constants.SECTION_HEADER_HEIGHT
local SECTION_HEADER_GAME_GRID_GAP = 14
local TOP_SECTION_HEIGHT = DROPDOWN_HEIGHT + DROPDOWN_SECTION_HEADER_GAP +
	SECTION_HEADER_HEIGHT + SECTION_HEADER_GAME_GRID_GAP

local SORT_CATEGORY = Constants.GameSortGroups.GamesSeeAll

local GamesList = Roact.PureComponent:extend("GamesList")

function GamesList:init()
	self.refresh = function()
		return self.props.dispatchRefresh(self.props.networking, self.props.sortName)
	end

	self.loadMoreGames = function(count)
		local loadCount = count or Constants.DEFAULT_GAME_FETCH_COUNT
		local dispatchLoadMoreGames = self.props.dispatchLoadMoreGames
		local networking = self.props.networking
		local selectedSort = self.props.selectedSort
		local selectedSortContents = self.props.selectedSortContents

		return dispatchLoadMoreGames(networking, selectedSort, selectedSortContents.rowsRequested, loadCount,
			selectedSortContents.nextPageExclusiveStartId)
	end

	self.navigateToSort = function(sort, position)
		self.props.analytics.reportFilterChange(sort.name, position)
		self.props.navigateToSort(sort)
	end

	self.reportGameDetailOpened = function(index)
		local selectedSortName = self.props.sortName
		local selectedSort = self.props.selectedSort
		local analytics = self.props.analytics

		local entries = self.props.selectedSortContents.entries

		local itemsInSort = #entries
		local entry = entries[index]
		local placeId = entry.placeId
		local isAd = entry.isSponsored
		local gameSetTargetId = selectedSort and selectedSort.gameSetTargetId

		analytics.reportOpenGameDetail(
			placeId,
			selectedSortName,
			gameSetTargetId,
			index,
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
end

function GamesList:render()
	local topBarHeight = self.props.topBarHeight
	local selectedSortName = self.props.sortName
	local screenSize = self.props.screenSize

	local selectedSort = self.props.selectedSort
	local selectedSortContents = self.props.selectedSortContents

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 0,
			},{
				TopBar = Roact.createElement(TopBar, {
					ZIndex = 2,
					showBuyRobux = true,
					showNotifications = true,
					showSearch = true,
				}),
				Scroller = Roact.createElement(RefreshScrollingFrameWithLoadMore, {
					Position = UDim2.new(0, 0, 0, topBarHeight),
					Size = UDim2.new(1, 0, 1, -topBarHeight),
					CanvasSize = UDim2.new(1, 0, 0, 0),
					refresh = self.refresh,
					onLoadMore = (selectedSortContents.hasMoreRows or UseNewRefreshScrollingFrame)
						and self.loadMoreGames,
					-- If there're no more games, create an end section.
					-- TODO: remove with UseNewRefreshScrollingFrame
					createEndOfScrollElement = not selectedSortContents.hasMoreRows,
					hasMoreRows = UseNewRefreshScrollingFrame and selectedSortContents.hasMoreRows,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Padding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, GAME_GRID_PADDING),
						PaddingRight = UDim.new(0, GAME_GRID_PADDING),
						PaddingTop = UDim.new(0, GAME_GRID_PADDING),
					}),
					TopSection = Roact.createElement(FitChildren.FitFrame, {
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Size = UDim2.new(1, 0, 0, TOP_SECTION_HEIGHT),
						fitAxis = FitChildren.FitAxis.Height,
					}, {
						Padding = Roact.createElement("UIPadding", {
							PaddingBottom = UDim.new(0, DROPDOWN_SECTION_HEADER_GAP)
						}),
						DropDown = Roact.createElement(GamesDropDownList, {
							size = UDim2.new(1, 0, 0, DROPDOWN_HEIGHT),
							position = UDim2.new(0, 0, 0, 0),
							sortCategory = SORT_CATEGORY,
							selectedSortName = selectedSortName,
							onSelected = self.navigateToSort,
						}),
						Title = Roact.createElement(FitTextLabel, {
							Text = selectedSort.displayName,
							Position = UDim2.new(0, 0, 0, DROPDOWN_HEIGHT + DROPDOWN_SECTION_HEADER_GAP),
							Font = style.Font.Header1.Font,
							TextSize = style.Font.BaseSize * style.Font.Header1.RelativeSize,
							TextColor3 = style.Theme.TextEmphasis.Color,
							TextTransparency = style.Theme.TextEmphasis.Transparency,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							fitAxis = FitChildren.FitAxis.Height,
							TextWrapped = true,
						}),
					}),
					["GameGrid " .. selectedSortName] = Roact.createElement(GameGrid, {
						LayoutOrder = 2,
						entries = selectedSortContents.entries,
						reportGameDetailOpened = self.reportGameDetailOpened,
						reportQuickGameLaunch = self.reportQuickGameLaunch,
						windowSize = Vector2.new(screenSize.X - 2 * GAME_GRID_PADDING, screenSize.Y),
					}),
				}),
			})
		end)
	else
		-- Build up the outer frame of the page, to include our components:
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
		},{
			TopBar = Roact.createElement(TopBar, {
				ZIndex = 2,
				showBuyRobux = true,
				showNotifications = true,
				showSearch = true,
			}),
			Scroller = Roact.createElement(RefreshScrollingFrameWithLoadMore, {
				Position = UDim2.new(0, 0, 0, topBarHeight),
				Size = UDim2.new(1, 0, 1, -topBarHeight),
				BackgroundColor3 = Constants.Color.GRAY4,
				CanvasSize = UDim2.new(1, 0, 0, 0),
				refresh = self.refresh,
				onLoadMore = selectedSortContents.hasMoreRows and self.loadMoreGames,
				-- If there're no more games, create an end section.
				createEndOfScrollElement = not selectedSortContents.hasMoreRows,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, GAME_GRID_PADDING),
					PaddingRight = UDim.new(0, GAME_GRID_PADDING),
					PaddingTop = UDim.new(0, GAME_GRID_PADDING),
				}),
				TopSection = Roact.createElement(FitChildren.FitFrame, {
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, TOP_SECTION_HEIGHT),
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingBottom = UDim.new(0, DROPDOWN_SECTION_HEADER_GAP)
					}),
					DropDown = Roact.createElement(GamesDropDownList, {
						size = UDim2.new(1, 0, 0, DROPDOWN_HEIGHT),
						position = UDim2.new(0, 0, 0, 0),
						sortCategory = SORT_CATEGORY,
						selectedSortName = selectedSortName,
						onSelected = self.navigateToSort,
					}),
					Title = Roact.createElement(FitTextLabel, {
						Text = selectedSort.displayName,
						Position = UDim2.new(0, 0, 0, DROPDOWN_HEIGHT + DROPDOWN_SECTION_HEADER_GAP),
						TextSize = SECTION_HEADER_HEIGHT,
						Font = Enum.Font.SourceSansLight,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						fitAxis = FitChildren.FitAxis.Height,
						TextWrapped = true,
					}),
				}),
				["GameGrid " .. selectedSortName] = Roact.createElement(GameGrid, {
					LayoutOrder = 2,
					entries = selectedSortContents.entries,
					reportGameDetailOpened = self.reportGameDetailOpened,
					reportQuickGameLaunch = self.reportQuickGameLaunch,
					windowSize = Vector2.new(screenSize.X - 2 * GAME_GRID_PADDING, screenSize.Y),
				}),
			}),
		})
	end
end

function GamesList:didMount()
	-- Refresh expiring tokens upon mounting the page, since they are not fetched anywhere else.
	self.props.dispatchFetchExpiringTokens(self.props.networking)

	-- If we have no sort data then trigger a fetch. This covers sorts that are on GamesSeeAll
	-- but may not already have been fetched because they are not on any other page.
	if #self.props.selectedSortContents.entries == 0 then
		self.props.dispatchRefreshSortContents(self.props.networking, self.props.sortName)
	end
end

local selectAnalytics = function(appRoutes, gamesAnalytics, homeAnalytics)
	local currentRoute = appRoutes[#appRoutes]
	local currentPage = currentRoute[1].name
	if currentPage == AppPage.Games then
		return gamesAnalytics
	elseif currentPage == AppPage.Home then
		return homeAnalytics
	else
		assert(false, string.format("Can not provide GamesList analytics for current page %s.", currentPage))
	end
end

GamesList = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			selectedSort = state.GameSorts[props.sortName],
			selectedSortContents = state.GameSortsContents[props.sortName],
			topBarHeight = state.TopBar.topBarHeight,
			analytics = selectAnalytics(state.Navigation.history, props.gamesAnalytics, props.homeAnalytics),
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			dispatchRefresh = function(networking, sortName)
				return dispatch(FetchDataWithErrorToasts(RefreshGameSorts(networking, { SORT_CATEGORY }, sortName)))
			end,
			dispatchRefreshSortContents = function(networking, sortName)
				return dispatch(ApiFetchGamesData(networking, nil, sortName))
			end,
			navigateToSort = function(sort)
				dispatch(NavigateSideways({ name = AppPage.GamesList, detail = sort.name }))
			end,
			dispatchLoadMoreGames = function(networking, sort, startRows, maxRows, nextPageExclusiveStartId)
				return dispatch(FetchDataWithErrorToasts(ApiFetchGamesInSort(networking, sort, true, {
					startRows = startRows,
					maxRows = maxRows,
					exclusiveStartId = nextPageExclusiveStartId
				})))
			end,
			dispatchFetchExpiringTokens = function(networking)
				return dispatch(RefreshExpiringSortTokens(networking, { SORT_CATEGORY }))
			end,
		}
	end
)(GamesList)

return RoactServices.connect({
	networking = RoactNetworking,
	gamesAnalytics = RoactAnalyticsGamesPage,
	homeAnalytics = RoactAnalyticsHomePage,
})(GamesList)
