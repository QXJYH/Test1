
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Cryo = require(CorePackages.Cryo)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local RoactRodux = require(Modules.Common.RoactRodux)
local DefaultPolicy = require(Modules.LuaApp.Policies.DefaultPolicy)
local Symbol = require(Modules.Common.Symbol)


local appPolicyKey = Symbol.named("AppPolicy")

-- POLICY PROVIDER: makes the policy available to Roact

local AppPolicyProvider = Roact.Component:extend("AppPolicyProvider")

function AppPolicyProvider:init(props)
		ArgCheck.isType(props.policy, "table", "policy prop")
		self._context[appPolicyKey] = props.policy
end

function AppPolicyProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

local RoactAppPolicy = {
	Provider = AppPolicyProvider,
}

-- POLICY WRAPPER: allows read only access to the policy

local function getPolicyValue(policy, feature, params)
	local value = policy[feature]
	if value == nil then
		return nil
	end
	if type(value) == "function" then
		value = value(params)
	end
	return value
end

local function makePolicyWrapper(policy, params)
	local policyWrapper = {}
	for feature, defaultValue in pairs(DefaultPolicy) do
		local value = getPolicyValue(policy, feature, params)
		if value == nil and policy ~= DefaultPolicy then
			value = getPolicyValue(DefaultPolicy, feature, params)
		end
		if type(value) == "function" then
			policyWrapper["get" .. feature] = value
		else
			policyWrapper["get" .. feature] = function()
				return value
			end
		end
	end
	return policyWrapper
end

-- POLICY CONNECTOR: provides policy information as props

function RoactAppPolicy.connect(mapper)
	ArgCheck.isType(mapper, 'function', 'App Policy Mapper')
	return function(component)
		-- component needs to connect to store to resolve policy
		local connectedComponent = RoactRodux.UNSTABLE_connect2(
			function(state, props)
				local policy = props[appPolicyKey]
				local policyWrapper = makePolicyWrapper(policy, state)
				local newProps = mapper(policyWrapper, props)
				return newProps
			end
		)(component)

		local name = ("AppPolicy(%s)"):format(tostring(component))
		local providerNotFound = string.format("%s: Not a descendent of AppPolicyProvider", name)
		local Connection = Roact.PureComponent:extend(name)

		function Connection:init(props)
			assert(self._context[appPolicyKey], providerNotFound)
		end

		function Connection:render()
			local props = Cryo.Dictionary.join(self.props, {
				[appPolicyKey] = self._context[appPolicyKey],
			})
			return Roact.createElement(connectedComponent, props)
		end

		return Connection
	end
end

-- LEGACY CONNECTOR: can be removed once FFlagLuaAppPolicyRoactConnector is cleaned

function RoactAppPolicy.legacy_connect(mapper)
	ArgCheck.isType(mapper, 'function', 'App Policy Mapper')
	return function(component)
		local name = ("AppPolicy(%s)"):format(tostring(component))
		local Connection = Roact.PureComponent:extend(name)

		function Connection:render()
			local policyProps = mapper(self._context.AppPolicy, self.props)
			local newProps = Cryo.Dictionary.join(self.props, policyProps)
			return Roact.createElement(component, newProps)
		end

		return Connection
	end
end

return RoactAppPolicy
