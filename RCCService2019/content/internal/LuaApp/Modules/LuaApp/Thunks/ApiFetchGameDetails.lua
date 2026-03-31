local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local Promise = require(Modules.LuaApp.Promise)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local Result = require(Modules.LuaApp.Result)

local GamesMultigetDetails = require(Modules.LuaApp.Http.Requests.GamesMultigetDetails)
local AddGameDetails = require(Modules.LuaApp.Actions.AddGameDetails)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GameDetail = require(Modules.LuaApp.Models.GameDetail)

local ApiFetchGameDetails = {}

local keyMapper = function(universeId)
	return "luaapp.gamesapi.games."..universeId
end

ApiFetchGameDetails.KeyMapper = keyMapper

function ApiFetchGameDetails.GetFetchingStatus(state, universeId)
	return PerformFetch.GetStatus(state, keyMapper(universeId))
end

function ApiFetchGameDetails.Fetch(networkImpl, universeIds)
	ArgCheck.isType(universeIds, "table", "ApiFetchGameDetails: universeIds")

	return PerformFetch.Batch(universeIds, keyMapper, function(store, filteredUniverseIds)
		return GamesMultigetDetails(networkImpl, filteredUniverseIds):andThen(function(result)
			local results = {}

			local data = result and result.responseBody and result.responseBody.data
			if data ~= nil then
				local decodedGameDetails = {}

				for _, gameDetails in ipairs(data) do
					local decodedGameDetail = GameDetail.fromJsonData(gameDetails)
					decodedGameDetails[decodedGameDetail.id] = decodedGameDetail
					results[keyMapper(decodedGameDetail.id)] = Result.new(true, decodedGameDetail)
				end

				if next(decodedGameDetails) then
					store:dispatch(AddGameDetails(decodedGameDetails))
				end
			else
				Logging.warn("Response from GamesMultigetDetails is malformed!")
			end

			return Promise.resolve(results)
		end,

		function(err)
			return Promise.resolve({})
		end)
	end)
end

return ApiFetchGameDetails
