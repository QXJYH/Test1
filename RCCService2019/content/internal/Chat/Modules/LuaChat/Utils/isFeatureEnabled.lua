
local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

return function(appState, feature)
	local appPolicy = appState.AppPolicy
	if FFlagLuaAppPolicyRoactConnector then
		return not appPolicy or appPolicy["get" .. feature]()
	else
		return not appPolicy or appPolicy.IsFeatureEnabled(feature)
	end
end
