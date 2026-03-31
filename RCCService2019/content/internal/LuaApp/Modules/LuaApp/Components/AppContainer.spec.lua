return function()
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local FlagSettings = require(Modules.LuaApp.FlagSettings)
	local AppContainer = require(Modules.LuaApp.Components.AppContainer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)

	it("should create and destroy without errors", function()
		local testStore = MockStore.new()

		local element = mockServices({
			AppContainer = Roact.createElement(AppContainer, {
				store = testStore,
			})
		}, {
			includeLocalizationProvider = true,
			includeStoreProvider = true,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
			store = testStore,
		})

		local instance = Roact.mount(element)

		Roact.unmount(instance)
	end)
end
