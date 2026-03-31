local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local Promise = require(Modules.LuaApp.Promise)
local PromiseUtilities = require(Modules.LuaApp.PromiseUtilities)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)

local SetNextDataExpirationTime = require(Modules.LuaApp.Actions.SetNextDataExpirationTime)
local SetGameDetailsPageDataStatus = require(Modules.LuaApp.Actions.SetGameDetailsPageDataStatus)

local ApiFetchGameDetails = require(Modules.LuaApp.Thunks.ApiFetchGameDetails)
local ApiFetchGameMedia = require(Modules.LuaApp.Thunks.ApiFetchGameMedia)
local ApiFetchGameIsFavorite = require(Modules.LuaApp.Thunks.ApiFetchGameIsFavorite)
local ApiFetchGameFollowingStatus = require(Modules.LuaApp.Thunks.ApiFetchGameFollowingStatus)
local ApiFetchGameSocialLinks = require(Modules.LuaApp.Thunks.ApiFetchGameSocialLinks)
local ApiFetchGamePasses = require(Modules.LuaApp.Thunks.ApiFetchGamePasses)
local ApiFetchGameBadges = require(Modules.LuaApp.Thunks.ApiFetchGameBadges)
local FetchGamePlayabilityAndProductInfo = require(Modules.LuaApp.Thunks.FetchGamePlayabilityAndProductInfo)
local FetchGameVotes = require(Modules.LuaApp.Thunks.FetchGameVotes)
local FetchUserGameVotes = require(Modules.LuaApp.Thunks.FetchUserGameVotes)
local RecommendedGames = require(Modules.LuaApp.Thunks.RecommendedGames)

local refreshInterval = tonumber(settings():GetFVariable("LuaAppGameDetailsRefreshIntervalInSeconds"))
local FFlagLuaAppGameDetailsHideEmptySections = settings():GetFFlag("LuaAppGameDetailsHideEmptySections")

local function startFirstClassFetchPromises(networkingImpl, store, universeId, isForceRefresh)
	local firstClassDataPromises = {}

	if isForceRefresh or store:getState().GameDetails[universeId] == nil then
		table.insert(
			firstClassDataPromises,
			store:dispatch(ApiFetchGameDetails.Fetch(networkingImpl, { universeId }))
		)
	end

	local currentPlayabilityAndProductInfoFetchingStatus =
		FetchGamePlayabilityAndProductInfo.GetFetchingStatus(store:getState(), universeId)

	if isForceRefresh or currentPlayabilityAndProductInfoFetchingStatus == RetrievalStatus.NotStarted or
		currentPlayabilityAndProductInfoFetchingStatus == RetrievalStatus.Failed then
		store:dispatch(FetchGamePlayabilityAndProductInfo.Fetch(networkingImpl, universeId))
	end

	if isForceRefresh or store:getState().GameMedia[universeId] == nil then
		table.insert(
			firstClassDataPromises,
			store:dispatch(ApiFetchGameMedia.Fetch(networkingImpl, universeId))
		)
	end

	return firstClassDataPromises
end

local function startSecondClassFetchPromises(networkingImpl, store, universeId, isForceRefresh)
	if isForceRefresh or store:getState().GameVotes[universeId] == nil then
		store:dispatch(FetchGameVotes.Fetch(networkingImpl, universeId))
	end

	if isForceRefresh or store:getState().UserGameVotes[universeId] == nil then
		store:dispatch(FetchUserGameVotes.Fetch(networkingImpl, universeId))
	end

	if isForceRefresh or store:getState().GameFavorites[universeId] == nil then
		store:dispatch(ApiFetchGameIsFavorite(networkingImpl, universeId))
	end

	if isForceRefresh or store:getState().GameFollowings[universeId] == nil then
		store:dispatch(ApiFetchGameFollowingStatus(networkingImpl, universeId))
	end

	if isForceRefresh or store:getState().GameSocialLinks[universeId] == nil then
		store:dispatch(ApiFetchGameSocialLinks(networkingImpl, universeId))
	end

	if isForceRefresh or store:getState().RecommendedGameEntries[universeId] == nil then
		store:dispatch(RecommendedGames.Fetch(networkingImpl, universeId, false, {
			maxRows = Constants.DEFAULT_RECOMMENDED_GAMES_FETCH_COUNT,
		}))
	end

	if FFlagLuaAppGameDetailsHideEmptySections then
		if isForceRefresh or store:getState().GamePasses[universeId] == nil then
			store:dispatch(ApiFetchGamePasses(networkingImpl, universeId))
		end

		if isForceRefresh or store:getState().GameBadges[universeId] == nil then
			store:dispatch(ApiFetchGameBadges(networkingImpl, universeId))
		end
	end

end

return function(networkingImpl, universeId)
	if type(universeId) ~= "string" then
		error("FetchGameDetailsPageData thunk expects universeId to be a string")
	end

	return function(store)

		if store:getState().GameDetailsPageDataStatus[universeId] == RetrievalStatus.Fetching then
			return Promise.resolve("game details page data is already fetching for universe: "..universeId)
		end

		local isForceRefresh = false

		local dataExpirationTimeKey = AppPage.GameDetail..universeId
		local currentTime = tick()
		local nextDataExpirationTime = store:getState().NextDataExpirationTime[dataExpirationTimeKey]

		if nextDataExpirationTime == nil or currentTime > nextDataExpirationTime then
			isForceRefresh = true
		end

		-- Start 1st class data fetching calls:
		-- Page will display loading bar as long as these data fetches are not fully done
		local firstClassDataPromises = startFirstClassFetchPromises(networkingImpl, store, universeId, isForceRefresh)

		if #firstClassDataPromises > 0 then
			store:dispatch(SetGameDetailsPageDataStatus(universeId, RetrievalStatus.Fetching))

			return PromiseUtilities.Batch(firstClassDataPromises):andThen(
				function(results)
					local gameDetail = store:getState().GameDetails[universeId]
					local isSuccess = gameDetail ~= nil

					store:dispatch(SetGameDetailsPageDataStatus(universeId,
						isSuccess and RetrievalStatus.Done or RetrievalStatus.Failed))

					if isSuccess then
						currentTime = tick()
						nextDataExpirationTime = math.floor(currentTime + refreshInterval)
						store:dispatch(SetNextDataExpirationTime(dataExpirationTimeKey, nextDataExpirationTime))
					end

					-- Start 2nd class data fetching calls:
					-- Page status is not affected by these data fetches
					startSecondClassFetchPromises(networkingImpl, store, universeId, isForceRefresh)
				end
			)
		else
			startSecondClassFetchPromises(networkingImpl, store, universeId, isForceRefresh)
		end
	end

end
