local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GetAccountSettingsEmail = require(Modules.LuaApp.Http.Requests.GetAccountSettingsEmail)
local SetEmailNotificationCount = require(Modules.LuaApp.Actions.SetEmailNotificationCount)

local performFetchKey = "luaapp.accountsettingsapi.email"

return function(networkImpl)
	return PerformFetch.Single(performFetchKey, function(store)
		return GetAccountSettingsEmail(networkImpl):andThen(function(result)
			local count = result.responseBody.verified == false and 1 or 0
			store:dispatch(SetEmailNotificationCount(count))

			return Promise.resolve(result)
		end,
		function(err)
			return Promise.reject(err)
		end)
	end)
end