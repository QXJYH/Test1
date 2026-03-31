local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local RoactRodux = require(CorePackages.RoactRodux)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local AlertWindow = require(Modules.LuaApp.Components.AlertWindow)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)

local PremiumMigrationNotice = Roact.PureComponent:extend("PremiumMigrationNotice")

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local withLocalization = require(Modules.LuaApp.withLocalization)
local withStyle = UIBlox.Style.withStyle

PremiumMigrationNotice.defaultProps = {
	robuxGranted = 0,
}

function PremiumMigrationNotice:render()
	local containerWidth = self.props.containerWidth
	local closeAlert = self.props.closeAlert
	local robuxGranted = self.props.robuxGranted

	local function render(localizedStrings, style)
		local titleText = localizedStrings.titleText
		local messageText = localizedStrings.messageText
		local confirmButtonText = localizedStrings.confirmButtonText
		local theme = style.Theme

		return Roact.createElement(AlertWindow, {
			theme = theme,
			containerWidth = containerWidth,
			titleText = titleText,
			titleFont = style.Font.Title.Font,
			titleTextSize = 22,
			messageText = messageText,
			messageTextAlignment = Enum.TextXAlignment.Left,
			messageFont = style.Font.Title.Font,
			buttonFont = style.Font.Header1.Font,
			confirmButtonText = confirmButtonText,
			onConfirm = closeAlert,
			isConfirming = false,
			hasCancelButton = false,
		})
	end

	return withLocalization({
		titleText = "Feature.PremiumMigration.PopUp.Title",
		messageText = {"Feature.PremiumMigration.PopUp.Body", robuxAmount = robuxGranted},
		confirmButtonText = "CommonUI.Messages.Action.OK",
	})(function(localizedStrings)
		if UseNewAppStyle then
			return withStyle(function(style)
				return render(localizedStrings, style)
			end)
		else
			local theme = self._context.AppTheme

			local style = {
				Theme = theme,
				Font = {
					Title = {Font = theme.AlertWindow.Title.Font},
					Header1 = {Font = theme.AlertWindow.Button.Font},
				}
			}
			return render(localizedStrings, style)
		end
	end)
end

PremiumMigrationNotice = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			closeAlert = function()
				return dispatch(CloseCentralOverlay())
			end,
		}
	end
)(PremiumMigrationNotice)

return PremiumMigrationNotice