local HttpService = game:GetService("HttpService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local StatusCodes = require(Modules.LuaApp.Http.StatusCodes)
local GamesPatchUserVotes = require(Modules.LuaApp.Http.Requests.GamesPatchUserVotes)

local ReasonForNotVoteable = require(Modules.LuaApp.Enum.ReasonForNotVoteable)
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local VoteStatus = require(Modules.LuaApp.Enum.VoteStatus)

local SetGameVotes = require(Modules.LuaApp.Actions.SetGameVotes)
local SetUserGameVotes = require(Modules.LuaApp.Actions.SetUserGameVotes)
local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)

local PLAY_GAME_ERROR_CODE = 6

local function getNewGameVotes(curGameVotes, curVote, newVote)
	if curVote == newVote then
		return curGameVotes
	end

	local upVotes = curGameVotes and curGameVotes.upVotes
	local downVotes = curGameVotes and curGameVotes.downVotes
	if newVote == VoteStatus.VotedUp then
		upVotes = upVotes + 1
		if curVote == VoteStatus.VotedDown then
			downVotes = downVotes - 1
		end
	elseif newVote == VoteStatus.VotedDown then
		downVotes = downVotes + 1
		if curVote == VoteStatus.VotedUp then
			upVotes = upVotes - 1
		end
	elseif newVote == VoteStatus.NotVoted then
		if curVote == VoteStatus.VotedUp then
			upVotes = upVotes - 1
		elseif curVote == VoteStatus.VotedDown then
			downVotes = downVotes - 1
		end
	end

	return {
		upVotes = upVotes,
		downVotes = downVotes,
	}
end

local function isTooManyRequestsError(err)
	return err and err.HttpError == Enum.HttpError.OK and err.StatusCode == StatusCodes.TOO_MANY_REQUESTS
end

local function isPlayGameError(err)
	if err and err.HttpError == Enum.HttpError.OK and err.StatusCode == StatusCodes.FORBIDDEN then
		local success, body = pcall(function() return HttpService:JSONDecode(err.Body) end)
		if success and body and body.errors then
			for _, errorInfo in ipairs(body.errors) do
				if errorInfo.code == PLAY_GAME_ERROR_CODE then
					return true
				end
			end
		end
	end
	return false
end

local function fetchKeymapper(universeId)
	return "luaapp.gamesapi.patch-user-votes"..universeId
end

local PatchUserVotes = {}

PatchUserVotes.getNewGameVotes = getNewGameVotes

function PatchUserVotes.Patch(networkImpl, universeId, vote, curVote)
	assert(type(universeId) == "string",
		string.format("PatchUserVotes thunk expects universeId to be a string, was %s", type(universeId)))
	assert(type(vote) == "string",
		string.format("PatchUserVotes thunk expects vote to be a string, was %s", type(vote)))
	assert(type(curVote) == "string",
		string.format("PatchUserVotes thunk expects curVote to be a string, was %s", type(curVote)))

	if vote == curVote then
		-- Avoid redundant patches
		return Promise.resolve()
	end

	return PerformFetch.Single(fetchKeymapper(universeId), function(store)
		return GamesPatchUserVotes(networkImpl, universeId, vote):andThen(
			function(result)
				local gameVotes = store:getState().GameVotes[universeId]
				local newGameVotes = getNewGameVotes(gameVotes, curVote, vote)

				store:dispatch(SetGameVotes(universeId, newGameVotes.upVotes, newGameVotes.downVotes))
				store:dispatch(SetUserGameVotes(universeId, true, vote, ""))
				return Promise.resolve(result)
			end,
			function(err)
				if isTooManyRequestsError(err) then
					store:dispatch(SetUserGameVotes(universeId, false, curVote,
						ReasonForNotVoteable.FloodCheckThresholdMet))
					store:dispatch(SetCurrentToastMessage({
						toastType = ToastType.NetworkingError,
						toastMessage = "Feature.Toast.VoteError.FloodCheckThresholdMet",
					}))
					return Promise.reject(err)
				elseif isPlayGameError(err) then
					store:dispatch(SetUserGameVotes(universeId, false, curVote,
						ReasonForNotVoteable.PlayGame))
					store:dispatch(SetCurrentToastMessage({
						toastType = ToastType.NetworkingError,
						toastMessage = "Feature.Toast.VoteError.PlayGame",
					}))
					return Promise.reject(err)
				end
				store:dispatch(SetNetworkingErrorToast(err))
				return Promise.reject(err)
			end
		)
	end)
end

function PatchUserVotes.GetPatchingStatus(state, universeId)
	return PerformFetch.GetStatus(state, fetchKeymapper(universeId))
end

return PatchUserVotes