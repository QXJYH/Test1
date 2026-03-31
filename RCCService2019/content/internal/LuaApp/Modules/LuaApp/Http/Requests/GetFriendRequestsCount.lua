local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
	https://friends.roblox.com/docs#!/Friends/get_v1_user_friend_requests_count

	This endpoint returns a promise that resolves to:
	{
		"count": 0
	}

]]--

return function(requestImpl)
	local url = string.format("%s/user/friend-requests/count", Url.FRIEND_URL)

	-- return a promise of the result listed above
	return requestImpl(url, "GET")
end