local Modules = game:GetService("CoreGui").RobloxGui.Modules
local SetSignupUsername = require(Modules.LuaApp.Actions.SetSignUpUsername)

return function(state, action)
	state = state or ""

	if action.type == SetSignupUsername.name then
		return action.signupUsername
	end

	return state
end