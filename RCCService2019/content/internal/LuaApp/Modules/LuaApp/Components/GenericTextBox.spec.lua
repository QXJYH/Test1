return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local GenericTextBox = require(Modules.LuaApp.Components.GenericTextBox)

	local function wrapComponentWithMockServices(components, initialStoreState)
		initialStoreState = initialStoreState or {}

		return mockServices(components, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = initialStoreState,
		})
	end

	it("should create and destroy without errors", function()
		local element = wrapComponentWithMockServices({
			GenericTextBox = Roact.createElement(GenericTextBox),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
