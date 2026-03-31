local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local GetAccountInfo = require(Modules.LuaApp.Http.Requests.GetAccountInfo)
local User = require(script.Parent.User)
local GetLocalUser = require(Modules.LuaApp.Thunks.GetLocalUser)
local PromiseUtilities = require(Modules.LuaApp.PromiseUtilities)
local SetAuthenticationStatus = require(Modules.LuaApp.Actions.SetAuthenticationStatus)
local ResetNavigationHistory = require(Modules.LuaApp.Thunks.ResetNavigationHistory)
local GetLocaleAndGotoLoginPage = require(script.Parent.GetLocaleAndGotoLoginPage)
local FetchLocale = require(Modules.LuaApp.Thunks.FetchLocale)
local FetchTheme = require(Modules.LuaApp.Thunks.FetchTheme)
local AppStorageUtilities = require(script.Parent.AppStorageUtilities)
local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local AppPage = require(Modules.LuaApp.AppPage)

return function(networkImpl)
	return function(store)
		return GetAccountInfo(networkImpl):andThen(
			function(result)
				local localPlayerInfo = User.fromRequest(result)
				localPlayerInfo:setToLocalPlayer()
				localPlayerInfo:setToLocalStorage()
				store:dispatch(GetLocalUser())
				PromiseUtilities.Batch({FetchLocale(networkImpl), FetchTheme(networkImpl, localPlayerInfo.userId)}):andThen(
					function(results)
						results[1]:match(function(locale)
							AppStorageUtilities.setRobloxLocaleId(locale.generalExperienceLocale)
							AppStorageUtilities.setGameLocaleId(locale.ugcLocale)
						end)
						results[2]:match(function(theme)
							AppStorageUtilities.setTheme(theme)
						end)
						AppStorageUtilities.flush()
						store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_IN))
						store:dispatch(ResetNavigationHistory({ { name = AppPage.Home } }))
					end
				)
			end,
			function(err)
				store:dispatch(GetLocaleAndGotoLoginPage(networkImpl))
			end
		)
	end
end