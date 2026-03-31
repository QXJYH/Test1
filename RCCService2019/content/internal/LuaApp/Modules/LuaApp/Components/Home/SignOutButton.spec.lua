return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local SignOutButton = require(Modules.LuaApp.Components.Home.SignOutButton)

	it("should create and destroy without errors", function()
		local element = mockServices({
			SignOutButton = Roact.createElement(SignOutButton),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end