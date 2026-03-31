local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")
local Modules = CoreGui.RobloxGui.Modules
local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local memoize = require(Modules.Common.memoize)
local RoactServices = require(Modules.LuaApp.RoactServices)
local Constants = require(Modules.LuaApp.Constants)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local LuaAppEvents = require(Modules.LuaApp.LuaAppEvents)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local ChatMaster = require(Modules.ChatMaster)
local Toast = require(Modules.LuaApp.Components.Toast)
local CentralOverlay = require(Modules.LuaApp.Components.CentralOverlay)
local NavBar = require(Modules.LuaApp.Components.NavBar.NavBar)
local NavBarButton = require(Modules.LuaApp.Components.NavBar.NavBarButton)
local NavBarButtonWithText = require(Modules.LuaApp.Components.NavBar.NavBarButtonWithText)
local NavBarScreenGuiWrapper = require(Modules.LuaApp.Components.NavBar.NavBarScreenGuiWrapper)
local UniversalBottomBar = require(Modules.LuaApp.Components.UniversalBottomBar)
local UniversalBottomBarButton = require(Modules.LuaApp.Components.UniversalBottomBarButton)
local ScreenGuiWrap = require(Modules.LuaApp.Components.ScreenGuiWrap)

local AppNotificationService = require(Modules.LuaApp.Services.AppNotificationService)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local RoactAnalyticsBottomBar = require(Modules.LuaApp.Services.RoactAnalyticsBottomBar)

local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local AppPage = require(Modules.LuaApp.AppPage)
local AppRouter = require(Modules.LuaApp.Components.AppRouter)
local DiscussionsEntrypoint = require(Modules.LuaDiscussions.DiscussionsEntrypoint)
local HomePage = require(Modules.LuaApp.Components.Home.HomePage)
local HomePageWithAvatarAndWidget = require(Modules.LuaApp.Components.Home.HomePageWithAvatarAndWidget)
local GamesHub = require(Modules.LuaApp.Components.Games.GamesHub)
local ChallengePage = require(Modules.LuaApp.Components.ChallengePage)
local ChinaCatalogPage = require(Modules.LuaApp.Components.Catalog.China.ChinaCatalogPage)
local ChinaBundleModal = require(Modules.LuaApp.Components.Catalog.China.ChinaBundleModal)
local GamesList = require(Modules.LuaApp.Components.Games.GamesList)
local GameDetails = require(Modules.LuaApp.Components.GameDetails.GameDetails)
local SearchPage = require(Modules.LuaApp.Components.Search.SearchPage)
local YouTubePageWrapper = require(Modules.LuaApp.Components.YouTubePageWrapper)
local GenericWebPageWrapper = require(Modules.LuaApp.Components.GenericWebPageWrapper)
local GenericNativePageWrapper = require(Modules.LuaApp.Components.GenericNativePageWrapper)
local GameDetailWrapper = require(Modules.LuaApp.Components.GameDetailWrapper)
local RoactChatWrapper = require(Modules.LuaApp.Components.Chat.RoactChatWrapper)
local RoactGameShareWrapper = require(Modules.LuaApp.Components.Chat.RoactGameShareWrapper)
local StartupPage = require(Modules.LuaApp.Components.Login.StartupPage)
local WeChatLoginWrapper = require(Modules.LuaApp.Components.Login.WeChatLoginWrapper)
local LoginView = require(Modules.LuaApp.Components.Login.LoginView)
local UsernameSelectionPage = require(Modules.LuaApp.Components.Login.UsernameSelectionPage)
local NativeViewUserProfileWrapper = require(Modules.LuaApp.Components.NativeViewUserProfileWrapper)
local NativeViewProfileWrapper = require(Modules.LuaApp.Components.NativeViewProfileWrapper)
local LandingPage = require(Modules.LuaApp.Components.Landing.LandingPage)
local BirthdayPage = require(Modules.LuaApp.Components.Login.BirthdayPage)

local MorePage = require(Modules.LuaApp.Components.More.MorePage)
local AboutPage = require(Modules.LuaApp.Components.More.AboutPage)
local SettingsPage = require(Modules.LuaApp.Components.More.SettingsPage)
local EventsPage = require(Modules.LuaApp.Components.More.EventsPage)

local AgreementPage = require(Modules.LuaApp.Components.Home.AgreementPage)

local PreloadApplicationData = require(Modules.LuaApp.Thunks.PreloadApplicationData)
local NavigateToRoute = require(Modules.LuaApp.Thunks.NavigateToRoute)
local SetPlatform = require(Modules.LuaApp.Actions.SetPlatform)

local RoactAvatarEditorWrapper = require(Modules.LuaApp.Components.Avatar.RoactAvatarEditorWrapperV2)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

game:DefineFastFlag("LuaAppFixMorePageFlicker", false)
local FFlagLuaAppFixMorePageFlicker = game:GetFastFlag("LuaAppFixMorePageFlicker")

local function getDevicePlatform()
	if _G.__TESTEZ_RUNNING_TEST__ then
		return Enum.Platform.None
	end

	return UserInputService:GetPlatform()
end

local function wrapPageInScreenGui(component, pageType, navigationProps, props)
	return Roact.createElement(ScreenGuiWrap, {
		component = component,
		pageType = pageType,
		isVisible = navigationProps.isVisible,
		DisplayOrder = navigationProps.displayOrder,
		props = props,
	})
end

local DEVICE_PLATFORM = getDevicePlatform()

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local IsLuaBottomBarEnabled = FlagSettings.IsLuaBottomBarEnabled()
local IsLuaBottomBarWithText = FlagSettings.IsLuaBottomBarWithText()
local UseNewNavBar = FlagSettings.UseNewNavBar()
local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local FFlagEnableLuaChatDiscussions = settings():GetFFlag("EnableLuaChatDiscussions")

local MAX_BOTTOM_BAR_WIDTH = 600
local BOTTOM_BAR_ITEMS = {
	{
		page = AppPage.Home,
		icon = "LuaApp/icons/navbar_home",
		titleKey = "CommonUI.Features.Label.Home",
		actionType = Enum.AppShellActionType.TapHomePageTab,
		badgeCount = 0,
	},
	{
		page = AppPage.Games,
		icon = "LuaApp/icons/navbar_games",
		titleKey = "CommonUI.Features.Label.Game",
		actionType = Enum.AppShellActionType.TapGamePageTab,
		badgeCount = 0,
	},
	{
		page = AppPage.AvatarEditor,
		icon = "LuaApp/icons/navbar_avatar",
		titleKey = "CommonUI.Features.Label.Avatar",
		actionType = Enum.AppShellActionType.TapAvatarTab,
		badgeCount = 0,
	},
	{
		page = AppPage.Chat,
		icon = "LuaApp/icons/navbar_chat",
		titleKey = "CommonUI.Features.Label.Chat",
		actionType = Enum.AppShellActionType.TapChatTab,
		badgeCount = 0,
	},
	{
		page = AppPage.More,
		icon = "LuaApp/icons/navbar_more",
		titleKey = "CommonUI.Features.Label.More",
		actionType = nil,
		badgeCount = 0,
	},
}

local PageIndex = {}
for index, item in ipairs(BOTTOM_BAR_ITEMS) do
	PageIndex[item.page] = index
end

local AppContainer = Roact.Component:extend("AppContainer")

function AppContainer:init()
	local store = self.props.store
	local bottomBarAnalytics = self.props.bottomBarAnalytics
	local useHomePageWithAvatarAndPanel = self.props.useHomePageWithAvatarAndPanel
	local morePageType = self.props.morePageType

	-- Place platform info into store at initialization time
	store:dispatch(SetPlatform(DEVICE_PLATFORM))

	self._chatMaster = ChatMaster.new(store)

	self._pageConstructors = {
		[AppPage.None] = function()
			return nil
		end,
		[AppPage.Startup] = function(navigationProps)
			if FlagSettings.LuaAppLoginEnabled() then
				return wrapPageInScreenGui(StartupPage, AppPage.Startup, navigationProps)
			end
			return nil
		end,
		[AppPage.Login] = function(navigationProps)
			if FlagSettings.LuaAppLoginEnabled() and FlagSettings.EnableLuaAppLoginPageForUniversalAppDev() then
				return wrapPageInScreenGui(LoginView, AppPage.Login, navigationProps)
			end
			return nil
		end,
		[AppPage.UsernameSelectionPage] = function(navigationProps)
			return wrapPageInScreenGui(UsernameSelectionPage, AppPage.UsernameSelectionPage, navigationProps)
		end,
		[AppPage.WeChatLoginWrapper] = function(navigationProps)
			if FlagSettings.LuaAppLoginEnabled() then
				return wrapPageInScreenGui(WeChatLoginWrapper, AppPage.WeChatLoginWrapper, navigationProps)
			end
			return nil
		end,
		[AppPage.Home] = function(navigationProps)
			if useHomePageWithAvatarAndPanel then
				return wrapPageInScreenGui(HomePageWithAvatarAndWidget, AppPage.Home, navigationProps)
			else
				return wrapPageInScreenGui(HomePage, AppPage.Home, navigationProps)
			end
		end,
		[AppPage.Games] = function(navigationProps)
			return wrapPageInScreenGui(GamesHub, AppPage.Games, navigationProps)
		end,
		[AppPage.Challenge] = function(navigationProps)
			return wrapPageInScreenGui(ChallengePage, AppPage.Challenge, navigationProps)
		end,
		-- TODO: CLIAVATAR-2349 - clean up or remove China Catalog code
		[AppPage.ChinaCatalog] = function(navigationProps)
			return wrapPageInScreenGui(ChinaCatalogPage, AppPage.ChinaCatalog, navigationProps)
		end,
		[AppPage.GamesList] = function(navigationProps, detail)
			return wrapPageInScreenGui(GamesList, AppPage.GamesList, navigationProps, { sortName = detail })
		end,
		[AppPage.SearchPage] = function(navigationProps, detail)
			local parameters = detail and { searchUuid = detail } or nil
			return wrapPageInScreenGui(SearchPage, AppPage.SearchPage, navigationProps, parameters)
		end,
		[AppPage.GameDetail] = function(navigationProps, detail)
			if FlagSettings.IsLuaGameDetailsPageEnabled() then
				local parameters = detail and { universeId = detail } or nil
				return wrapPageInScreenGui(GameDetails, AppPage.GameDetail, navigationProps, parameters)
			else
				return Roact.createElement(GameDetailWrapper, {
					isVisible = navigationProps.isVisible,
					placeId = detail,
				})
			end
		end,
		-- TODO: CLIAVATAR-2349 - clean up or remove China Catalog code
		[AppPage.ChinaBundleModal] = function(navigationProps, itemId)
			local parameters = itemId and { itemId = itemId } or nil
			return wrapPageInScreenGui(ChinaBundleModal, AppPage.ChinaBundleModal, navigationProps, parameters)
		end,
		[AppPage.AvatarEditor] = function(navigationProps)
			return Roact.createElement(RoactAvatarEditorWrapper, {
				isVisible = navigationProps.isVisible,
			})
		end,
		[AppPage.Chat] = function(navigationProps, detail)
			return Roact.createElement(RoactChatWrapper, {
				chatMaster = self._chatMaster,
				isVisible = navigationProps.isVisible,
				pageType = AppPage.Chat,
				parameters = detail and { conversationId = detail } or nil
			})
		end,
		[AppPage.Discussions] = FFlagEnableLuaChatDiscussions and function(navigationProps, detail)
			return Roact.createElement(DiscussionsEntrypoint, {
				isVisible = navigationProps.isVisible,
			})
		end or nil,
		[AppPage.ShareGameToChat] = function(navigationProps, detail)
			local parameters = {
				chatMaster = self._chatMaster,
			}
			if detail then
				parameters.placeId = detail
			end
			return wrapPageInScreenGui(
				RoactGameShareWrapper, AppPage.ShareGameToChat, navigationProps, parameters)
		end,
		[AppPage.More] = function(navigationProps)
			return wrapPageInScreenGui(MorePage, AppPage.More, navigationProps, {
				morePageType = morePageType,
			})
		end,
		[AppPage.Landing] = function(navigationProps)
			return wrapPageInScreenGui(LandingPage, AppPage.Landing, navigationProps)
		end,
		[AppPage.Birthday] = function(navigationProps)
			return wrapPageInScreenGui(BirthdayPage, AppPage.Birthday, navigationProps)
		end,
		[AppPage.About] = function(navigationProps)
			return wrapPageInScreenGui(AboutPage, AppPage.About, navigationProps)
		end,
		[AppPage.Settings] = function(navigationProps)
			return wrapPageInScreenGui(SettingsPage, AppPage.Settings, navigationProps)
		end,
		[AppPage.Events] = function(navigationProps)
			return wrapPageInScreenGui(EventsPage, AppPage.Events, navigationProps)
		end,
		[AppPage.GenericWebPage] = function(navigationProps, detail, extraProps)
			return Roact.createElement(GenericWebPageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				url = detail,
				title = extraProps.title,
				titleKey = extraProps.titleKey,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
		[AppPage.YouTubePlayer] = function(navigationProps, detail, extraProps)
			return Roact.createElement(YouTubePageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				url = detail,
				title = extraProps.title,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
		[AppPage.PurchaseRobux] = function(navigationProps, _, extraProps)
			return Roact.createElement(GenericNativePageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				notificationType = NotificationType.PURCHASE_ROBUX,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
		[AppPage.AgreementPage] = function(navigationProps, detail)
			return wrapPageInScreenGui(AgreementPage, AppPage.AgreementPage, navigationProps, { pageId = detail })
		end,
		[AppPage.Notifications] = function(navigationProps, _, extraProps)
			return Roact.createElement(GenericNativePageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				notificationType = NotificationType.VIEW_NOTIFICATIONS,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
		[AppPage.MyFeed] = function(navigationProps, _, extraProps)
			return Roact.createElement(GenericNativePageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				notificationType = NotificationType.VIEW_MY_FEED,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
		[AppPage.LogoutConfirmation] = function(navigationProps, _, extraProps)
			return Roact.createElement(GenericNativePageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				notificationType = NotificationType.ACTION_LOG_OUT,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
		[AppPage.AddFriends] = function(navigationProps, _, extraProps)
			return Roact.createElement(GenericNativePageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				notificationType = NotificationType.UNIVERSAL_FRIENDS,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
		[AppPage.ViewUserProfile] = function(navigationProps, detail)
			return Roact.createElement(NativeViewUserProfileWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				userId = detail,
			})
		end,
		[AppPage.ViewProfile] = function(navigationProps, detail)
			return Roact.createElement(NativeViewProfileWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				url = detail,
			})
		end,
		[AppPage.LoginNative] = function(navigationProps, _, extraProps)
			return Roact.createElement(GenericNativePageWrapper, {
				isVisible = navigationProps.isVisible,
				DisplayOrder = navigationProps.displayOrder,
				notificationType = NotificationType.ACTION_LOG_IN,
				transitionAnimation = extraProps and extraProps.transitionAnimation or nil,
			})
		end,
	}

	self.bottomBarButtonActivated = function(page, actionType)
		local currentPage = self.props.currentPage
		local selectedBottomBarItemIndex = self.props.selectedBottomBarItemIndex
		local selectedRootPage = BOTTOM_BAR_ITEMS[selectedBottomBarItemIndex].page

		if page == currentPage then
			LuaAppEvents.ReloadPage:fire(page)
		else
			self.props.navigateToPage(page)
			if actionType then
				self.props.notificationService:ActionTaken(actionType)
			end
		end

		bottomBarAnalytics.ButtonActivated(page, selectedRootPage)
	end

	self.createBottomBarButton = function(context, selected)
		local fillDirection = nil
		local buttonComponent = UseNewNavBar and NavBarButton or UniversalBottomBarButton
		if IsLuaBottomBarWithText then
			local deviceOrientation = self.props.deviceOrientation
			if deviceOrientation == DeviceOrientationMode.Portrait then
				fillDirection = Enum.FillDirection.Vertical
			else
				fillDirection = Enum.FillDirection.Horizontal
			end
			if UseNewNavBar then
				buttonComponent = NavBarButtonWithText
			end
		end

		return Roact.createElement(buttonComponent, Cryo.Dictionary.join(context, {
			selected = selected,
			fillDirection = fillDirection,
			onActivated = self.bottomBarButtonActivated,
		}))
	end

	self.getBottomBarLayoutInfo = memoize(function(screenSize, globalGuiInset, fillDirection)
		local bottomBarWidth = screenSize.X - globalGuiInset.left - globalGuiInset.right
		local extraHorizontalPadding = math.max(bottomBarWidth - MAX_BOTTOM_BAR_WIDTH, 0)
		local bottomPadding = math.max(globalGuiInset.bottom - Constants.BOTTOM_BAR_SIZE, 0)
		if UseNewNavBar then
			-- TODO: refactor layoutInfo when we get rid of globalGuiInset
			if fillDirection == Enum.FillDirection.Vertical then
				return {
					fillDirection = fillDirection,
					background = {
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
						Size = UDim2.new(0, Constants.BOTTOM_BAR_SIZE, 0, screenSize.Y),
					},
				}
			else
				return {
					fillDirection = fillDirection,
					background = {
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.new(0, -globalGuiInset.left, 1, 0),
						Size = UDim2.new(0, screenSize.X, 0, globalGuiInset.bottom),
					},
					padding = {
						PaddingLeft = UDim.new(0, globalGuiInset.left + extraHorizontalPadding/2),
						PaddingRight = UDim.new(0, globalGuiInset.right + extraHorizontalPadding/2),
						PaddingBottom = UDim.new(0, bottomPadding),
					},
				}
			end
		else
			return {
				Background = {
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.new(0, -globalGuiInset.left, 1, 0),
					Size = UDim2.new(0, screenSize.X, 0, globalGuiInset.bottom),
				},
				Padding = {
					PaddingLeft = UDim.new(0, globalGuiInset.left + extraHorizontalPadding/2),
					PaddingRight = UDim.new(0, globalGuiInset.right + extraHorizontalPadding/2),
					PaddingBottom = UDim.new(0, bottomPadding),
				},
				TopBorder = (not UseNewAppStyle) and {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, -globalGuiInset.left, 1, 0),
					Size = UDim2.new(0, screenSize.X, 0, 1),
				} or nil,
			}
		end
	end)
end

function AppContainer:didMount()
	-- TODO remove this dependency on the entire appPolicy object
	local appPolicy = self.props.appPolicy
	local store = self.props.store
	local networking = self.props.networking
	local analytics = self.props.analytics

	if not FlagSettings.LuaAppLoginEnabled() then
		-- All preloading tasks should be put into PreloadApplicationData instead of AppContainer!
		store:dispatch(PreloadApplicationData(networking, analytics, appPolicy))
	end
end

function AppContainer:render()
	local policyUseBottomBar = self.props.policyUseBottomBar
	local screenSize = self.props.screenSize
	local globalGuiInset = self.props.globalGuiInset
	local bottomBarVisible = self.props.bottomBarVisible
	local selectedBottomBarItemIndex = self.props.selectedBottomBarItemIndex
	local bottomBarItems = self.props.bottomBarItems

	local showBottomBar = IsLuaBottomBarEnabled and policyUseBottomBar

	local alwaysRenderedPages = {
		{ name = AppPage.Home },
		{ name = AppPage.Games },
		{ name = AppPage.AvatarEditor },
		{ name = AppPage.Chat },
	}

	if policyUseBottomBar and FFlagLuaAppFixMorePageFlicker then
		table.insert(alwaysRenderedPages, { name = AppPage.More })
	end

	return Roact.createElement("Folder", {}, {
		Toast = Roact.createElement(Toast, {
			displayOrder = Constants.DisplayOrder.Toast,
		}),
		CentralOverlay = Roact.createElement(CentralOverlay, {
			displayOrder = Constants.DisplayOrder.CentralOverlay,
		}),
		BottomBar = (showBottomBar and not UseNewNavBar) and Roact.createElement(UniversalBottomBar, {
			isVisible = bottomBarVisible,
			displayOrder = Constants.DisplayOrder.BottomBar,
			layoutInfo = self.getBottomBarLayoutInfo(screenSize, globalGuiInset),
			selectedIndex = selectedBottomBarItemIndex,
			items = bottomBarItems,
			renderItem = self.createBottomBarButton,
		}),
		NavBar = (showBottomBar and UseNewNavBar) and Roact.createElement(NavBarScreenGuiWrapper, {
			isVisible = bottomBarVisible,
			displayOrder = Constants.DisplayOrder.BottomBar,
			component = NavBar,
			props = {
				layoutInfo = self.getBottomBarLayoutInfo(screenSize, globalGuiInset, Enum.FillDirection.Horizontal),
				selectedIndex = selectedBottomBarItemIndex,
				items = bottomBarItems,
				renderItem = self.createBottomBarButton,
			},
		}),
		AppRouter = Roact.createElement(AppRouter, {
			pageConstructors = self._pageConstructors,
			alwaysRenderedPages = alwaysRenderedPages,
		})
	})
end

local getBottomBarItems = memoize(function(chatBadgeCount)
	local bottomBarItems = Cryo.List.join(BOTTOM_BAR_ITEMS)
	local chatPageIndex = PageIndex[AppPage.Chat]
	bottomBarItems[chatPageIndex].badgeCount = chatBadgeCount
	return bottomBarItems
end)

AppContainer = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local routeHistory = state.Navigation.history
		local currentRoute = routeHistory[#routeHistory]
		local chatBadgeCount = state.ChatAppReducer.UnreadConversationCount

		return {
			deviceOrientation = state.DeviceOrientation,
			screenSize = state.ScreenSize,
			globalGuiInset = state.GlobalGuiInset,
			bottomBarVisible = state.TabBarVisible,
			selectedBottomBarItemIndex = PageIndex[currentRoute[1].name],
			currentPage = currentRoute[#currentRoute].name,
			bottomBarItems = getBottomBarItems(chatBadgeCount),
		}
	end,
	function(dispatch)
		return {
			navigateToPage = function(page)
				dispatch(NavigateToRoute({ { name = page } }))
			end
		}
	end
)(AppContainer)

AppContainer = RoactServices.connect({
	notificationService = AppNotificationService,
	networking = RoactNetworking,
	analytics = RoactAnalytics,
	bottomBarAnalytics = RoactAnalyticsBottomBar,
})(AppContainer)

if FFlagLuaAppPolicyRoactConnector then
	AppContainer = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			useHomePageWithAvatarAndPanel = appPolicy.getUseHomePageWithAvatarAndPanel(),
			policyUseBottomBar = appPolicy.getUseBottomBar(),
			morePageType = appPolicy.getMorePageType(),
			appPolicy = appPolicy,
		}
	end)(AppContainer)
else
	AppContainer = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			useHomePageWithAvatarAndPanel = appPolicy.IsFeatureEnabled(AppFeature.UseHomePageWithAvatarAndPanel),
			policyUseBottomBar = appPolicy.getUseBottomBar(),
			morePageType = appPolicy.getMorePageType(),
			appPolicy = appPolicy,
		}
	end)(AppContainer)
end

return AppContainer
