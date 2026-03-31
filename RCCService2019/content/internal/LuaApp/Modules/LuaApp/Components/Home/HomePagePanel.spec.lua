return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local HomePagePanel = require(Modules.LuaApp.Components.Home.HomePagePanel)
	local PerformFetch = require(CorePackages.AppTempCommon.LuaApp.Thunks.Networking.Util.PerformFetch)

	it("should create and destroy without errors", function()
		PerformFetch.ClearOutstandingPromiseStatus()

		local element = mockServices({
			HomePagePanel = Roact.createElement(HomePagePanel, {
				zIndex = 2,
				size = UDim2.new(1, 0, 0, 600),
				position = UDim2.new(0, 0, 0.5, 0),
				anchorPoint = Vector2.new(0, 0.5),
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)

		PerformFetch.ClearOutstandingPromiseStatus()
	end)

	it("should create and destroy without errors with no input props", function()
		PerformFetch.ClearOutstandingPromiseStatus()

		local element = mockServices({
			HomePagePanel = Roact.createElement(HomePagePanel),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)

		PerformFetch.ClearOutstandingPromiseStatus()
	end)

end