local Modules = game:getService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

return function(requestImpl)
	local logoutUrl = string.format("%sv1/logout", Url.AUTH_URL)
	return requestImpl(logoutUrl, "POST", { postBody = "", maxRetryCount = 0})
end