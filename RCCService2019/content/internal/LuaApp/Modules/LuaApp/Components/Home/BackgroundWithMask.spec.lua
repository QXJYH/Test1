return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local BackgroundWithMask = require(Modules.LuaApp.Components.Home.BackgroundWithMask)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

	local mockStore = Rodux.Store.new(AppReducer, {
		FormFactor = FormFactor.WIDE,
		ScreenSize = Vector2.new(100, 100),
	})

	it("should create and destroy without errors", function()
		local element = mockServices({
			BackgroundWithMask = Roact.createElement(BackgroundWithMask, {
				zIndex = 1,
			}),
		}, {
			includeStoreProvider = true,
			store = mockStore,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with no props and empty store", function()
		local element = mockServices({
			BackgroundWithMask = Roact.createElement(BackgroundWithMask),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
