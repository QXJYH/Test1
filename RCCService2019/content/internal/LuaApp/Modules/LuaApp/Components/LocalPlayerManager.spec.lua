return function()
	local LocalPlayerManager = require(script.Parent.LocalPlayerManager)
	local CorePackages = game:GetService("CorePackages")
	local CoreGui = game:GetService("CoreGui")
	local Modules = CoreGui.RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			ProviderContainer = Roact.createElement(LocalPlayerManager)
		}, {
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
