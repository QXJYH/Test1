local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local GetTheme = require(Modules.LuaApp.Http.Requests.GetTheme)

return function(networkImpl, userId)
	return GetTheme(networkImpl, userId):andThen(
		function(result)
			local data = result[1]
			local theme = string.lower(data.themeType)
			return theme
		end
	)
end