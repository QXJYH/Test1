return function()
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local SystemPrimaryButton = require(Modules.LuaApp.Components.SystemPrimaryButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			SystemPrimaryButton = Roact.createElement(SystemPrimaryButton),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end