local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Promise = require(Modules.LuaApp.Promise)
local Result = require(Modules.LuaApp.Result)
local Logging = require(CorePackages.Logging)
local SetGamesProductInfo = require(Modules.LuaApp.Actions.SetGamesProductInfo)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GamesGetProductInfo = require(Modules.LuaApp.Http.Requests.GamesGetProductInfo)
local GameProductInfo = require(Modules.LuaApp.Models.GameProductInfo)

local MAX_UNIVERSE_IDS = 100

local FetchGamesProductInfo = {}

local keyMapper = function(universeId)
	return "luaapp.gamesapi.games-product-info."..universeId
end

FetchGamesProductInfo.KeyMapper = keyMapper

function FetchGamesProductInfo.Fetch(networkImpl, universeIds)
	assert(type(universeIds) == "table", "FetchGamesProductInfo thunk expects universeIds to be a table")
	assert(#universeIds > 0, "FetchGamesProductInfo thunk expects universeIds count to be greater than 0")
	assert(#universeIds <= MAX_UNIVERSE_IDS,
		"FetchGamesProductInfo thunk expects universeIds count to not exceed " .. MAX_UNIVERSE_IDS)

	return PerformFetch.Batch(universeIds, keyMapper, function(store, filteredUniverseIds)
		return GamesGetProductInfo(networkImpl, filteredUniverseIds):andThen(function(result)
			local results = {}
			for _, universeId in ipairs(filteredUniverseIds) do
				results[keyMapper(universeId)] = Result.new(false, nil)
			end

			local data = result and result.responseBody and result.responseBody.data
			if data ~= nil then
				local gamesProductInfo = {}
				for _, gameProductInfo in ipairs(data) do
					GameProductInfo.fromJsonData(gameProductInfo):match(function(decodedGameProductInfo)
						gamesProductInfo[decodedGameProductInfo.universeId] = decodedGameProductInfo
						results[keyMapper(decodedGameProductInfo.universeId)] = Result.new(true, nil)
					end):matchError(function(err)
						Logging.warn(err)
					end)
				end

				if next(gamesProductInfo) then
					store:dispatch(SetGamesProductInfo(gamesProductInfo))
				end
			else
				Logging.warn("Response from GamesGetProductInfo is malformed!")
			end

			return Promise.resolve(results)
		end,

		function(err)
			local results = {}
			for _, universeId in ipairs(filteredUniverseIds) do
				results[keyMapper(universeId)] = Result.new(false, nil)
			end
			return Promise.resolve(results)
		end)
	end)
end

function FetchGamesProductInfo.GetFetchingStatus(state, universeId)
	return PerformFetch.GetStatus(state, keyMapper(universeId))
end

return FetchGamesProductInfo