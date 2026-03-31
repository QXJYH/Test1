local Modules = game:GetService("CoreGui").RobloxGui.Modules

local GetUnreadNotificationCount = require(Modules.LuaApp.Http.Requests.GetUnreadNotificationCount)
local SetNotificationCount = require(Modules.LuaApp.Actions.SetNotificationCount)

local FFlagFixCountOfUnreadNotificationError = settings():GetFFlag("FixCountOfUnreadNotificationError")

return function(networkImpl)
	return function(store)
		return GetUnreadNotificationCount(networkImpl):andThen(function(response)
			local responseBody = response.responseBody
			local notificationCount = responseBody.unreadNotifications
			if FFlagFixCountOfUnreadNotificationError then
				if notificationCount and tonumber(notificationCount) >= 0 then
					store:dispatch(SetNotificationCount(notificationCount))
				else
					warn(string.format(
						"ApiFetchUnreadNotificationCount - notificationCount is not a valid number: %s",
						tostring(notificationCount)))
				end
			else
				store:dispatch(SetNotificationCount(notificationCount))
			end

			return notificationCount
		end)
	end
end