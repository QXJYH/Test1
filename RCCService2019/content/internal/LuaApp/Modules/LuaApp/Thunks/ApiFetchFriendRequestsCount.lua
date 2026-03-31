local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GetFriendRequestsCount = require(Modules.LuaApp.Http.Requests.GetFriendRequestsCount)
local SetFriendRequestsCount = require(Modules.LuaApp.Actions.SetFriendRequestsCount)

local performFetchKey = "luaapp.friendsapi.friend-requests-count"

return function(networkImpl)
	return PerformFetch.Single(performFetchKey, function(store)
		return GetFriendRequestsCount(networkImpl):andThen(function(result)
			local count = result.responseBody.count
			store:dispatch(SetFriendRequestsCount(count))

			return Promise.resolve(result)
		end,
		function(err)
			return Promise.reject(err)
		end)
	end)
end