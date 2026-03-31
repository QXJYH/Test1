local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local SetAuthenticationStatus = require(Modules.LuaApp.Actions.SetAuthenticationStatus)
local ResetNavigationHistory = require(Modules.LuaApp.Thunks.ResetNavigationHistory)
local AppStorageUtilities = require(script.Parent.AppStorageUtilities)
local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local FetchLocale = require(Modules.LuaApp.Thunks.FetchLocale)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

-- LuaAppLoginMethod 's numeric values:
--    0 => The Native Login
--    1 => The Lua Login
local LUA_APP_LOGIN_METHOD = tonumber(settings():GetFVariable("LuaAppLoginMethod"))

return function(networkImpl)
	return function(store)
		return FetchLocale(networkImpl):andThen(function(locale)
			AppStorageUtilities.setRobloxLocaleId(locale.signupAndLoginLocale)
			store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_OUT))
			if LUA_APP_LOGIN_METHOD == 0 then
				store:dispatch(NavigateDown({ name = AppPage.LoginNative }))
			else
				store:dispatch(ResetNavigationHistory({ { name = AppPage.Login } }))
			end
		end)
	end
end