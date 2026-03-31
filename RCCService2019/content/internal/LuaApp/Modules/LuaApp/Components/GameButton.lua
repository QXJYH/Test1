local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local LuaAppFlags = CorePackages.AppTempCommon.LuaApp.Flags
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local RoactAnalyticsHomePage = require(Modules.LuaApp.Services.RoactAnalyticsHomePage)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local FeatureContext = require(Modules.LuaApp.Enum.FeatureContext)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local PlayabilityStatus = require(Modules.LuaApp.Enum.PlayabilityStatus)

local convertUniverseIdToString = require(LuaAppFlags.ConvertUniverseIdToString)
local joinGame = require(Modules.LuaChat.Utils.joinGame)
local formatInteger = require(Modules.LuaChat.Utils.formatInteger)

local Constants = require(Modules.LuaApp.Constants)
local FitImageTextButton = require(Modules.LuaApp.Components.FitImageTextButton)
local LoadingBarWithTheme = require(Modules.LuaApp.Components.LoadingBarWithTheme)

local AppFlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = AppFlagSettings.UseNewAppStyle()

local DEFAULT_BUTTON_COLOR = Constants.Color.GREEN_PRIMARY
local DEFAULT_BUTTON_TEXT_COLOR = Constants.Color.WHITE
local DEFAULT_LOADING_BAR_CONTAINER_HEIGHT = 32
local DEFAULT_LOADING_BAR_CONTAINER_WIDTH = 104
local DEFAULT_BUTTON_WIDTH = 90

local VIEW_GAME_DETAILS_FROM_BUTTON = Constants.AnalyticsKeyword.VIEW_GAME_DETAILS_FROM_BUTTON

local ROBUX_ICON = "rbxasset://textures/ui/LuaApp/icons/ic-ROBUX.png"
local ROUNDED_BUTTON = "rbxasset://textures/ui/LuaChat/9-slice/input-default.png"

local CONFIGURE_BY_FEATURE_DEFAULT_KEY = "Default"

local GameButtonConfigByFeature = {
	[FeatureContext.PeopleList] = {
		ViewDetailsEnabled = true,
		JoinGameEnabled = true,
		BuyToPlayButtonEnabled = true,
	},
	[FeatureContext.PlacesList] = {
		ViewDetailsEnabled = false,
		JoinGameEnabled = false,
		BuyToPlayButtonEnabled = true,
	},
	[CONFIGURE_BY_FEATURE_DEFAULT_KEY] = {
		ViewDetailsEnabled = true,
		JoinGameEnabled = true,
		BuyToPlayButtonEnabled = true,
	},
}

local GameButton = Roact.PureComponent:extend("GameButton")

GameButton.defaultProps = {
	showLoadingIndicatorWhenDataNotReady = false,
}

function GameButton:init()
	self.openGameDetailsFromButton = function()
		local universePlaceInfo = self.props.universePlaceInfo
		if not universePlaceInfo then
			return
		end

		local guiService = self.props.guiService
		local analytics = self.props.analytics
		local friend = self.props.friend
		local index = self.props.index
		local callbackOnOpenGameDetails = self.props.callbackOnOpenGameDetails
		local featureContext = self.props.featureContext

		local rootPlaceId = universePlaceInfo.universeRootPlaceId
		local placeId = universePlaceInfo.placeId
		local universeId = universePlaceInfo.universeId

		if placeId then
			if featureContext == FeatureContext.PeopleList then
				analytics.reportViewProfileFromPeopleList(friend.id, index, rootPlaceId, VIEW_GAME_DETAILS_FROM_BUTTON)
			end

			if callbackOnOpenGameDetails then
				callbackOnOpenGameDetails()
			end

			if useNewAppStyle then
				local navigateDown = self.props.navigateDown
				navigateDown({
					name = AppPage.GameDetail,
					detail = convertUniverseIdToString(universeId)
				})
			else
				guiService:BroadcastNotification(
					placeId,
					NotificationType.VIEW_GAME_DETAILS_ANIMATED
				)
			end
		end
	end

	self.joinGameByUser = function()
		local universePlaceInfo = self.props.universePlaceInfo
		if not universePlaceInfo then
			return
		end

		local analytics = self.props.analytics
		local friend = self.props.friend
		local index = self.props.index
		local callbackOnJoinGame = self.props.callbackOnJoinGame
		local featureContext = self.props.featureContext

		local placeId = universePlaceInfo.placeId
		local rootPlaceId = universePlaceInfo.universeRootPlaceId

		if callbackOnJoinGame then
			callbackOnJoinGame()
		end
		if featureContext == FeatureContext.PeopleList then
			analytics.reportPeopleListJoinGame(friend.id, index, placeId, rootPlaceId, friend.gameInstanceId)
		elseif featureContext == FeatureContext.PlacesList then
			analytics.reportJoinGameInPlacesList(friend.id, placeId, rootPlaceId, friend.gameInstanceId)
		end
		joinGame:ByUser(friend)
	end

end

function GameButton:render()
	local universePlaceInfo = self.props.universePlaceInfo

	-- Show a loading indicator when game data is not ready
	if not universePlaceInfo and self.props.showLoadingIndicatorWhenDataNotReady then
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, DEFAULT_LOADING_BAR_CONTAINER_WIDTH, 0, DEFAULT_LOADING_BAR_CONTAINER_HEIGHT),
		}, {
			LoadingBar = Roact.createElement(LoadingBarWithTheme),
		})
	end

	local localization = self.props.localization
	local layoutOrder = self.props.layoutOrder
	local maxWidth = self.props.maxWidth
	local featureContext = self.props.featureContext
	local featureConfig = GameButtonConfigByFeature[featureContext]
							or GameButtonConfigByFeature[CONFIGURE_BY_FEATURE_DEFAULT_KEY]

	local displayJoinGameButton = false
	local displayBuyToPlayButton = false
	local gamePrice

	if universePlaceInfo then
		displayJoinGameButton = featureConfig.JoinGameEnabled and universePlaceInfo.isPlayable
		displayBuyToPlayButton = featureConfig.BuyToPlayButtonEnabled
									and universePlaceInfo.reasonProhibited == PlayabilityStatus.PurchaseRequired
		gamePrice = universePlaceInfo.price
	end

	local displayViewDetailsButton = featureConfig.ViewDetailsEnabled

	local renderFunction = function(stylePalette)
		local contextualButtonColor = DEFAULT_BUTTON_COLOR
		local contextualButtonTransparency = 0
		local contextualButtonTextColor = DEFAULT_BUTTON_TEXT_COLOR
		local contextualButtonTextTransparency = 0
		local systemButtonColor = Constants.Color.WHITE
		local systemButtonTransparency = 0
		local systemButtonTextColor = Constants.Color.GRAY1
		local systemButtonTextTransparency = 0
		local robuxIcon = ROBUX_ICON
		local textFont

		if stylePalette then
			local theme = stylePalette.Theme
			local font = stylePalette.Font
			contextualButtonColor = theme.ContextualPrimaryDefault.Color
			contextualButtonTransparency = theme.ContextualPrimaryDefault.Transparency
			contextualButtonTextColor = theme.ContextualPrimaryContent.Color
			contextualButtonTextTransparency = theme.ContextualPrimaryContent.Transparency
			systemButtonColor = theme.SystemPrimaryDefault.Color
			systemButtonTransparency = theme.SystemPrimaryDefault.Transparency
			systemButtonTextColor = theme.SystemPrimaryContent.Color
			systemButtonTextTransparency = theme.SystemPrimaryContent.Transparency
			textFont = font.Header2.Font
		end

		local backgroundColor = contextualButtonColor
		local backgroundTransparency = contextualButtonTransparency
		local textColor = contextualButtonTextColor
		local textTransparency = contextualButtonTextTransparency
		local textKey
		local onActivated
		local leftIcon

		if displayJoinGameButton then
			textKey = "Feature.Chat.Drawer.Join"
			onActivated = self.joinGameByUser
		elseif displayBuyToPlayButton then
			onActivated = self.openGameDetailsFromButton
			leftIcon = robuxIcon
		elseif displayViewDetailsButton then
			textKey = "Feature.Chat.Drawer.ViewDetails"
			onActivated = self.openGameDetailsFromButton
			backgroundColor = systemButtonColor
			backgroundTransparency = systemButtonTransparency
			textColor = systemButtonTextColor
			textTransparency = systemButtonTextTransparency
		else -- Do not create button for an unidentifiable button type.
			return nil
		end

		local text = displayBuyToPlayButton and formatInteger(gamePrice) or localization:Format(textKey)

		return Roact.createElement(FitImageTextButton, {
			backgroundColor = backgroundColor,
			backgroundTransparency = backgroundTransparency,
			backgroundImage = ROUNDED_BUTTON,
			layoutOrder = layoutOrder,
			leftIconEnabled = (leftIcon ~= nil),
			leftIcon = leftIcon,
			maxWidth = maxWidth,
			minWidth = DEFAULT_BUTTON_WIDTH,
			textFont = textFont,
			text = text,
			textColor = textColor,
			textTransparency = textTransparency,
			onActivated = onActivated,
		})
	end

	if useNewAppStyle then
		return withStyle(renderFunction)
	else
		return renderFunction(nil)
	end
end

GameButton = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local universeId = convertUniverseIdToString(props.universeId)

		return {
			universePlaceInfo = state.UniversePlaceInfos[universeId],
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(GameButton)

GameButton = RoactServices.connect({
	analytics = RoactAnalyticsHomePage,
	guiService = AppGuiService,
	localization = RoactLocalization,
})(GameButton)

return GameButton