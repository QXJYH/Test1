local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Promise = require(CorePackages.AppTempCommon.LuaApp.Promise)

local ApiFetchGameIcons = require(CorePackages.AppTempCommon.LuaApp.Thunks.ApiFetchGameIcons)
local ApiFetchGameDetails = require(Modules.LuaApp.Thunks.ApiFetchGameDetails)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)

local key = "luaapp.challengepage"

local FetchChallengePageData = {}

FetchChallengePageData.Key = key

function FetchChallengePageData.Fetch(networkingImpl)
	return PerformFetch.Single(key, function(store)
		-- TODO: [MOBLUAPP-1264] We should put a limit to how many items are fetched each time
		-- and add the ability to loadMore as user scrolls through the content.
		local universeIds = store:getState().ChallengeItems

		-- Fetch game icons. The icons are not must-haves, so we don't need to return it
		-- and include it in the fetching status.
		store:dispatch(ApiFetchGameIcons(networkingImpl, universeIds))


		-- Fetch game details. (This is to get the name of the games)
		local gameDetails = store:getState().GameDetails

		local filteredIds = {}
		for _, universeId in ipairs(universeIds) do
			if gameDetails[universeId] == nil then
				table.insert(filteredIds, universeId)
			end
		end

		if #filteredIds > 0 then
			return store:dispatch(ApiFetchGameDetails.Fetch(networkingImpl, filteredIds))
		else
			return Promise.resolve()
		end
	end)
end

function FetchChallengePageData.GetFetchingStatus(state)
	return PerformFetch.GetStatus(state, key)
end

return FetchChallengePageData