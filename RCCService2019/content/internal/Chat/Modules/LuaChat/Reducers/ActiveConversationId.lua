local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local DEFAULT_STATE = nil
local SetRoute = require(Modules.LuaChat.Actions.SetRoute)

return function(state, action)
	state = state or DEFAULT_STATE

	if action.type == SetRoute.name then
		return action.parameters.conversationId or nil
	end

	return state
end