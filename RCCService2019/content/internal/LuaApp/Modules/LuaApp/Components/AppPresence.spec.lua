return function()
	local AppPresence = require(script.Parent.AppPresence)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			AppPresence = Roact.createElement(AppPresence)
		}, {
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end