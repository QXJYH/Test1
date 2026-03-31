local CorePackages = game:GetService("CorePackages")
local PerformFetch = require(CorePackages.AppTempCommon.LuaApp.Thunks.Networking.Util.PerformFetch)

local NetworkThunk = {}

function NetworkThunk.GET(api, networkImpl, urlBuilder)
	return PerformFetch.Batch(urlBuilder:getIds(), urlBuilder:makeKeyMapper(), function(store, filteredIds)
		return networkImpl(urlBuilder:makeUrl(filteredIds), "GET"):andThen(
			function(payload)
				store:dispatch(api.Succeeded(filteredIds, payload.responseBody))
			end,
			function(error)
				store:dispatch(api.Failed(filteredIds, error))
			end
		)
	end)
end

function NetworkThunk.POST(api, networkImpl, urlBuilder, postBody)
	return function(store)
		local filteredIds = urlBuilder:getIds()
		return networkImpl(urlBuilder:makeUrl(filteredIds), "POST", postBody):andThen(
			function(payload)
				store:dispatch(api.Succeeded(filteredIds, payload.responseBody))
			end,
			function(error)
				store:dispatch(api.Failed(filteredIds, error))
			end
		)
	end
end

return NetworkThunk
