return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local SecondaryButton = require(Modules.LuaApp.Components.SecondaryButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			SecondaryButton = Roact.createElement(SecondaryButton),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end