local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local AlertWindow = require(Modules.LuaApp.Components.AlertWindow)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)

local LeaveRobloxAlert = Roact.PureComponent:extend("LeaveRobloxAlert")

function LeaveRobloxAlert:render()
	local theme = self.props.theme
	local containerWidth = self.props.containerWidth
	local closeAlert = self.props.closeAlert
	local continue = self.props.continueFunc
	local localization = self.props.localization

	-- Set theme for all child Components
	-- TODO: MOBLUAPP-1298 Remove all theme pass-throughs when theme is unified globally
	self._context.AppTheme = theme

	return Roact.createElement(AlertWindow, {
		theme = theme,
		containerWidth = containerWidth,
		titleText = localization:Format("Feature.GameDetails.Message.LeaveRobloxInquiry"),
		titleFont = theme.GameDetails.Text.BoldFont,
		messageText = localization:Format("Feature.GameDetails.Message.LeaveRobloxForAnotherSite"),
		messageFont = theme.GameDetails.Text.Font,
		buttonFont = theme.GameDetails.Text.Font,
		confirmButtonText = localization:Format("Feature.GameDetails.Action.Continue"),
		onConfirm = continue,
		isConfirming = false,
		hasCancelButton = true,
		onCancel = closeAlert,
	})
end

LeaveRobloxAlert = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			closeAlert = function()
				return dispatch(CloseCentralOverlay())
			end,
		}
	end
)(LeaveRobloxAlert)

LeaveRobloxAlert = RoactServices.connect({
	localization = RoactLocalization,
})(LeaveRobloxAlert)

return LeaveRobloxAlert
