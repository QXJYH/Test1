return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local EmptyStatePage = require(Modules.LuaApp.Components.EmptyStatePage)
	local DarkTheme = require(Modules.LuaApp.Themes.DeprecatedDarkTheme)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local mockStore = {
		ScreenSize = Vector2.new(500, 700),
	}

	it("should create and destroy without errors in classic theme", function()
		local element = mockServices({
			EmptyStatePage = Roact.createElement(EmptyStatePage)
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = mockStore,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors in dark theme", function()
		local element = mockServices({
			EmptyStatePage = Roact.createElement(EmptyStatePage)
		}, {
			includeThemeProvider = true,
			theme = DarkTheme,
			includeStoreProvider = true,
			store = mockStore,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end