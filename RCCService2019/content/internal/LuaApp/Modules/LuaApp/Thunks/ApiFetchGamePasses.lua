local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Actions = Modules.LuaApp.Actions
local SetGamePasses = require(Actions.SetGamePasses)
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GamesGetPasses = require(Modules.LuaApp.Http.Requests.GamesGetPasses)

return function(networkImpl, universeId)
	return PerformFetch.Single("ApiFetchGamePasses"..universeId, function(store)
		return GamesGetPasses(networkImpl, universeId):andThen(function(result)
			local passes = result.responseBody.data
			store:dispatch(SetGamePasses(universeId, passes))
			return Promise.resolve(result)
		end)
	end)
end
