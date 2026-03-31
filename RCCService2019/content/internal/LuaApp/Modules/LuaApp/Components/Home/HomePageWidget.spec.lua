return function()
	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local HomePageWidget = require(Modules.LuaApp.Components.Home.HomePageWidget)

	it("should create and destroy without errors", function()
		local element = mockServices({
			HomePageWidget = Roact.createElement(HomePageWidget, {
				layoutOrder = 1,
				icon = "LuaApp/buttons/buttonFill",
				textKey = "Feature.GameDetails.Action.BuyRobux",
				renderContent = function() return Roact.createElement("Frame") end,
				onActivated = function() end,
			}),
		},{
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when no props are passed down", function()
		local element = mockServices({
			HomePageWidget = Roact.createElement(HomePageWidget),
		},{
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end