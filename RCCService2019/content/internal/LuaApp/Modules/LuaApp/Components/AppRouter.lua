local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local AppNotificationService = require(Modules.LuaApp.Services.AppNotificationService)
local AppRunService = require(Modules.LuaApp.Services.AppRunService)
local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local AppPage = require(Modules.LuaApp.AppPage)
local AppPageProperties = require(Modules.LuaApp.AppPageProperties)
local RouterAnalyticsReporter = require(Modules.LuaApp.Components.Analytics.RouterAnalyticsReporter)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local SetScreenGuiBlur = require(Modules.LuaApp.Actions.SetScreenGuiBlur)
local FetchHomePageData = require(Modules.LuaApp.Thunks.FetchHomePageData)
local FetchGamesPageData = require(Modules.LuaApp.Thunks.FetchGamesPageData)
local SetTabBarVisible = require(Modules.LuaApp.Actions.SetTabBarVisible)
local SetNavigationLocked = require(Modules.LuaApp.Thunks.SetNavigationLocked)
local luaPageLoad = require(Modules.LuaApp.Analytics.Events.luaPageLoad)

local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()
local FFlagLuaPageLoadEvent = settings():GetFFlag("LuaPageLoadEvent")
local FFlagLuaAppEnablePageBlur = settings():GetFFlag("LuaAppEnablePageBlur")
local RENDER_TRANSPARENT_PAGE_MAX_COUNT = FlagSettings.GetLuaAppRenderTransparentPageMaxCount()

local AppRouter = Roact.PureComponent:extend("AppRouter")

AppRouter.defaultProps = {
	alwaysRenderedPages = {},
}

local function getPageName(page)
	return page.detail and (page.name .. ":" .. page.detail) or page.name
end

local function getTopPageFromProps(props)
	local routeHistory = props.routeHistory
	local route = routeHistory[#routeHistory]
	return route[#route]
end

function AppRouter:addUniquePage(pages, pageInfo, isVisible, displayOrder)
	local pageConstructors = self.props.pageConstructors
	local pageName = getPageName(pageInfo)
	if not pages[pageName] then
		local navigationProps = {
			isVisible = isVisible,
			displayOrder = displayOrder,
		}
		pages[pageName] = pageConstructors[pageInfo.name](navigationProps, pageInfo.detail, pageInfo.extraProps)
	end
end

function AppRouter:collectPagesFromRouteHistory(pages)
	local routeHistory = self.props.routeHistory
	local firstOpaquePage = 0

	-- find and render 1st opaque page
	for index = #routeHistory, 1, -1 do
		local route = routeHistory[index]
		local pageInfo = route[#route]
		local pageProperties = AppPageProperties[pageInfo.name] or {}

		if not pageProperties.renderUnderlyingPage then
			firstOpaquePage = index

			self:addUniquePage(pages, pageInfo, true, 0)
			break
		end
	end

	-- render a limited number of transparent pages (RENDER_TRANSPARENT_PAGE_MAX_COUNT)
	-- on top of the opaque page
	local transparentPageStartIndex = math.max(firstOpaquePage + 1,
		#routeHistory - RENDER_TRANSPARENT_PAGE_MAX_COUNT + 1)
	local hasCoreBlur = false
	local blurDisplayOrder = 0
	for index = transparentPageStartIndex, #routeHistory do
		local route = routeHistory[index]
		local pageInfo = route[#route]
		local displayOrder = index - transparentPageStartIndex + 1

		if FFlagLuaAppEnablePageBlur then
			local pageProperties = AppPageProperties[pageInfo.name] or {}
			if pageProperties.blurUnderlyingPage then
				hasCoreBlur = true
				blurDisplayOrder = math.max(displayOrder, blurDisplayOrder)
			end
		end

		self:addUniquePage(pages, pageInfo, true, displayOrder)
	end

	if FFlagLuaAppEnablePageBlur then
		self.props.setScreenGuiBlur(hasCoreBlur, blurDisplayOrder)
	end

	-- all other pages are invisible.
	for index = #routeHistory, 1, -1 do
		local route = routeHistory[index]
		local pageInfo = route[#route]

		self:addUniquePage(pages, pageInfo, false, 0)
	end
end

function AppRouter:collectAlwaysRenderedPages(pages)
	local alwaysRenderedPages = self.props.alwaysRenderedPages

	if self.props.renderAlwaysRenderedPages or not FlagSettings.LuaAppLoginEnabled() then
		for index = 1, #alwaysRenderedPages do
			local pageInfo = alwaysRenderedPages[index]

			self:addUniquePage(pages, pageInfo, false, 0)
		end
	end
end

function AppRouter:render()
	local routeHistory = self.props.routeHistory
	local pageConstructors = self.props.pageConstructors
	local alwaysRenderedPages = self.props.alwaysRenderedPages

	local currentRoute = routeHistory[#routeHistory]
	local currentPage = currentRoute[#currentRoute].name
	local pages = {
		RouterAnalyticsReporter = Roact.createElement(RouterAnalyticsReporter, {
			currentPage = currentPage,
		}),
	}

	self:collectPagesFromRouteHistory(pages)
	self:collectAlwaysRenderedPages(pages)

	return Roact.createElement("Folder", {}, pages)
end

function AppRouter:willUpdate(nextProps)
	local newPage = getTopPageFromProps(nextProps)
	local newPageProperties = AppPageProperties[newPage.name] or {}

	-- Adjust tab bar (aka bottom bar) visibility according to page settings
	local newTabBarVisible = not newPageProperties.tabBarHidden
	if not newPageProperties.overridesAppRouterTabBarControl and newTabBarVisible ~= nextProps.tabBarVisible then
		self.props.setTabBarVisible(newTabBarVisible)
	end
end

function AppRouter:onPageChange(oldPage, newPage)
	local eventStreamImpl = RoactAnalytics.get(self._context).EventStream

	luaPageLoad(eventStreamImpl, "AppRouter", newPage.name, newPage.detail)
end

function AppRouter:didMount()
	local routeHistory = self.props.routeHistory
	local route = routeHistory[#routeHistory]
	local page = route[#route]

	if FFlagLuaPageLoadEvent then
		self:onPageChange(nil, page)
	end
end

function AppRouter:didUpdate(prevProps, prevState)
	local localUserId = self.props.localUserId
	local notificationService = self.props.NotificationService
	local runService = self.props.RunService
	local newRouteHistory = self.props.routeHistory
	local newRoute = newRouteHistory[#newRouteHistory]
	local newPage = newRoute[#newRoute]

	local oldRouteHistory = prevProps.routeHistory
	local oldRoute = oldRouteHistory[#oldRouteHistory]
	local oldPage = oldRoute[#oldRoute]

	if FFlagLuaPageLoadEvent then
		if getPageName(oldPage) ~= getPageName(newPage) then
			self:onPageChange(oldPage, newPage)
		end
	end

	-- Every time the route history changes, we must clear the lockout of
	-- subsequent navigation events to the Navigation reducer. This precludes
	-- simultaneous navigation to multiple pages from corrupting the route history.
	if FFlagLuaNavigationLockRefactor and newRoute ~= oldRoute then
		self.props.clearNavigationLock(runService)
	end

	if newPage.name == AppPage.Games
		and self.props.gamesPageDataStatus == RetrievalStatus.NotStarted then
		self.props.loadGamesPage(RoactNetworking.get(self._context), RoactAnalytics.get(self._context))
	end

	if newPage.name == AppPage.Home and
		self.props.homePageDataStatus == RetrievalStatus.NotStarted then
		self.props.loadHomePage(RoactNetworking.get(self._context), RoactAnalytics.get(self._context), localUserId)
	end

	local fetchedGames = newPage.name == AppPage.Games
		and self.props.gamesPageDataStatus == RetrievalStatus.Done
	local oldFetchedGames = oldPage.name == AppPage.Games
		and prevProps.gamesPageDataStatus == RetrievalStatus.Done
	if fetchedGames and not oldFetchedGames then
		notificationService:ActionEnabled(Enum.AppShellActionType.GamePageLoaded)
	end

	local fetchedHome = newPage.name == AppPage.Home
		and self.props.homePageDataStatus == RetrievalStatus.Done
	local oldFetchedHome = oldPage.name == AppPage.Home
		and prevProps.homePageDataStatus == RetrievalStatus.Done
	if fetchedHome and not oldFetchedHome then
		notificationService:ActionEnabled(Enum.AppShellActionType.HomePageLoaded)
	end

	local fetchedChat = newPage.name == AppPage.Chat and self.props.chatLoaded
	local oldFetchedChat = oldPage.name == AppPage.Chat and prevProps.chatLoaded
	if fetchedChat and not oldFetchedChat then
		notificationService:ActionEnabled(Enum.AppShellActionType.TapConversationEntry)
	end
end

AppRouter = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			localUserId = state.LocalUserId,
			routeHistory = state.Navigation.history,
			gamesPageDataStatus = state.Startup.GamesPageDataStatus,
			homePageDataStatus = state.Startup.HomePageDataStatus,
			chatLoaded = state.ChatAppReducer.AppLoaded,
			tabBarVisible = state.TabBarVisible,
			renderAlwaysRenderedPages = state.Authentication.status == LoginStatus.LOGGED_IN,
		}
	end,
	function(dispatch)
		return {
			loadHomePage = function(networking, analytics, localUserId)
				return dispatch(FetchHomePageData(networking, analytics, localUserId))
			end,
			loadGamesPage = function(networking, analytics)
				return dispatch(FetchGamesPageData(networking, analytics))
			end,
			setTabBarVisible = function(isVisible)
				-- LuaChat has internal code that listens for changes to TabBarVisible.
				-- It will set the native bottom bar state accordingly, and this state variable also
				-- directly controls the Lua bottom bar, so we do not need to do anything else.
				dispatch(SetTabBarVisible(isVisible))
			end,
			clearNavigationLock = function(runService)
				-- Clearing of nav lock must be delayed by one frame to give game engine time to
				-- update the UI, otherwise we might end up acting upon input events that
				-- were already queued up against the OLD page structure even though Lua already
				-- believes the tree has changed.
				coroutine.wrap(function()
					runService.Heartbeat:Wait()
					dispatch(SetNavigationLocked(false))
				end)()
			end,
			setScreenGuiBlur = function(blur, displayOrder)
				dispatch(SetScreenGuiBlur("AppRouter", blur, displayOrder))
			end,
		}
	end
)(AppRouter)

return RoactServices.connect({
	NotificationService = AppNotificationService,
	RunService = AppRunService,
})(AppRouter)
