return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
	local HomePageWithAvatarAndWidget = require(Modules.LuaApp.Components.Home.HomePageWithAvatarAndWidget)

	local storeWithFormFactorCompactView = { FormFactor = FormFactor.COMPACT }

	local storeWithFormFactorWideView = { FormFactor = FormFactor.WIDE }

	it("should create and destroy without errors", function()
		local element = mockServices({
			HomePageWithAvatarAndWidget = Roact.createElement(HomePageWithAvatarAndWidget),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
			store = storeWithFormFactorCompactView,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)

		element = mockServices({
			HomePageWithAvatarAndWidget = Roact.createElement(HomePageWithAvatarAndWidget),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
			store = storeWithFormFactorWideView,
		})
		instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when the store is empty", function()
		local element = mockServices({
			HomePageWithAvatarAndWidget = Roact.createElement(HomePageWithAvatarAndWidget),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end
