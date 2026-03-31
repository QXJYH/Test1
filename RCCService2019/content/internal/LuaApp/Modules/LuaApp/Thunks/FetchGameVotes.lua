local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local GetGameVotes = require(Modules.LuaApp.Http.Requests.GetGameVotes)
local SetGameVotes = require(Modules.LuaApp.Actions.SetGameVotes)

local FetchGameVotes = {}

local function fetchKeymapper(universeId)
	return "luaapp.gamesapi.game-votes"..universeId
end

function FetchGameVotes.Fetch(networkImpl, universeId)
	assert(type(universeId) == "string",
		string.format("FetchGameVotes thunk expects universeId to be a string, was %s", type(universeId)))

	return PerformFetch.Single(fetchKeymapper(universeId), function(store)
		return GetGameVotes(networkImpl, universeId):andThen(function(result)
			local data = result.responseBody

			if data ~= nil and data.upVotes ~= nil and data.downVotes ~= nil then
				store:dispatch(SetGameVotes(universeId, data.upVotes < 0 and 0 or data.upVotes,
					data.downVotes < 0 and 0 or data.downVotes))
				return Promise.resolve(result)
			else
				Logging.warn("Response from GetGameVotes is malformed!")
				return Promise.reject({HttpError = Enum.HttpError.OK})
			end
		end,
		function(err)
			store:dispatch(SetNetworkingErrorToast(err))
			return Promise.reject(err)
		end)
	end)
end

function FetchGameVotes.GetFetchingStatus(state, universeId)
	return PerformFetch.GetStatus(state, fetchKeymapper(universeId))
end

return FetchGameVotes