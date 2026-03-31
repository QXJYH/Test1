-- Written by Kip Turner, Copyright Roblox 2015

-- App's Main
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
local Modules = RobloxGui:FindFirstChild("Modules")
local ShellModules = Modules:FindFirstChild("Shell")
local LocalizationService = game:GetService("LocalizationService")
local CorePackages = game:GetService("CorePackages")
local GuiService = game:GetService("GuiService")

-- TODO: Will use for re-auth when finished
local UserInputService = game:GetService('UserInputService')
local PlatformService = nil
pcall(function() PlatformService = game:GetService('PlatformService') end)
local ThirdPartyUserService = nil
pcall(function() ThirdPartyUserService = game:GetService('ThirdPartyUserService') end)
local Players = game:GetService("Players")

-- Start up background scene before anything else
require(ShellModules.BackgroundSceneManager)

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local Localization = require(Modules.LuaApp.Localization)
local Utility = require(ShellModules:FindFirstChild('Utility'))
local AppHubModule = require(ShellModules:FindFirstChild('AppHub'))
local ScreenManager = require(ShellModules:FindFirstChild('ScreenManager'))
local Errors = require(ShellModules:FindFirstChild('Errors'))
local ErrorOverlay = require(ShellModules:FindFirstChild('ErrorOverlay'))
local EventHub = require(ShellModules:FindFirstChild('EventHub'))
local GameGenreScreen = require(ShellModules:FindFirstChild('GameGenreScreen'))
local EngagementScreenModule = require(ShellModules:FindFirstChild('EngagementScreen'))
local BadgeScreenModule = require(ShellModules:FindFirstChild('BadgeScreen'))
local AccountScreen = require(ShellModules:FindFirstChild('AccountScreen'))
local UserData = require(ShellModules:FindFirstChild('UserData'))
local ControllerStateManager = require(ShellModules:FindFirstChild('ControllerStateManager'))
local Alerts = require(ShellModules:FindFirstChild('Alerts'))
local AEConsoleLoader = require(Modules.LuaApp.Components.Avatar.AEConsoleLoader)
local SiteInfoWidget = require(ShellModules:FindFirstChild('SiteInfoWidget'))
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local Analytics = require(Modules.Common.Analytics)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local ResetStore = require(ShellModules.Actions.ResetStore)
local GameDetailModule = require(ShellModules:FindFirstChild('GameDetailScreen'))
local AvatarEditorScreenWrapper = require(ShellModules.AvatarEditorScreenWrapper)
local AVATAR_EDITOR_ID = "AvatarEditorScreen"
local AvatarEditorRoact = nil

-- Initialize AppState and in turn initialize the Store
local AppState = require(ShellModules.AppState)

local AppContainer = require(ShellModules.AppContainer)
local TitleSafeContainer = AppContainer.TitleSafeContainer

local EngagementScreen = EngagementScreenModule()
EngagementScreen:SetParent(TitleSafeContainer)

-- Site Info View
SiteInfoWidget.new()

-- Initialzie Account Age View
require(ShellModules.Components.AccountAgeStatus).new(AppState.store, TitleSafeContainer)

-- Initialize hero stat manager
require(script.Parent.HeroStatsManager)

local function mountAvatarEditor()
	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = AppState.store,
	}, {
		services = Roact.createElement(RoactServices.ServiceProvider, {
			services = {
				[RoactLocalization] = Localization.new(LocalizationService.RobloxLocaleId),
				[RoactAnalytics] = Analytics.new(),
				[AppGuiService] = GuiService,
			}
		}, {
			Roact.createElement(AEConsoleLoader)
		}),
	})

	AvatarEditorRoact = Roact.mount(element, RobloxGui, AVATAR_EDITOR_ID)
end

local function returnToEngagementScreen()
	if ScreenManager:ContainsScreen(EngagementScreen) then
		while ScreenManager:GetTopScreen() ~= EngagementScreen do
			ScreenManager:CloseCurrent()
		end
	else
		while ScreenManager:GetTopScreen() do
			ScreenManager:CloseCurrent()
		end
		ScreenManager:OpenScreen(EngagementScreen)
	end
end

local AppHub = nil
local function onAuthenticationSuccess(isNewLinkedAccount)
	-- Set UserData
	UserData:Initialize()

	local SetRobloxUser = require(ShellModules.Actions.SetRobloxUser)
	AppState.store:dispatch(SetRobloxUser( {
		robloxName = Players.LocalPlayer.Name,
		rbxuid = Players.LocalPlayer.UserId,
		under13 = Players.LocalPlayer:GetUnder13(),
	} ))

	-- Unwind Screens if needed - this will be needed once we put in account linking
	returnToEngagementScreen()

	AppHub = AppHubModule()
	AppHub:SetParent(TitleSafeContainer)

	EventHub:addEventListener(EventHub.Notifications["OpenGameDetail"], "gameDetail",
		function(placeId)
			local gameDetail = GameDetailModule(placeId)
			gameDetail:SetParent(TitleSafeContainer);
			ScreenManager:OpenScreen(gameDetail);
		end);
	EventHub:addEventListener(EventHub.Notifications["OpenGameGenre"], "gameGenre",
		function(sortName, gameCollection)
			local gameGenre = GameGenreScreen(sortName, gameCollection)
			gameGenre:SetParent(TitleSafeContainer);
			ScreenManager:OpenScreen(gameGenre);
		end);
	EventHub:addEventListener(EventHub.Notifications["OpenBadgeScreen"], "gameBadges",
		function(badgeData, previousScreenName)
			local badgeScreen = BadgeScreenModule(badgeData, previousScreenName)
			badgeScreen:SetParent(TitleSafeContainer);
			ScreenManager:OpenScreen(badgeScreen);
		end)
	EventHub:addEventListener(EventHub.Notifications["OpenSettingsScreen"], "settingsScreen",
		function(settingsScreen)
			settingsScreen:SetParent(TitleSafeContainer);
			ScreenManager:OpenScreen(settingsScreen);
		end)

	EventHub:addEventListener(EventHub.Notifications["OpenAvatarEditorScreen"], "avatarEditorScreen",
		function(screen)
			ScreenManager:OpenScreen(AvatarEditorScreenWrapper)
		end)

	EventHub:addEventListener(EventHub.Notifications["OpenAccountSettingsScreen"], "accountSettingsScreen",
		function(errorCode)
			local accountScreen = AccountScreen(errorCode)
			accountScreen:SetParent(TitleSafeContainer);
			ScreenManager:OpenScreen(accountScreen);
		end)

	Utility.DebugLog("User and Event initialization finished. Opening AppHub")
	ScreenManager:OpenScreen(AppHub);

	if PlatformService and not PlatformService:SeenCPPWelcomeMsg() then
		ScreenManager:OpenScreen(ErrorOverlay(Alerts.CrossPlatformPlayWelcome), false)
	end

	-- Comment out for now since this has never been called in current flow
	-- show info popup to users on newly linked accounts
--	if isNewLinkedAccount == true then
--		ScreenManager:OpenScreen(ErrorOverlay(Alerts.PlatformLink), false)
--	end

	-- Mount the Roact Avatar Editor
	mountAvatarEditor()
end

local function onReAuthentication(reauthenticationReason)
	if AvatarEditorRoact then
		Roact.unmount(AvatarEditorRoact)
		AvatarEditorRoact = nil
	end

	Utility.DebugLog("Beging Reauth, cleaning things up")

	local SetRobloxUser = require(ShellModules.Actions.SetRobloxUser)
	AppState.store:dispatch(SetRobloxUser())

	local SetXboxUser = require(ShellModules.Actions.SetXboxUser)
	AppState.store:dispatch(SetXboxUser())

	-- unwind ScreenManager
	returnToEngagementScreen()

	UserData:Reset()
	AppHub = nil
	EventHub:removeEventListener(EventHub.Notifications["OpenGameDetail"], "gameDetail")
	EventHub:removeEventListener(EventHub.Notifications["OpenGameGenre"], "gameGenre")
	EventHub:removeEventListener(EventHub.Notifications["OpenBadgeScreen"], "gameBadges")
	EventHub:removeEventListener(EventHub.Notifications["OpenSettingsScreen"], "settingsScreen")
	EventHub:removeEventListener(EventHub.Notifications["OpenAvatarEditorScreen"], "avatarEditorScreen")
	EventHub:removeEventListener(EventHub.Notifications["OpenAccountSettingsScreen"], "accountSettingsScreen")

	Utility.DebugLog("Reauth complete. Return to engagement screen.")

	-- When switching accounts, reset the store and return to the engagement screen.
	AppState.store:dispatch(ResetStore())
	ScreenManager:OpenScreen(EngagementScreen)

	-- show reason overlay
	local alert = Alerts.SignOut[reauthenticationReason] or Alerts.Default

	if reauthenticationReason == 6 then
		alert = nil
	end

	if alert then
		ScreenManager:OpenScreen(ErrorOverlay(alert), false)
	end
end

local function onGameJoin(joinResult, placeId)
	-- 0 is success, anything else is an error
	local joinSuccess = joinResult == 0
	if not joinSuccess then
		local err = Errors.GameJoin[joinResult] or Errors.GameJoin.Default
		ScreenManager:OpenScreen(ErrorOverlay(err), false)
	end
	EventHub:dispatchEvent(EventHub.Notifications["GameJoin"], joinSuccess, placeId)
end

if PlatformService then
	PlatformService.GameJoined:connect(onGameJoin)
end

if ThirdPartyUserService then
	ThirdPartyUserService.ActiveUserSignedOut:connect(onReAuthentication)
end

ControllerStateManager:Initialize()

EventHub:addEventListener(EventHub.Notifications["AuthenticationSuccess"], "authUserSuccess", function(isNewLinkedAccount)
		Utility.DebugLog("User authenticated, initializing app shell")
		onAuthenticationSuccess(isNewLinkedAccount)
	end);
ScreenManager:OpenScreen(EngagementScreen)

UserInputService.MouseIconEnabled = false

return {}
