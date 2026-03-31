local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp

local LoginStatus = require(Modules.LuaApp.Enum.LoginStatus)
local SetAuthenticationStatus = require(LuaApp.Actions.SetAuthenticationStatus)
local Cryo = require(CorePackages.Cryo)

return function(state, action)
	state = state or {
		status = LoginStatus.UNKNOWN,
	}

	if action.type == SetAuthenticationStatus.name then
		state = Cryo.Dictionary.join(state, {status = action.status})
	end

	return state
end