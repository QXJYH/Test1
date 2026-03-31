return function()
	local PremiumMigrationNotice = require(script.Parent.PremiumMigrationNotice)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			PremiumMigrationNotice = Roact.createElement(PremiumMigrationNotice, {
				containerWidth = 128,
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			includeStyleProvider = true,
			includeLocalizationProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end