local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
	https://auth.roblox.com/docs#!/Passwords/get_v2_passwords_current_status

	This endpoint returns a promise that resolves to:
	{
		"valid": true
	}

]]--

return function(requestImpl)
	local url = string.format("%sv2/passwords/current-status", Url.AUTH_URL)

	-- return a promise of the result listed above
	return requestImpl(url, "GET")
end