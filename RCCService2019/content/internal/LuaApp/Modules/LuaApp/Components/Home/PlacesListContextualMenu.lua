local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalyticsHomePage = require(Modules.LuaApp.Services.RoactAnalyticsHomePage)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local Constants = require(Modules.LuaApp.Constants)
local JoinableFriendsList = require(Modules.LuaApp.Components.Home.JoinableFriendsList)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local FitChildren = require(Modules.LuaApp.FitChildren)
local SetTabBarVisible = require(Modules.LuaApp.Actions.SetTabBarVisible)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)
local UserActiveGame = require(Modules.LuaApp.Components.Home.UserActiveGame)
local FeatureContext = require(Modules.LuaApp.Enum.FeatureContext)
local ApiFetchGamesDataByPlaceIds = require(Modules.LuaApp.Thunks.ApiFetchGamesDataByPlaceIds)
local FormBasedContextualMenu = require(Modules.LuaApp.Components.FormBasedContextualMenu)

local FramePopOut = require(Modules.LuaApp.Components.FramePopOut)
local FramePopup = require(Modules.LuaApp.Components.FramePopup)

local FFlagRealtimeFriendsContextualMenuRefactor = settings():GetFFlag("RealtimeFriendsContextualMenuRefactor")

local WIDE_MENU_VERTICAL_PADDING_TOP = 50
local WIDE_MENU_VERTICAL_PADDING_BOTTOM = 10

local MENU_WIDTH_ON_WIDE = Constants.DEFAULT_WIDE_CONTEXTUAL_MENU__WIDTH
local CANCEL_HEIGHT = Constants.DEFAULT_CONTEXTUAL_MENU_CANCEL_HEIGHT
local BOTTOM_BAR_SIZE = Constants.BOTTOM_BAR_SIZE

local PlacesListContextualMenu = Roact.PureComponent:extend("PlacesListContextualMenu")

function PlacesListContextualMenu:init()
	local analytics = self.props.analytics
	local placeId = self.props.game.placeId
	local formFactor = self.props.formFactor
	local setTabBarVisible = self.props.setTabBarVisible
	local tabBarVisible = self.props.tabBarVisible

	analytics.reportOpenModalFromGameTileForPlacesList(placeId)

	local tabBarVisibilityChanged = false
	if not FFlagRealtimeFriendsContextualMenuRefactor then
		if formFactor == FormFactor.COMPACT then
			setTabBarVisible(false)
			tabBarVisibilityChanged = true
		end
	end

	self.state = {
		originalTabBarVisibility = tabBarVisible, -- TODO Remove when removing RealtimeFriendsContextualMenuRefactor
		tabBarVisibilityChanged = tabBarVisibilityChanged, -- TODO Remove when removing RealtimeFriendsContextualMenuRefactor
		headerHeight = 0,
	}

	self.headerRef = Roact.createRef()
	self.updateHeaderHeight = function()
		self:setState({
			headerHeight = self.headerRef.current and self.headerRef.current.AbsoluteSize.Y or 0,
		})
	end
end

function PlacesListContextualMenu:didMount()
	local requestGameData = self.props.requestGameData
	local networking = self.props.networking
	local placeId = self.props.game.placeId

	requestGameData(networking, placeId)

	self.headerSizeChanged = self.headerRef.current and
		self.headerRef.current:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.updateHeaderHeight()
	end)
	self.updateHeaderHeight()
end

function PlacesListContextualMenu:render()
	local game = self.props.game
	local anchorSpaceSize = self.props.anchorSpaceSize
	local anchorSpacePosition = self.props.anchorSpacePosition
	local screenSize = self.props.screenSize
	local formFactor = self.props.formFactor
	local topBarHeight = self.props.topBarHeight
	local closeCallback = self.props.closeCallback

	local headerHeight = self.state.headerHeight

	local isWideView = formFactor == FormFactor.WIDE
	local itemWidth = isWideView and MENU_WIDTH_ON_WIDE or screenSize.X
	local modalComponent = isWideView and FramePopOut or FramePopup

	local screenHeightOffsetTop = topBarHeight + WIDE_MENU_VERTICAL_PADDING_TOP
	local screenHeightOffsetBottom = BOTTOM_BAR_SIZE + WIDE_MENU_VERTICAL_PADDING_BOTTOM

	local listMaxHeight = isWideView and screenSize.Y - screenHeightOffsetTop - screenHeightOffsetBottom - headerHeight
									or screenSize.Y * .5 - CANCEL_HEIGHT

	if FFlagRealtimeFriendsContextualMenuRefactor then
		return Roact.createElement(FormBasedContextualMenu, {
			anchorSpaceSize = anchorSpaceSize,
			anchorSpacePosition = anchorSpacePosition,
			itemWidth = itemWidth,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),
			Header = Roact.createElement(UserActiveGame, {
				layoutOrder = 1,
				width = itemWidth,
				universeId = game.universeId,
				dismissContextualMenu = closeCallback,
				featureContext = FeatureContext.PlacesList,
				[Roact.Ref] = self.headerRef,
			}),
			Divider = Roact.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Constants.Color.GRAY4,
				BorderSizePixel = 0,
			}),
			JoinableFriendsList = Roact.createElement(JoinableFriendsList, {
				LayoutOrder = 3,
				maxHeight = listMaxHeight,
				width = itemWidth,
				universeId = game.universeId,
			}),
		})
	else
		return Roact.createElement(modalComponent, {
			onCancel = closeCallback,
			itemWidth = itemWidth,
			parentShape = {
				x = anchorSpacePosition.X,
				y = anchorSpacePosition.Y,
				width = anchorSpaceSize.X,
				height = anchorSpaceSize.Y,
				parentWidth = screenSize.X,
				parentHeight = screenSize.Y - screenHeightOffsetBottom,
			},
		}, {
			Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				fitAxis = FitChildren.FitAxis.Height,
				Size = UDim2.new(0, itemWidth, 0, 0),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
				}),
				Header = Roact.createElement(UserActiveGame, {
					layoutOrder = 1,
					width = itemWidth,
					universeId = game.universeId,
					dismissContextualMenu = closeCallback,
					featureContext = FeatureContext.PlacesList,
					[Roact.Ref] = self.headerRef,
				}),
				Divider = Roact.createElement("Frame", {
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = Constants.Color.GRAY4,
					BorderSizePixel = 0,
				}),
				JoinableFriendsList = Roact.createElement(JoinableFriendsList, {
					LayoutOrder = 3,
					maxHeight = listMaxHeight,
					width = itemWidth,
					universeId = game.universeId,
				}),
			}),
		})
	end
end

if not FFlagRealtimeFriendsContextualMenuRefactor then
	function PlacesListContextualMenu:didUpdate(prevProps, prevState)
		local closeCallback = self.props.closeCallback

		if prevProps.currentRoute ~= self.props.currentRoute then
			closeCallback()
		end
	end
end

function PlacesListContextualMenu:willUnmount()
	if not FFlagRealtimeFriendsContextualMenuRefactor then
		local setTabBarVisible = self.props.setTabBarVisible
		local tabBarVisibilityChanged = self.state.tabBarVisibilityChanged
		local originalTabBarVisibility = self.state.originalTabBarVisibility

		if tabBarVisibilityChanged then
			setTabBarVisible(originalTabBarVisibility)
		end
	end

	if self.headerSizeChanged then
		self.headerSizeChanged:Disconnect()
	end
end

PlacesListContextualMenu = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			tabBarVisible = state.TabBarVisible, -- TODO Remove when removing RealtimeFriendsContextualMenuRefactor
			topBarHeight = state.TopBar.topBarHeight,
			formFactor = state.FormFactor,
			screenSize = state.ScreenSize,
			routeHistory = state.Navigation.history, -- TODO Remove when removing RealtimeFriendsContextualMenuRefactor
		}
	end,
	function(dispatch)
		return {
			requestGameData = function(networking, placeId)
				return dispatch(ApiFetchGamesDataByPlaceIds(networking, { placeId }))
			end,
			setTabBarVisible = function(visible) -- TODO Remove when removing RealtimeFriendsContextualMenuRefactor
				return dispatch(SetTabBarVisible(visible))
			end,
			closeCallback = function()
				dispatch(CloseCentralOverlay())
			end,
		}
	end
)(PlacesListContextualMenu)

PlacesListContextualMenu = RoactServices.connect({
	analytics = RoactAnalyticsHomePage,
	networking = RoactNetworking,
})(PlacesListContextualMenu)

return PlacesListContextualMenu
