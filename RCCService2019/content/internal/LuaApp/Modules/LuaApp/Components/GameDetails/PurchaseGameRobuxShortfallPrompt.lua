local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local Functional = require(Modules.Common.Functional)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local AlertWindow = require(Modules.LuaApp.Components.AlertWindow)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local FFlagEnablePopupDataModelFocusedEvents = settings():GetFFlag("EnablePopupDataModelFocusedEvents")

local PurchaseGameRobuxShortfallPrompt = Roact.PureComponent:extend("PurchaseGameRobuxShortfallPrompt")

function PurchaseGameRobuxShortfallPrompt:init()
	self.buyRobux = function()
		local closePrompt = self.props.closePrompt
		local guiService = self.props.guiService

		if FFlagEnablePopupDataModelFocusedEvents then
			closePrompt()
			self.props.openPurchaseRobuxPage()
		else
			guiService:BroadcastNotification("", NotificationType.PURCHASE_ROBUX)
			closePrompt()
		end
	end
end

function PurchaseGameRobuxShortfallPrompt:didMount()
	-- TODO: MOBLUAPP-1098 After router-side fix is done, please REMOVE this temporary fix.
	local pageFilter = self.props.pageFilter
	local currentPage = self.props.currentPage
	local closePrompt = self.props.closePrompt
	if pageFilter and not Functional.Find(pageFilter, currentPage) then
		closePrompt()
	end
end

function PurchaseGameRobuxShortfallPrompt:render()
	local theme = self.props.theme
	local containerWidth = self.props.containerWidth
	local robuxShortfall = self.props.robuxShortfall
	local closePrompt = self.props.closePrompt
	local localization = self.props.localization
	local gameName = self.props.gameName

	-- Set theme for all child Components
	-- TODO: MOBLUAPP-1298 Remove all theme pass-throughs when theme is unified globally
	self._context.AppTheme = theme

	return Roact.createElement(AlertWindow, {
		theme = theme,
		containerWidth = containerWidth,
		titleText = localization:Format("Feature.GameDetails.Heading.PurchaseGame"),
		titleFont = theme.GameDetails.Text.BoldFont,
		messageText = localization:Format("Feature.GameDetails.Message.BuyMoreRobuxToPurchaseGame", {
			gameName = gameName,
			shortfallPrice = robuxShortfall,
		}),
		messageFont = theme.GameDetails.Text.Font,
		buttonFont = theme.GameDetails.Text.Font,
		confirmButtonText = localization:Format("Feature.GameDetails.Action.BuyRobux"),
		onConfirm = self.buyRobux,
		hasCancelButton = true,
		onCancel = closePrompt,
	})
end

PurchaseGameRobuxShortfallPrompt = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		return {
			currentPage = currentRoute[#currentRoute].name,
		}
	end,
	function(dispatch)
		return {
			closePrompt = function()
				dispatch(CloseCentralOverlay())
			end,
			openPurchaseRobuxPage = function()
				return dispatch(NavigateDown({
					name = AppPage.PurchaseRobux,
				}))
			end,
		}
	end
)(PurchaseGameRobuxShortfallPrompt)

PurchaseGameRobuxShortfallPrompt = RoactServices.connect({
	localization = RoactLocalization,
	guiService = AppGuiService,
})(PurchaseGameRobuxShortfallPrompt)

return PurchaseGameRobuxShortfallPrompt
