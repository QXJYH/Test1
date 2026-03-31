local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

return Action(script.Name, function(count)
	ArgCheck.isNonNegativeNumber(count, "SetFriendRequestsCount: count")

	return {
		count = count,
	}
end)