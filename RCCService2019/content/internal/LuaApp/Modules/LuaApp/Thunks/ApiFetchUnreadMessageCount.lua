local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GetIncomingItemsCount = require(Modules.LuaApp.Http.Requests.GetIncomingItemsCount)
local SetUnreadMessageCount = require(Modules.LuaApp.Actions.SetUnreadMessageCount)

-- TODO: Update performFetchKey to "luaapp.messagesapi.xxx" when endpoint is ready(SOC-5686)
local performFetchKey = "luaapp.apiProxy.incoming-items-count"

return function(networkImpl)
	return PerformFetch.Single(performFetchKey, function(store)
		return GetIncomingItemsCount(networkImpl):andThen(function(result)
			local count = result.responseBody.unreadMessageCount
			store:dispatch(SetUnreadMessageCount(count))

			return Promise.resolve(result)
		end,
		function(err)
			return Promise.reject(err)
		end)
	end)
end