return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

	local CharacterSelector = require(Modules.LuaApp.Components.Login.CharacterSelector)

	local mockInitialReducerValues = {
		FormFactor = FormFactor.WIDE,
	}

	local function wrapComponentWithMockServices(components, initialReducerValues)
		initialReducerValues = initialReducerValues or {}
		return mockServices(components, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = initialReducerValues,
		})
	end

	it("should create and destroy without errors with default reducer", function()
		local element = wrapComponentWithMockServices({
			CharacterSelector = Roact.createElement(CharacterSelector),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with no props passed down", function()
		local element = wrapComponentWithMockServices({
			CharacterSelector = Roact.createElement(CharacterSelector),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with empty bundleIds prop", function()
		local element = wrapComponentWithMockServices({
			CharacterSelector = Roact.createElement(CharacterSelector, {
				bundleIds = {},
				onSelectedCharacterChanged = function() end,
			}),
		}, mockInitialReducerValues)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with non-empty bundleIds prop", function()
		local element = wrapComponentWithMockServices({
			CharacterSelector = Roact.createElement(CharacterSelector, {
				bundleIds = {"123", "432", "0000"},
				onSelectedCharacterChanged = function() end,
			}),
		}, mockInitialReducerValues)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end