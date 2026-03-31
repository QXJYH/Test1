local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FFlagLuaNavigationLockRefactor = FlagSettings.UseLuaNavigationLockRefactor()

local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateToRoute = require(Modules.LuaApp.Thunks.NavigateToRoute)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local NavigateBack = require(Modules.LuaApp.Thunks.NavigateBack)
local NavigateBackFromNativePageWrapper = require(Modules.LuaApp.Thunks.NavigateBackFromNativePageWrapper)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)

local NavigationEventReceiver = Roact.Component:extend("NavigationEventReceiver")

function NavigationEventReceiver:handleBackButtonPressed()
	local currentPage = self.props.currentRoute[1].name
	local centralOverlayType = self.props.centralOverlayType
	local closeCentralOverlay = self.props.closeCentralOverlay

	-- Currently, LuaChat has its own handler for
	-- the BackButtonPressed event, and it sends BACK_BUTTON_NOT_CONSUMED.
	-- To avoid sending the notification multiple times, we need to check if
	-- we're on the Chat page.
	-- TODO: we should remove this code, along with Chat's code for
	-- connecting with the back button signal, once it uses our AppRouter.
	-- Related ticket: MOBLUAPP-631
	if currentPage == AppPage.Chat then
		return
	end

	-- close Central Overlay if it exists
	if centralOverlayType then
		closeCentralOverlay()
		return
	end

	if #self.props.currentRoute > 1 then
		self.props.navigateBack()
	else
		GuiService:BroadcastNotification("", NotificationType.BACK_BUTTON_NOT_CONSUMED)
	end
end

function NavigationEventReceiver:init()
	local robloxEventReceiver = self.props.RobloxEventReceiver

	self.tokens = {
		robloxEventReceiver:observeEvent("Navigations", function(detail, detailType)
			if detailType == "Destination" or detailType == "Reload" then
				if detail.appName == AppPage.ShareGameToChat then
					self.props.navigateDown({
						name = AppPage.ShareGameToChat,
						detail = detail.parameters.placeId,
					})
				elseif detail.appName == AppPage.Chat then
					self.props.setPage({
						name = AppPage.Chat,
						detail = detail.parameters and detail.parameters.conversationId,
					})
				else
					self.props.setPage({
						name = AppPage[detail.appName] or AppPage.None,
					})
				end
			end
		end),
		GuiService.ShowLeaveConfirmation:Connect(function()
			self:handleBackButtonPressed()
		end),
		robloxEventReceiver:observeEvent("AppInput", function(detail, detailType)
			if detailType == "Focused" then
				self.props.navigateBackFromNativePageWrapper()
			end
		end),
	}
end

function NavigationEventReceiver:render()
end

function NavigationEventReceiver:willUnmount()
	for _, connection in pairs(self.tokens) do
		connection:disconnect()
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			currentRoute = state.Navigation.history[#state.Navigation.history],
			centralOverlayType = state.CentralOverlay.OverlayType,
		}
	end,
	function(dispatch)
		return {
			setPage = function(page)
				-- Native navigation events bypass AppRouter navigation lock because of async timing.
				return dispatch(NavigateToRoute({ page }, FFlagLuaNavigationLockRefactor and true or nil))
			end,
			navigateDown = function(page)
				return dispatch(NavigateDown(page, FFlagLuaNavigationLockRefactor and true or nil))
			end,
			navigateBack = function()
				return dispatch(NavigateBack(FFlagLuaNavigationLockRefactor and true or nil))
			end,
			navigateBackFromNativePageWrapper = function()
				return dispatch(NavigateBackFromNativePageWrapper())
			end,
			closeCentralOverlay = function()
				dispatch(CloseCentralOverlay())
            end,
		}
	end
)(NavigationEventReceiver)
