local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Promise = require(Modules.LuaApp.Promise)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local Constants = require(Modules.LuaApp.Constants)
local ApiFetchSortTokens = require(Modules.LuaApp.Thunks.ApiFetchSortTokens)
local SetGamesPageDataStatus = require(Modules.LuaApp.Actions.SetGamesPageDataStatus)
local ApiFetchGamesData = require(Modules.LuaApp.Thunks.ApiFetchGamesData)

local diagCounterPageLoadTimes = settings():GetFVariable("LuaAppsDiagPageLoadTimeGames")

return function(networkImpl, analytics)

	return function(store)
		if store:getState().Startup.GamesPageDataStatus == RetrievalStatus.Fetching then
			return Promise.resolve("games page data is already fetching")
		end

		local startTime = tick()
		store:dispatch(SetGamesPageDataStatus(RetrievalStatus.Fetching))

		return store:dispatch(ApiFetchSortTokens(networkImpl, Constants.GameSortGroups.Games)):andThen(
			function()
				store:dispatch(SetGamesPageDataStatus(RetrievalStatus.Done))
				return store:dispatch(ApiFetchGamesData(networkImpl, Constants.GameSortGroups.Games)):andThen(
					function(result)
						local endTime = tick()
						local deltaMs = (endTime - startTime) * 1000

						analytics.Diag:reportStats(diagCounterPageLoadTimes, deltaMs)
					end
				)
			end,
			function(err)
				store:dispatch(SetGamesPageDataStatus(RetrievalStatus.Failed))
				return Promise.reject(err)
			end
		)
	end
end
