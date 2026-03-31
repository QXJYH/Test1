local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat
local LuaApp = Modules.LuaApp

local Rodux = require(Modules.Common.Rodux)

local AppReducer = require(LuaApp.AppReducer)
local AppState = require(LuaChat.AppState)
local Config = require(LuaApp.Config)
local FormFactor = require(LuaApp.Enum.FormFactor)
local NotificationType = require(LuaApp.Enum.NotificationType)
local DebugManager = require(LuaChat.Debug.DebugManager)
local Device = require(LuaChat.Device)
local DialogInfo = require(LuaChat.DialogInfo)
local NotificationBroadcaster = require(Modules.LuaChat.NotificationBroadcaster)
local PerformanceTesting = require(LuaApp.PerformanceTesting)
local RetrievalStatus = require(CorePackages.AppTempCommon.LuaApp.Enum.RetrievalStatus)
local RobloxEventReceiver = require(Modules.LuaChat.RobloxEventReceiver)

local FetchChatData = require(LuaApp.Thunks.FetchChatData)
local SetRoute = require(LuaChat.Actions.SetRoute)
local PopRoute = require(LuaChat.Actions.PopRoute)
local ToggleChatPaused = require(LuaChat.Actions.ToggleChatPaused)
local SetTabBarVisibleFromChat = require(LuaApp.Thunks.SetTabBarVisibleFromChat)

local Alert = require(LuaChat.Views.Phone.Alert)
local ToastView = require(LuaChat.Views.ToastView)

local Intent = DialogInfo.Intent

local LuaAppFlagSettings = require(LuaApp.FlagSettings)
local IsLuaBottomBarEnabled = LuaAppFlagSettings.IsLuaBottomBarEnabled()
local FFlagLuaChatKeep3DRenderingEnabled = settings():GetFFlag("LuaChatKeep3DRenderingEnabled")
local FFlagLuaAppUseRedirectedRodux = settings():GetFFlag("LuaAppUseRedirectedRodux")
local FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults =
	settings():GetFFlag("LuaChatScreenManagerAlwaysUpdatesWithDefaultsV390")

local ChatMaster = {}
ChatMaster.__index = ChatMaster

ChatMaster.Type = {
	Default = "Default",
	GameShare = "GameShare",
}

function ChatMaster.new(roduxStore)
	local self = {}
	setmetatable(self, ChatMaster)

	if Players.LocalPlayer == nil then
		Players.PlayerAdded:Wait()
	end

	-- In debug mode, load the DebugManager overlay and logging system
	if Config.LuaChat.Debug then
		warn("CHAT DEBUG MODE IS ENABLED")
		DebugManager:Initialize(CoreGui)
		DebugManager:Start()
	end

	-- Reduce render quality to optimize performance
    local renderSteppedConnection = nil
    renderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if renderSteppedConnection then
            renderSteppedConnection:Disconnect()
        end
        settings().Rendering.QualityLevel = 1
    end)

	if FFlagLuaAppUseRedirectedRodux then
		roduxStore = roduxStore or Rodux.Store.new(AppReducer, nil, { Rodux.thunkMiddleware })
	else
		roduxStore = roduxStore or Rodux.Store.new(AppReducer)
	end

	-- Device has to be called before AppState is constructed because constructor for
	-- ScreenManager needs to know device type/orientation. ScreenManager is bound to
	-- AppState since Views in LuaChat needs to access it directly for GetCurrentView().
	Device.simulatePlatformIfInStudio(roduxStore)

	self._appState = AppState.new(CoreGui, roduxStore)
	self._chatRunning = false
	self._gameShareRunning = false

	PerformanceTesting:Initialize(self._appState)

	RobloxEventReceiver:init(roduxStore)
	self._notificationBroadcaster = NotificationBroadcaster.new(roduxStore)

	do
		self._screenGui = Instance.new("ScreenGui")
		self._screenGui.DisplayOrder = 9
		self._screenGui.Parent = CoreGui
		self._alertView = Alert.new(self._appState)
		self._alertView.rbx.Parent = self._screenGui
		self._alertView.rbx.Name = "AlertView"
		self._toastView = ToastView.new(self._appState)
		self._toastView.rbx.Parent = self._screenGui
		self._toastView.rbx.Name = "ToastView"
	end

	-- Connection for dealing with the Android native back button
	self.backButtonConnection = nil
	self.onBackButtonPressed = function()
		if #self._appState.store:getState().ChatAppReducer.Location.history > 1 then
			self._appState.store:dispatch(PopRoute())
		else
			GuiService:BroadcastNotification("", NotificationType.BACK_BUTTON_NOT_CONSUMED)
		end
	end

	return self
end

function ChatMaster:SetAppPolicy(appPolicy)
	self._appState.AppPolicy = appPolicy
end

function ChatMaster:Start(startType, parameters)
	if not startType then
		startType = ChatMaster.Type.Default
	end

	--pcall since tests run at a lower security context
	pcall(function()
		RunService:setThrottleFramerateEnabled(Config.General.PerformanceTestingMode == Enum.VirtualInputMode.None)
		if not FFlagLuaChatKeep3DRenderingEnabled then
			RunService:Set3dRenderingEnabled(false)
		end
		self.backButtonConnection = GuiService.ShowLeaveConfirmation:Connect(self.onBackButtonPressed)
	end)

	self._appState.store:dispatch(ToggleChatPaused(false))

	if startType == ChatMaster.Type.Default then
		-- We assumed bottom bar is always visible when we start Chat,
		-- but when lua bottom bar is enabled, this is not always true.
		local curState = self._appState.store:getState()
		if IsLuaBottomBarEnabled and curState.FormFactor == FormFactor.WIDE then
			self._appState.store:dispatch(SetTabBarVisibleFromChat(true))
		end

		if FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults then
			-- When we tap on the Chat tab, we need to check if we
			-- have already fetched chat data.

			-- For some users, we may not preload chat data from
			-- our prefetch operations if the user is not deemed
			-- an "active" chat user.
			if not curState.ChatAppReducer.AppLoaded then
				local chatSettingsRetrievalStatus = curState.ChatAppReducer.ChatSettings.retrievalStatus
				if chatSettingsRetrievalStatus ~= RetrievalStatus.Fetching then
					self._appState.store:dispatch(FetchChatData())
				end
			end
		end

		if not next(self._appState.store:getState().ChatAppReducer.Location.current) then
			self._appState.store:dispatch(SetRoute(Intent.ConversationHub, {}))
		end
		self._chatRunning = true

	elseif startType == ChatMaster.Type.GameShare then

		self._appState.store:dispatch(SetRoute(Intent.GameShare, parameters))
		self._gameShareRunning = true
	end
end

function ChatMaster:Stop(stopType)
	if not stopType then
		stopType = ChatMaster.Type.Default
	end

	if stopType == ChatMaster.Type.Default and self._gameShareRunning then
		warn('cannot stop chat while share game to chat is running')
		return
	end

	if stopType == ChatMaster.Type.GameShare and self._chatRunning then
		warn('cannot stop share game to chat while chat is running')
		return
	end

	PerformanceTesting:Stop()

	self._chatRunning = false
	self._gameShareRunning = false

	--pcall since tests run at a lower security context
	pcall(function()
		RunService:setThrottleFramerateEnabled(false)
		if not FFlagLuaChatKeep3DRenderingEnabled then
			RunService:Set3dRenderingEnabled(true)
		end
	end)

	if self.backButtonConnection ~= nil then
		self.backButtonConnection:Disconnect()
	end

	self._appState.store:dispatch(ToggleChatPaused(true))
end

function ChatMaster:Destruct()
	-- Doesn't Destruct AppState since the store could be still used elsewhere.
	self._screenGui:Destroy()
	self._notificationBroadcaster:Destruct()
end

return ChatMaster
