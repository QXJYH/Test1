local Modules = game:GetService("CoreGui").RobloxGui.Modules
local PromiseUtilities = require(Modules.LuaApp.PromiseUtilities)

local ApiFetchAccountSettingsEmail = require(Modules.LuaApp.Thunks.ApiFetchAccountSettingsEmail)
local ApiFetchPasswordStatus = require(Modules.LuaApp.Thunks.ApiFetchPasswordStatus)
local ApiFetchFriendRequestsCount = require(Modules.LuaApp.Thunks.ApiFetchFriendRequestsCount)
local ApiFetchUnreadMessageCount = require(Modules.LuaApp.Thunks.ApiFetchUnreadMessageCount)
local ApiFetchUnreadNotificationCount = require(Modules.LuaApp.Thunks.ApiFetchUnreadNotificationCount)

return function(networkImpl)
	return function(store)
		local promises = {}

		table.insert(promises, store:dispatch(ApiFetchAccountSettingsEmail(networkImpl)))
		table.insert(promises, store:dispatch(ApiFetchPasswordStatus(networkImpl)))
		table.insert(promises, store:dispatch(ApiFetchFriendRequestsCount(networkImpl)))
		table.insert(promises, store:dispatch(ApiFetchUnreadMessageCount(networkImpl)))
		table.insert(promises, store:dispatch(ApiFetchUnreadNotificationCount(networkImpl)))

		return PromiseUtilities.Batch(promises):andThen(function(results)
			local failureCount = PromiseUtilities.CountResults(results).failureCount

			if failureCount ~= 0 then
				warn(string.format("%d of %d notification count fetching failed!", failureCount, #promises))
			end
		end)
	end
end