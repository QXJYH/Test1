local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GetPasswordStatus = require(Modules.LuaApp.Http.Requests.GetPasswordStatus)
local SetPasswordNotificationCount = require(Modules.LuaApp.Actions.SetPasswordNotificationCount)

local performFetchKey = "luaapp.authapi.passwords-current-status"

return function(networkImpl)
	return PerformFetch.Single(performFetchKey, function(store)
		return GetPasswordStatus(networkImpl):andThen(function(result)
			local count = result.responseBody.valid == false and 1 or 0
			store:dispatch(SetPasswordNotificationCount(count))

			return Promise.resolve(result)
		end,
		function(err)
			return Promise.reject(err)
		end)
	end)
end