local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local PolicyReader = require(Modules.LuaApp.Policies.PolicyReader)

local AppPolicyProvider = Roact.Component:extend("AppPolicyProvider")

function AppPolicyProvider:init(props)
	local policyWrapper = {
		IsFeatureEnabled = function(feature)
			return PolicyReader.IsFeatureEnabled(props.policy, feature, props.params)
		end
	}
	PolicyReader.generateFeatureFunctions(props.policy, props.params, policyWrapper)
	self._context.AppPolicy = policyWrapper
end

function AppPolicyProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

AppPolicyProvider = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			params = {
				userInfo = {
					under13 = state.IsLocalUserUnder13,
				},
			},
		}
	end
)(AppPolicyProvider)

return AppPolicyProvider
