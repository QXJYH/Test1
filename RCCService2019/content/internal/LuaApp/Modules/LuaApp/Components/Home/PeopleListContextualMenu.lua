local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalyticsHomePage = require(Modules.LuaApp.Services.RoactAnalyticsHomePage)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local FeatureContext = require(Modules.LuaApp.Enum.FeatureContext)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local User = require(Modules.LuaApp.Models.User)
local ListPicker = require(Modules.LuaApp.Components.ListPicker)
local UserActiveGame = require(Modules.LuaApp.Components.Home.UserActiveGame)
local FormBasedContextualMenu = require(Modules.LuaApp.Components.FormBasedContextualMenu)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()

local PeopleListContextualMenu = Roact.PureComponent:extend("PeopleListContextualMenu")

local LIST_PICKER_MAX_HEIGHT = 162
local WIDE_MENU_WIDTH = Constants.DEFAULT_WIDE_CONTEXTUAL_MENU__WIDTH

local EVENT_GO_TO_CHAT = "goToChatInPeopleList"
local EVENT_VIEW_PROFILE = "viewProfileInPeopleList"
local EVENT_OPEN_PEOPLE_LIST = "openPeopleList"

local CHAT_ICON
local VIEW_PROFILE_ICON

if useNewAppStyle then
	CHAT_ICON = "LuaApp/icons/menu/menu_messages"
	VIEW_PROFILE_ICON = "LuaApp/icons/menu/menu_profile"
else
	CHAT_ICON = "LuaApp/icons/ic-chat20x20"
	VIEW_PROFILE_ICON = "LuaApp/icons/ic-view-details20x20"
end

PeopleListContextualMenu.defaultProps = {
	positionIndex = 0,
}

function PeopleListContextualMenu:init()
	local analytics = self.props.analytics
	local guiService = self.props.guiService
	local closeCentralOverlay = self.props.closeCentralOverlay
	local navigateDown = self.props.navigateDown
	local user = self.props.user
	local positionIndex = self.props.positionIndex

	self.chatWithUser = function(userId)
		analytics.reportPeopleListInteraction(
			EVENT_GO_TO_CHAT,
			userId,
			positionIndex
		)

		guiService:BroadcastNotification(userId, NotificationType.LAUNCH_CONVERSATION)
	end

	self.viewProfile = function(userId)
		analytics.reportPeopleListInteraction(
			EVENT_VIEW_PROFILE,
			userId,
			positionIndex
		)

		navigateDown({
			name = AppPage.ViewUserProfile,
			detail = userId,
		})

		closeCentralOverlay()
	end

	analytics.reportPeopleListInteraction(
		EVENT_OPEN_PEOPLE_LIST,
		user.id,
		positionIndex
	)
end

function PeopleListContextualMenu:didMount()
	local onOpen = self.props.onOpen

	if onOpen then
		onOpen()
	end
end

function PeopleListContextualMenu:render()
	local localization = self.props.localization
	local screenSize = self.props.screenSize
	local formFactor = self.props.formFactor
	local closeCentralOverlay = self.props.closeCentralOverlay

	local user = self.props.user
	local positionIndex = self.props.positionIndex
	local anchorSpaceSize = self.props.anchorSpaceSize
	local anchorSpacePosition = self.props.anchorSpacePosition

	local isPlayerInGame = (user.presence == User.PresenceType.IN_GAME) and user.universeId

	local isCompactView = formFactor == FormFactor.COMPACT
	local itemWidth = isCompactView and screenSize.X or WIDE_MENU_WIDTH

	local menuItems = {
		{
			displayIcon = CHAT_ICON,
			text = localization:Format("Feature.Home.PeopleList.ChatWith", {username = user.name}),
			onSelect = function()
				self.chatWithUser(user.id)
			end
		},
		{
			displayIcon = VIEW_PROFILE_ICON,
			text = localization:Format("Feature.Chat.Label.ViewProfile"),
			onSelect = function()
				self.viewProfile(user.id)
			end
		},
	}

	return Roact.createElement(FormBasedContextualMenu, {
		anchorSpaceSize = anchorSpaceSize,
		anchorSpacePosition = anchorSpacePosition,
		itemWidth = itemWidth,
	}, {
		Content = Roact.createElement(FitChildren.FitFrame, {
			BackgroundTransparency = 1,
			fitAxis = FitChildren.FitAxis.Height,
			Size = UDim2.new(1, 0, 0, 0),
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			GameHeader = isPlayerInGame and Roact.createElement(UserActiveGame, {
				friend = user,
				layoutOrder = 1,
				width = itemWidth,
				index = positionIndex,
				universeId = user.universeId,
				dismissContextualMenu = closeCentralOverlay,
				featureContext = FeatureContext.PeopleList,
			}),
			ListPicker = Roact.createElement(ListPicker, {
				formFactor = formFactor,
				items = menuItems,
				layoutOrder = 2,
				width = itemWidth,
				maxHeight = LIST_PICKER_MAX_HEIGHT,
			}),
		}),
	})
end

function PeopleListContextualMenu:willUnmount()
	local onClose = self.props.onClose

	if onClose then
		onClose()
	end
end

PeopleListContextualMenu = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
			closeCentralOverlay = function()
				dispatch(CloseCentralOverlay())
			end,
		}
	end
)(PeopleListContextualMenu)

PeopleListContextualMenu = RoactServices.connect({
	analytics = RoactAnalyticsHomePage,
	localization = RoactLocalization,
	guiService = AppGuiService,
})(PeopleListContextualMenu)

return PeopleListContextualMenu
