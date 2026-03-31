local Modules = game:GetService("CoreGui").RobloxGui.Modules
local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local OpenCentralOverlayForPremiumMigrationNotice = require(Modules.LuaApp.Thunks.OpenCentralOverlayForPremiumMigrationNotice)

return function(networkImpl)
	return PerformFetch.Single("FetchPremiumMigrationNotice", function(store)
		local url = UrlBuilder.fromString("premium:membership-migrations")()
		return networkImpl(url, "POST", {
			postBody = "",
		})
		:andThen(function(result)
			-- safeguard against show the prompt if, for some reason, we don't have the information we need
			if not result then return end
			if not result.responseBody then return end
			if not result.responseBody.robuxGranted then return end

			-- show the prompt
			store:dispatch(
				OpenCentralOverlayForPremiumMigrationNotice(result.responseBody.robuxGranted)
			)
		end)
		:catch(function(err)
			-- any request that isn't a 200 is to be ignored
		end)
	end)
end