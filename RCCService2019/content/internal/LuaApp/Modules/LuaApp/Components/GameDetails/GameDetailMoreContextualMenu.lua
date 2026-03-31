local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")
local BaseUrl = ContentProvider.BaseUrl
local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local SetGameFavorite = require(Modules.LuaApp.Actions.SetGameFavorite)
local GamePostFavorite = require(Modules.LuaApp.Thunks.GamePostFavorite)
local SetGameFollow = require(Modules.LuaApp.Actions.SetGameFollow)
local SendGameFollow = require(Modules.LuaApp.Thunks.SendGameFollow)
local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)
local FramePopup = require(Modules.LuaApp.Components.FramePopup)
local ListCellMenu = require(Modules.LuaApp.Components.ListCellMenu)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local GameDetailsEvents = require(Modules.LuaApp.Analytics.Events.GameDetailsEvents)

local sendShareGameToChatEvent = GameDetailsEvents.ShareGameToChat
local sendFavoriteEvent = GameDetailsEvents.Favorite
local sendFollowEvent = GameDetailsEvents.Follow

local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)
local FFlagLuaHttpUrlBuilder = settings():GetFFlag("LuaHttpUrlBuilder")

local GameDetailMoreContextualMenu = Roact.PureComponent:extend("GameDetailMoreContextualMenu")

function GameDetailMoreContextualMenu:getItems()
	local closeCallback = self.props.closeCallback
	local localization = self.props.localization
	local localizedTextReport = localization:Format("Feature.GameDetails.Action.Report")
	local isFavoriteDisabeld = (self.props.isFavorite == nil)
	local isFollowDisabled = (self.props.gameFollowings == nil)

	local favoriteChecked = (self.props.isFavorite ~= nil) and self.props.isFavorite or false
	local canFollow = (self.props.gameFollowings ~= nil) and self.props.gameFollowings.canFollow or false
	local followChecked = (self.props.gameFollowings ~= nil) and self.props.gameFollowings.isFollowed or false

	local analyticsEventStream = self.props.analytics.EventStream
	local analyticsEventContext = "GameDetailMoreContextualMenu"
	local rootPlaceId = self.props.rootPlaceId

	return {
		{
			text = "Feature.Favorites.Label.Favorite",
			textChecked = "Feature.Favorites.Label.Favorite",
			textLocalization = true,
			displayIcon = "LuaApp/icons/GameDetails/favoriteOff",
			displayIconChecked = "LuaApp/icons/GameDetails/favoriteOn",
			checked = favoriteChecked,
			disabled = isFavoriteDisabeld,
			onActivated = function()
				if isFavoriteDisabeld then
					return
				end
				local universeId = self.props.universeId
				local gamePostFavorite = self.props.gamePostFavorite
				local setGameFavorite = self.props.setGameFavorite
				local networking = self.props.networking
				local isFavorite = self.props.isFavorite
				setGameFavorite(universeId, not isFavorite)
				gamePostFavorite(networking, universeId, not isFavorite)
				sendFavoriteEvent(analyticsEventStream, analyticsEventContext, rootPlaceId, not isFavorite)
			end
		},
		{
			text =  "Feature.GameDetails.Label.Follow",
			textChecked = "Feature.GameDetails.Label.Follow",
			textLocalization = true,
			displayIcon = "LuaApp/icons/GameDetails/notificationsOff",
			displayIconChecked = "LuaApp/icons/GameDetails/notificationsOn",
			checked = followChecked,
			disabled = isFollowDisabled,
			onActivated = function()
				if isFollowDisabled then
					return
				end
				local setCurrentToastMessage = self.props.setCurrentToastMessage
				local isFollowed = self.props.gameFollowings.isFollowed
				if not canFollow and not isFollowed then
					setCurrentToastMessage({
						toastType = ToastType.GameFollowError,
						toastMessage = "Feature.GameFollows.TooltipFollowLimitReached",
					})
					return
				end
				local universeId = self.props.universeId
				local sendGameFollow = self.props.sendGameFollow
				local setGameFollow = self.props.setGameFollow
				local networking = self.props.networking
				setGameFollow(universeId, not isFollowed)
				sendGameFollow(networking, universeId, not isFollowed)
				sendFollowEvent(analyticsEventStream, analyticsEventContext, rootPlaceId, not isFollowed)
			end
		},
		{
			text = "Feature.GameDetails.Action.InviteFriends",
			textLocalization = true,
			displayIcon = "LuaApp/icons/GameDetails/invite",
			onActivated = function()
				local placeId = self.props.rootPlaceId
				self.props.navigateDown({
					name = AppPage.ShareGameToChat,
					detail = placeId,
				})
				sendShareGameToChatEvent(analyticsEventStream, analyticsEventContext, rootPlaceId)
				closeCallback()
			end
		},
		{
			text = localizedTextReport,
			displayIcon = "LuaApp/icons/GameDetails/feedback",
			onActivated = function()
				local placeId = self.props.rootPlaceId
				local linkPage = BaseUrl .. "/abusereport/asset?id=" .. placeId

				if FFlagLuaHttpUrlBuilder then
					linkPage = UrlBuilder.game.report({
						placeId = placeId,
					})
				end

				self.props.navigateDown({
					name = AppPage.GenericWebPage,
					detail = linkPage,
					extraProps = {
						title = localizedTextReport,
					},
				})

				closeCallback()
			end
		},
	}
end

function GameDetailMoreContextualMenu:didMount()
	-- TODO: MOBLUAPP-1098 After router-side fix is done, please REMOVE this temporary fix.
	local currentPage = self.props.currentPage
	local closeCallback = self.props.closeCallback
	if currentPage ~= AppPage.GameDetail then
		closeCallback()
	end
end

function GameDetailMoreContextualMenu:render()
	local items = self:getItems()
	local closeCallback = self.props.closeCallback
	local menuPosition = self.props.menuPosition
	local menuWidth= self.props.menuWidth
	-- TODO: we should remove the line below if theme is globally applied
	self._context.AppTheme = self.props.theme

	return Roact.createElement(FramePopup, {
		enableCancelButton = false,
		onCancel = closeCallback,
		contentPosition = menuPosition,
	}, {
		ListCellMenu = Roact.createElement(ListCellMenu, {
			items = items,
			width = menuWidth,
		})
	})
end

GameDetailMoreContextualMenu = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		return {
			rootPlaceId = state.GameDetails[props.universeId].rootPlaceId,
			isFavorite = state.GameFavorites[props.universeId],
			gameFollowings = state.GameFollowings[props.universeId],
			currentPage = currentRoute[#currentRoute].name,
		}
	end,
	function(dispatch)
		return {
			closeCallback = function()
				dispatch(CloseCentralOverlay())
			end,
			gamePostFavorite = function(networking, universeId, isFavorite)
				return dispatch(GamePostFavorite(networking, universeId, isFavorite))
			end,
			setGameFavorite = function(universeId, isFavorite)
				return dispatch(SetGameFavorite(universeId, isFavorite))
			end,
			sendGameFollow = function(networking, universeId, isFollowed)
				return dispatch(SendGameFollow(networking, universeId, isFollowed))
			end,
			setGameFollow = function(universeId, isFollowed)
				return dispatch(SetGameFollow(universeId, isFollowed))
			end,
			setCurrentToastMessage = function(toastMessage)
				return dispatch(SetCurrentToastMessage(toastMessage))
			end,
			navigateDown = function(page)
				return dispatch(NavigateDown(page))
			end,
		}
	end
)(GameDetailMoreContextualMenu)

return RoactServices.connect({
	networking = RoactNetworking,
	localization = RoactLocalization,
	analytics = RoactAnalytics,
})(GameDetailMoreContextualMenu)
