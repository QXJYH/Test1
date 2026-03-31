--[[
	Unit testing components tends to require a lot of boilerplate,
	use this to easily hook up RoactServices with all the appropriate pieces.

	Any component that uses analytics, makes networking calls, or has localized children should use this in tests.
]]

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Rodux = require(CorePackages.Rodux)
local RoactRodux = require(CorePackages.RoactRodux)
local Analytics = require(Modules.Common.Analytics)
local AppReducer = require(Modules.LuaApp.AppReducer)
local Localization = require(Modules.LuaApp.Localization)
local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local AppRunService = require(Modules.LuaApp.Services.AppRunService)
local MockGuiService = require(Modules.LuaApp.TestHelpers.MockGuiService)
local MockRunService = require(Modules.LuaApp.TestHelpers.MockRunService)
local RoactServices = require(Modules.LuaApp.RoactServices)
local ThemeProvider = require(Modules.LuaApp.ThemeProvider)
local StyleProvider = require(CorePackages.AppTempCommon.LuaApp.Style.AppStyleProvider)
local StyleConstants = require(CorePackages.AppTempCommon.LuaApp.Style.Constants)
local AppPolicyProvider = require(Modules.LuaApp.AppPolicyProvider)
local LocalizationProvider = require(Modules.LuaApp.LocalizationProvider)
local ClassicTheme = require(Modules.LuaApp.Themes.ClassicTheme)
local DefaultPolicy = require(Modules.LuaApp.Policies.DefaultPolicy)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local AppNotificationService = require(Modules.LuaApp.Services.AppNotificationService)
local MockNotificationService = require(Modules.LuaApp.TestHelpers.MockNotificationService)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

-- mockServices() : provides a test heirarchy for rendering a component that requires services
-- componentMap : (map<string, Roact.Component>) a map of elements to test render
-- extraArgs : (table, optional)
--   includeStoreProvider : (bool) when true, adds a StoreProvider in the heirarchy
--   store : (map<string, table>) a populated table of data from a reducer to include with the StoreProvider
--   includeStyleProvider : (bool) when true, adds a StyleProvider in the heirarchy
--   includeThemeProvider : (bool) when true, adds a ThemeProvider in the heirarchy
--   theme : (table) a specific theme to use (classic, dark, light, and etc). Defaults to Classic.
--   includeAppPolicyProvider : (bool) when true, adds an AppPolicyProvider in the hierarhcy
--   appPolicy : (table) a specific app policy to use. Defaults to DefaultPolicy.
--   includeLocalizationProvider : (bool) when true, adds a LocalizationProvider in the heirarchy
--   extraServices : (map<table, value>) a map of services as keys that will be added to the services prop
local function mockServices(componentMap, extraArgs)
	assert(componentMap, "Expected a map of components, recieved none")

	local includeStoreProvider = false
	local includeStyleProvider = true
	local includeThemeProvider = true
	local includeAppPolicyProvider = false
	local includeLocalizationProvider = true
	local store = nil
	local initialStoreState = nil
	local theme = ClassicTheme
	local themeName = "Classic"
	local appStyle = {
		themeName = StyleConstants.ThemeName.Dark,
		fontName = StyleConstants.FontName.Gotham,
	}
	local appPolicy = DefaultPolicy
	local localization = Localization.mock()
	local fakeServiceProps = {
		services = {
			[RoactAnalytics] = Analytics.mock(),
			[RoactLocalization] = Localization.mock(),
			[RoactNetworking] = MockRequest.simpleSuccessRequest("{}"),
			[AppNotificationService] = MockNotificationService.new(),
			[AppGuiService] = MockGuiService.new(),
			[AppRunService] = MockRunService.new(),
		}
	}

	if extraArgs then
		if extraArgs["includeStoreProvider"] ~= nil then
			includeStoreProvider = extraArgs["includeStoreProvider"]
			assert(type(includeStoreProvider) == "boolean", "Expected includeStoreProvider to be a bool")
		end

		if extraArgs["store"] ~= nil then
			store = extraArgs["store"]
			assert(type(store) == "table", "Expected store to be a table")
		end

		if extraArgs["initialStoreState"] ~= nil then
			initialStoreState = extraArgs["initialStoreState"]
			assert(type(initialStoreState) == "table", "Expected initialStoreState to be a table")
		end

		if extraArgs["includeStyleProvider"] ~= nil then
			includeStyleProvider = extraArgs["includeStyleProvider"]
			assert(type(includeStyleProvider) == "boolean", "Expected includeStyleProvider to be a bool")
		end

		if extraArgs["includeThemeProvider"] ~= nil then
			includeThemeProvider = extraArgs["includeThemeProvider"]
			assert(type(includeThemeProvider) == "boolean", "Expected includeThemeProvider to be a bool")
		end

		if extraArgs["includeAppPolicyProvider"] ~= nil then
			includeAppPolicyProvider = extraArgs["includeAppPolicyProvider"]
			assert(type(includeAppPolicyProvider) == "boolean", "Expected includeAppPolicyProvider to be a bool")
		end

		if extraArgs["includeLocalizationProvider"] ~= nil then
			includeLocalizationProvider = extraArgs["includeLocalizationProvider"]
			assert(type(includeLocalizationProvider) == "boolean", "Expected includeLocalizationProvider to be a bool")
		end

		if extraArgs["theme"] ~= nil then
			theme = extraArgs["theme"]
			assert(type(theme) == "table", "Expected theme to be a table")
		end

		if extraArgs["appPolicy"] ~= nil then
			appPolicy = extraArgs["appPolicy"]
			assert(type(appPolicy) == "table", "Expected appPolicy to be a table")
		end

		if extraArgs["themeName"] ~= nil then
			themeName = extraArgs["themeName"]
			assert(type(themeName) == "string", "Expected themeName to be a string")
		end

		if extraArgs["appStyle"] ~= nil then
			appStyle = extraArgs["appStyle"]
			assert(type(appStyle) == "table", "Expected appStyle to be a table")
		end

		if extraArgs["localization"] ~= nil then
			localization = extraArgs["localization"]
			assert(type(localization) == "table", "Expected localization to be a table")
		end

		if extraArgs["extraServices"] ~= nil then
			local extraServices = extraArgs["extraServices"]
			assert(type(extraServices) == "table", "Expected extraServices to be a table")
			for service, value in pairs(extraServices) do
				assert(type(service) == "table", "Expected key to be a table")
				fakeServiceProps.services[service] = value
			end
		end
	end

	local root = componentMap

	if includeAppPolicyProvider then
		if FFlagLuaAppPolicyRoactConnector then
			root = {
				AppPolicyProvider = Roact.createElement(RoactAppPolicy.Provider, {
					policy = appPolicy,
				}, root)
			}
		else
			root = {
				AppPolicyProvider = Roact.createElement(AppPolicyProvider, {
					policy = appPolicy,
					params = {
						userInfo = {
							under13 = false
						},
					}
				}, root)
			}
		end
	end

	if initialStoreState then
		store = Rodux.Store.new(AppReducer, initialStoreState, { Rodux.thunkMiddleware })
	else
		-- TODO: CLILUACORE-472 - be explicit about how store is created and set
		if store then
			if getmetatable(store) == nil then
				-- pass through the table as initialState
				store = Rodux.Store.new(AppReducer, store, { Rodux.thunkMiddleware })
			end
		else
			store = Rodux.Store.new(AppReducer, nil, { Rodux.thunkMiddleware })
		end
	end

	if includeStoreProvider or includeAppPolicyProvider then
		root = {
			StoreProvider = Roact.createElement(RoactRodux.StoreProvider, {
				store = store,
			}, root)
		}
	end

	if includeThemeProvider then
		root = {
			ThemeProvider = Roact.createElement(ThemeProvider, {
				theme = theme,
				themeName = themeName
			}, root)
		}
	end

	if includeStyleProvider then
		root = {
			StyleProvider = Roact.createElement(StyleProvider, {
				style = appStyle,
			}, root)
		}
	end

	if includeLocalizationProvider then
		root = {
			LocalizationProvider = Roact.createElement(LocalizationProvider, {
				localization = localization,
			}, root)
		}
	end

	root = Roact.createElement(RoactServices.ServiceProvider,
		fakeServiceProps,
		root)

	return root
end


return mockServices
