local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local EconomyGetCurrency = require(Modules.LuaApp.Http.Requests.EconomyGetCurrency)
local SetUserRobux = require(Modules.LuaApp.Actions.SetUserRobux)

return function(networkImpl, userId, forceRefresh)
	if type(userId) ~= "string" then
		error("ApiFetchEconomyCurrency thunk expects userId to be a string")
	end

	return PerformFetch.Single("com.roblox.economy.users."..userId..".currency", function(store)
		local robux = store:getState().UserRobux[userId]
		if not forceRefresh and robux ~= nil then
			return Promise.resolve()
		end
		return EconomyGetCurrency(networkImpl, userId):andThen(
			function(result)
				local data = result.responseBody

				if data ~= nil and data.robux ~= nil then
					store:dispatch(SetUserRobux(userId, data.robux))
					return Promise.resolve(result)
				else
					Logging.warn("Response from EconomyGetCurrency is malformed!")
					return Promise.reject({HttpError = Enum.HttpError.OK})
				end
			end,
			function(err)
				return Promise.reject(err)
			end
		)
	end)
end
