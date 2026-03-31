local BrowserService = game:GetService("BrowserService")
local HttpService = game:GetService("HttpService")

local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Constants = require(Modules.LuaApp.Constants)
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)

local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local LoadingBar = require(Modules.LuaApp.Components.LoadingBar)
local FitImageTextButton = require(Modules.LuaApp.Components.FitImageTextButton)
local FetchAccountSettings = require(Modules.LuaApp.Thunks.Authentication.FetchAccountSettings)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

local ROUNDED_BUTTON = "LuaApp/buttons/buttonFill"

local WeChatLoginWrapper = Roact.PureComponent:extend("WeChatLoginWrapper")

function WeChatLoginWrapper:init()
	self.state = {
		showingBrowser = true,
		hasAuthenticated = false,
	}
	self.openWWWLogin = function()
		BrowserService:OpenWeChatAuthWindow()
		self:setState({
			showingBrowser = true,
		})
	end
	self.onBrowserWindowClosed = function()
		self:setState({
			showingBrowser = false,
		})
	end
	self.onAuthTokenUpdated = function()
		-- TODO remove this dependency on the entire appPolicy object
		local appPolicy = self.props.appPolicy
		self.props.fetchAccountSettings(self.props.networking, self.props.analytics, appPolicy)
	end
	self.onJavascriptCallback = function(value)
		local data = HttpService:JSONDecode(value)
		if data.moduleID ~= "Navigation" then
			return
		end
		if data.functionName ~= "navigateToFeature" then
			return
		end
		local feature = data.params.params.feature;
		if feature == "login" or feature == "signUp" then
			BrowserService:CopyAuthCookieFromBrowserToEngine()
			BrowserService:CloseBrowserWindow()
			spawn(function()
				self:setState({
					hasAuthenticated = true,
				})
			end)
		end
	end
end

function WeChatLoginWrapper:didMount()
	BrowserService:OpenWeChatAuthWindow()
end

function WeChatLoginWrapper:render()
	local theme = self._context.AppTheme
	local localization = self.props.localization

	local children = {
		BrowserWindowClosedConnection = Roact.createElement(ExternalEventConnection, {
			event = BrowserService.BrowserWindowClosed,
			callback = self.onBrowserWindowClosed,
		}),
		AuthCookieCopiedToEngineConnection = Roact.createElement(ExternalEventConnection, {
			event = BrowserService.AuthCookieCopiedToEngine,
			callback = self.onAuthTokenUpdated,
		}),
		JavaScriptCallbackConnection = Roact.createElement(ExternalEventConnection, {
			event = BrowserService.JavaScriptCallback,
			callback = self.onJavascriptCallback,
		}),
	}
	if self.state.showingBrowser or self.state.hasAuthenticated then
		children["LoadingBar"] = Roact.createElement(LoadingBar)
	else
		children["LoginButton"] = Roact.createElement(FitImageTextButton, {
			backgroundColor = theme.Authentication.WeChatButton.Background.Color,
			backgroundImage = ROUNDED_BUTTON,
			sliceCenter = Rect.new(8, 8, 9, 9),
			maxWidth = 200,
			minWidth = 50,
			anchorPoint = Vector2.new(0.5, 0.5),
			position = UDim2.new(0.5, 0, 0.5, 0),
			horizontalPadding = 30,
			verticalPadding = 9,
			iconRightPadding = 5,
			text = localization:Format("Authentication.Login.Action.WeChatLogin"),
			textColor = theme.Authentication.WeChatButton.Text.Color,
			textFont = theme.Authentication.WeChatButton.Text.Font,
			textSize = theme.Authentication.WeChatButton.Text.Size,
			onActivated = self.openWWWLogin,
		})
	end
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Constants.Color.GRAY4,
		ZIndex = 1,
	}, children)
end

WeChatLoginWrapper = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {}
	end,
	function(dispatch)
		return {
			fetchAccountSettings = function(networking, analytics, appPolicy)
				dispatch(FetchAccountSettings(networking, analytics, appPolicy))
			end,
		}
	end
)(WeChatLoginWrapper)

WeChatLoginWrapper = RoactServices.connect({
	networking = RoactNetworking,
	analytics = RoactAnalytics,
	localization = RoactLocalization,
})(WeChatLoginWrapper)

if FFlagLuaAppPolicyRoactConnector then
	WeChatLoginWrapper = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			appPolicy = appPolicy,
		}
	end)(WeChatLoginWrapper)
else
	WeChatLoginWrapper = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			appPolicy = appPolicy,
		}
	end)(WeChatLoginWrapper)
end

return WeChatLoginWrapper
