local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local RoactAnalyticsSearchPage = require(Modules.LuaApp.Services.RoactAnalyticsSearchPage)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local SearchUuid = require(Modules.LuaApp.SearchUuid)
local SearchRetrievalStatus = require(Modules.LuaApp.Enum.SearchRetrievalStatus)

local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local FitTextButton = require(Modules.LuaApp.Components.FitTextButton)
local FitChildren = require(Modules.LuaApp.FitChildren)
local GameGrid = require(Modules.LuaApp.Components.Games.GameGrid)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local LocalizedFitTextLabel = require(Modules.LuaApp.Components.LocalizedFitTextLabel)
local RefreshScrollingFrameWithLoadMore = require(Modules.LuaApp.Components.RefreshScrollingFrameWithLoadMore)
local SearchResultPlayerRecommendation = require(Modules.LuaApp.Components.Search.SearchResultPlayerRecommendation)

local RemoveSearchInGames = require(Modules.LuaApp.Actions.RemoveSearchInGames)
local SetSearchInGamesStatus = require(Modules.LuaApp.Actions.SetSearchInGamesStatus)
local SetSearchParameters = require(Modules.LuaApp.Actions.SetSearchParameters)
local ApiFetchSearchInGames = require(Modules.LuaApp.Thunks.ApiFetchSearchInGames)
local OpenWebview = require(Modules.LuaApp.Thunks.OpenWebview)
local NavigateSideways = require(Modules.LuaApp.Thunks.NavigateSideways)
local FetchDataWithErrorToasts = require(Modules.LuaApp.Thunks.FetchDataWithErrorToasts)

local FFlagLuaAppGameSearchPlayerSuggestion = settings():GetFFlag("LuaAppGameSearchPlayerSuggestion376")
local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local UseNewRefreshScrollingFrame = FlagSettings.UseNewRefreshScrollingFrame()

local HEADER_GRID_PADDING = 12
local HEADER_INNER_PADDING = 6
local TITLE_KEYWORD_PADDING = 2
local SEARCH_RESULT_TEXT_SIZE = 18

local GamesSearch = Roact.PureComponent:extend("GamesSearch")

function GamesSearch:getSearchedKeyword()
	local searchInGames = self.props.searchInGames
	local keyword = searchInGames.keyword
	local correctedKeyword = searchInGames.correctedKeyword
	return correctedKeyword and correctedKeyword or keyword
end

function GamesSearch:getDisplayedSearchKeyword()
	local searchInGames = self.props.searchInGames
	local keyword = searchInGames.keyword
	local correctedKeyword = searchInGames.correctedKeyword
	local filteredKeyword = searchInGames.filteredKeyword
	return filteredKeyword and filteredKeyword or correctedKeyword or keyword
end

function GamesSearch:getDisplayedSuggestedKeyword()
	local searchInGames = self.props.searchInGames
	local keyword = searchInGames.keyword
	local suggestedKeyword = searchInGames.suggestedKeyword
	local correctedKeyword = searchInGames.correctedKeyword
	return correctedKeyword and keyword or suggestedKeyword
end

function GamesSearch:init()
	self.refresh = function()
		local networking = self.props.networking
		local searchUuid = self.props.searchUuid
		local searchInGames = self.props.searchInGames
		local dispatchSearchWithErrorToast = self.props.dispatchSearchWithErrorToast

		return dispatchSearchWithErrorToast(networking, searchInGames.keyword, searchUuid,
			searchInGames.isKeywordSuggestionEnabled)
	end

	self.dispatchInitialSearch = function()
		local networking = self.props.networking
		local searchUuid = self.props.searchUuid
		local searchParameters = self.props.searchParameters
		local dispatchSearch = self.props.dispatchSearch

		return dispatchSearch(networking, searchParameters.searchKeyword, searchUuid,
			searchParameters.isKeywordSuggestionEnabled)
	end

	self.loadMore = function()
		local loadCount = Constants.DEFAULT_GAME_FETCH_COUNT
		local networking = self.props.networking
		local searchUuid = self.props.searchUuid
		local searchInGames = self.props.searchInGames
		local dispatchLoadMore = self.props.dispatchLoadMore

		return dispatchLoadMore(networking, searchInGames.keyword, searchUuid,
			searchInGames.rowsRequested, loadCount, searchInGames.isKeywordSuggestionEnabled)
	end

	self.onKeywordButtonActivated = function()
		local searchUuid = SearchUuid()
		local searchKeyword = self:getDisplayedSuggestedKeyword()

		self.props.setSearchParameters(searchUuid, searchKeyword, false)
		self.props.navigateSideways(searchUuid)
	end
end

function GamesSearch:renderOnLoaded()
	local analytics = self.props.analytics
	local guiService = self.props.guiService
	local localization = self.props.localization
	local openWebview = self.props.openWebview
	local screenSize = self.props.screenSize
	local searchInGames = self.props.searchInGames

	local entries = searchInGames.entries
	local suggestedKeyword = searchInGames.suggestedKeyword
	local correctedKeyword = searchInGames.correctedKeyword
	local filteredKeyword = searchInGames.filteredKeyword
	local keyword = searchInGames.keyword
	local hasSuggestion = suggestedKeyword or correctedKeyword
	local showPlayerSearchFrame = FFlagLuaAppGameSearchPlayerSuggestion and
		string.len(keyword) > 0 and (not hasSuggestion) and (not filteredKeyword)
	local displayedSearchKeyword = self:getDisplayedSearchKeyword()
	local displayedSuggestedKeyword = self:getDisplayedSuggestedKeyword()
	local suggestionTitleText = correctedKeyword and {"Feature.GamePage.LabelSearchInsteadFor"} or
		{"Feature.GamePage.LabelSearchYouMightMean"}

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement(RefreshScrollingFrameWithLoadMore, {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				CanvasSize = UDim2.new(1, 0, 1, 0),
				refresh = self.refresh,
				onLoadMore = (searchInGames.hasMoreRows or UseNewRefreshScrollingFrame)
					and self.loadMore,
				-- TODO: remove with UseNewRefreshScrollingFrame
				createEndOfScrollElement = not searchInGames.hasMoreRows,
				hasMoreRows = UseNewRefreshScrollingFrame and searchInGames.hasMoreRows,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, HEADER_GRID_PADDING),
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, Constants.GAME_GRID_PADDING),
					PaddingRight = UDim.new(0, Constants.GAME_GRID_PADDING),
					PaddingTop = UDim.new(0, Constants.GAME_GRID_PADDING),
					PaddingBottom = UDim.new(0, Constants.GAME_GRID_PADDING),
				}),
				SearchResultHeader = Roact.createElement(FitChildren.FitFrame, {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = 1,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					Layout = (hasSuggestion or showPlayerSearchFrame) and Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, HEADER_INNER_PADDING),
					}),
					ShowingResultsFrame = Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, SEARCH_RESULT_TEXT_SIZE),
						LayoutOrder = 1,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, TITLE_KEYWORD_PADDING),
						}),
						ShowingResultsText = Roact.createElement(LocalizedFitTextLabel, {
							Text = "Feature.GamePage.LabelShowingResultsFor",
							LayoutOrder = 1,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 1,
							TextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
							Font = style.Font.Body.Font,
							TextColor3 = style.Theme.TextDefault.Color,
							TextTransparency = style.Theme.TextDefault.Transparency,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							fitAxis = FitChildren.FitAxis.Width,
						}),
						Keyword = Roact.createElement(FitTextLabel, {
							Text = displayedSearchKeyword,
							LayoutOrder = 2,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 1,
							TextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
							Font = style.Font.Body.Font,
							TextColor3 = style.Theme.TextEmphasis.Color,
							TextTransparency = style.Theme.TextEmphasis.Transparency,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							fitAxis = FitChildren.FitAxis.Width,
						}),
					}),
					SuggestionFrame = hasSuggestion and Roact.createElement("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, SEARCH_RESULT_TEXT_SIZE),
						LayoutOrder = 2,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, TITLE_KEYWORD_PADDING),
						}),
						SuggestionTitleText = Roact.createElement(LocalizedFitTextLabel, {
							Text = suggestionTitleText,
							LayoutOrder = 1,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 1,
							TextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
							Font = style.Font.Body.Font,
							TextColor3 = style.Theme.TextDefault.Color,
							TextTransparency = style.Theme.TextDefault.Transparency,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							fitAxis = FitChildren.FitAxis.Width,
						}),
						SuggestedKeyword = Roact.createElement(FitTextButton, {
							Text = displayedSuggestedKeyword,
							LayoutOrder = 2,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 1,
							TextSize = style.Font.Body.RelativeSize * style.Font.BaseSize,
							Font = style.Font.Body.Font,
							TextColor3 = style.Theme.TextEmphasis.Color,
							TextTransparency = style.Theme.TextEmphasis.Transparency,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							fitAxis = FitChildren.FitAxis.Width,
							[Roact.Event.Activated] = self.onKeywordButtonActivated,
						}, {
							-- We can achieve the underline with RichText once the feature is stable.
							Underline = Roact.createElement("Frame", {
								Size = UDim2.new(1, 0, 0, 1),
								Position = UDim2.new(0, 0, 1, -1),
								BackgroundColor3 = style.Theme.TextEmphasis.Color,
								BackgroundTransparency = style.Theme.TextEmphasis.Transparency,
							}),
						}),
					}),
					PlayerSearchFrameFrame = showPlayerSearchFrame and Roact.createElement(SearchResultPlayerRecommendation, {
						analytics = analytics,
						guiService = guiService,
						keyword = keyword,
						layoutOrder = 2,
						localization = localization,
						openWebview = openWebview,
					}),
				}),
				GameGrid = Roact.createElement(GameGrid, {
					LayoutOrder = 2,
					entries = entries,
					reportGameDetailOpened = function(index)
						local entry = entries[index]
						local placeId = entry.placeId
						local isAd = entry.isSponsored
						local sortName = self:getSearchedKeyword()
						local itemsInSort = #entries
						analytics.reportOpenGameDetail(placeId, sortName, nil, index, itemsInSort, isAd)
					end,
					reportQuickGameLaunch = {
						entry = function()
							return analytics.reportQuickGameLaunchEntry()
						end,
						success = function()
							return analytics.reportQuickGameLaunchSuccess()
						end,
						failure = function(reason)
							return analytics.reportQuickGameLaunchFailed(reason)
						end,
					},
					windowSize = Vector2.new(screenSize.X - 2 * Constants.GAME_GRID_PADDING, screenSize.Y),
				}),
			})
		end)
	else
		return Roact.createElement(RefreshScrollingFrameWithLoadMore, {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Constants.Color.GRAY4,
			CanvasSize = UDim2.new(1, 0, 1, 0),
			refresh = self.refresh,
			onLoadMore = searchInGames.hasMoreRows and self.loadMore,
			createEndOfScrollElement = not searchInGames.hasMoreRows,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, HEADER_GRID_PADDING),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, Constants.GAME_GRID_PADDING),
				PaddingRight = UDim.new(0, Constants.GAME_GRID_PADDING),
				PaddingTop = UDim.new(0, Constants.GAME_GRID_PADDING),
				PaddingBottom = UDim.new(0, Constants.GAME_GRID_PADDING),
			}),
			SearchResultHeader = Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				LayoutOrder = 1,
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				Layout = (hasSuggestion or showPlayerSearchFrame) and Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, HEADER_INNER_PADDING),
				}),
				ShowingResultsFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, SEARCH_RESULT_TEXT_SIZE),
					LayoutOrder = 1,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, TITLE_KEYWORD_PADDING),
					}),
					ShowingResultsText = Roact.createElement(LocalizedFitTextLabel, {
						Text = "Feature.GamePage.LabelShowingResultsFor",
						LayoutOrder = 1,
						Size = UDim2.new(0, 0, 1, 0),
						BackgroundTransparency = 1,
						TextSize = SEARCH_RESULT_TEXT_SIZE,
						TextColor3 = Constants.Color.GRAY1,
						Font = Enum.Font.SourceSansLight,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						fitAxis = FitChildren.FitAxis.Width,
					}),
					Keyword = Roact.createElement(FitTextLabel, {
						Text = displayedSearchKeyword,
						LayoutOrder = 2,
						Size = UDim2.new(0, 0, 1, 0),
						BackgroundTransparency = 1,
						TextSize = SEARCH_RESULT_TEXT_SIZE,
						TextColor3 = Constants.Color.GRAY1,
						Font = Enum.Font.SourceSansBold,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						fitAxis = FitChildren.FitAxis.Width,
					}),
				}),
				SuggestionFrame = hasSuggestion and Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, SEARCH_RESULT_TEXT_SIZE),
					LayoutOrder = 2,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, TITLE_KEYWORD_PADDING),
					}),
					SuggestionTitleText = Roact.createElement(LocalizedFitTextLabel, {
						Text = suggestionTitleText,
						LayoutOrder = 1,
						Size = UDim2.new(0, 0, 1, 0),
						BackgroundTransparency = 1,
						TextSize = SEARCH_RESULT_TEXT_SIZE,
						TextColor3 = Constants.Color.GRAY1,
						Font = Enum.Font.SourceSansLight,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						fitAxis = FitChildren.FitAxis.Width,
					}),
					SuggestedKeyword = Roact.createElement(FitTextButton, {
						Text = displayedSuggestedKeyword,
						LayoutOrder = 2,
						Size = UDim2.new(0, 0, 1, 0),
						BackgroundTransparency = 1,
						TextSize = SEARCH_RESULT_TEXT_SIZE,
						TextColor3 = Constants.Color.BLUE_PRIMARY,
						Font = Enum.Font.SourceSansBold,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						fitAxis = FitChildren.FitAxis.Width,
						[Roact.Event.Activated] = self.onKeywordButtonActivated,
					}),
				}),
				PlayerSearchFrameFrame = showPlayerSearchFrame and Roact.createElement(SearchResultPlayerRecommendation, {
					analytics = analytics,
					guiService = guiService,
					keyword = keyword,
					layoutOrder = 2,
					localization = localization,
					openWebview = openWebview,
				}),
			}),
			GameGrid = Roact.createElement(GameGrid, {
				LayoutOrder = 2,
				entries = entries,
				reportGameDetailOpened = function(index)
					local entry = entries[index]
					local placeId = entry.placeId
					local isAd = entry.isSponsored
					local sortName = self:getSearchedKeyword()
					local itemsInSort = #entries
					analytics.reportOpenGameDetail(placeId, sortName, nil, index, itemsInSort, isAd)
				end,
				reportQuickGameLaunch = {
					entry = function()
						return analytics.reportQuickGameLaunchEntry()
					end,
					success = function()
						return analytics.reportQuickGameLaunchSuccess()
					end,
					failure = function(reason)
						return analytics.reportQuickGameLaunchFailed(reason)
					end,
				},
				windowSize = Vector2.new(screenSize.X - 2 * Constants.GAME_GRID_PADDING, screenSize.Y),
			}),
		})
	end
end

function GamesSearch:render()
	local searchInGamesStatus = self.props.searchInGamesStatus
	local searchParameters = self.props.searchParameters

	return Roact.createElement(LoadingStateWrapper, {
		dataStatus = searchInGamesStatus,
		onRetry = self.dispatchInitialSearch,
		debugName = "GamesSearch-" .. searchParameters.searchKeyword,
		renderOnFailed = LoadingStateWrapper.RenderOnFailedStyle.EmptyStatePage,
		renderOnLoaded = function()
			return self:renderOnLoaded()
		end,
	})
end

function GamesSearch:didMount()
	self.dispatchInitialSearch()
end

function GamesSearch:willUnmount()
	local searchUuid = self.props.searchUuid
	local dispatchRemoveSearch = self.props.dispatchRemoveSearch

	dispatchRemoveSearch(searchUuid)
end

local function selectSearchInGamesStatus(state, props)
	local searchInGamesStatus = state.RequestsStatus.SearchesInGamesStatus[props.searchUuid]

	if searchInGamesStatus == nil then
		searchInGamesStatus = SearchRetrievalStatus.NotStarted
	end

	return searchInGamesStatus
end

GamesSearch = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			searchInGames = state.Search.SearchesInGames[props.searchUuid],
			searchInGamesStatus = selectSearchInGamesStatus(state, props),
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			dispatchSearch = function(networking, searchKeyword, searchUuid, isKeywordSuggestionEnabled)
				return dispatch(ApiFetchSearchInGames(networking, {
					searchKeyword = searchKeyword,
					searchUuid = searchUuid,
					isAppend = false,
				}, {
					isKeywordSuggestionEnabled = isKeywordSuggestionEnabled,
				}))
			end,
			dispatchSearchWithErrorToast = function(networking, searchKeyword, searchUuid, isKeywordSuggestionEnabled)
				return dispatch(FetchDataWithErrorToasts(ApiFetchSearchInGames(networking, {
					searchKeyword = searchKeyword,
					searchUuid = searchUuid,
					isAppend = false,
				}, {
					isKeywordSuggestionEnabled = isKeywordSuggestionEnabled,
				})))
			end,
			dispatchLoadMore = function(networking, searchKeyword, searchUuid, startRows, maxRows, isKeywordSuggestionEnabled)
				return dispatch(FetchDataWithErrorToasts(ApiFetchSearchInGames(networking, {
					searchKeyword = searchKeyword,
					searchUuid = searchUuid,
					isAppend = true,
				}, {
					startRows = startRows,
					maxRows = maxRows,
					isKeywordSuggestionEnabled = isKeywordSuggestionEnabled,
				})))
			end,
			setSearchParameters = function(searchUuid, searchKeyword, isKeywordSuggestionEnabled)
				return dispatch(SetSearchParameters(searchUuid, {
					searchKeyword = searchKeyword,
					isKeywordSuggestionEnabled = isKeywordSuggestionEnabled,
				}))
			end,
			dispatchRemoveSearch = function(searchUuid)
				dispatch(RemoveSearchInGames(searchUuid))
				dispatch(SetSearchInGamesStatus(searchUuid, SearchRetrievalStatus.Removed))
			end,
			navigateSideways = function(searchUuid)
				dispatch(NavigateSideways({ name = AppPage.SearchPage, detail = searchUuid }))
			end,
			openWebview = function(url, title)
				return dispatch(OpenWebview(url, title))
			end,
		}
	end
)(GamesSearch)

return RoactServices.connect({
	analytics = RoactAnalyticsSearchPage,
	guiService = AppGuiService,
	localization = RoactLocalization,
	networking = RoactNetworking,
})(GamesSearch)
