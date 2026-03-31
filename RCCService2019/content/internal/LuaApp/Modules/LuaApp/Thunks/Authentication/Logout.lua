local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local Players = game:GetService("Players")

local AppPage = require(Modules.LuaApp.AppPage)
local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local LogoutRequest = require(Modules.LuaApp.Http.Requests.Logout)
local ResetNavigationHistory = require(Modules.LuaApp.Thunks.ResetNavigationHistory)
local SetAuthenticationStatus = require(Modules.LuaApp.Actions.SetAuthenticationStatus)
local ClearUserSpecificData = require(Modules.LuaApp.Actions.ClearUserSpecificData)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local ClearApp = require(script.Parent.ClearApp)
local GetLocaleAndGotoLoginPage = require(script.Parent.GetLocaleAndGotoLoginPage)
local User = require(script.Parent.User)
local PromiseUtilities = require(Modules.LuaApp.PromiseUtilities)
local AppStorageService = game:GetService("AppStorageService")

return function(networkImpl, guiService)
	if FlagSettings.EnableLuaAppLoginPageForUniversalAppDev() then
		return function(store)
			local logoutRequestPromise = LogoutRequest(networkImpl)
			PromiseUtilities.Batch({logoutRequestPromise}):andThen(function()
				store:dispatch(ClearApp())
				store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_OUT))
				store:dispatch(GetLocaleAndGotoLoginPage(networkImpl))
				User.clearLocalStorage()
				AppStorageService:flush()
			end)
		end
	else
		return function(store)
			LogoutRequest(networkImpl)
			Players:SetLocalPlayerInfo(-1, "", 0, true)
			store:dispatch(ClearUserSpecificData())
			store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_OUT))
			store:dispatch(ResetNavigationHistory({ { name = AppPage.WeChatLoginWrapper } }))
			guiService:BroadcastNotification("", NotificationType.DID_LOG_OUT)
		end
	end
end