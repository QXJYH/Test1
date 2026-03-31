local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

-- Response format
-- {"themeType":"Classic"}

return function(requestImpl, userId)
	local url = string.format("%sv1/themes/User/%d", Url.ACCOUNT_SETTINGS, userId)

	return requestImpl(url, "GET")
end