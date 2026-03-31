local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local FollowingsGetStatus = require(Modules.LuaApp.Http.Requests.FollowingsGetStatus)
local SetGameFollowingStatus = require(Modules.LuaApp.Actions.SetGameFollowingStatus)

return function(networkImpl, universeId)
	if type(universeId) ~= "string" then
		error("ApiFetchGameFollowingStatus thunk expects universeId to be a string")
	end

	return PerformFetch.Single("ApiFetchGameFollowingStatus"..universeId, function(store)
        local userId = store:getState().LocalUserId
		return FollowingsGetStatus(networkImpl, userId, universeId):andThen(
			function(result)
				local data = result.responseBody

				if data ~= nil and data.CanFollow ~= nil and data.IsFollowing ~= nil then
                    store:dispatch(SetGameFollowingStatus(universeId, data.CanFollow, data.IsFollowing))
					return Promise.resolve(result)
				else
					Logging.warn("Response from FollowingsGetStatus is malformed!")
					return Promise.reject({HttpError = Enum.HttpError.OK})
				end
			end,
			function(err)
				return Promise.reject(err)
			end
		)
	end)
end
