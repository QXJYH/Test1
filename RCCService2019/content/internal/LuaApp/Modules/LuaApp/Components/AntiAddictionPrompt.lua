local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local Constants = require(Modules.LuaApp.Constants)
local withLocalization = require(Modules.LuaApp.withLocalization)

local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local AppRunService = require(Modules.LuaApp.Services.AppRunService)
local AppUserInputService = require(Modules.LuaApp.Services.AppUserInputService)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local AlertWindow = require(Modules.LuaApp.Components.AlertWindow)
local ScreenGuiWithBlurControl = require(Modules.LuaApp.Components.ScreenGuiWithBlurControl)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local Logout = require(Modules.LuaApp.Thunks.Authentication.Logout)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local AppPage = require(Modules.LuaApp.AppPage)

local SetScreenGuiBlur = require(Modules.LuaApp.Actions.SetScreenGuiBlur)

local ALERT_TITLE_KEY = "CommonUI.Messages.Label.Alert"
local OK_KEY = "CommonUI.Messages.Action.OK"
local LOGOUT_KEY = "Application.Logout.Action.Logout"

local DEFAULT_PROMPT_WIDTH = 400

local FFlagEnablePopupDataModelFocusedEvents = settings():GetFFlag("EnablePopupDataModelFocusedEvents")
local FFlagLuaAppEnablePageBlur = settings():GetFFlag("LuaAppEnablePageBlur")

local AntiAddictionPrompt = Roact.PureComponent:extend("AntiAddictionPrompt")

function AntiAddictionPrompt:init()

	self.OkCallback = function(...)
		if self.props.okCallback then
			self.props.okCallback(...)
		end
	end

	self.LogoutCallback = function(...)
		if FlagSettings.LuaAppLoginEnabled() then
			self.props.logout(self.props.networking, self.props.guiService)
			--Temp fix. Close the prompt here since PC version will need to dismiss the prompt after logout.
			if self.props.okCallback then
				self.props.okCallback(...)
			end
		elseif FFlagEnablePopupDataModelFocusedEvents then
			self.props.openLogoutPage()
		else
			self.props.guiService:BroadcastNotification("", NotificationType.ACTION_LOG_OUT)
		end
	end
end

function AntiAddictionPrompt:render()
	local theme = self._context.AppTheme.AlertWindow
	local titleFont = theme.Title.Font
	local messageText = self.props.message
	local messageFont = theme.Message.Font
	local buttonFont = theme.Button.Font
	local width = self.props.width or DEFAULT_PROMPT_WIDTH
	local lockOut = self.props.lockOut
	local callBack = lockOut and self.LogoutCallback or self.OkCallback
	-- Remove focus from any focused textbox
	local textbox = self.props.userInputService:GetFocusedTextBox()
	if textbox then
		textbox:ReleaseFocus()
	end

	local renderAntiAddictionPrompt = function(localized)
		local alertWindow = Roact.createElement(AlertWindow, {
			titleText = localized.alertTitle,
			titleFont = titleFont,
			messageText = messageText,
			messageFont = messageFont,
			buttonFont = buttonFont,
			confirmButtonText = localized.buttonText,
			onConfirm = callBack,
			hasCancelButton = false,
			containerWidth = width,
		})
		local overlay = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 1,
			Active = true,
			Selectable = false,
		}, {
			AlertWindow = alertWindow
		})
		return Roact.createElement(FFlagLuaAppEnablePageBlur and ScreenGuiWithBlurControl or "ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = Constants.DisplayOrder.AntiAddictionPrompt,
			OnTopOfCoreBlur = lockOut,
		}, {
			Overlay = overlay
		})
	end

	return withLocalization({
		buttonText = lockOut and LOGOUT_KEY or OK_KEY,
		alertTitle = ALERT_TITLE_KEY,
	})(function(localized)
		return renderAntiAddictionPrompt(localized)
	end)
end

function AntiAddictionPrompt:didMount()
	local lockOut = self.props.lockOut

	if FFlagLuaAppEnablePageBlur then
		if lockOut then
			self.props.setScreenGuiBlur(true)
		end
	else
		self.props.runService:SetRobloxGuiFocused(lockOut)
	end
end

function AntiAddictionPrompt:willUnmount()
	local lockOut = self.props.lockOut

	if FFlagLuaAppEnablePageBlur then
		if lockOut then
			self.props.setScreenGuiBlur(false)
		end
	else
		self.props.runService:SetRobloxGuiFocused(false)
	end
end

AntiAddictionPrompt = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			logout = function(networkImpl, guiService)
				dispatch(Logout(networkImpl, guiService))
			end,
			openLogoutPage = function()
				dispatch(NavigateDown({ name = AppPage.LogoutConfirmation }))
			end,
			setScreenGuiBlur = function(blur)
				dispatch(SetScreenGuiBlur("AntiAddictionPrompt", blur, Constants.DisplayOrder.AntiAddictionPrompt))
			end,
		}
	end
)(AntiAddictionPrompt)

AntiAddictionPrompt = RoactServices.connect({
	guiService = AppGuiService,
	runService = AppRunService,
	userInputService = AppUserInputService,
	networking = RoactNetworking,
})(AntiAddictionPrompt)

return AntiAddictionPrompt
