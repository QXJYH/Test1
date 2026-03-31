local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Actions = Modules.LuaApp.Actions
local Requests = Modules.LuaApp.Http.Requests
local GamesGetSorts = require(Requests.GamesGetSorts)
local ReportToDiagByCountryCode = require(Requests.ReportToDiagByCountryCode)
local AddGameSorts = require(Actions.AddGameSorts)
local SetGameSortsInGroup = require(Actions.SetGameSortsInGroup)
local GameSort = require(Modules.LuaApp.Models.GameSort)
local Promise = require(Modules.LuaApp.Promise)
local SetGameSortTokenFetchingStatus = require(Actions.SetGameSortTokenFetchingStatus)
local SetNextTokenRefreshTime = require(Modules.LuaApp.Actions.SetNextTokenRefreshTime)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)

local min = math.min

local PercentReportingGamesSortsRTT = tonumber(settings():GetFVariable("PercentReportingGamesSortsRTT"))

local function parseSortDataIntoStore(sortCategory, store, result)
	local data = result.responseBody
	if data.sorts then
		local decodedDataSorts = {}
		local gameSorts = {}
		local minExpiryTime = nil
		for _, gameSortJson in ipairs(data.sorts) do
			local gameSort = GameSort.fromJsonData(gameSortJson)
			decodedDataSorts[#decodedDataSorts + 1] = gameSort
			gameSorts[#gameSorts + 1] = gameSortJson.name

			-- get minimum time for the next refresh
			if not minExpiryTime then
				minExpiryTime = gameSortJson.tokenExpiryInSeconds
			else
				minExpiryTime = min(minExpiryTime, gameSortJson.tokenExpiryInSeconds)
			end
		end
		store:dispatch(AddGameSorts(decodedDataSorts))
		store:dispatch(SetGameSortsInGroup(sortCategory, gameSorts))
		return minExpiryTime
	end
	return -1
end

--[[
	This function will retry for MAX_RETRY_TIME before it
	fails and reject with false.
	retryTime -- How many time has this request retried
]]
local function fetchToken(networkImpl, store, sortCategory, checkPoints)
	if checkPoints ~= nil and checkPoints.startFetchSortTokens ~= nil then
		checkPoints:startFetchSortTokens()
	end
	return GamesGetSorts(networkImpl, sortCategory):andThen(function(result)
		local minExpiryTime = parseSortDataIntoStore(sortCategory, store, result)

		-- there is no data in fetching result
		if minExpiryTime < 0 then
			store:dispatch(SetGameSortTokenFetchingStatus(sortCategory, RetrievalStatus.Failed))
			return Promise.reject("No sort data found in response.")
		end

		store:dispatch(SetNextTokenRefreshTime(sortCategory, tick() + minExpiryTime))
		store:dispatch(SetGameSortTokenFetchingStatus(sortCategory, RetrievalStatus.Done))

		ReportToDiagByCountryCode("GamesSorts", "RoundTripTime", result.responseTimeMs, PercentReportingGamesSortsRTT)

		if checkPoints ~= nil and checkPoints.finishFetchSortTokens ~= nil  then
			checkPoints:finishFetchSortTokens()
		end

		return Promise.resolve()
	end,

	-- failure handler for request 'GamesGetSorts'
	function(err)
		store:dispatch(SetGameSortTokenFetchingStatus(sortCategory, RetrievalStatus.Failed))
		return Promise.reject(err)
	end)
end

--[[
	A thunk fetches the tokens for sorts
	networkImpl -- networking object
	sortCategory -- HomeGames/Games
]]
return function(networkImpl, sortCategory, checkPoints)
	return function(store)
		if(store:getState().RequestsStatus.GameSortTokenFetchingStatus[sortCategory] == RetrievalStatus.Fetching) then
			return Promise.resolve("Data is fetching.")
		else
			store:dispatch(SetGameSortTokenFetchingStatus(sortCategory, RetrievalStatus.Fetching))
		end
		return fetchToken(networkImpl, store, sortCategory, checkPoints)
	end
end