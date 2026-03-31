local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)

local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local LoadingBar = require(Modules.LuaApp.Components.LoadingBar)
local AppPage = require(Modules.LuaApp.AppPage)

local Constants = require(Modules.LuaApp.Constants)
local FetchAccountSettings = require(Modules.LuaApp.Thunks.Authentication.FetchAccountSettings)
local LaunchAppParallel = require(Modules.LuaApp.Thunks.Authentication.LaunchAppParallel)
local LaunchApp = require(Modules.LuaApp.Thunks.Authentication.LaunchApp)
local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

local StartupPage = Roact.PureComponent:extend("StartupPage")

function StartupPage:didMount()
	-- TODO remove this dependency on the entire appPolicy object
	local appPolicy = self.props.appPolicy
	if FlagSettings.EnableLuaAppLoginPageForUniversalAppDev() then
		if self.props.authStatus == LoginStatus.UNKNOWN then
			if FlagSettings.EnableLuaAppParallelLoginDev() then
				self.props.launchAppParallel(self.props.networking)
			else
				self.props.launchApp(self.props.networking)
			end
		end
	else
		self.props.fetchAccountSettings(self.props.networking, self.props.analytics, appPolicy)
	end
end

function StartupPage:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Constants.Color.GRAY4,
		ZIndex = 1,
	}, {
		LoadingBar = Roact.createElement(LoadingBar),
	})
end

function StartupPage:didUpdate(previousProps, previousState)
	local currentPageName = self.props.currentPageName
	local previousPageName = previousProps.currentPageName

	if currentPageName == AppPage.Startup and previousPageName == AppPage.LoginNative then
		self.props.launchApp(self.props.networking)
	end
end

StartupPage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]

		return {
			authStatus = state.Authentication.status,
			currentPageName = currentRoute[#currentRoute].name,
		}
	end,
	function(dispatch)
		return {
			fetchAccountSettings = function(networking, analytics, appPolicy)
				dispatch(FetchAccountSettings(networking, analytics, appPolicy))
			end,
			launchAppParallel = function(networking)
				dispatch(LaunchAppParallel(networking))
			end,
			launchApp = function(networking)
				dispatch(LaunchApp(networking))
			end
		}
	end
)(StartupPage)

StartupPage = RoactServices.connect({
	networking = RoactNetworking,
	analytics = RoactAnalytics,
})(StartupPage)

if FFlagLuaAppPolicyRoactConnector then
	StartupPage = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			appPolicy = appPolicy,
		}
	end)(StartupPage)
else
	StartupPage = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			appPolicy = appPolicy,
		}
	end)(StartupPage)
end

return StartupPage
