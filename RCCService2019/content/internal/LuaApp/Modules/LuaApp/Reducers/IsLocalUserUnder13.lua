local Modules = game:GetService("CoreGui").RobloxGui.Modules
local SetLocalUserUnder13 = require(Modules.LuaApp.Actions.SetLocalUserUnder13)

return function(state, action)
	state = state == true or false

	if action.type == SetLocalUserUnder13.name then
		return action.isUnder13
	end

	return state
end