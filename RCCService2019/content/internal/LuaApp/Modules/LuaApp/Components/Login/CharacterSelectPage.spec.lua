return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

	local CharacterSelectPage = require(Modules.LuaApp.Components.Login.CharacterSelectPage)

	local mockInitialReducerValues = {
		FormFactor = FormFactor.WIDE,
		-- BundleIds = {...}, TODO Hook this up while doing LUASTARTUP-48
		-- AssetIdsInBundle = {...}, TODO Hook this up while doing LUASTARTUP-48
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
			CharacterSelectPage = Roact.createElement(CharacterSelectPage),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors", function()
		local element = wrapComponentWithMockServices({
			CharacterSelectPage = Roact.createElement(CharacterSelectPage),
		}, mockInitialReducerValues)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end