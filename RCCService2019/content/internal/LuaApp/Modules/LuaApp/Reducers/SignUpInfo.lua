local Modules = game:GetService("CoreGui").RobloxGui.Modules
local SignUpUsername = require(Modules.LuaApp.Reducers.SignUpUsername)

return function(state, action)
	state = state or {}

	return {
		SignUpUsername = SignUpUsername(state.SignUpUsername, action),
		-- this reducer will expand in future to include reducers for SignUpBirthday, SignUpBundleId, SignUpPassword, SignUpVerified
	}
end