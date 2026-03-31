local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local GetSponsoredEvents = require(Modules.LuaApp.Http.Requests.GetSponsoredEvents)
local SetSponsoredEvents = require(Modules.LuaApp.Actions.SetSponsoredEvents)
local SponsoredEvent = require(Modules.LuaApp.Models.SponsoredEvent)

local SponsoredEvents = {}

local performFetchKey = "SponsoredEvents"

function SponsoredEvents.Fetch(networkImpl)
	return PerformFetch.Single(performFetchKey, function(store)
		return GetSponsoredEvents(networkImpl):andThen(function(result)
			local data = result.responseBody.data

			if data ~= nil then
				local sponsoredEvents = {}

				for index, sponsoredEvent in ipairs(data) do
					sponsoredEvents[index] = SponsoredEvent.fromJsonData(sponsoredEvent)
				end

				if #sponsoredEvents > 0 then
					store:dispatch(SetSponsoredEvents(sponsoredEvents))
				end
			end

			return Promise.resolve()
		end,
		function(error)
			return Promise.reject(error)
		end)
	end)
end

function SponsoredEvents.GetFetchingStatus(state)
	return PerformFetch.GetStatus(state, performFetchKey)
end

return SponsoredEvents