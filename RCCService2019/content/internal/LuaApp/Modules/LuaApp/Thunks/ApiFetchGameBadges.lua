local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Actions = Modules.LuaApp.Actions
local SetGameBadges = require(Actions.SetGameBadges)
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local BadgesGetBadges = require(Modules.LuaApp.Http.Requests.BadgesGetBadges)

return function(networkImpl, universeId)
	return PerformFetch.Single("ApiFetchGameBadges"..universeId, function(store)
		return BadgesGetBadges(networkImpl, universeId):andThen(function(result)
			local badges = result.responseBody.data
			store:dispatch(SetGameBadges(universeId, badges))
			return Promise.resolve(result)
		end)
	end)
end
