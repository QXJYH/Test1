local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	This endpoint returns a promise that resolves to:

	{
		"unreadMessageCount": 0,
		"friendRequestsCount": 0
	}

]]--

return function(requestImpl)
	local url = string.format("%sincoming-items/counts", Url.API_URL)

	-- return a promise of the result listed above
	return requestImpl(url, "GET")
end