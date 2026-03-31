local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local NotificationService = game:GetService("NotificationService")
local LocalizationService = game:GetService("LocalizationService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService('UserInputService')
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local Rodux = require(CorePackages.Rodux)
local RoactRodux = require(CorePackages.RoactRodux)

local Analytics = require(Modules.Common.Analytics)
local AppReducer = require(Modules.LuaApp.AppReducer)
local Localization = require(Modules.LuaApp.Localization)
local AppPolicyProvider = require(Modules.LuaApp.AppPolicyProvider)
local AppContainer = require(Modules.LuaApp.Components.AppContainer)
local ProviderContainer = require(Modules.LuaApp.Components.ProviderContainer)
local EventStreamUpdater = require(Modules.LuaApp.Components.EventStreamUpdater)
local AppPresence = require(Modules.LuaApp.Components.AppPresence)
local MutedErrorReporter = require(Modules.LuaApp.Components.MutedErrorReporter)
local EventReceiverLifecycleAdapter = require(Modules.LuaApp.Components.EventReceiverLifecycleAdapter)
local LocalPlayerManager = require(Modules.LuaApp.Components.LocalPlayerManager)
local ViewportManager = require(Modules.LuaApp.Components.ViewportManager)
local FrameRateManager = require(Modules.LuaApp.Components.FrameRateManager)
local LocaleManager = require(Modules.LuaApp.Components.LocaleManager)
local LocalStorageListener = require(Modules.LuaApp.Components.LocalStorageListener)

local LocalizationProvider = require(Modules.LuaApp.LocalizationProvider)
local StyleProvider = require(CorePackages.AppTempCommon.LuaApp.Style.AppStyleProvider)
----NOTE: remove the following when FFlagLuaAppEnableStyleProvider is removed
local ThemeProvider = require(Modules.LuaApp.ThemeProvider)
local ClassicTheme = require(Modules.LuaApp.Themes.ClassicTheme)
local DarkTheme = require(Modules.LuaApp.Themes.DeprecatedDarkTheme)
----

local RobloxEventReceiver = require(Modules.LuaApp.RobloxEventReceiver)
local BadgeEventReceiver = require(Modules.LuaApp.Components.EventReceivers.BadgeEventReceiver)
local RobuxEventReceiver = require(Modules.LuaApp.Components.EventReceivers.RobuxEventReceiver)
local FriendshipEventReceiver = require(Modules.LuaApp.Components.EventReceivers.FriendshipEventReceiver)
local NavigationEventReceiver = require(Modules.LuaApp.Components.EventReceivers.NavigationEventReceiver)
local AvatarEditorEventReceiver = require(Modules.LuaApp.Components.EventReceivers.AvatarEditorEventReceiver)
local AntiAddictionEventReceiver = require(Modules.LuaApp.Components.EventReceivers.AntiAddictionEventReceiver)
local ThemeChangeEventReceiver = require(Modules.LuaApp.Components.EventReceivers.ThemeChangeEventReceiver)

local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local AppNotificationService = require(Modules.LuaApp.Services.AppNotificationService)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local AppRunService = require(Modules.LuaApp.Services.AppRunService)
local AppUserInputService = require(Modules.LuaApp.Services.AppUserInputService)
local requestService = require(Modules.LuaApp.Http.request)

local ChinaLicensingBuildPolicy = require(Modules.LuaApp.Policies.ChinaLicensingBuildPolicy)
local DefaultPolicy = require(Modules.LuaApp.Policies.DefaultPolicy)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagChinaLicensingApp = settings():GetFFlag("ChinaLicensingApp")
local analyticsReleasePeriod = tonumber(settings():GetFVariable("LuaAnalyticsReleasePeriod"))
local appPresencePollingInterval = FlagSettings.LuaAppPresencePollingIntervalInSeconds()
local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")
local useNewAppStyle = FlagSettings.UseNewAppStyle()


-- NOTE: UniversalApp is the top-level component that hosts all of our application code.
-- It is intended to be declarative. Please avoid adding arbitrary logic directly in this file.
-- If you need to tie something into App lifecycle, make a new event receiver/listener/etc and
-- then reference it in this file instead of burying the logic here.
local UniversalApp = Roact.Component:extend("UniversalApp")

function UniversalApp:init()
	self._store = Rodux.Store.new(AppReducer, nil, { Rodux.thunkMiddleware })
	self._analytics = Analytics.new()
	self._localization = Localization.new(LocalizationService.RobloxLocaleId)
	self._robloxEventReceiver = RobloxEventReceiver.new(NotificationService)
end

function UniversalApp:render()
	local appName = self.props.appName
	-- This logic looks complicated, becase FFlagChinaLicensingApp controls too much,
	-- we need it on to load universal app.
	local policyData = (FFlagChinaLicensingApp and not FlagSettings.EnableLuaAppLoginPageForUniversalAppDev()) and
		ChinaLicensingBuildPolicy or DefaultPolicy
	local selectedTheme = (FFlagChinaLicensingApp and not FlagSettings.EnableLuaAppLoginPageForUniversalAppDev()) and
		DarkTheme or ClassicTheme
	local selectedThemeName = FFlagChinaLicensingApp and "dark" or ( useNewAppStyle and NotificationService.SelectedTheme or nil )

	local providers = {}

	table.insert(providers, {
		class = RoactRodux.StoreProvider,
		props = {
			store = self._store,
		},
	})

	if FFlagLuaAppPolicyRoactConnector then
		table.insert(providers, {
			class = RoactAppPolicy.Provider,
			props = {
				policy = policyData,
			},
		})
	else
		table.insert(providers, {
			class = AppPolicyProvider,
			props = {
				policy = policyData,
				params = {
					userInfo = {
						under13 = Players.LocalPlayer and Players.LocalPlayer:GetUnder13() or nil,
					},
				},
			},
		})
	end

	table.insert(providers, {
		class = RoactServices.ServiceProvider,
		props = {
			services = {
				[RoactAnalytics] = self._analytics,
				-- Remove RoactLocalization when migration to LocalizationProvider is done
				[RoactLocalization] = self._localization,
				[RoactNetworking] = requestService,
				[AppNotificationService] = NotificationService,
				[AppGuiService] = GuiService,
				[AppRunService] = RunService,
				[AppUserInputService] = UserInputService,
			},
		},
	})

	if useNewAppStyle then
		local appStyle = {
			themeName = selectedThemeName,
			--Need a way to change fonts. This will be hardcoded for now.
			fontName = "gotham",
		}
		table.insert(providers, {
			class = StyleProvider,
			props = {
				style = appStyle,
			},
		})
	end

	table.insert(providers, {
		class = ThemeProvider,
		props = {
			theme = selectedTheme,
			themeName = selectedThemeName,
		},
	})

	table.insert(providers, {
		class = LocalizationProvider,
		props = {
			localization = self._localization,
		},
	})

	return Roact.createElement(ProviderContainer, {
		providers = providers,
	}, {
		EventReceivers = Roact.createElement(EventReceiverLifecycleAdapter, {
			RobloxEventReceiver = self._robloxEventReceiver,
			receiverComponents = {
				NavigationEventReceiver,
				BadgeEventReceiver,
				RobuxEventReceiver,
				FriendshipEventReceiver,
				AvatarEditorEventReceiver,
				AntiAddictionEventReceiver, --NOTE: The anti addiction event is behind CLB flag on the C++ side. Should not affact the normal App.
				ThemeChangeEventReceiver,
			},
		}),
		LocalPlayerManager = Roact.createElement(LocalPlayerManager),
		ViewportManager = Roact.createElement(ViewportManager),
		FrameRateManager = Roact.createElement(FrameRateManager),
		LocaleManager = Roact.createElement(LocaleManager, {
			localization = self._localization,
		}),
		EventStreamUpdater = Roact.createElement(EventStreamUpdater, {
			releasePeriod = analyticsReleasePeriod,
		}),
		LocalStorageListener = FlagSettings:EnableLuaAppLoginPageForUniversalAppDev()
			and Roact.createElement(LocalStorageListener)
			or nil,
		AppPresence = appPresencePollingInterval > 0 and Roact.createElement(AppPresence) or nil,
		MutedErrorReporter = Roact.createElement(MutedErrorReporter, {
			appName = appName,
		}),

		-- AppContainer holds the visual UI of the entire application, adapted to
		-- theme and policy configurations set above.
		AppContainer = Roact.createElement(AppContainer, {
			store = self._store, -- Needs access to instance of store, not just store.state
		}),
	})
end

return UniversalApp
