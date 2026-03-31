local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local Common = Modules.Common
local LuaApp = Modules.LuaApp
local LuaChat = Modules.LuaChat

local LuaAppFlagSettings = require(LuaApp.FlagSettings)
local Constants = require(LuaChat.Constants)
local Create = require(LuaChat.Create)
local DialogInfo = require(LuaChat.DialogInfo)
local Signal = require(Common.Signal)
local NotificationType = require(LuaApp.Enum.NotificationType)
local GetCurrentTheme = require(LuaChat.GetCurrentTheme)

local AppFeature = require(LuaApp.Enum.AppFeature)

local Components = LuaChat.Components
local ChatDisabledIndicator = require(Components.ChatDisabledIndicator)
local ChatLoadingIndicator = require(Components.ChatLoadingIndicator)
local ConversationList = require(Components.ConversationList)
local ConversationSearchBox = require(Components.ConversationSearchBox)
local ConversationEntry = require(Components.ConversationEntry)
local HeaderLoader = require(Components.HeaderLoader)
local NoFriendsIndicator = require(Components.NoFriendsIndicator)
local PaddedImageButton = require(Components.PaddedImageButton)

local ConversationActions = require(LuaChat.Actions.ConversationActions)

local appStageLoaded = require(LuaApp.Analytics.Events.appStageLoaded)
local FetchChatData = require(LuaApp.Thunks.FetchChatData)
local RetrievalStatus = require(CorePackages.AppTempCommon.LuaApp.Enum.RetrievalStatus)

local isFeatureEnabled = require(LuaChat.Utils.isFeatureEnabled)

local UseNewAppStyle = LuaAppFlagSettings.UseNewAppStyle()

local CREATE_CHAT_IMAGE = "rbxasset://textures/ui/LuaChat/icons/ic-createchat1-24x24.png"
local NOTIFICATION_ICON = "rbxasset://textures/Icon_Stream_Off.png"
local SEARCH_ICON = "rbxasset://textures/ui/LuaChat/icons/ic-search.png"

if UseNewAppStyle then
	CREATE_CHAT_IMAGE = "rbxasset://textures/ui/LuaChatV2/actions_editing_compose.png"
	NOTIFICATION_ICON = "rbxasset://textures/ui/LuaChatV2/actions_notificationOn.png"
	SEARCH_ICON = "rbxasset://textures/ui/LuaChatV2/common_search.png"
end

local Intent = DialogInfo.Intent

local FlagSettings = require(LuaChat.FlagSettings)
local FFlagEnableLuaChatDiscussions = FlagSettings.EnableLuaChatDiscussions()

local ConversationHub = {}

ConversationHub.__index = ConversationHub

local FFlagLuaChatFixConversationHubHeaders = settings():GetFFlag("LuaChatFixConversationHubHeaders369")
local FFlagLuaChatHeaderEnableHomeButton = settings():GetFFlag("LuaChatHeaderEnableHomeButton")
local FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults =
	settings():GetFFlag("LuaChatScreenManagerAlwaysUpdatesWithDefaultsV390")

local function requestOlderConversations(appState)
	-- Don't fetch older conversations if the oldest conversation has already been fetched.
	if appState.store:getState().ChatAppReducer.ConversationsAsync.oldestConversationIsFetched then
		return
	end

	-- Don't fetch older conversations if the oldest conversation is  fetched.
	if appState.store:getState().ChatAppReducer.ConversationsAsync.pageConversationsIsFetching then
		return
	end

	-- Ask for new conversations
	local convoCount = 0
	for _, _ in pairs(appState.store:getState().ChatAppReducer.Conversations) do
		convoCount = convoCount + 1
	end
	local pageSize = Constants.PageSize.GET_CONVERSATIONS
	local currentPage = math.floor(convoCount / pageSize)
	spawn(function()
		appState.store:dispatch(ConversationActions.GetLocalUserConversationsAsync(currentPage + 1, pageSize))
	end)
end

local function refreshChatData(appState)
	local chatSettingsRetrievalStatus = appState.store:getState().ChatAppReducer.ChatSettings.retrievalStatus
	if chatSettingsRetrievalStatus ~= RetrievalStatus.Fetching then
		appState.store:dispatch(FetchChatData(function(chatEnabled)
			-- no opt
		end))
	end
end

function ConversationHub.new(appState)
	local self = {}
	self.rbx_connections = {}

	setmetatable(self, ConversationHub)

	local state = appState.store:getState()

	if not FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults then
		-- Only refresh here if we're not loaded:
		if not state.ChatAppReducer.AppLoaded then
			refreshChatData(appState)
		end
	end

	self.appState = appState
	self._analytics = appState.analytics

	self.rbx = Create.new "Frame" {
		Name = "ConversationHub",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Constants.Color.WHITE,
		BorderSizePixel = 0,

		Create.new "UIListLayout" {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}
	}

	self.ConversationTapped = Signal.new()
	self.CreateChatButtonPressed = Signal.new()
	self.isSearchOpen = false

	local header = HeaderLoader.GetHeader(appState, Intent.ConversationHub)
	header:SetTitle(appState.localization:Format("CommonUI.Features.Label.Chat"))
	header:SetDefaultSubtitle()
	header:SetBackButtonEnabled(false)
	local homePolicyEnabled = isFeatureEnabled(self.appState, AppFeature.ChatHeaderHomeButton)
	if homePolicyEnabled and FFlagLuaChatHeaderEnableHomeButton then
		header:SetHomeButtonEnabled(true)
	end

	if FFlagEnableLuaChatDiscussions then
		header.discussionsButton.rbx.Visible = true
	else
		-- Just in case, we will try to hide this button if it exists.
		if header.discussionsButton and header.discussionsButton.rbx then
			header.discussionsButton.rbx.Visible = false
		end
	end

	header.rbx.Parent = self.rbx
	header.rbx.LayoutOrder = 0
	self.header = header

	local createChatButton = PaddedImageButton.new(self.appState, "CreateChat", CREATE_CHAT_IMAGE)

	createChatButton:SetVisible(false)
	createChatButton.Pressed:connect(function()
		self.CreateChatButtonPressed:fire()
	end)

	self.createChatButton = createChatButton

	local searchConversationsButton = PaddedImageButton.new(self.appState,
		"SearchConversations", SEARCH_ICON)

	if isFeatureEnabled(self.appState, AppFeature.ChatHeaderSearch) then
		header:AddButton(searchConversationsButton)
	end

	if isFeatureEnabled(self.appState, AppFeature.ChatHeaderCreateChatGroup) then
		header:AddButton(createChatButton)
	end

	local notificationButton = PaddedImageButton.new(self.appState, "Notification",
		NOTIFICATION_ICON)
	notificationButton.Pressed:connect(function()
		GuiService:BroadcastNotification("", NotificationType.VIEW_NOTIFICATIONS)
	end)

	--Apply theme to icons if flag is turned on
	if UseNewAppStyle then
		local theme = GetCurrentTheme()

		local themeIconColor = theme.SystemPrimaryButton.Color
		local themeIconTransparency = theme.SystemPrimaryButton.Transparency

		createChatButton.rbx.ImageLabel.ImageColor3 = themeIconColor
		createChatButton.rbx.ImageLabel.ImageTransparency = themeIconTransparency


		searchConversationsButton.rbx.ImageLabel.ImageColor3 = themeIconColor
		searchConversationsButton.rbx.ImageLabel.ImageTransparency = themeIconTransparency

		notificationButton.rbx.ImageLabel.ImageColor3 = themeIconColor
		notificationButton.rbx.ImageLabel.ImageTransparency = themeIconTransparency
	end

	if isFeatureEnabled(self.appState, AppFeature.ChatHeaderNotifications) then
		header:AddButton(notificationButton)
	end

	local searchHeader = HeaderLoader.GetHeader(appState, Intent.ConversationHub)
	searchHeader:SetTitle("")
	searchHeader:SetSubtitle("")
	searchHeader.rbx.LayoutOrder = 1

	if FFlagLuaChatFixConversationHubHeaders then
		searchHeader.rbx.Parent = self.rbx
		searchHeader.rbx.Visible = false
	end

	local conversationSearchBox = ConversationSearchBox.new(self.appState)
	searchHeader:AddContent(conversationSearchBox)

	local noFriendsIndicator = NoFriendsIndicator.new(appState)
	self.noFriendsIndicator = noFriendsIndicator
	noFriendsIndicator.rbx.Size = UDim2.new(1, 0, 1, -header.rbx.Size.Y.Offset)
	noFriendsIndicator.rbx.Parent = self.rbx
	noFriendsIndicator.rbx.LayoutOrder = 2

	local chatDisabledIndicator = ChatDisabledIndicator.new(appState)
	self.chatDisabledIndicator = chatDisabledIndicator
	chatDisabledIndicator.rbx.Size = UDim2.new(1, 0, 1, -header.rbx.Size.Y.Offset)
	chatDisabledIndicator.rbx.Parent = self.rbx
	chatDisabledIndicator.rbx.LayoutOrder = 2

	local chatLoadingIndicator = ChatLoadingIndicator.new(appState)
	self.chatLoadingIndicator = chatLoadingIndicator
	chatLoadingIndicator.rbx.Size = UDim2.new(1, 0, 1, -header.rbx.Size.Y.Offset)
	chatLoadingIndicator.rbx.Parent = self.rbx
	chatLoadingIndicator.rbx.LayoutOrder = 2

	chatDisabledIndicator.openPrivacySettings:connect(function()
		GuiService:BroadcastNotification("", NotificationType.PRIVACY_SETTINGS)
	end)

	local list = ConversationList.new(appState, appState.store:getState().ChatAppReducer.Conversations, ConversationEntry)
	self.list = list
	list.rbx.Size = UDim2.new(1, 0, 1, -header.rbx.Size.Y.Offset)
	list.rbx.Parent = self.rbx
	list.rbx.LayoutOrder = 2

	list.ConversationTapped:connect(function(convoId)
		conversationSearchBox:Cancel()
		self.ConversationTapped:fire(convoId)
	end)

	list.RequestOlderConversations:connect(function()
		requestOlderConversations(appState)
	end)

	searchConversationsButton.Pressed:connect(function()
		if FFlagLuaChatFixConversationHubHeaders then
			self.header.rbx.Visible = false
			searchHeader.rbx.Visible = true
		else
			self.rbx.Position = UDim2.new(0, 0, 0, -header.rbx.AbsoluteSize.Y)
			searchHeader.rbx.Parent = self.rbx
		end
		self.rbx.BackgroundColor3 = Constants.Color.GRAY5
		list:SetFilterPredicate(conversationSearchBox.SearchFilterPredicate)
		conversationSearchBox.rbx.SearchBoxContainer.SearchBoxBackground.Search:CaptureFocus()
		self.isSearchOpen = true
	end)

	conversationSearchBox.SearchChanged:connect(function()
		list:SetFilterPredicate(conversationSearchBox.SearchFilterPredicate)
		self:getOlderConversationsForSearchIfNecessary()
	end)

	conversationSearchBox.Closed:connect(function()
		if FFlagLuaChatFixConversationHubHeaders then
			self.header.rbx.Visible = true
			searchHeader.rbx.Visible = false
		else
			searchHeader.rbx.Parent = nil
			self.rbx.Position = UDim2.new(0, 0, 0, 0)
		end
		self.rbx.BackgroundColor3 = Constants.Color.WHITE
		list:SetFilterPredicate(nil)
		self.isSearchOpen = false
	end)

	appState.store.changed:connect(function(state, oldState)
		self:Update(state, oldState)

		if state.ChatAppReducer.Conversations ~= oldState.ChatAppReducer.Conversations
			or state.ChatAppReducer.Location.current ~= oldState.ChatAppReducer.Location.current then
			list:Update(state, oldState)
		end
	end)

	state = appState.store:getState()
	self:Update(state, state)

	local appRoutes = state.Navigation.history
	local currentRoute = appRoutes[#appRoutes]
	local currentSection = currentRoute[1]
	appStageLoaded(self._analytics.EventStream, currentSection.name, "chatRender")

	return self
end

function ConversationHub:Start()
	local inputServiceConnection = UserInputService:GetPropertyChangedSignal('OnScreenKeyboardVisible'):Connect(function()
		self:TweenRescale()
	end)
	table.insert(self.rbx_connections, inputServiceConnection)

	local statusBarTappedConnection = UserInputService.StatusBarTapped:Connect(function()
		if self.appState.store:getState().ChatAppReducer.Location.current.intent ~= Intent.ConversationHub then
			return
		end
		self.list.rbx:ScrollToTop()
	end)
	table.insert(self.rbx_connections, statusBarTappedConnection)
end

function ConversationHub:Stop()
	for _, connection in ipairs(self.rbx_connections) do
		connection:Disconnect()
	end
	self.rbx_connections = {}
end

function ConversationHub:Update(state, oldState)
	self.header:SetConnectionState(state.ConnectionState)

	local conversations = state.ChatAppReducer.Conversations
	local appLoaded = state.ChatAppReducer.AppLoaded

	local haveConversations = next(conversations) ~= nil

	local chatEnabled = state.ChatAppReducer.ChatSettings.chatEnabled

	if chatEnabled then
		self.chatDisabledIndicator.rbx.Visible = false

		local oldChatEnabled = oldState.ChatAppReducer.ChatSettings.chatEnabled

		if chatEnabled ~= oldChatEnabled then
			refreshChatData(self.appState)
		end
	else
		self.chatDisabledIndicator.rbx.Visible = true
		self.list.rbx.Visible = false
		self.noFriendsIndicator.rbx.Visible = false
		self.chatLoadingIndicator:SetVisible(false)

		return
	end

	if appLoaded then
		self.chatLoadingIndicator:SetVisible(false)
	else
		self.chatLoadingIndicator:SetVisible(true)
		self.list.rbx.Visible = false
		self.noFriendsIndicator.rbx.Visible = false

		return
	end

	if haveConversations then
		self.list.rbx.Visible = true
		self.noFriendsIndicator.rbx.Visible = false
	else
		self.list.rbx.Visible = false
		self.noFriendsIndicator.rbx.Visible = true
	end

	if state.FriendCount < Constants.MIN_PARTICIPANT_COUNT then
		self.createChatButton:SetVisible(false)
	else
		self.createChatButton:SetVisible(true)
	end

	if state.ChatAppReducer.ConversationsAsync.pageConversationsIsFetching
		~= oldState.ChatAppReducer.ConversationsAsync.pageConversationsIsFetching then
		self.list:Update(state, oldState)
		self:getOlderConversationsForSearchIfNecessary()
	end
end

function ConversationHub:getOlderConversationsForSearchIfNecessary(appState)
	-- To Check:
	-- 1) Search is open
	-- 2) Not have loaded all oldest conversations
	-- 3) Not currently getting conversations
	-- 4) Has enough items to show
	-- Note that we already try to load more conversations if we scroll down to the bottom of the list
	local state = self.appState.store:getState()
	if not self.isSearchOpen
		or state.ChatAppReducer.ConversationsAsync.oldestConversationIsFetched
		or state.ChatAppReducer.ConversationsAsync.pageConversationsIsFetching then
		return
	end

	if self.list.rbx.CanvasSize.Y.Offset > self.list.rbx.AbsoluteSize.Y then
		return
	end

	requestOlderConversations(self.appState)
end

function ConversationHub:TweenRescale()
	local keyboardSize = 0
	if UserInputService.OnScreenKeyboardVisible then
		keyboardSize = self.rbx.AbsoluteSize.Y - UserInputService.OnScreenKeyboardPosition.Y
	end
	local newSize = UDim2.new(1, 0, 1, -(self.header.rbx.Size.Y.Offset + keyboardSize))

	local duration = UserInputService.OnScreenKeyboardAnimationDuration
	local tweenInfo = TweenInfo.new(duration)

	local propertyGoals = {
		Size = newSize
	}
	local tween = TweenService:Create(self.list.rbx, tweenInfo, propertyGoals)

	tween:Play()
end

return ConversationHub