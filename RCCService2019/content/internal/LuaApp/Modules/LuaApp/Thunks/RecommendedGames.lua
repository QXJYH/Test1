local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Promise = require(Modules.LuaApp.Promise)
local TableUtilities = require(Modules.LuaApp.TableUtilities)

local Game = require(Modules.LuaApp.Models.Game)
local GameSortEntry = require(Modules.LuaApp.Models.GameSortEntry)

local AddGames = require(Modules.LuaApp.Actions.AddGames)
local SetRecommendedGameEntries = require(Modules.LuaApp.Actions.SetRecommendedGameEntries)

local ApiFetchGameThumbnails = require(Modules.LuaApp.Thunks.ApiFetchGameThumbnails)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GameGetRecommendedGames = require(Modules.LuaApp.Http.Requests.GameGetRecommendedGames)

local RecommendedGames = {}

local function fetchKeymapper(universeId)
	return "RecommendedGames"..universeId
end

function RecommendedGames.Fetch(networkImpl, universeId, isAppend, argTable)
	assert(type(universeId) == "string", "RecommendedGames thunk expects universeId to be a string")
	assert(type(argTable) == "table", "RecommendedGames thunk expects argTable to be a table")

	return PerformFetch.Single(fetchKeymapper(universeId), function(store)
		return GameGetRecommendedGames(networkImpl, universeId, argTable):andThen(function(result)
			-- parse out the games and thumbnails
			local entries = {}
			local decodedGamesData = {}
			local thumbnailTokens = {}
			local storedGames = store:getState().Games
			local data = result.responseBody

			if #data.games == 0 then
				warn("Found no recommended games related to universe", universeId)
			end

			for index, game in ipairs(data.games) do
				local decodedEntryResult = GameSortEntry.fromJsonData(game)

				decodedEntryResult:match(function(decodedEntry)
					local decodedGameDataResult = Game.fromJsonData(game)

					return decodedGameDataResult:match(function(decodedGameData)
						entries[index] = decodedEntry
						local universeId = decodedGameData.universeId

						if not TableUtilities.ShallowEqual(decodedGameData, storedGames[universeId]) then
							decodedGamesData[universeId] = decodedGameData

							if storedGames[universeId] == nil or decodedGameData.imageToken ~= storedGames[universeId].imageToken then
								table.insert(thumbnailTokens, decodedGameData.imageToken)
							end
						end
					end)
				end):matchError(function(decodeError)
					warn(decodeError)
				end)
			end

			if next(decodedGamesData) then
				-- write these games to the store
				store:dispatch(AddGames(decodedGamesData))
			end

			store:dispatch(SetRecommendedGameEntries(universeId, entries))

			-- request the updated thumbnails for this sort
			if #thumbnailTokens > 0 then
				store:dispatch(ApiFetchGameThumbnails(networkImpl, thumbnailTokens))
			end

			return Promise.resolve(result)
		end,
		function(err)
			store:dispatch(SetNetworkingErrorToast(err))
			return Promise.reject(err)
		end)
	end)
end

function RecommendedGames.GetFetchingStatus(state, universeId)
	return PerformFetch.GetStatus(state, fetchKeymapper(universeId))
end

return RecommendedGames