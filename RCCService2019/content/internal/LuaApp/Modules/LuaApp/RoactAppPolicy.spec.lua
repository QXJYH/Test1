return function()

	local RoactAppPolicy = require(script.parent.RoactAppPolicy)
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local ProviderContainer = require(Modules.LuaApp.Components.ProviderContainer)
	local DefaultPolicy = require(Modules.LuaApp.Policies.DefaultPolicy)
	local RoactRodux = require(CorePackages.RoactRodux)

	local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

	if not FFlagLuaAppPolicyRoactConnector then
		SKIP()
	end

	local testStore = Rodux.Store.new(function(state, action)
		return {
			feature = action.value or false
		}
	end)

	local TestComponent = Roact.Component:extend("TestComponent")
	function TestComponent:render()
		if self.props.onRender then
			self.props.onRender(self.props)
		end
	end

	local featureKey = next(DefaultPolicy)

	local testPolicy = {
		[featureKey] = function(state)
			return state.feature
		end
	}

	local TestConnection = RoactAppPolicy.connect(function(appPolicy, props)
		if props.onConnect then
			props.onConnect(appPolicy)
		end
		return {
			testFeature = appPolicy["get" .. featureKey](),
		}
	end)

	local function TestProvider(props)
		return Roact.createElement(ProviderContainer, {
			providers = {
				{
					class = RoactRodux.StoreProvider,
					props = {
						store = testStore,
					},
				},
				{
					class = RoactAppPolicy.Provider,
					props = {
						policy = testPolicy,
					},
				},
			}
		}, {
			Content = Roact.oneChild(props[Roact.Children]),
		})
	end

	describe("Roact app policy connector", function()
		it("should extract the policy from context", function()
			local expectedValue = "expected test value"
			local actualValue = nil

			testStore:dispatch({
				type = "feature",
				value = expectedValue,
			})

			local element = Roact.createElement(TestProvider, {}, {
				Content = Roact.createElement(TestConnection(TestComponent), {
					onConnect = function(appPolicy)
						actualValue = appPolicy["get" .. featureKey]()
					end,
				}),
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)

			expect(actualValue).to.equal(expectedValue)
		end)

		it("should provide policy information to the component", function()
			local expectedValue = "expected test value"
			local actualValue = nil

			testStore:dispatch({
				type = "feature",
				value = expectedValue,
			})

			local element = Roact.createElement(TestProvider, {}, {
				Content = Roact.createElement(TestConnection(TestComponent), {
					onRender = function(props)
						actualValue = props.testFeature
					end,
				}),
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)

			expect(actualValue).to.equal(expectedValue)
		end)

		it("should fail if not under a PolicyProvider", function()
			local element = Roact.createElement(ProviderContainer, {
				providers = {
					{
						class = RoactRodux.StoreProvider,
						props = {
							store = testStore,
						},
					},
				}
			}, {
				Content = Roact.createElement(TestConnection(TestComponent), {}),
			})

			expect(function()
				Roact.mount(element)
			end).to.throw()
		end)

		it("should not fail if applied multiple times", function()
			local expectedValue = "expected test value"
			local actualValue = nil

			testStore:dispatch({
				type = "feature",
				value = expectedValue,
			})

			local element = Roact.createElement(TestProvider, {}, {
				Content = Roact.createElement(TestConnection(TestConnection(TestComponent)), {
					onRender = function(props)
						actualValue = props.testFeature
					end,
				}),
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)

			expect(actualValue).to.equal(expectedValue)
		end)

		it("should update the policy on store changes", function()
			local expectedValues = {"one", "two"}
			local actualValues = {}

			testStore:dispatch({
				type = "feature",
				value = expectedValues[1],
			})

			local element = Roact.createElement(TestProvider, {}, {
				Content = Roact.createElement(TestConnection(TestComponent), {
					onRender = function(props)
						table.insert(actualValues, props.testFeature)
					end,
				}),
			})

			local instance = Roact.mount(element)
			testStore:dispatch({
				type = "feature",
				value = expectedValues[2],
			})
			testStore:flush()
			Roact.unmount(instance)

			expect(#actualValues).to.equal(#expectedValues)
			expect(actualValues[1]).to.equal(expectedValues[1])
			expect(actualValues[2]).to.equal(expectedValues[2])
		end)

	end)

end
