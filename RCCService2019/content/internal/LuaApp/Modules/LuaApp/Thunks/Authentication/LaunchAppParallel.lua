local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local GetAccountInfo = require(Modules.LuaApp.Http.Requests.GetAccountInfo)
local User = require(script.Parent.User)
local GetLocalUser = require(Modules.LuaApp.Thunks.GetLocalUser)
local PromiseUtilities = require(Modules.LuaApp.PromiseUtilities)
local SetAuthenticationStatus = require(Modules.LuaApp.Actions.SetAuthenticationStatus)
local ResetNavigationHistory = require(Modules.LuaApp.Thunks.ResetNavigationHistory)
local FetchLocale = require(Modules.LuaApp.Thunks.FetchLocale)
local FetchTheme = require(Modules.LuaApp.Thunks.FetchTheme)
local ClearApp = require(script.Parent.ClearApp)
local AppStorageUtilities = require(script.Parent.AppStorageUtilities)
local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local AppPage = require(Modules.LuaApp.AppPage)

return function(networkImpl)
	return function(store)
		local getAccountInfoPromise = GetAccountInfo(networkImpl)
		local fetchLocalePromise = FetchLocale(networkImpl)
		local fetchThemePromise = nil

		local appStarted = false
		local cachedUser = User.fromLocalStorage()

		if cachedUser.userId ~= -1 then
			cachedUser:setToLocalPlayer()
			store:dispatch(GetLocalUser())
			store:dispatch(ResetNavigationHistory({ { name = AppPage.Home } }))
			fetchThemePromise = FetchTheme(networkImpl, cachedUser.userId)
			appStarted = true
		end

		getAccountInfoPromise:andThen(
			function(result)
					local localPlayerInfo = User.fromRequest(result)
					if not localPlayerInfo:isSame(cachedUser) then
						localPlayerInfo:setToLocalPlayer()
						localPlayerInfo:setToLocalStorage()
						fetchThemePromise = FetchTheme(networkImpl, localPlayerInfo.userId)
						if appStarted then
							store:dispatch(ClearApp())
						end
						store:dispatch(GetLocalUser())
						store:dispatch(ResetNavigationHistory({ { name = AppPage.Home } }))
					end

					local promises = {}
					table.insert(promises,
						fetchLocalePromise:andThen(function(locale)
							AppStorageUtilities.setRobloxLocaleId(locale.generalExperienceLocale)
							AppStorageUtilities.setGameLocaleId(locale.ugcLocale)
						end)
					)
					table.insert(promises,
						fetchThemePromise:andThen(function(theme)
							AppStorageUtilities.setTheme(theme)
						end)
					)

					PromiseUtilities.Batch(promises):andThen(function()
						AppStorageUtilities.flush()
					end)

					store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_IN))
			end,
			function(err)
				PromiseUtilities.Batch({fetchLocalePromise}):andThen(function(results)
					results[1]:match(function(locale)
						AppStorageUtilities.setRobloxLocaleId(locale.signupAndLoginLocale)
					end)
					if appStarted then
						store:dispatch(ClearApp())
					end
					store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_OUT))
					store:dispatch(ResetNavigationHistory({ { name = AppPage.Login } }))
				end)
			end
		)
	end
end