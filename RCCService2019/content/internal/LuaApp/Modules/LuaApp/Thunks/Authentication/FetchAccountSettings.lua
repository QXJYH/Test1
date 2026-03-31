local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Modules = CoreGui.RobloxGui.Modules

local Promise = require(Modules.LuaApp.Promise)

local AppPage = require(Modules.LuaApp.AppPage)
local GetAccountInfo = require(Modules.LuaApp.Http.Requests.GetAccountInfo)
local SetAuthenticationStatus = require(Modules.LuaApp.Actions.SetAuthenticationStatus)
local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local ResetNavigationHistory = require(Modules.LuaApp.Thunks.ResetNavigationHistory)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local PreloadApplicationData = require(Modules.LuaApp.Thunks.PreloadApplicationData)
local GetLocalUser = require(Modules.LuaApp.Thunks.GetLocalUser)

return function(networkImpl, analytics, appPolicy)
	return function(store)
		return GetAccountInfo(networkImpl, true):andThen(
			function(result)
				local username = result.responseBody.Username
				local userId = result.responseBody.UserId
				local membershipType = tonumber(result.responseBody.MembershipType)
				local isUnder13 = result.responseBody.AgeBracket == 1
				Players:SetLocalPlayerInfo(userId, username, membershipType, isUnder13)
				store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_IN))
				store:dispatch(ResetNavigationHistory({ { name = AppPage.Home } }))
				store:dispatch(PreloadApplicationData(networkImpl, analytics, appPolicy))
				return Promise.resolve()
			end,
			function(err)
				store:dispatch(SetAuthenticationStatus(LoginStatus.LOGGED_OUT))
				store:dispatch(ResetNavigationHistory({ { name = AppPage.WeChatLoginWrapper } }))
				return Promise.reject(err)
			end
		)
	end
end