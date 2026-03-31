local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Common = Modules.Common
local LuaApp = Modules.LuaApp

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local RoactAnalyticsHomePage = require(Modules.LuaApp.Services.RoactAnalyticsHomePage)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppPage = require(Modules.LuaApp.AppPage)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local Promise = require(Modules.LuaApp.Promise)
local RefreshScrollingFrame = require(Modules.LuaApp.Components.RefreshScrollingFrame)
local RefreshScrollingFrameNew = require(Modules.LuaApp.Components.RefreshScrollingFrameNew)
local UserCarouselEntry = require(LuaApp.Components.Home.UserCarouselEntry)
local HomeHeaderUserInfo = require(LuaApp.Components.Home.HomeHeaderUserInfo)
local UserInfoWidget = require(LuaApp.Components.Home.UserInfoWidget)
local MyFeedButton = require(LuaApp.Components.Home.MyFeedButton)
local TopBar = require(LuaApp.Components.TopBar)
local GameCarousels = require(LuaApp.Components.GameCarousels)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local FreezableUserCarousel = require(LuaApp.Components.Home.FreezableUserCarousel)
local HomeFTUEGameGrid = require(LuaApp.Components.Home.HomeFTUEGameGrid)
local PlacesList = require(LuaApp.Components.Home.PlacesList)
local LocalizedSectionHeaderWithSeeAll = require(Modules.LuaApp.Components.LocalizedSectionHeaderWithSeeAll)
local Constants = require(LuaApp.Constants)
local FitChildren = require(LuaApp.FitChildren)
local Functional = require(Common.Functional)
local Immutable = require(Common.Immutable)
local memoize = require(Common.memoize)
local TokenRefreshComponent = require(Modules.LuaApp.Components.TokenRefreshComponent)
local NotificationType = require(LuaApp.Enum.NotificationType)
local AvatarThumbnailTypes = require(CorePackages.AppTempCommon.LuaApp.Enum.AvatarThumbnailTypes)
local sortFriendsByPresence = require(LuaApp.sortFriendsByPresence)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local Url = require(Modules.LuaApp.Http.Url)
local RefreshGameSorts = require(Modules.LuaApp.Thunks.RefreshGameSorts)
local ApiFetchUsersFriends = require(Modules.LuaApp.Thunks.ApiFetchUsersFriends)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local FetchHomePageData = require(Modules.LuaApp.Thunks.FetchHomePageData)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

local UrlBuilder = require(LuaApp.Http.UrlBuilder)
local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")

local MAX_FRIENDS_IN_CAROUSEL = tonumber(settings():GetFVariable("LuaHomeMaxFriends")) or 0
local FFlagPeopleListV1 = FlagSettings.IsPeopleListV1Enabled()
local GetEnableFriendFooterOnHomePage = require(CorePackages.AppTempCommon.LuaApp.Flags.GetEnableFriendFooterOnHomePage)
local FFlagLuaAppMakeAvatarThumbnailTypesEnum = settings():GetFFlag("LuaAppMakeAvatarThumbnailTypesEnum")
local FFlagMoveMyFeedToMore = FlagSettings.MoveMyFeedToMore()
local useNewAppStyle = FlagSettings.UseNewAppStyle()
local UseNewRefreshScrollingFrame = FlagSettings.UseNewRefreshScrollingFrame()

local SIDE_PADDING = 15
local SECTION_PADDING = 15
local CAROUSEL_PADDING = Constants.GAME_CAROUSEL_PADDING
local CAROUSEL_PADDING_DIM = UDim.new(0, CAROUSEL_PADDING)

local LAYOUT_PADDING = 24

local FRIEND_SECTION_MARGIN = 15 - UserCarouselEntry.horizontalPadding()

local FEED_SECTION_PADDING = 60
local FEED_SECTION_PADDING_TOP = FEED_SECTION_PADDING - CAROUSEL_PADDING
local FEED_SECTION_PADDING_BOTTOM = FEED_SECTION_PADDING
local FEED_BUTTON_HEIGHT = 32
local FEED_SECTION_HEIGHT = FEED_SECTION_PADDING_TOP + FEED_BUTTON_HEIGHT + FEED_SECTION_PADDING_BOTTOM

local TOP_MARGIN = 24
local COMPACT_LEFT_MARGIN = 24
local WIDE_LEFT_MARGIN = 48
local BOTTOM_MARGIN = 48
local CARD_WIDTH = 80
local CARD_HEIGHT = 105

local AVATAR_THUMBNAIL_REQUEST = Constants.AvatarThumbnailRequests.USER_CAROUSEL_HEAD_SHOT

local function Spacer(props)
	local height = props.height
	local layoutOrder = props.LayoutOrder

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
	})
end

local HomePage = Roact.PureComponent:extend("HomePage")

function HomePage:init()
	self.refresh = function()
		return self.props.refresh(self.props.networking, self.props.localUserModel)
	end

	self.fetchHomePageData = function()
		return self.props.fetchHomePageData(self.props.networking, self.props.appAnalytics, self.props.localUserId)
	end

	self.onUsernameActivated = function()
		local localUserId = self.props.localUserModel.id
		local navigateDown = self.props.navigateDown
		navigateDown({
			name = AppPage.ViewUserProfile,
			detail = localUserId,
		})
	end

	self.onSeeAllFriends = function()
		local url
		if FFlagLuaAppHttpsWebViews then
			url = UrlBuilder.static.friends()
		else
			url = string.format("%susers/friends", Url.BASE_URL)
		end
		self.props.guiService:BroadcastNotification(url, NotificationType.VIEW_PROFILE)
	end
end


function HomePage:getFriendElement()
	local friendCount = self.props.friendCount
	local friends = self.props.friends
	local formFactor = self.props.formFactor
	local guiService = self.props.guiService

	local friendSectionHeight = UserCarouselEntry.height(formFactor)
	local userEntryWidth = UserCarouselEntry.getCardWidth(formFactor)
	local friendSectionMargin = 15 - UserCarouselEntry.horizontalPadding()

	local function createUserEntry(user, count)
		local avatarThumbnailType
		if FFlagLuaAppMakeAvatarThumbnailTypesEnum then
			avatarThumbnailType = AvatarThumbnailTypes.HeadShot
		else
			avatarThumbnailType = Constants.AvatarThumbnailTypes.HeadShot
		end

		return Roact.createElement(UserCarouselEntry, {
			totalWidth = CARD_WIDTH,
			totalHeight = CARD_HEIGHT,
			user = user,
			formFactor = formFactor,
			count = count,
			highlightColor = Constants.Color.WHITE,
			thumbnailType = avatarThumbnailType,
		})
	end

	if FFlagPeopleListV1 or useNewAppStyle then
		return Roact.createElement(FreezableUserCarousel, {
			LayoutOrder = 4,
			friends = friends,
			guiService = guiService,
			friendCount = friendCount,
			formFactor = formFactor,
		})
	end

	if #friends > 0 then
		local canvasWidth = #friends * userEntryWidth + friendSectionMargin

		return Roact.createElement(FitChildren.FitFrame, {
			Size = UDim2.new(1, 0, 0, 0),
			fitAxis = FitChildren.FitAxis.Height,
			BackgroundTransparency = 1,
			LayoutOrder = 4,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Container = Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				fitFields = {
					Size = FitChildren.FitAxis.Height,
				},
			}, {
				SidePadding = Roact.createElement("UIPadding", {
					PaddingLeft = CAROUSEL_PADDING_DIM,
					PaddingRight = CAROUSEL_PADDING_DIM,
				}),
				Header = Roact.createElement(LocalizedSectionHeaderWithSeeAll, {
					text = {
						"Feature.Home.HeadingFriends",
						friendCount = friendCount,
					},
					LayoutOrder = 1,
					onSelected = self.onSeeAllFriends
				}),
			}),
			CarouselFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, friendSectionHeight),
				BackgroundColor3 = Constants.Color.WHITE,
				BorderSizePixel = 0,
				LayoutOrder = 2,
			}, {
				Carousel = Roact.createElement("ScrollingFrame", {
					Size = UDim2.new(1, 0, 1, 0),
					ScrollBarThickness = 0,
					BackgroundTransparency = 1,
					CanvasSize = UDim2.new(0, canvasWidth, 1, 0),
					ScrollingDirection = Enum.ScrollingDirection.X,
					ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
				}, Immutable.JoinDictionaries(Functional.Map(friends, createUserEntry), {
					listLayout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
					}),
					leftAlignSpacer = Roact.createElement("UIPadding", {
						PaddingRight = UDim.new(0, FRIEND_SECTION_MARGIN),
						PaddingLeft = UDim.new(0, FRIEND_SECTION_MARGIN),
					}),
				})),
			}),
		})
	end
end

function HomePage:renderScrollingArea(offset, stylePalette)
	local LuaHomePageEnablePlacesListV1 = FlagSettings.IsPlacesListV1Enabled()
	local EnableFriendFooterOnHomePage = GetEnableFriendFooterOnHomePage()
	local localUserModel = self.props.localUserModel
	local friends = self.props.friends
	local formFactor = self.props.formFactor
	local isFTUE = self.props.isFTUE
	local analytics = self.props.analytics
	local friendElement = self:getFriendElement()

	local footerSection
	local titleSection
	local layout
	local leftMargin = 0
	local topMargin = 0
	local bottomMargin = 0
	local backgroundColor = Constants.Color.GRAY4
	local backgroundTransparency = 0
	if stylePalette then
		local theme = stylePalette.Theme
		backgroundColor = theme.BackgroundDefault.Color
		backgroundTransparency = theme.BackgroundDefault.Transparency
		layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, LAYOUT_PADDING),
		})
		titleSection = localUserModel and Roact.createElement(UserInfoWidget, {
			layoutOrder = 1,
			localUserModel = localUserModel,
			onActivated = self.onUsernameActivated,
			formFactor = formFactor,
		})
		topMargin = TOP_MARGIN
		bottomMargin = BOTTOM_MARGIN
		if formFactor == FormFactor.COMPACT then
			leftMargin = COMPACT_LEFT_MARGIN
		else
			leftMargin = WIDE_LEFT_MARGIN
		end
	else
		layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		titleSection = localUserModel and Roact.createElement(HomeHeaderUserInfo, {
			sidePadding = SIDE_PADDING,
			sectionPadding = SECTION_PADDING,
			LayoutOrder = 2,
			localUserModel = localUserModel,
			formFactor = formFactor,
		})
		footerSection = not FFlagMoveMyFeedToMore and Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, FEED_SECTION_HEIGHT),
			BackgroundTransparency = 1,
			LayoutOrder = 6,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			MyFeedPadding1 = Roact.createElement(Spacer, {
				height = FEED_SECTION_PADDING_TOP,
				LayoutOrder = 1,
			}),
			MyFeedButton = Roact.createElement(MyFeedButton, {
				Size = UDim2.new(1, 0, 0, FEED_BUTTON_HEIGHT),
				LayoutOrder = 2,
			}),
			MyFeedPadding2 = Roact.createElement(Spacer, {
				height = FEED_SECTION_PADDING_BOTTOM,
				LayoutOrder = 3,
			}),
		})
	end

	return Roact.createElement(UseNewRefreshScrollingFrame and
		RefreshScrollingFrameNew or RefreshScrollingFrame, {
		Position = UDim2.new(0, 0, 0, offset),
		Size = UDim2.new(1, 0, 1, -offset),
		CanvasSize = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		refresh = self.refresh,
		parentAppPage = AppPage.Home,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, topMargin),
			PaddingLeft = UDim.new(0, leftMargin),
			PaddingBottom = UDim.new(0, bottomMargin),
		}),
		Layout = layout,
		TitleSection = titleSection,
		FriendSection = friendElement,
		GameDisplay = isFTUE and Roact.createElement(HomeFTUEGameGrid, {
			LayoutOrder = 5,
			hasTopPadding = #friends > 0,
		}) or LuaHomePageEnablePlacesListV1 and Roact.createElement(PlacesList, {
			LayoutOrder = 5,
			hasTopPadding = #friends > 0,
		}) or Roact.createElement(GameCarousels, {
			gameSortGroup = Constants.GameSortGroups.HomeGames,
			LayoutOrder = 5,
			analytics = analytics,
			friendFooterEnabled = EnableFriendFooterOnHomePage,
		}),
		FooterSection = footerSection
	})
end

function HomePage:render()
	local topBarHeight = self.props.topBarHeight
	local homePageDataStatus = self.props.homePageDataStatus

	local renderFunction = function(stylePalette)
		local backgroundColor = Constants.Color.GRAY4
		local backgroundTransparency = 0
		if stylePalette then
			local theme = stylePalette.Theme
			backgroundColor = theme.BackgroundDefault.Color
			backgroundTransparency = theme.BackgroundDefault.Transparency
		end
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
		}, {
			TokenRefreshComponent = Roact.createElement(TokenRefreshComponent, {
				sortToRefresh = Constants.GameSortGroups.HomeGames,
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
					dataStatus = homePageDataStatus,
					onRetry = self.fetchHomePageData,
					debugName = "HomePage",
					renderOnLoaded = function()
						return self:renderScrollingArea(0, stylePalette)
					end,
				}),
			}),
		})
	end
	if useNewAppStyle then
		return withStyle(renderFunction)
	else
		return renderFunction(nil)
	end
end

local selectFriends = memoize(function(users)
	local allFriends = {}
	for _, user in pairs(users) do
		if user.isFriend then
			allFriends[#allFriends + 1] = user
		end
	end

	table.sort(allFriends, sortFriendsByPresence)

	if FFlagPeopleListV1 then
		return allFriends
	else
		local filteredFriends = {}
		for index, user in ipairs(allFriends) do
			filteredFriends[index] = user
			if index >= MAX_FRIENDS_IN_CAROUSEL then
				break
			end
		end

		return filteredFriends
	end
end)

local selectLocalUser = memoize(function(users, id)
	return users[id]
end)

local selectIsFTUE = function(sortGroups)
	local homeSortGroup = Constants.GameSortGroups.HomeGames
	local sorts = sortGroups[homeSortGroup].sorts

	return #sorts == 1
end

HomePage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			friends = selectFriends(
				state.Users
			),
			localUserId = state.LocalUserId,
			localUserModel = selectLocalUser(state.Users, state.LocalUserId),
			isFTUE = selectIsFTUE(state.GameSortGroups),
			formFactor = state.FormFactor,
			friendCount = state.FriendCount,
			topBarHeight = state.TopBar.topBarHeight,
			homePageDataStatus = state.Startup.HomePageDataStatus,
		}
	end,
	function(dispatch)
		return {
			refresh = function(networking, localUserModel)
				local LuaHomePageEnablePlacesListV1 = FlagSettings.IsPlacesListV1Enabled()
				local fetchPromises = {}

				table.insert(fetchPromises, dispatch(ApiFetchUsersFriends(
					networking,
					localUserModel.id,
					AVATAR_THUMBNAIL_REQUEST
				)))

				if not LuaHomePageEnablePlacesListV1 then
					table.insert(fetchPromises, dispatch(RefreshGameSorts(
						networking,
						{ Constants.GameSortGroups.HomeGames },
						nil,
						nil
					)))
				end

				if LuaHomePageEnablePlacesListV1 then
					table.insert(fetchPromises, dispatch(RefreshGameSorts(
						networking,
						{ Constants.GameSortGroups.UnifiedHomeSorts },
						nil,
						{ maxRows = Constants.UNIFIED_HOME_GAMES_FETCH_COUNT }
					)))
				end

				return Promise.all(fetchPromises):andThen(
					function(results)
						return Promise.resolve(results)
					end,
					function(err)
						dispatch(SetNetworkingErrorToast(err))
						return Promise.reject(err)
					end
				)
			end,
			fetchHomePageData = function(networking, analytics, localUserId)
				return dispatch(FetchHomePageData(networking, analytics, localUserId))
			end,
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(HomePage)

return RoactServices.connect({
	networking = RoactNetworking,
	appAnalytics = RoactAnalytics,
	analytics = RoactAnalyticsHomePage,
	guiService = AppGuiService
})(HomePage)
