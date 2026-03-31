local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Url = require(Modules.LuaApp.Http.Url)

--[[
	Documentation of endpoint:
	https://accountsettings.roblox.com/docs#!/Email/get_v1_email

	This endpoint returns a promise that resolves to:
	{
		"emailAddress": "string",
		"verified": true
	}

]]--

return function(requestImpl)
	local url = string.format("%sv1/email", Url.ACCOUNT_SETTINGS_URL)

	-- return a promise of the result listed above
	return requestImpl(url, "GET")
end