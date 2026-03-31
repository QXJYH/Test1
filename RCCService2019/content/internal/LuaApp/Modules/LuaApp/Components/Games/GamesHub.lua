local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local RoactAnalyticsGamesPage = require(Modules.LuaApp.Services.RoactAnalyticsGamesPage)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactServices = require(Modules.LuaApp.RoactServices)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

local TopBar = require(Modules.LuaApp.Components.TopBar)
local RefreshScrollingFrame = require(Modules.LuaApp.Components.RefreshScrollingFrame)
local RefreshScrollingFrameNew = require(Modules.LuaApp.Components.RefreshScrollingFrameNew)
local GameCarousels = require(Modules.LuaApp.Components.GameCarousels)
local TokenRefreshComponent = require(Modules.LuaApp.Components.TokenRefreshComponent)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)

local RefreshGameSorts = require(Modules.LuaApp.Thunks.RefreshGameSorts)
local FetchGamesPageData = require(Modules.LuaApp.Thunks.FetchGamesPageData)
local FetchDataWithErrorToasts = require(Modules.LuaApp.Thunks.FetchDataWithErrorToasts)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()
local UseNewRefreshScrollingFrame = FlagSettings.UseNewRefreshScrollingFrame()

local TOP_MARGIN = 24
local COMPACT_LEFT_MARGIN = 24
local WIDE_LEFT_MARGIN = 48

local GamesHub = Roact.PureComponent:extend("GamesHub")

function GamesHub:init()
	self.refresh = function()
		return self.props.refresh(self.props.networking)
	end

	self.fetchGamesPageData = function()
		return self.props.fetchGamesPageData(self.props.networking, self.props.appAnalytics)
	end
end

function GamesHub:renderGamesHub(stylePalette)
	local topBarHeight = self.props.topBarHeight
	local analytics = self.props.analytics
	local gamesPageDataStatus = self.props.gamesPageDataStatus
	local backgroundColor = Constants.Color.GRAY4
	local backgroundTransparency = 0

	local padding

	if stylePalette then
		local formFactor = self.props.formFactor
		local theme = stylePalette.Theme
		backgroundColor = theme.BackgroundUIDefault.Color
		backgroundTransparency = theme.BackgroundUIDefault.Transparency
		local leftMargin = WIDE_LEFT_MARGIN
		if formFactor == FormFactor.COMPACT then
			leftMargin = COMPACT_LEFT_MARGIN
		end
		padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, TOP_MARGIN),
			PaddingLeft = UDim.new(0, leftMargin),
			PaddingBottom = UDim.new(0, TOP_MARGIN * 2),
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
	}, {
		TokenRefreshComponent = Roact.createElement(TokenRefreshComponent, {
			sortToRefresh = Constants.GameSortGroups.Games,
		}),
		TopBar = Roact.createElement(TopBar, {
			showBuyRobux = true,
			showNotifications = true,
			showSearch = true,
			ZIndex = 2,
		}),
		Content = Roact.createElement("Frame", {
			Position = UDim2.new(0, 0, 0, topBarHeight),
			Size = UDim2.new(1, 0, 1, -topBarHeight),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
		}, {
			LoadingStateWrapper = Roact.createElement(LoadingStateWrapper, {
				dataStatus = gamesPageDataStatus,
				onRetry = self.fetchGamesPageData,
				debugName = "GamesHub",
				renderOnFailed = LoadingStateWrapper.RenderOnFailedStyle.EmptyStatePage,
				renderOnLoaded = function()
					return Roact.createElement(UseNewRefreshScrollingFrame and
						RefreshScrollingFrameNew or RefreshScrollingFrame, {
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = backgroundColor,
						BackgroundTransparency = backgroundTransparency,
						CanvasSize = UDim2.new(1, 0, 0, 0),
						refresh = self.refresh,
						parentAppPage = AppPage.Games,
					}, {
						--[[
							Adding UIListLayout to go around the issue with FitChildren wrongly
							calculating when the AbsolutePosition of its only child is negative
						]]
						Padding = padding,
						Layout = Roact.createElement("UIListLayout"),
						GameCarousels = Roact.createElement(GameCarousels, {
							gameSortGroup = Constants.GameSortGroups.Games,
							analytics = analytics,
						}),
					})
				end,
			}),
		}),
	})
end

function GamesHub:render()
	if useNewAppStyle then
		local renderFuntion = function(stylePalette)
			return self:renderGamesHub(stylePalette)
		end
		return withStyle(renderFuntion)
	else
		return self:renderGamesHub()
	end
end

GamesHub = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			topBarHeight = state.TopBar.topBarHeight,
			gamesPageDataStatus = state.Startup.GamesPageDataStatus,
		}
	end,
	function(dispatch)
		return {
			refresh = function(networking)
				return dispatch(FetchDataWithErrorToasts(RefreshGameSorts(
					networking,
					{ Constants.GameSortGroups.Games },
					nil
				)))
			end,
			fetchGamesPageData = function(networking, analytics)
				return dispatch(FetchGamesPageData(networking, analytics))
			end,
		}
	end
)(GamesHub)

return RoactServices.connect({
	networking = RoactNetworking,
	appAnalytics = RoactAnalytics,
	analytics = RoactAnalyticsGamesPage,
})(GamesHub)
