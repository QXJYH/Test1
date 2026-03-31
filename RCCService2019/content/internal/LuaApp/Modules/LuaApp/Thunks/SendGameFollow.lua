local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local FollowingsPostFollowRequest = require(Modules.LuaApp.Http.Requests.FollowingsPostFollow)
local FollowingsDeleteFollowRequest = require(Modules.LuaApp.Http.Requests.FollowingsDeleteFollow)
local SetGameFollow = require(Modules.LuaApp.Actions.SetGameFollow)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local ToastType = require(Modules.LuaApp.Enum.ToastType)

local function SendGameFollow(networkImpl, universeId, isFollowed)
	if type(universeId) ~= "string" then
		error("SendGameFollow thunk expects universeId to be a string")
	end
	if type(isFollowed) ~= "boolean" then
		error("SendGameFollow thunk expects isFollowed to be a boolean")
	end

	return PerformFetch.Single("SendGameFollow"..universeId, function(store)
		local userId = store:getState().LocalUserId
		if isFollowed then
			return FollowingsPostFollowRequest(networkImpl, userId, universeId):andThen(
				function(result)
					local curIsFollowed = store:getState().GameFollowings[universeId].isFollowed
					if curIsFollowed then
						return Promise.resolve(result)
					else
						return SendGameFollow(networkImpl, universeId, false)
					end
				end,
				function(err)
					store:dispatch(SetGameFollow(universeId, false))

					if err.StatusCode == 400 then
						store:dispatch(SetCurrentToastMessage({
							toastType = ToastType.GameFollowError,
							toastMessage = "Feature.GameFollows.TooltipFollowLimitReached",
						}))
					else
						store:dispatch(SetNetworkingErrorToast(err))
					end

					return Promise.reject(err)
				end
			)
		else
			return FollowingsDeleteFollowRequest(networkImpl, userId, universeId):andThen(
				function(result)
					local curIsFollowed = store:getState().GameFollowings[universeId].isFollowed
					if not curIsFollowed then
						return Promise.resolve(result)
					else
						return SendGameFollow(networkImpl, universeId, true)
					end
				end,
				function(err)
					store:dispatch(SetGameFollow(universeId, true))
					store:dispatch(SetNetworkingErrorToast(err))
					return Promise.reject(err)
				end
			)
		end
	end)
end

return SendGameFollow