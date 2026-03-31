local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Common = Modules.Common
local LuaApp = Modules.LuaApp

local AppGuiService = require(LuaApp.Services.AppGuiService)
local Roact = require(Common.Roact)
local RoactRodux = require(Common.RoactRodux)
local RoactServices = require(LuaApp.RoactServices)
local RoactAnalyticsHomePage = require(LuaApp.Services.RoactAnalyticsHomePage)
local RoactLocalization = require(LuaApp.Services.RoactLocalization)

local ContextualListMenu = require(LuaApp.Components.ContextualListMenu)
local ListPicker = require(LuaApp.Components.ListPicker)
local UserActiveGame = require(LuaApp.Components.Home.UserActiveGame)
local UserThumbnailDefaultOrientation = require(LuaApp.Components.Home.UserThumbnailDefaultOrientation)
local UserThumbnailPortraitOrientation = require(LuaApp.Components.Home.UserThumbnailPortraitOrientation)
local UserTile = require(Modules.LuaApp.Components.Common.UserTile)

local Constants = require(LuaApp.Constants)
local FormFactor = require(LuaApp.Enum.FormFactor)
local ImageSetButton = require(LuaApp.Components.ImageSetButton)
local NotificationType = require(LuaApp.Enum.NotificationType)
local SetTabBarVisible = require(LuaApp.Actions.SetTabBarVisible)
local Url = require(LuaApp.Http.Url)
local User = require(LuaApp.Models.User)
local FeatureContext = require(LuaApp.Enum.FeatureContext)
local OpenCentralOverlayForPeopleList = require(LuaApp.Thunks.OpenCentralOverlayForPeopleList)

local UrlBuilder = require(LuaApp.Http.UrlBuilder)
local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()


local HORIZONTAL_PADDING = 7.5
local LIST_PICKER_MAX_HEIGHT = 162
local WIDE_MENU_DEFAULT_WIDTH = Constants.DEFAULT_WIDE_CONTEXTUAL_MENU__WIDTH
local USER_ENTRY_WIDTH = 105
local USER_ENTRY_WIDTH_COMPACT = 115
local VERTICAL_PADDING = 15

local CHAT_ICON = "LuaApp/icons/ic-chat20x20"
local VIEW_PROFILE_ICON = "LuaApp/icons/ic-view-details20x20"


local EVENT_GO_TO_CHAT = "goToChatInPeopleList"
local EVENT_VIEW_PROFILE = "viewProfileInPeopleList"
local EVENT_OPEN_PEOPLE_LIST = "openPeopleList"

local FFlagPeopleListV1 = FlagSettings.IsPeopleListV1Enabled()

local FFlagRealtimeFriendsContextualMenuRefactor = useNewAppStyle or settings():GetFFlag("RealtimeFriendsContextualMenuRefactor")

local UserCarouselEntry = Roact.PureComponent:extend("UserCarouselEntry")

local function getCardWidth(formFactor)
	if formFactor == FormFactor.COMPACT then
		return USER_ENTRY_WIDTH_COMPACT
	else
		return USER_ENTRY_WIDTH
	end
end

function UserCarouselEntry:init()
	self.state = {
		highlighted = false,
		showContextualMenu = false, -- TODO Remove when removing FFlagRealtimeFriendsContextualMenuRefactor
		screenShape = {},
	}

	self.isMounted = false

	if FFlagRealtimeFriendsContextualMenuRefactor then
		self.userCarouselEntryRef = Roact.createRef()
	else
		self.onRef = function(rbx)
			self.ref = rbx
		end
	end

	self.onInputBegan = function(_, inputObject)
		--TODO: Remove after CLIPLAYEREX-1468
		if self.inputStateChangedConnection then
			self.inputStateChangedConnection:Disconnect()
		end
		self.inputStateChangedConnection = inputObject:GetPropertyChangedSignal("UserInputState"):Connect(function()
			if inputObject.UserInputState == Enum.UserInputState.End
				or inputObject.UserInputState == Enum.UserInputState.Cancel then
				self.inputStateChangedConnection:Disconnect()
				self.onInputEnded()
			end
		end)
		self:setState({
			highlighted = true,
		})
	end

	self.onInputEnded = function()
		self:setState({
			highlighted = false,
		})
	end

	self.onInputChanged = self.onInputEnded

	self.onActivated = function(_, inputObject)
		if inputObject.UserInputState == Enum.UserInputState.End then
			local user = self.props.user
			if user then
				if FFlagPeopleListV1 then
					if FFlagRealtimeFriendsContextualMenuRefactor then
						-- if self reference does not exist, it probably wouldn't be activated
						if self.userCarouselEntryRef.current then
							local openContextualMenu = self.props.openContextualMenu
							local count = self.props.count
							local size = self.userCarouselEntryRef.current.AbsoluteSize
							local position = self.userCarouselEntryRef.current.AbsolutePosition
							local setPeopleListFrozen = self.props.setPeopleListFrozen

							local function onOpen()
								setPeopleListFrozen(true)
							end

							local function onClose()
								setPeopleListFrozen(false)
							end

							openContextualMenu(user, count, onOpen, onClose, size, position)
						end
					else
						self.openContextualMenu()
					end
				else
					self.viewProfile(user.id)
				end
			end
		end
	end

	self.viewProfile = function(userId)
		if not FFlagRealtimeFriendsContextualMenuRefactor then
			if FFlagPeopleListV1 then
				self.props.analytics.reportPeopleListInteraction(
					EVENT_VIEW_PROFILE,
					self.props.user.id,
					self.props.count
				)
			end
		end

		local url
		if FFlagLuaAppHttpsWebViews then
			url = UrlBuilder.user.profile({
				userId = userId,
			})
		else
			url = Url:getUserProfileUrl(userId)
		end
		self.props.guiService:BroadcastNotification(url, NotificationType.VIEW_PROFILE)
	end

	if not FFlagRealtimeFriendsContextualMenuRefactor then
		if FFlagPeopleListV1 then
			self.chatWithUser = function(uid)
				self.props.analytics.reportPeopleListInteraction(
					EVENT_GO_TO_CHAT,
					self.props.user.id,
					self.props.count
				)

				self.props.guiService:BroadcastNotification(uid, NotificationType.LAUNCH_CONVERSATION)
			end

			self.setBottomBarVisibility = function(visible)
				return self.props.setBottomBarVisibility(visible)
			end

			self.setPeopleListFrozen = function(frozen)
				if self.props.setPeopleListFrozen then
					self.props.setPeopleListFrozen(frozen)
				end
			end

			self.openContextualMenu = function()
				local formFactor = self.props.formFactor

				self.props.analytics.reportPeopleListInteraction(
					EVENT_OPEN_PEOPLE_LIST,
					self.props.user.id,
					self.props.count
				)

				if formFactor == FormFactor.COMPACT then
					self.setBottomBarVisibility(false)
				end

				self.setPeopleListFrozen(true)

				local screenSize = self.props.screenSize
				local screenWidth = screenSize.X
				local screenHeight = screenSize.Y

				spawn(function()
					if self.isMounted then
						self:setState({
							showContextualMenu = true,
							screenShape = {
								x = self.ref.AbsolutePosition.X,
								y = self.ref.AbsolutePosition.Y,
								width = self.ref.AbsoluteSize.X,
								height = self.ref.AbsoluteSize.Y,
								parentWidth = screenWidth,
								parentHeight = screenHeight,
							}
						})
					end
				end)
			end
		end
	end
end

if not FFlagRealtimeFriendsContextualMenuRefactor then
	function UserCarouselEntry:createContextualMenu()
		local formFactor = self.props.formFactor
		local localization = self.props.localization
		local count = self.props.count
		local screenShape = self.state.screenShape
		local user = self.props.user

		local isCompactView = formFactor == FormFactor.COMPACT

		local Components = {}

		local callbackCancel = function()
			if isCompactView then
				self.setBottomBarVisibility(true)
			end

			self.setPeopleListFrozen(false)
			self:setState({ showContextualMenu = false })
		end

		local gameItemWidth = isCompactView and screenShape.parentWidth or WIDE_MENU_DEFAULT_WIDTH
		local showGame = (user.presence == User.PresenceType.IN_GAME) and user.universeId

		if showGame then
			Components["Game"] = Roact.createElement(UserActiveGame, {
				friend = user,
				layoutOrder = 1,
				width = gameItemWidth,
				index = count,
				universeId = user.universeId,
				dismissContextualMenu = callbackCancel,
				featureContext = FeatureContext.PeopleList,
			})
		end

		local MenuItemChatWithFriend = {
			displayIcon = CHAT_ICON,
			text = localization:Format("Feature.Home.PeopleList.ChatWith", {username = user.name}),
			onSelect = function()
				self.chatWithUser(user.id)
				callbackCancel()
			end
		}
		local MenuItemViewProfile = {
			displayIcon = VIEW_PROFILE_ICON,
			text = localization:Format("Feature.Chat.Label.ViewProfile"),
			onSelect = function()
				self.viewProfile(user.id)
				callbackCancel()
			end
		}

		local menuItems = {MenuItemChatWithFriend, MenuItemViewProfile}
		Components["ListPicker"] = Roact.createElement(ListPicker, {
			formFactor = formFactor,
			items = menuItems,
			layoutOrder = 2,
			width = gameItemWidth,
			maxHeight = LIST_PICKER_MAX_HEIGHT,
		})
		return Roact.createElement(ContextualListMenu, {
			callbackCancel = callbackCancel,
			screenShape = screenShape,
		}, Components)
	end
end

function UserCarouselEntry:newRender()
	local user = self.props.user
	local thumbnailSize = self.props.thumbnailSize
	local totalWidth = self.props.totalWidth
	local totalHeight = self.props.totalHeight
	local count = self.props.count

	local ref = self.userCarouselEntryRef

	return Roact.createElement(UserTile, {
		user = user,
		thumbnailSize = thumbnailSize,
		width = totalWidth,
		height = totalHeight,
		layoutOrder = count,
		ref = ref,
		onActivated = self.onActivated,
	})
end


function UserCarouselEntry:oldRender()
	local count = self.props.count
	local formFactor = self.props.formFactor
	local thumbnailType = self.props.thumbnailType
	local user = self.props.user

	local highlightColor = self.state.highlighted and Constants.Color.GRAY5 or Constants.Color.WHITE
	local isCompactView = formFactor == FormFactor.COMPACT

	local totalHeight = self.props.totalHeight or UserCarouselEntry.height(formFactor)
	local thumbnailSize = UserCarouselEntry.thumbnailSize(formFactor)

	local userThumbnailComponent = isCompactView and UserThumbnailPortraitOrientation
		or UserThumbnailDefaultOrientation
	local totalWidth = self.props.totalWidth or getCardWidth(formFactor)

	local contextualListMenu
	if FFlagRealtimeFriendsContextualMenuRefactor then
		contextualListMenu = nil
	else
		if FFlagPeopleListV1 and self.state.showContextualMenu then
			contextualListMenu = self:createContextualMenu()
		end
	end

	local ref

	if FFlagRealtimeFriendsContextualMenuRefactor then
		ref = self.userCarouselEntryRef
	else
		ref = self.onRef
	end

	return Roact.createElement(ImageSetButton, {
		AutoButtonColor = false,
		Size = UDim2.new(0, totalWidth, 0, totalHeight),
		BackgroundColor3 = highlightColor,
		BorderSizePixel = 0,
		LayoutOrder = count,
		[Roact.Ref] = ref,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnded,
		-- When Touch is used for scrolling, InputEnded gets sunk into scrolling action
		[Roact.Event.InputChanged] = self.onInputChanged,
		[Roact.Event.Activated] = self.onActivated,
	}, {
		ThumbnailFrame = Roact.createElement("Frame", {
			Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
			Position = UDim2.new(0.5, 0, 0, VERTICAL_PADDING),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, {
			Thumbnail = Roact.createElement(userThumbnailComponent, {
				user = user,
				formFactor = formFactor,
				maskColor = Constants.Color.WHITE,
				highlightColor = highlightColor,
				thumbnailType = thumbnailType,
			}),
		}),
		ContextualListMenu = contextualListMenu, -- TODO Remove when removing FFlagRealtimeFriendsContextualMenuRefactor
	})
end

if useNewAppStyle then
	UserCarouselEntry.render = UserCarouselEntry.newRender
else
	UserCarouselEntry.render = UserCarouselEntry.oldRender
end

function UserCarouselEntry:didMount()
	self.isMounted = true
end

function UserCarouselEntry:willUnmount()
	self.isMounted = false

	if self.inputStateChangedConnection then
		self.inputStateChangedConnection:Disconnect()
		self.inputStateChangedConnection = nil
	end
end

if not FFlagRealtimeFriendsContextualMenuRefactor then
	function UserCarouselEntry:didUpdate(prevProps, prevState)
		local newRouteHistory = self.props.routeHistory
		local newRoute = newRouteHistory[#newRouteHistory]
		local newPage = newRoute[#newRoute]
		local oldRouteHistory = prevProps.routeHistory
		local oldRoute = oldRouteHistory[#oldRouteHistory]
		local oldPage = oldRoute[#oldRoute]

		if newPage.name ~= oldPage.name then
			self:setState({ showContextualMenu = false })
		end
	end
end

if FFlagRealtimeFriendsContextualMenuRefactor then
	UserCarouselEntry = RoactRodux.UNSTABLE_connect2(
		nil,
		function(dispatch)
			return {
				openContextualMenu = function(user, positionIndex, onOpen, onClose, anchorSpaceSize, anchorSpacePosition)
					dispatch(OpenCentralOverlayForPeopleList({
						user = user,
						positionIndex = positionIndex,
						onOpen = onOpen,
						onClose = onClose,
						anchorSpaceSize = anchorSpaceSize,
						anchorSpacePosition = anchorSpacePosition,
					}))
				end,
			}
		end
	)(UserCarouselEntry)

	UserCarouselEntry = RoactServices.connect({
		guiService = AppGuiService,
	})(UserCarouselEntry)
else
	UserCarouselEntry = RoactRodux.UNSTABLE_connect2(
		function(state, props)
			return {
				bottomBarVisibility = state.TabBarVisible,
				routeHistory = state.Navigation.history,
				screenSize = state.ScreenSize,
			}
		end,
		function(dispatch)
			return {
				setBottomBarVisibility = function(visible)
					return dispatch(SetTabBarVisible(visible))
				end,
			}
		end
	)(UserCarouselEntry)

	UserCarouselEntry = RoactServices.connect({
		analytics = RoactAnalyticsHomePage,
		guiService = AppGuiService,
		localization = RoactLocalization,
	})(UserCarouselEntry)
end

function UserCarouselEntry.thumbnailSize(formFactor)
	return formFactor == FormFactor.COMPACT and UserThumbnailPortraitOrientation.size(formFactor)
		or UserThumbnailDefaultOrientation.size(formFactor)
end

function UserCarouselEntry.height(formFactor)
	local component = formFactor == FormFactor.COMPACT and UserThumbnailPortraitOrientation
		or UserThumbnailDefaultOrientation

	return VERTICAL_PADDING
		+ component.height(formFactor)
		+ VERTICAL_PADDING
end

function UserCarouselEntry.horizontalPadding()
	return HORIZONTAL_PADDING
end

function UserCarouselEntry.getCardWidth(formFactor)
	return getCardWidth(formFactor)
end

return UserCarouselEntry
