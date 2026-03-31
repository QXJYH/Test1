local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local GetUserGameVotes = require(Modules.LuaApp.Http.Requests.GetUserGameVotes)
local SetUserGameVotes = require(Modules.LuaApp.Actions.SetUserGameVotes)
local VoteStatus = require(Modules.LuaApp.Enum.VoteStatus)

local function getUserVoteStatus(userVote)
	if userVote == true then
		return VoteStatus.VotedUp
	elseif userVote == false then
		return VoteStatus.VotedDown
	elseif userVote == nil then
		return VoteStatus.NotVoted
	end
	return nil
end

local FetchUserGameVotes = {}

local function fetchKeymapper(universeId)
	return "luaapp.gamesapi.user-game-votes"..universeId
end

function FetchUserGameVotes.Fetch(networkImpl, universeId)
	assert(type(universeId) == "string",
		string.format("FetchUserGameVotes thunk expects universeId to be a string, was %s", type(universeId)))

	return PerformFetch.Single(fetchKeymapper(universeId), function(store)
		return GetUserGameVotes(networkImpl, universeId):andThen(function(result)
			local data = result.responseBody

			if data ~= nil and data.canVote ~= nil and data.reasonForNotVoteable ~= nil then
				local userVoteStatus = getUserVoteStatus(data.userVote)
				if userVoteStatus then
					store:dispatch(SetUserGameVotes(universeId, data.canVote, userVoteStatus, data.reasonForNotVoteable))
				else
					Logging.warn("Response from GetUserGameVotes is malformed!")
					return Promise.reject({ HttpError = Enum.HttpError.OK })
				end
				return Promise.resolve(result)
			else
				Logging.warn("Response from GetUserGameVotes is malformed!")
				return Promise.reject({ HttpError = Enum.HttpError.OK })
			end
		end,
		function(err)
			store:dispatch(SetNetworkingErrorToast(err))
			return Promise.reject(err)
		end)
	end)
end

function FetchUserGameVotes.GetFetchingStatus(state, universeId)
	return PerformFetch.GetStatus(state, fetchKeymapper(universeId))
end

return FetchUserGameVotes