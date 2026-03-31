local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local AlertWindow = require(Modules.LuaApp.Components.AlertWindow)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)

local ConfirmSignOut = Roact.PureComponent:extend("ConfirmSignOut")

function ConfirmSignOut:render()
	local theme = self.props.theme
	local containerWidth = self.props.containerWidth
	local closeAlert = self.props.closeAlert
	local continue = self.props.continueFunc
	local localization = self.props.localization

	self._context.AppTheme = theme

	return Roact.createElement(AlertWindow, {
		theme = theme,
		containerWidth = containerWidth,
		titleText = localization:Format("Application.Logout.Title.Logout"),
		titleFont = theme.AlertWindow.Title.Font,
		messageText = localization:Format("Application.Logout.Message.Confirmation"),
		messageFont = theme.AlertWindow.Title.Font,
		buttonFont = theme.AlertWindow.Button.Font,
		confirmButtonText = localization:Format("Application.Logout.Action.Logout"),
		onConfirm = continue,
		isConfirming = false,
		hasCancelButton = true,
		onCancel = closeAlert,
	})
end

ConfirmSignOut = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			closeAlert = function()
				return dispatch(CloseCentralOverlay())
			end,
		}
	end
)(ConfirmSignOut)

ConfirmSignOut = RoactServices.connect({
	localization = RoactLocalization,
})(ConfirmSignOut)

return ConfirmSignOut