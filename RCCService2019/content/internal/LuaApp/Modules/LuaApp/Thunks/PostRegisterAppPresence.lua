local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local PostRegisterAppPresence = require(Modules.LuaApp.Http.Requests.PostRegisterAppPresence)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)

local function postKeymapper()
	return "luaapp.presenceapi.register-app-presence"
end

return function (networkImpl, locationId)
	assert(type(locationId) == "string",
		string.format("PostRegisterAppPresence thunk expects locationId to be a string, was %s", type(locationId)))

	return PerformFetch.Single(postKeymapper(), function(store)
		return PostRegisterAppPresence(networkImpl, locationId):andThen(
			function(result)
				return Promise.resolve(result)
			end,
			function(err)
				return Promise.reject(err)
			end
		)
	end)
end