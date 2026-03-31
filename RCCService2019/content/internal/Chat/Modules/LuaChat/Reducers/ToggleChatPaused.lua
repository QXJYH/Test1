local Modules = game:GetService("CoreGui").RobloxGui.Modules

local ToggleChatPaused = require(Modules.LuaChat.Actions.ToggleChatPaused)

local FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults =
	settings():GetFFlag("LuaChatScreenManagerAlwaysUpdatesWithDefaultsV390")

return function(state, action)
	if FFlagLuaChatScreenManagerAlwaysUpdatesWithDefaults then
		if state == nil then
			state = true
		end
	else
		state = state or false
	end

	if action.type == ToggleChatPaused.name then
		state = action.value
	end

	return state
end