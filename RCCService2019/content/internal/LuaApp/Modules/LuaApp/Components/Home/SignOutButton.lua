local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local IconTextBar = require(Modules.LuaApp.Components.Generic.IconTextBar)
local FitChildren = require(Modules.LuaApp.FitChildren)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)

local Logout = require(Modules.LuaApp.Thunks.Authentication.Logout)
local OpenCentralOverlayForConfirmSignOut = require(Modules.LuaApp.Thunks.OpenCentralOverlayForConfirmSignOut)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local AppPage = require(Modules.LuaApp.AppPage)

local LOGOUT_ICON_IMAGE = "LuaApp/icons/logout"
local LOGOUT_TEXT_KEY = "Application.Logout.Action.Logout"

local LOGOUT_ICON_SIZE = Constants.HomePagePanelProps.WidgetIconSize
local LOGOUT_ICON_TEXT_GUTTER = Constants.HomePagePanelProps.WidgetIconTextGutter
local LOGOUT_TEXT_SIZE = Constants.HomePagePanelProps.WidgetTextSize

local PADDING = {
	PaddingTop = UDim.new(0, 20),
	PaddingBottom = UDim.new(0, 30),
	PaddingLeft = UDim.new(0, 20),
	PaddingRight = UDim.new(0, 20),
}

local FFlagEnablePopupDataModelFocusedEvents = settings():GetFFlag("EnablePopupDataModelFocusedEvents")

local SignOutButton = Roact.PureComponent:extend("SignOutButton")

SignOutButton.defaultProps = {
	iconSize = LOGOUT_ICON_SIZE,
	gutterSize = LOGOUT_ICON_TEXT_GUTTER,
	textSize = LOGOUT_TEXT_SIZE,
}

function SignOutButton:render()
	local theme = self._context.AppTheme
	local iconSize = self.props.iconSize
	local gutterSize = self.props.gutterSize
	local textSize = self.props.textSize

	return Roact.createElement(FitChildren.FitImageButton, {
		Size = UDim2.new(1, 0, 0, 0),
		fitAxis = FitChildren.FitAxis.Height,
		ImageTransparency = 1,
		BackgroundTransparency = 1,
		[Roact.Event.Activated] = function()
			if FlagSettings.LuaAppLoginEnabled() then
				self.props.logout(self.props.networking, self.props.guiService, theme)
			elseif FFlagEnablePopupDataModelFocusedEvents then
				self.props.openLogoutPage()
			else
				self.props.guiService:BroadcastNotification("", NotificationType.ACTION_LOG_OUT)
			end
		end,
	}, {
		SignOut = Roact.createElement(IconTextBar, {
			padding = PADDING,
			icon = LOGOUT_ICON_IMAGE,
			iconSize = iconSize,
			gutterSize = gutterSize,
			textKey = LOGOUT_TEXT_KEY,
			textSize = textSize,
			textColor = theme.Widget.Header.Text.Color,
			textFont = theme.Widget.Header.Text.Font,
		}),
	})
end

SignOutButton = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			logout = function(networkImpl, guiService, theme)
				dispatch(OpenCentralOverlayForConfirmSignOut(function()
					dispatch(Logout(networkImpl, guiService))
				end, theme))
			end,
			openLogoutPage = function()
				return dispatch(NavigateDown({
					name = AppPage.LogoutConfirmation,
				}))
			end,
		}
	end
)(SignOutButton)

SignOutButton = RoactServices.connect({
	guiService = AppGuiService,
	networking = RoactNetworking,
})(SignOutButton)

return SignOutButton
