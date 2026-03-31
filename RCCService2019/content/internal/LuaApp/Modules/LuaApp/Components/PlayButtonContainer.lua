local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local LaunchErrorLocalizationKeys = require(Modules.LuaApp.LaunchErrorLocalizationKeys)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local PlayabilityStatusEnum = require(Modules.LuaApp.Enum.PlayabilityStatus)
local PlayButtonStates = require(Modules.LuaApp.Enum.PlayButtonStates)
local ReasonForNotVoteable = require(Modules.LuaApp.Enum.ReasonForNotVoteable)
local LaunchGame = require(Modules.LuaApp.Util.LaunchGame)

local PlayButton = require(Modules.LuaApp.Components.PlayButton)

local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local ClearUserGameVotes = require(Modules.LuaApp.Actions.ClearUserGameVotes)
local ApiFetchGameDetails = require(Modules.LuaApp.Thunks.ApiFetchGameDetails)
local OpenCentralOverlayForPurchaseGame = require(Modules.LuaApp.Thunks.OpenCentralOverlayForPurchaseGame)
local FetchGamePlayabilityAndProductInfo = require(Modules.LuaApp.Thunks.FetchGamePlayabilityAndProductInfo)

local gamePlayIntentEvent = require(Modules.LuaApp.Analytics.Events.gamePlayIntent)

local DEFAULT_UNPLAYABLE_MESSAGE = "Feature.GamePage.QuickLaunch.LaunchError.UnplayableOtherReason"

local PlayButtonContainer = Roact.PureComponent:extend("PlayButtonContainer")

function PlayButtonContainer:init()
	self.launchGame = function()
		local placeId = self.props.placeId
		local userGameVotes = self.props.userGameVotes
		gamePlayIntentEvent(self.props.analytics.EventStream, "PlayButton", placeId, tonumber(placeId))
		LaunchGame(placeId)
		if userGameVotes and userGameVotes.reasonForNotVoteable == ReasonForNotVoteable.PlayGame then
			-- Need to re-fetch userGameVotes data if player has played the game
			-- Will use the ExitGame signal to re-fetch later when it's implemented
			-- Right now clear user vote so that we would fetch again when game details page didMount again
			self.props.clearUserGameVotes(self.props.universeId)
		end
	end

	self.setLaunchError = function()
		local placeId = self.props.placeId
		local playabilityStatus = self.props.playabilityStatus
		local gameProductInfo = self.props.gameProductInfo
		local setCurrentToastMessage = self.props.setCurrentToastMessage

		local toastMessage
		if placeId == nil or
			(playabilityStatus.playabilityStatus == PlayabilityStatusEnum.PurchaseRequired and
			(gameProductInfo == nil or gameProductInfo.isForSale == false)) then
			toastMessage = DEFAULT_UNPLAYABLE_MESSAGE
		else
			toastMessage = LaunchErrorLocalizationKeys[playabilityStatus.playabilityStatus]
		end

		setCurrentToastMessage({
			toastType = ToastType.PlayButtonError,
			toastMessage = toastMessage,
		})
	end

	self.onActivated = function()
		local playButtonState = self.props.playButtonState

		if playButtonState == PlayButtonStates.Playable then
			self.launchGame()
		elseif playButtonState == PlayButtonStates.UnplayableOther or
			playButtonState == PlayButtonStates.Private then
			self.setLaunchError()
		elseif playButtonState == PlayButtonStates.PaidAccess then
			local theme = self._context.AppTheme
			local universeId = self.props.universeId
			local gameName = self.props.gameName
			local gameProductInfo = self.props.gameProductInfo
			local openPurchaseGameOverlay = self.props.openPurchaseGameOverlay
			local price = gameProductInfo.price
			local productId = gameProductInfo.productId
			local sellerId = gameProductInfo.sellerId
			local currentPage = self.props.currentPage

			openPurchaseGameOverlay(universeId, gameName, price, productId, sellerId, theme, { currentPage })
		elseif playButtonState == PlayButtonStates.Loading then
			return
		else
			error("invalid play button state!")
		end
	end
end

function PlayButtonContainer:render()
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local font = self.props.Font
	local playButtonState = self.props.playButtonState
	local gameProductInfo = self.props.gameProductInfo
	local price = gameProductInfo and gameProductInfo.price or 0

	return Roact.createElement(PlayButton, {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		Font = font,
		playButtonState = playButtonState,
		price = price,
		onActivated = self.onActivated,
	})
end

local function selectPlayButtonState(playabilityAndProductInfoFetchingStatus, gameDetailFetchingStatus,
	playabilityStatus, gameDetail, gameProductInfo)
	local playButtonState

	local isLoading = playabilityAndProductInfoFetchingStatus == RetrievalStatus.NotStarted or
		playabilityAndProductInfoFetchingStatus == RetrievalStatus.Fetching or
		gameDetailFetchingStatus == RetrievalStatus.NotStarted or
		gameDetailFetchingStatus == RetrievalStatus.Fetching

	if isLoading then
		playButtonState = PlayButtonStates.Loading
	else
		-- We can only launch if we have the placeId, which is contained in the GameDetail model
		if gameDetail ~= nil then
			if playabilityAndProductInfoFetchingStatus == RetrievalStatus.Done and playabilityStatus ~= nil then
				if playabilityStatus.isPlayable == true then
					playButtonState = PlayButtonStates.Playable
				elseif playabilityStatus.playabilityStatus == PlayabilityStatusEnum.UniverseRootPlaceIsPrivate then
					playButtonState = PlayButtonStates.Private
				elseif playabilityStatus.playabilityStatus == PlayabilityStatusEnum.PurchaseRequired and
					gameProductInfo ~= nil and gameProductInfo.isForSale == true then
					playButtonState = PlayButtonStates.PaidAccess
				else
					playButtonState = PlayButtonStates.UnplayableOther
				end
			-- If we can't fetch the playability status/product info for some reason, allow game launch anyway.
			-- There will be in-game errors if the user cannot play this game.
			else
				playButtonState = PlayButtonStates.Playable
			end
		else
			playButtonState = PlayButtonStates.UnplayableOther
		end
	end

	return playButtonState
end

PlayButtonContainer = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gameDetail = state.GameDetails[props.universeId]
		local playabilityStatus = state.PlayabilityStatus[props.universeId]
		local gameProductInfo = state.GamesProductInfo[props.universeId]
		local playabilityAndProductInfoFetchingStatus =
			FetchGamePlayabilityAndProductInfo.GetFetchingStatus(state, props.universeId)

		local gameDetailFetchingStatus = ApiFetchGameDetails.GetFetchingStatus(state, props.universeId)

		local currentRoute = state.Navigation.history[#state.Navigation.history]

		return {
			playabilityStatus = playabilityStatus,
			placeId = gameDetail and gameDetail.rootPlaceId or nil,
			gameName = gameDetail and gameDetail.name or nil,
			gameProductInfo = gameProductInfo,
			playButtonState = selectPlayButtonState(playabilityAndProductInfoFetchingStatus, gameDetailFetchingStatus,
				playabilityStatus, gameDetail, gameProductInfo),
			userGameVotes = state.UserGameVotes[props.universeId],
			currentPage = currentRoute[#currentRoute].name,
		}
	end,
	function(dispatch)
		return {
			setCurrentToastMessage = function(toastMessage)
				return dispatch(SetCurrentToastMessage(toastMessage))
			end,
			clearUserGameVotes = function(universeId)
				return dispatch(ClearUserGameVotes(universeId))
			end,
			openPurchaseGameOverlay = function(universeId, gameName, price, productId, sellerId, theme, pageFilter)
				return dispatch(OpenCentralOverlayForPurchaseGame(universeId,
					gameName, price, productId, sellerId, theme, pageFilter))
			end,
		}
	end
)(PlayButtonContainer)


PlayButtonContainer = RoactServices.connect({
	networking = RoactNetworking,
	analytics = RoactAnalytics,
})(PlayButtonContainer)

PlayButtonContainer.selectPlayButtonState = selectPlayButtonState

return PlayButtonContainer
