local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local PlayabilityStatusEnum = require(Modules.LuaApp.Enum.PlayabilityStatus)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local ApiFetchPlayabilityStatus = require(Modules.LuaApp.Thunks.ApiFetchPlayabilityStatus)
local FetchGamesProductInfo = require(Modules.LuaApp.Thunks.FetchGamesProductInfo)

local function keyMapper(universeId)
	return "luaapp.playability-and-productinfo." .. universeId
end

local FetchGamePlayabilityAndProductInfo = {}

FetchGamePlayabilityAndProductInfo.KeyMapper = keyMapper

function FetchGamePlayabilityAndProductInfo.Fetch(networkImpl, universeId)
	assert(type(universeId) == "string", "FetchPlayabilityAndProductInfo thunk expects universeId to be a string")

	return PerformFetch.Single(keyMapper(universeId), function(store)
		return store:dispatch(ApiFetchPlayabilityStatus.Fetch(networkImpl, { universeId })):andThen(
			function(playabilityResults)
				local playabilityResult = playabilityResults[ApiFetchPlayabilityStatus.KeyMapper(universeId)]
				local isPlayabilitySuccess, _ = playabilityResult:unwrap()
				if isPlayabilitySuccess then
					local playabilityStatus = store:getState().PlayabilityStatus[universeId]
					-- If this game is not playable because it needs to be purchased, we fetch
					-- the purchase info
					if playabilityStatus.isPlayable == false and
						playabilityStatus.playabilityStatus == PlayabilityStatusEnum.PurchaseRequired then
						return store:dispatch(FetchGamesProductInfo.Fetch(networkImpl, { universeId })):andThen(
							function(gamesProductInfoResults)
								local gamesProductInfoResult =
									gamesProductInfoResults[FetchGamesProductInfo.KeyMapper(universeId)]
								local isGameProductInfoSuccess, _ = gamesProductInfoResult:unwrap()
								if isGameProductInfoSuccess then
									return Promise.resolve()
								else
									return Promise.reject()
								end
							end
						)
					else
						return Promise.resolve()
					end
				else
					return Promise.reject()
				end
			end
		)
	end)
end

function FetchGamePlayabilityAndProductInfo.GetFetchingStatus(state, universeId)
	return PerformFetch.GetStatus(state, keyMapper(universeId))
end

return FetchGamePlayabilityAndProductInfo